require "nokogiri"
require "open-uri"

class ItemIdentifyJob < Struct.new(:args)
	def get_url
		return "parse", {:region => "us", :page => :item_tooltip, :i => args[:item_id]}
	end
	
	# Only for enchant spells, not items enchants
	# Because identify_enchant is called directly, without being a job
	# you need to use the symbol form to access args
	def identify_enchant
		if args[:enchant].nil?
			raise "Failed to find enchant text for #{args[:enchant_id]}"
		end
		
		@item_stats = {}
		@text_scanned = nil
		scan_text(args[:enchant])
				
		# Like items, we pass it to our helper function to identify!
		enchant = Enchant.find(:first, :conditions => {:enchant_id => args[:enchant_id]}) || Enchant.new
		# Unlike items, we don't get nicely formatted data, so text scan
		enchant.enchant_id = args[:enchant_id]
		enchant.spec_type = ENCHANTS["OVERRIDES"][args[:enchant_id]].nil? && identify_by_stats("enchant", nil) || ENCHANTS["OVERRIDES"][args[:enchant_id]]
		enchant.name = args[:name]
		enchant.icon = args[:icon]
		enchant.stat_hash = create_stat_hash()
		enchant.save
	end
	
	def parse(doc, raw_xml)
		item_doc = doc.css("itemTooltips itemTooltip")
		raise Armory::ArmoryParseError.new("noItem") if item_doc.length == 0
						
		puts "Identifying #{args[:item_id]}" if args[:debug]
		
		# Save the raw XML for Rawr
		raw = RawItemXml.find(:first, :conditions => {:item_id => args[:item_id]})
		if raw.nil?
			RawItemXml.create(:item_id => args[:item_id], :item_xml => raw_xml.gsub(/<\?xml.+\?>/, ""))
		end
		
		@item_stats = {}
		@text_scanned = nil
		
		inventory_type = item_doc.css("equipData inventoryType").text.to_i
		item_quality = item_doc.css("overallQualityId").text.to_i
		item_level = item_doc.css("itemLevel").text.to_i
		item_type = inventory_type && ITEMS["INV_TYPE_TO_TYPE"][inventory_type]

		item = Item.find(:first, :conditions => {:item_id => args[:item_id]}) || Item.new
		item.item_id = args[:item_id].to_i
		item.slot_id = inventory_type
		item.sockets = item_doc.css("socket").length
		item.set_name = item_doc.css("setData name").text
		item.is_heroic = item_doc.css("heroic").length > 0 ? true : false
		item.spec_type = nil
		
		class_tag = item_doc.css("allowableClasses class").text
		if !class_tag.blank?
			class_tag = class_tag.downcase.gsub(/ /, "")
			item.class_id = config_option("reverseClass")[class_tag]
		end
		
		for i in 0..item.sockets-1
			item["gem#{i+1}_type"] = item_doc.css("socket")[i].attr("color").downcase
		end
		
		puts "Slot id: #{item.slot_id}, Sockets: #{item.sockets}, Set: #{item.set_name}, Class: #{item.class_id} (#{class_tag})" if args[:debug]

		# Check if it's a random modifier, if so don't try and identify it
		if !args[:random].nil?
			item.item_type = item_type
			item.spec_type = "random"
			item.touch
			return
		end
				
		# Check if it's a trinket
		if item_type == "trinket"
			spell_data = item_doc.css("spellData spell desc")
			spell_text = spell_data && spell_data.text
			
			if !spell_text.blank?
				puts "Scanning text: #{spell_text}" if args[:debug]
 				scan_text(spell_text)
				
				ITEMS["TRINKET_TEXTS"].each do |stat_id, stat_text|
					if spell_text.match(/#{stat_text}/i)
						@item_stats[stat_id] = true
					end
				end
			end
		# Check if it's a relic
		elsif item_type == "relic"
			spell_data = item_doc.css("spellData spell desc")
			spell_text = spell_data && spell_data.text
			if !spell_text.blank? && spell_text.match(/resilience/i)
				puts "Found resilience on the relic: #{spell_text}" if args[:debug]
				item.spec_type = "pvp"
			elsif !spell_text.blank?
				puts "Scanning text: #{spell_text}"  if args[:debug]
				ITEMS["RELIC_SPELLS"].each do |spell_name, spec_type|
					if spell_text.match(/#{spell_name}/i)
						item.spec_type = spec_type
						break
					end
				end
			end

			# If we find it by spells, we're good. Otherwise will have to check by stats
			if item.spec_type
				puts "Identified relic #{item_type}" if args[:debug]
				item.item_type = item_type
			end
		# 0 is unequippable, so might be an enchant s
		elsif item.slot_id == 0
			spell_data = item_doc.css("spellData spell desc")
			scan_text(spell_data && spell_data.text)
			
			item_type = "enchant"
			
			puts "Found enchant: #{spell_data && spell_data.text}" if args[:debug]
		end
		
		# Check if it's a gem by the properties		
		# <gemProperties>+51 Stamina</gemProperties>
		gem_doc = item_doc.css("gemProperties")
		if gem_doc.length > 0
			scan_text(gem_doc.text)
			item_type = "gem"
			
			puts "Found gem: #{gem_doc.text}" if args[:debug]
		end
		
		# Find everything we need and convert them into our id format
		ITEMS["ARMOR_MAP"].each do |armory_id, stat_id|
			stat = item_doc.css(armory_id)
			if stat and stat.text != ""
				@item_stats[stat_id] = true
			end
		end
		
		puts "Stats #{item_type}: #{@item_stats.to_json}" if args[:debug]
		
		# If we found either no stats, or only one, and it's an equipped item
		# automatically switch to stat scanning mode
		if inventory_type && ITEMS["INV_TYPE_TO_TYPE"][inventory_type]
			if ( @item_stats.length <= 1 || item_quality <= ITEMS["QUALITY_RARE"] || item_level < 200 )
				spell_data = item_doc.css("spellData spell desc")
				scan_text(spell_data && spell_data.text)
			
				if @item_stats.length <= 1
					puts "Found 1 or less stats, switched to scanning spell data" if args[:debug]
				elsif item_level < 200
					puts "Item level is < 200, level #{item_level}" if args[:debug]
				else
					puts "Item quality is rare or less, switched to scanning spell data" if args[:debug]
				end
				puts "Stats are now: #{@item_stats.to_json}" if args[:debug]
			end
		end
		
		if ITEMS["OVERRIDES"][item.item_id].nil?
			item.spec_type ||= identify_by_stats(item_type, item_level)
		else
			item.spec_type = ITEMS["OVERRIDES"][item.item_id]
		end
		
		item.item_type = item_type
		item.stat_hash = create_stat_hash()
		item.touch
		
		puts "Done, item type is #{item_type}, spec type is #{item.spec_type}" if args[:debug]
	end
	
	private
	def create_stat_hash()
		# This is mostly a temporary hack fix, when stat scanning, we can match armor and armory penetration even if only armor exists on an item
		if !@text_scanned.nil? && !@item_stats["ARMOR_PENETRATION"].blank? && !@item_stats["ARMOR"].blank?
			@item_stats.delete("ARMOR")
		end
		
		return Digest::SHA1.hexdigest(@item_stats.keys.sort.join)
	end
	
	def scan_text(text)
		return if text.blank?
		@text_scanned = true
		
		ITEMS["STATS"].each do |stat_text, stat_id|
			if ITEMS["IGNORE_ON_SEARCH"][stat_id].nil? && text.match(/#{stat_text}/i)
				@text_scanned = true
				@item_stats[stat_id] = true
			end
		end
	end
		
	def identify_by_stats(item_type, item_level)
		if item_type.nil? || @item_stats.size == 0
			puts "No other type or stats found, returning quickly" if args[:debug]
			return "unknown"
		end
		
		row_id = 0
		ITEMS["IDENTIFY_RULES"].each do |rule|
			row_id += 1
			if rule["default"].nil? and rule[item_type].nil?
				next
			end
			
			# Check item level
			if !item_level.nil? && rule[:max_ilvl] && rule[:max_ilvl] < item_level
				next
			end
			
			# Check if we want this to be exclusive, no other stats can be listed if so
			if rule[:exclusive]
				total_stats = @item_stats.size
				if rule[:ignore_exclusive]
					rule[:ignore_exclusive].each do |stat_id|
						if @item_stats[stat_id]
							total_stats -= 1
						end
					end
				end
				
				puts "Exclusive match #{@item_stats.size}, now #{total_stats}" if args[:debug]
				if total_stats > 1
					puts "#{row_id}/#{rule[:id]}: Skipped, exclusive match" if args[:debug]
					next
				end
			end
			
			# Check if we have a black listed stat
			if rule[:skip_on]
				skip = false
				rule[:skip_on].each do |stat_id|
					if @item_stats[stat_id]
						skip = true
						puts "#{row_id}/#{rule[:id]}: Skipped, found stat #{stat_id}" if args[:debug]
						break
					end
				end
				
				if skip
					next
				end
			end
			
			# Check if we need another stat first
			if rule[:require_type]
				total_hits = 0
				rule[:requires].each do |stat_id|
					if @item_stats[stat_id]
						total_hits = total_hits + 1
					end
				end
				
				# Any = as long as we get a hit we're good. All = Everything has to match at least.
				if rule[:require_type] == "any" and total_hits == 0 || rule[:require_type] == "all" and total_hits < rule[:requires].size
					puts "#{row_id}/#{rule[:id]}: Requires #{rule[:require_type]} got #{total_hits} hits, we need #{rule[:requires].size}" if args[:debug]
					next
				end
			end
						
			# Merge the list for ease of use
			stat_list = nil
			if rule["default"] and rule[item_type]
				stat_list = rule["default"] | rule[item_type]
			elsif rule["default"]
				stat_list = rule["default"]
			elsif rule[item_type]
				stat_list = rule[item_type]
			end
			
			# No lists found for this item that are relevant, head to the next one
			if stat_list.nil?
				puts "#{row_id}/#{row_id}/#{rule[:id]}: Skipped, no stat list" if args[:debug]
				next
			end
						
			pass_checks = false
			stat_list.each do |stat_id|
				if @item_stats[stat_id]
					pass_checks = true
					puts "#{row_id}/#{row_id}/#{rule[:id]}: Found match! #{stat_id}" if args[:debug]
					break
				end
			end
			
			# Didn't pass, we can get out quickly then
			if !pass_checks
				next
			end
			
			return rule[:id]
		end
	
		puts "Found no matches, unknown returned" if args[:debug]
		return "unknown"
	end
end
