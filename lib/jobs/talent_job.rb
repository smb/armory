require "nokogiri"

class TalentJob < Struct.new(:args)
	def get_url
		return "parse", {:page => :talents, :region => args[:region], :r => args[:realm], :cn => args[:name]}
	end
	
	def parse(doc, raw_xml)
		character = Character.find_by_hash_id(args[:character_hash])
		return if character.nil?
		
		character.spec_role = "unknown"
		character.active_group = 1
		character.has_talents = true
		character.average_ilvl = 0
		character.equip_percent = 0
		character.gem_percent = 0
		character.enchant_percent = 0
		
		glyph_data = {}
		active_talents = nil
		
		# <talentGroup active="1" group="2" icon="ability_marksmanship" prim="Marksmanship">
		doc.css("characterInfo/talents/talentGroup").each do |talent_group|
			# <talentSpec treeOne="7" treeThree="7" treeTwo="57" value="502000000000000000000000000353051012300132331350313515000002000000000000000000000"/>
			talent_spec = talent_group.css("talentSpec")
			
			ActiveRecord::Base.transaction do
				group_id = talent_group.attr("group").to_i
				talent = character.talents.find(:first, :conditions => {:group => group_id}) || character.talents.new
				talent.group = group_id
				talent.active = talent_group.attr("active").nil? ? false : true
				talent.sum_tree1 = talent_spec.attr("treeOne").value.to_i
				talent.sum_tree2 = talent_spec.attr("treeTwo").value.to_i
				talent.sum_tree3 = talent_spec.attr("treeThree").value.to_i
				talent.compressed_data = talent_spec.attr("value").value
				talent.spec_role = talent.get_role(character.class_id)
				talent.unspent = (character.level - config_option("player")["talentpoints"]) - (talent.sum_tree1 + talent.sum_tree2 + talent.sum_tree3)
			
				# Cache the players equipment summaries
				character.current_group = talent.group
				character.current_role = talent.spec_role
				
				summary = character.equip_summary
				talent.average_ilvl = summary[:average_ilvl]
				talent.equip_percent = summary[:equip_percent]
				talent.gem_percent = summary[:gem_percent]
				talent.enchant_percent = summary[:enchant_percent]
				talent.is_pvp = summary[:is_pvp]

				# Cache the players active spec role so we don't have to keep checking the talents for it
				unless talent.active.blank?
					character.spec_role = talent.spec_role
					character.active_group = talent.group
					character.average_ilvl = summary[:average_ilvl]
					character.equip_percent = summary[:equip_percent]
					character.gem_percent = summary[:gem_percent]
					character.enchant_percent = summary[:enchant_percent]
					
					active_talents = talent
					talent.touch
				else
					talent.save
				end
				
				glyph_cache = {}
				data_cache = {}
				character.glyphs.all(:conditions => {:group_id => group_id}).each do |glyph|
					glyph_cache[glyph.glyph_id] = true
				end
								
				added_ids = []
			
				# Pull whatever they currently have
				# <glyph effect="Reduces the cooldown of Kill Shot by 6 sec." icon="ui-glyph-rune-17" id="692" name="Glyph of Kill Shot" type="major"/>
				talent_group.css("glyph").each do |glyph|
					glyph_id = glyph.attr("id").to_i
					
					# Nice thing about Glyphs is, they are pretty stable data. If they are found, you know nothings changed
					if glyph_cache[glyph_id].nil?
						talent.glyphs.create(:group_id => talent.group, :glyph_id => glyph_id, :character_id => character.id)
						data_cache[glyph_id] = {:glyph_id => glyph_id, :name => glyph.attr("name"), :is_major => glyph.attr("type") == "major" ? true : nil, :icon => glyph.attr("icon")}
					end

					added_ids.push(glyph_id)
				end
			
				# Kill anything not matching the glyph ids we used
				if added_ids.size > 0
					character.glyphs.all(:conditions => ["group_id = ? and glyph_id not in (?)", group_id, added_ids]).each do |glyph|
						glyph.destroy
					end
				end
				
				# Remove any information we already have
				if data_cache.size > 0
					GlyphData.all(:conditions => ["glyph_id in (?)", data_cache.keys]).each do |glyph|
						data_cache.delete(glyph.glyph_id)
					end
					
					if data_cache.size > 0
						data_cache.each do |glyph_id, glyph|
							glyph[:name] = GLYPHS["REMAP"][glyph_id] || glyph[:name]
							GlyphData.create(glyph)
						end
					end
				end
			end
		end
		
=begin
		# Figure out the statistics info we need to insert or remove
		unless active_talents.nil?
			# First off, cache all the info
			item_stats = {}
			ItemStatistic.find(:all, :conditions => {:character_id => character.id}).each do |stat|
				item_stats[stat.equipment_id] ||= {}
				if stat.item_type == ITEMS["EQUIP_TYPES"][:gear] then
					item_stats[stat.equipment_id][:equip] = stat
				elsif stat.item_type == ITEMS["EQUIP_TYPES"][:gem] then
					item_stats[stat.equipment_id][:gems] ||= []
					item_stats[stat.equipment_id][:gems].push(stat)
				elsif stat.item_type == ITEMS["EQUIP_TYPES"][:enchant] then
					item_stats[stat.equipment_id][:enchant] = stat
				end
			end
			
			ActiveRecord::Base.transaction do
				character.equipment.all(:conditions => {:group_id => character.current_group}, :include => [:item, :item_gem1, :item_gem2, :item_gem3, :item_enchant, :spell_enchant]).each do |equipment|
					next if equipment.item.nil? || !equipment.valid_equip?(character)
					stats = item_stats[equipment.equipment_id] || {}
					
					# Equipment
					create_statistics(:statistic => stats[:equip], :char => character, :equipment_id => equipment.equipment_id, :item_type => ITEMS["EQUIP_TYPES"][:gear], :item_id => equipment.item.item_id)
					
					# Enchant
					if equipment.item_enchant or equipment.spell_enchant
						enchant = {:statistic => stats[:enchant], :char => character, :equipment_id => equipment.equipment_id, :item_type => ITEMS["EQUIP_TYPES"][:enchant]}
						enchant[:item_id] = equipment.item_enchant.item_id unless equipment.item_enchant.nil?
						enchant[:enchant_id] = equipment.spell_enchant.enchant_id unless equipment.spell_enchant.nil?
						
						#create_statistics(enchant)
					end
					
					# Gems
					(1..equipment.total_gems).each do |index|
						gem_data = equipment.send("item_gem#{index}")
						next if gem_data.nil? or equipment["gem#{index}_id"].nil?
						
						gem_stat = stats[:gems] && stats[:gems][index - 1]
						create_statistics(:statistic => gem_stat, :char => character, :equipment_id => equipment.equipment_id, :item_type => ITEMS["EQUIP_TYPES"][:gem], :item_id => gem_data.item_id, :socket_color => ITEMS["SOCKET_COLORS"][equipment.socket_color(index)])
					
						stats[:gems][index - 1] = nil unless stats[:gems].nil?
					end
					
					# Clean up
					stats.delete(:equip)
					stats.delete(:enchant)
				end
			
				# Remove anything that was untouched
				item_stats.each do |equip_id, equipment|
					equipment[:equip].destroy unless equipment[:equip].nil?
					equipment[:enchant].destroy unless equipment[:enchant].nil?
				
					unless equipment[:gems].nil?
						equipment[:gems].each do |stat|
							stat.destroy unless stat.nil?
						end
					end
				end
			end
		end
=end

		# Save pet talents if they have pets
		# <pet catId="60" family="Wasp" familyId="44" icon="ability_hunter_pet_wasp" lvl="80" name="Tehaxhasdied" npcId="28086" npcName="Sapphire Hive Wasp">
		pet_cache = {}
		seen_ids = []
	
		ActiveRecord::Base.transaction do
			character.pet_talents.each do |talent|
				pet_cache[talent.cat_id] = talent
			end

			doc.css("characterInfo/talents/pet").each do |pet_group|
				cat_id = pet_group.attr("catId").to_i
				# <talentGroup active="1" group="1" icon="ability_druid_swipe" key="Ferocity" order="0" prim="Ferocity">
				talent_group = pet_group.css("talentGroup")
				# <talentSpec treeOne="16" treeThree="0" treeTwo="0" value="210000130300003010101"/>
				talent_spec = pet_group.css("talentSpec")
				next if cat_id.nil? || talent_group.length == 0 || talent_spec.length == 0
				
				talent = pet_cache[cat_id] || character.pet_talents.new
				talent.cat_id = cat_id
				talent.active = talent_group.attr("active").nil? ? false : true
				talent.group = talent_group.attr("group")
				talent.pet_name = pet_group.attr("name")
				talent.pet_family_id = pet_group.attr("familyId")
				talent.pet_family_name = pet_group.attr("family")
				talent.pet_npc_id = pet_group.attr("npcId")
				talent.pet_npc_name = pet_group.attr("name")
				talent.pet_level = pet_group.attr("lvl")
				talent.tree_type = talent_group.attr("key").value.downcase
				talent.sum_tree1 = talent_spec.attr("treeOne").value
				talent.sum_tree2 = talent_spec.attr("treeTwo").value
				talent.sum_tree3 = talent_spec.attr("treeThree").value
				talent.compressed_data = talent_spec.attr("value").value
				talent.save
				
				seen_ids.push(cat_id)
			end
		end
		
		character.pet_talents.all(:conditions => ["cat_id not in (?)", seen_ids]).each do |talent|
			talent.destroy
		end

		character.touch
	end
	
	private
=begin
	def create_statistics(args)
		statistic = args[:statistic] || ItemStatistic.new
		statistic.character_id = args[:char].id
		statistic.character_level = args[:char].level
		statistic.average_ilvl = args[:char].average_ilvl
		statistic.spec_role = args[:char].spec_role
		statistic.equipment_id = args[:equipment_id]
		statistic.socket_color = args[:socket_color]
		statistic.item_type = args[:item_type]
		statistic.item_id = args[:item_id]
		statistic.enchant_id = args[:enchant_id]
		statistic.save
	end
=end
end