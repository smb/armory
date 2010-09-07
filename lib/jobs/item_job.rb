require "nokogiri"
require "open-uri"

class ItemJob < Struct.new(:args)
	def get_url
		return "parse", {:region => "us", :page => :item_info, :i => args[:item_id]}
	end
		
	def parse(doc, raw_xml)
		item_doc = doc.css("itemInfo")
		item_base = item_doc.css("item")
		
		raise Armory::ArmoryParseError.new("noItem") if item_base.length == 0
		
		# Figure out if it's faction restricted
		# <translationFor factionEquiv="0">
		faction_id = item_doc.css("translationFor").length > 0 && item_doc.css("translationFor").attr("factionEquiv") || nil
		if faction_id == "1"
			faction_id = 0
		elsif faction_id == "0"
			faction_id = 1
		end
		
		# <item icon="inv_bracer_36a" id="47582" level="245" name="Bracers of Swift Death" quality="4" type="Leather">
		# <item icon="inv_mace_99" id="46017" level="245" name="Val'anyr, Hammer of Ancient Kings" quality="5" type="One-Handed Maces">
		# Grab equip type
		equip_type = item_base.attr("type")
		if !equip_type.nil? && !equip_type.value.blank?
			equip_type = equip_type.value.downcase
		else
			equip_type = nil
		end
		
		@item = Item.find(:first, :conditions => {:item_id => args[:item_id]}) || Item.new
		@item.item_id = item_base.attr("id").value
		@item.quality = item_base.attr("quality").value
		@item.level = item_base.attr("level").value
		@item.name = item_base.attr("name").value
		@item.icon = item_base.attr("icon").value
		@item.equip_type = equip_type
		@item.faction_id = faction_id
		
		#<token count="50" icon="spell_holy_summonchampion" id="47241"/>
		cost = item_doc.css("cost token")
		if cost.length > 0
			@item.token_id = cost.attr("id").value
			@item.token_cost = cost.attr("count").value
		end
		
		@item.touch
		
		@source_cache = {}
		ItemSource.find(:all, :conditions => {:item_id => @item.item_id}).each do |source|
			@source_cache[source[:npc_id]] = source
		end
		
		# Record created by info
		# <spell icon="trade_leatherworking" id="67142" name="Knightbane Carapace">
		# <reagent count="24" icon="inv_misc_leatherscrap_19" id="38425" name="Heavy Borean Leather" quality="1"/>
		reagent_cache = {}
		ItemReagents.find(:all, :conditions => {:item_id => @item.item_id}).each do |reagent|
			reagent_cache[reagent[:reagent_id]] = reagent
		end
		
		found_reagents = {}
		item_doc.css("createdBy spell").each do |created|
			add_source(:npc_id => created.attr("id").to_i, :name => created.attr("name"), :type => "craft")
			
			created.css("reagent").each do |reagent_doc|
				reagent_id = reagent_doc.attr("id").to_i
				reagent = reagent_cache[reagent_id] || ItemReagents.new
				reagent.item_id = @item.item_id
				reagent.reagent_id = reagent_id
				reagent.quantity = reagent_doc.attr("quality")
				reagent.save
				
				found_reagents[reagent_id] = true
			end
		end
		
		DataManager.mass_queue_reagents(found_reagents)
		
		# Record drop locations
		# <creature area="Icecrown Citadel" classification="0" heroic="1" id="38316" maxLevel="80" minLevel="80" name="Ormus the Penitent" title="Death Knight Armor" type="Humanoid"/>
		item_doc.css("vendors creature").each do |creature|
			add_source(:npc_id => creature.attr("id").to_i, :area => creature.attr("area"), :name => creature.attr("name"), :title => creature.attr("title"), :is_heroic => creature.attr("heroic"), :type => "vendor")
		end
		
		# <creature area="Icecrown Citadel (10)" areaUrl="fl[source]=dungeon&amp;fl[dungeon]=icecrowncitadel10&amp;fl[boss]=all&amp;fl[difficulty]=all" classification="3" dropRate="2" heroic="1" id="37958" maxLevel="83" minLevel="83" name="Lord Marrowgar" type="Undead" url="fl[source]=dungeon&amp;fl[dungeon]=icecrowncitadel10&amp;fl[difficulty]=heroic&amp;fl[boss]=36612"/>
		item_doc.css("dropCreatures creature").each do |creature|
			# The id attribute is the internal id that Blizzard uses, the id in fl[boss] is the "real" one
			match = creature.attr("url") && creature.attr("url").match(/fl\[boss\]=([0-9]+)/)
			if !match.nil?
				npc_id = match[1].to_i
			end
			
			npc_id ||= creature.attr("id").to_i
			
			add_source(:npc_id => npc_id, :area => creature.attr("area"), :name => creature.attr("name"), :title => creature.attr("title"), :is_heroic => creature.attr("heroic"), :type => "drop")
		end
		
		# <object area="Trial of the Crusader" dropRate="3" id="195665" name="Argent Crusade Tribute Chest"/>
		item_doc.css("containerObjects object").each do |object|
			add_source(:npc_id => object.attr("id").to_i, :area => object.attr("area"), :name => object.attr("name"), :is_heroic => object.attr("heroic"), :type => "object")
		end

		# <quest area="Icecrown Citadel" id="24845" level="80" name="A Change of Heart" reqMinLevel="80" suggestedPartySize="0"/>
		item_doc.css("rewardFromQuests quest").each do |quest|
			add_source(:npc_id => quest.attr("id").to_i, :area => quest.attr("area"), :name => quest.attr("name"), :is_heroic => quest.attr("heroic"), :type => "quest")
		end
		
		# Record meta info
		if equip_type == "meta"
			record_requirements()
		end
	end
	
	private
	def record_requirements
		retries = 0
		begin
			requirements = []

			content = open("http://db.mmo-champion.com/i/#{@item.item_id}/tooltip/js").read
			if content.match(/Error retrieving tooltip/i)
				return
			end
			
			content.scan(/<div class="tti-gem_conditions">(.+?)<\/div>/).each do |text|
				req = text[0].match(/Requires more (.+) gems than (.+) gem/i)
				if req then
					requirements.push({:type => "more", :more => req[1].downcase, :than => req[2].downcase})
					next
				end
				
				req = text[0].match(/Requires exactly ([0-9]+) (.+) gem/)
				if req then
					requirements.push({:type => "exactly", :exact => req[2].downcase, :count => req[1].to_i})
					next
				end
				
				req = text[0].match(/Requires at least ([0-9]+) (.+) gem/)
				if req then
					requirements.push({:type => "least", :least => req[2].downcase, :count => req[1].to_i})
					next
				end
			end
		rescue Exception => e
			retries += 1
			retry if retries <= 3
		end
		
		if requirements.length > 0
			meta = MetaGem.find(:first, :conditions => {:item_id => @item.item_id}) || MetaGem.new
			meta.item_id = @item.item_id
			meta.requirements = requirements.to_yaml
			meta.save
		end
	end
	
	def add_source(data)
		# Figure out the dungeon type
		if !data[:area].blank?
			match = data[:area].match(/\(([0-9]+)\)$/)
			if !match.nil?
				players = match[1]
				data[:area] = data[:area].gsub(/\([0-9]+\)$/, "").strip()
			end
		end
	
		source = @source_cache[data[:npc_id]] || ItemSource.new
		source.npc_id = data[:npc_id]
		source.item_id = @item.item_id
		source.title = data[:title]
		source.area = data[:area]
		source.name = data[:name]
		source.players = players
		source.is_heroic = data[:is_heroic] == "1" and true or nil
		source.source_type = data[:type]
		source.save
	end
end
