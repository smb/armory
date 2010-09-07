require "nokogiri"
class CharacterJob < Struct.new(:args)
	CHARACTER_ATTRIBS = {
		:name => "name",
		:realm => "realm",
		:guild => "guildName",
		:level => "level",
		:title_id => "titleId",
		:class_id => "classId",
		:faction_id => "factionId",
		:race_id => "raceId",
		:gender_id => "genderId",
		:battlegroup => "battleGroup",
		:achievement_points => "points"
	}
	
	def get_url
		return "parse", {:page => :character, :region => args[:region], :n => args[:name], :r => args[:realm]}
	end
	
	def handle_error(error)
		if error == "inactive"
			character = Character.find(:first, :conditions => {:hash_id => Character.get_hash(args[:region], args[:realm], args[:name])})
			if !character.nil?
				character.inactive = true
				character.save
			end
		# If we fail to find a character 4 times over at least 4 days, then delete them
		elsif error == "noCharacter"
			character = Character.find(:first, :conditions => {:hash_id => Character.get_hash(args[:region], args[:realm], args[:name])})
			if !character.nil? && character.updated_at >= 24.hours.ago
				if !character.failed.nil? && character.failed >= 3
					character.destroy
					return
				end
				
				character.failed ||= 0
				character.failed += 1
				character.touch
			end
		end
	end
	
	def parse(doc, raw_xml)
		character_hash = Character.get_hash(args[:region], args[:realm], args[:name])
		armory_char = doc.css("characterInfo character")
		return if armory_char.nil?
	
		# Find the active talent group
		@talent_group = 1
		doc.css("characterTab talentSpecs talentSpec").each do |talent_spec|
			unless talent_spec.attr("active").blank?
				@talent_group = talent_spec.attr("group").to_i
			end
		end		

		# Store base character data
		# character battleGroup="Stormstrike" charUrl="r=Mal%27Ganis&amp;cn=Shadow" class="Druid" classId="11" classUrl="c=Druid" faction="Horde" factionId="1" gender="Female" genderId="1" guildName="Internet Relay Chat" guildUrl="r=Mal%27Ganis&amp;gn=Internet+Relay+Chat" lastModified="March 12, 2010" level="80" name="Shadow" points="6720" prefix="Obsidian Slayer " race="Tauren" raceId="6" realm="Mal'Ganis" suffix="" titleId="106">
		@character = Character.find(:first, :conditions => {:hash_id => character_hash}) || Character.new
		@character.region = args[:region].downcase
		@character.hash_id = character_hash	
		@character.active_group = @talent_group
		@character.inactive = false
		@character.failed = 0
		
		# Check last login, if it's the same as what we last had and we're spidering, we don't want to bother again
		last_login = armory_char.attr("lastModified")
		last_login = !last_login.blank? && last_login.value.blank? && Time.parse(last_login.value).to_i || Time.now.to_i
		if !args[:check_login].nil? && !@character.last_login.nil? && @character.last_login == last_login && !@character.has_talents.blank? && !@character.has_achievements.blank?
			return
		end
		@character.last_login = last_login
		
		# Grab common attributes 
		CHARACTER_ATTRIBS.each do |db_key, attrib_key|
			@character[db_key] = armory_char.attr(attrib_key).value
		end
		
		# Hash the guild for easy searching
		if !@character.guild.blank?
			@character.guild_hash = Guild.get_hash(@character.region, @character.realm, @character.guild)
			@character.guild_rank = args[:guild_rank].blank? ? @character.guild_rank : args[:guild_rank]

			# Indicate that any caches of this characters guild should be invalidated in case a summary is done on them
			guild = Guild.find(:first, :conditions => {:hash_id => @character.guild_hash})
			if guild
				guild.touch
			end
			
			# If the character was queued manually, and not by another 
			if guild.nil? && args[:guild_hash].blank?
				DataManager.queue_guild_spider(:name => @character.guild, :region => @character.region, :realm => @character.realm, :guild_hash => @character.guild_hash, :priority => PRIORITIES[:guild_data], :no_queue => true)
			end
		else
			@character.guild_hash = nil
			@character.guild_rank = nil
		end

		@character.touch
	
		# Queue talents
		DataManager.queue_talents(:character_hash => @character.hash_id, :region => @character.region, :name => @character.name, :realm => @character.realm, :priority => args[:priority], :guild_hash => @character.guild_hash)

		# Queue achievements
		DataManager.queue_achievements(:character_hash => @character.hash_id, :region => @character.region, :name => @character.name, :realm => @character.realm, :priority => args[:priority], :guild_hash => @character.guild_hash)
		DataManager.queue_statistics(:character_hash => @character.hash_id, :region => @character.region, :name => @character.name, :realm => @character.realm, :priority => args[:priority], :guild_hash => @character.guild_hash)
		
		# Queue reputation
		#DataManager.queue_reputation(:character_hash => @character.hash_id, :region => @character.region, :name => @character.name, :realm => @character.realm, :priority => args[:priority])
		
		# Queue and record equipment
		# rarity <= 1 should be ignored as they are white or less and no useful stats
		# Leatherwork only enchant
		# <item displayInfoId="61182" durability="30" gem0Id="40155" gem1Id="0" gem2Id="0" gemIcon0="inv_jewelcrafting_gem_39" icon="inv_bracer_36b" id="47584" level="245" maxDurability="40" name="Moonshadow Armguards" permanentEnchantIcon="trade_leatherworking" permanentEnchantSpellDesc="Permanently enchant bracers to increase spell power by 76.&#10;&#10;&#10;&#10;Can only be used on the leatherworker's bracers, and doing so will cause them to become soulbound.  Fur Lining requires at least 400 skill in Leatherworking to remain active." permanentEnchantSpellName="Fur Lining - Spell Power" permanentenchant="3758" pickUp="PickUpCloth_Leather01" putDown="PutDownCloth_Leather01" randomPropertiesId="0" rarity="4" seed="1028597760" slot="8"/>
		# Ring with an enchanter only enchant
		# <item displayInfoId="43095" durability="0" gem0Id="0" gem1Id="0" gem2Id="0" icon="inv_jewelry_ring_54" id="47732" level="245" maxDurability="0" name="Band of the Invoker" permanentEnchantIcon="trade_engraving" permanentEnchantSpellDesc="Permanently enchant a ring to increase spell power by 23.  Only the Enchanter's rings can be enchanted, and enchanting a ring will cause it to become soulbound." permanentEnchantSpellName="Enchant Ring - Greater Spellpower" permanentenchant="3840" pickUp="PickUpRing" putDown="PutDownRing" randomPropertiesId="0" rarity="4" seed="0" slot="11"/>
		# Enchant with item version
		# <item displayInfoId="61203" durability="46" gem0Id="41380" gem1Id="49110" gem2Id="0" gemIcon0="inv_jewelcrafting_shadowspirit_02" gemIcon1="inv_misc_gem_pearl_12" icon="inv_helmet_145b" id="48188" level="232" maxDurability="70" name="Runetotem's Headguard of Conquest" permanentEnchantIcon="ability_warrior_swordandboard" permanentEnchantItemId="44878" permanentenchant="3818" pickUp="PickUpCloth_Leather01" putDown="PutDownCloth_Leather01" randomPropertiesId="0" rarity="4" seed="0" slot="0"/>
		# Item when the armory does not "have" it yet
		# <item durability="75" gem0Id="49110" gem1Id="0" gem2Id="0" id="51398" permanentenchant="3834" pickUp="" putDown="" randomPropertiesId="0" seed="0" slot="15"/>
       
		ActiveRecord::Base.transaction do
			equip_cache = {}
			queue_items = {}
			queue_enchants = {}
			enchant_spells, enchant_items = {}, {}
			
			@character.equipment.find(:all, :conditions => {:group_id => @talent_group}).each do |equipment|
				equip_cache[equipment.equipment_id] = equipment
			end
			
			added_ids = []
			equip_list = doc.css("characterInfo characterTab items item")
			equip_list.each do |item_data|
				slot = item_data.attr("slot").to_i

				# Not a slot we care about, discard
				next if slot.nil? or ITEMS["SLOT_TO_TYPE"][slot].nil?
				
				equipment = equip_cache[slot] || @character.equipment.new
				equipment.equipment_id = slot
				equipment.group_id = @talent_group
				equipment.item_id = item_data.attr("id").to_i
				equipment.gem1_id = item_data.attr("gem0Id").to_i > 0 && item_data.attr("gem0Id").to_i || nil
				equipment.gem2_id = item_data.attr("gem1Id").to_i > 0 && item_data.attr("gem1Id").to_i || nil
				equipment.gem3_id = item_data.attr("gem2Id").to_i > 0 && item_data.attr("gem2Id").to_i || nil
				equipment.durability = item_data.attr("maxDurability").to_i > 0 && item_data.attr("durability").to_i || nil
				equipment.random_suffix = item_data.attr("randomPropertiesId").to_i != 0 && item_data.attr("randomPropertiesId").to_i || nil
						
				# Most enchants have an item version, typically a scroll.
				# Enchant with an item equivalent
				equipment.enchant_spell = item_data.attr("permanentenchant").to_i > 0 && item_data.attr("permanentenchant").to_i || nil
				equipment.enchant_item = item_data.attr("permanentEnchantItemId").to_i > 0 && item_data.attr("permanentEnchantItemId").to_i || nil
				
				if equipment.enchant_item
					remap = ENCHANTS["REMAP"][ITEMS["SLOT_TO_TYPE"][slot]]
					if remap and remap[equipment.enchant_item]
						equipment.enchant_item = remap[equipment.enchant_item]
					end

					enchant_items[equipment.enchant_item] = slot unless equipment.enchant_item.nil?
					queue_items[equipment.enchant_item] = 1
				elsif equipment.enchant_spell && !item_data.attr("permanentEnchantSpellDesc").blank?
					enchant_spells[equipment.enchant_spell] = slot unless equipment.enchant_spell.nil?
					queue_enchants[equipment.enchant_spell] ||= {:enchant_id => equipment.enchant_spell, :name => item_data.attr("permanentEnchantSpellName"), :icon => item_data.attr("permanentEnchantIcon"), :enchant => item_data.attr("permanentEnchantSpellDesc")}
				end
				
				equipment.save
				added_ids.push(equipment.equipment_id)

				# Figure out what items we need to scrap new data for
				if !equipment.gem1_id.nil?
					queue_items[equipment.gem1_id] = 1
				end
				if !equipment.gem2_id.nil?
					queue_items[equipment.gem2_id] = 1
				end
				if !equipment.gem3_id.nil?
					queue_items[equipment.gem3_id] = 1
				end
				
				queue_items[equipment.item_id] = equipment.random_suffix.nil? ? 1 : 2
			end
			
			if enchant_items.length > 0
				enchant_slots = {}
				EnchantSlot.find(:all, :conditions => ["item_id IN (?)", enchant_items.keys]).each do |enchant|
					enchant_slots[enchant.item_id] ||= {}
					enchant_slots[enchant.item_id][enchant.equipment_id] = enchant
				end
				
				enchant_items.each do |item_id, slot|
					enchant = enchant_slots[item_id] && enchant_slots[item_id][slot] || EnchantSlot.new
					enchant.item_id = item_id
					enchant.equipment_id = slot
					enchant.save
				end
			end

			if enchant_spells.length > 0
				enchant_slots = {}
				EnchantSlot.find(:all, :conditions => ["spell_id IN (?)", enchant_spells.keys]).each do |enchant|
					enchant_slots[enchant.spell_id] ||= {}
					enchant_slots[enchant.spell_id][enchant.equipment_id] = enchant
				end
				
				enchant_spells.each do |spell_id, slot|
					enchant = enchant_slots[spell_id] && enchant_slots[spell_id][slot] || EnchantSlot.new
					enchant.spell_id = spell_id
					enchant.equipment_id = slot
					enchant.save
				end
			end

			
			# Clean up any unequipped items
			@character.equipment.all(:conditions => ["equipment_id not in (?) and group_id = ?", added_ids, @talent_group]).each do |equipment|
				equipment.destroy
			end
		
			DataManager.mass_queue_items(queue_items)
			DataManager.mass_queue_enchants(queue_enchants)
		end
		
		# Arenas!
		ActiveRecord::Base.transaction do
			team_cache = {}
			seen_teams = []
			armory_char.css("arenaTeams arenaTeam").each do |team_doc|
				bracket = team_doc.attr("teamSize").to_i
				
				team_hash = ArenaTeam.get_hash(@character.region, @character.realm, bracket, team_doc.attr("name"))
				team_data = ArenaTeam.find(:first, :conditions => {:team_hash => team_hash}) || ArenaTeam.new
				team_data.bracket = bracket
				team_data.team_hash = team_hash
				team_data.name = team_doc.attr("name")
				team_data.rating = team_doc.attr("rating")
				team_data.played = team_doc.attr("gamesPlayed")
				team_data.won = team_doc.attr("gamesWon")
				team_data.season_played = team_doc.attr("seasonGamesPlayed")
				team_data.season_won = team_doc.attr("seasonGamesWon")
				team_data.previous_rank = team_doc.attr("lastSeasonRanking")
				team_data.current_rank = team_doc.attr("ranking")
				
				retries = 0
				begin
					team_data.save
				rescue Mysql::Error => e
					retries += 1
					retry if retries <= 5
				end

				seen_teams.push(team_data.id)
				
				char_cache = {}
				team_data.arena_characters.each do |team_char|
					char_cache[team_char.character_hash] = team_char
				end
				
				seen_hashes = []
				team_doc.css("members character").each do |team_char_doc|
					name_hash = Character.get_hash(@character.region, @character.realm, team_char_doc.attr("name"))
					team_char = char_cache[name_hash] || team_data.arena_characters.new
					team_char.character_hash = name_hash
					team_char.played = team_char_doc.attr("gamesPlayed")
					team_char.won = team_char_doc.attr("gamesWon")
					team_char.season_played = team_char_doc.attr("seasonGamesPlayed")
					team_char.season_won = team_char_doc.attr("seasonGamesWon")
					team_char.personal_rank = team_char_doc.attr("teamRank")
					team_char.personal_rating = team_char_doc.attr("contribution")
					team_char.save
					
					seen_hashes.push(name_hash)
					#DataManager.queue_character(:character_hash => name_hash, :region => @character.region, :realm => @character.realm, :name => team_char_doc.attr("name"))
				end

				team_data.arena_characters.all(:conditions => ["character_hash not in (?)", seen_hashes]).each do |team_char|
					team_char.destroy
				end
			end
			
			@character.arena_characters.all(:conditions => ["arena_team_id not in (?)", seen_teams]).each do |team_char|
				team_char.destroy
			end
		end
		
		# Check if they have a title, we might need to cache its data
		if @character.title_id && !Rails.cache.read("title/#{@character.title_id}", :raw => true, :expires_in => 1.week)
			Rails.cache.write("title/#{@character.title_id}", "1", :raw => true, :expires_in => 1.week)
			
			title = Title.find(:first, :conditions => {:title_id => @character.title_id})
			if title.nil?
				title = Title.new
				
				if armory_char.attr("prefix").value != ""
					title.name = armory_char.attr("prefix").value
					title.location = "prefix"
				else
					title.name = armory_char.attr("suffix").value
					title.location = "suffix"
				end

				title.title_id = @character.title_id
				title.save
			end
		end
	
		# Add professions
		ActiveRecord::Base.transaction do
			armory_profs = doc.css("characterInfo characterTab professions skill")
			if armory_profs
				added_ids = []
				prof_cache = {}
				
				@character.professions.each do |profession|
					prof_cache[profession.profession_id] = profession
				end
				
				prof_data_cache = Rails.cache.fetch("prof/all", :expires_in => 1.week) do
					
					cache = []
					ProfessionData.all.each do |profession|
						cache[profession.profession_id] = true
					end
					
					cache
				end
					
				# <skill id="755" key="jewelcrafting" max="450" name="Jewelcrafting" value="450"/>
		        armory_profs.each do |skill|
					skill_id = skill.attr("id").to_i 
					added_ids.push(skill_id)

					profession = prof_cache[skill_id] || @character.professions.new
					profession.profession_id = skill_id
					profession.max = skill.attr("max")
					profession.current = skill.attr("value")
					profession.save
					
					if prof_data_cache[skill_id].nil?
						prof_data = ProfessionData.new
						prof_data.profession_id = skill_id
						prof_data.key = skill.attr("key")
						prof_data.name = skill.attr("name")
						prof_data.save
						
						Rails.cache.delete("prof/all")
					end
				end

				@character.professions.all(:conditions => ["profession_id not in (?)", added_ids]).each do |profession|
					profession.destroy
				end
			end
		end
		
		# Figure out stats
		@stat_cache = {}
		@character.stats.find(:all, :conditions => {:group_id => @talent_group}).each do |stat|
			@stat_cache[stat[:category]] ||= {}
			@stat_cache[stat[:category]][stat[:stat_type]] ||= {}
			@stat_cache[stat[:category]][stat[:stat_type]] = stat
		end
					
		@stats = @character.stats
		character_tab = doc.css("characterInfo characterTab")
	
		ActiveRecord::Base.transaction do
			# Do the general health/power
			bars = character_tab.css("characterBars")
			# <health effective="31377"/>
			add_stat("character", "health", bars.css("health").attr("effective").value, nil)
		
			# Identify if it's rage/energy/mana. For Druids, this is always mana, it won't change based on the form you logout in
			# <secondBar casting="0" effective="6231" notCasting="45" type="m"/>
			second_bar = bars.css("secondBar")
			type = "mana"
			if second_bar.attr("type").value == "e" then
				type = "energy"
			elsif second_bar.attr("type").value == "r" then
				type = "rage"
			end
		
			add_stat("character", type, second_bar.attr("effective").value, nil)
		
			# <strength attack="756" base="99" block="-1" effective="388"/>
			# <agility armor="2084" attack="-1" base="82" critHitPercent="19.98" effective="1042"/>
			# <stamina base="104" effective="2377" health="23590" petBonus="-1"/>
			# <intellect base="176" critHitPercent="3.06" effective="201" mana="2735" petBonus="-1"/>
			# <spirit base="170" effective="191" healthRegen="15" manaRegen="45"/>
			# <armor base="8852" effective="8852" percent="36.75" petBonus="-1"/>
			base_stats = character_tab.css("baseStats")
		
			Stat::BASE_ATTRIBS.each do |stat|
				add_stat("base", stat, base_stats.css(stat).attr("effective").value, nil)
			end
		
			# Defensive stats
			defensive_stats = character_tab.css("defenses")
			# <armor base="30172" effective="30637" percent="66.79" petBonus="-1"/>
			armor = defensive_stats.css("armor")
			add_stat("defensive", "armor", armor.attr("effective").value, armor.attr("percent").value)
			# <defense decreasePercent="7.96" increasePercent="7.96" plusDefense="199" rating="981" value="400.00"/>
			defense = defensive_stats.css("defense")
			add_stat("defensive", "defense", defense.attr("rating").value, defense.attr("plusDefense").value.to_i + defense.attr("value").value.to_i)
			# <resilience damagePercent="25.04" hitPercent="11.38" value="1073.00"/>
			resilience = defensive_stats.css("resilience")
			add_stat("defensive", "resilience", resilience.attr("value").value, resilience.attr("hitPercent").value)
			# <dodge increasePercent="14.01" percent="28.35" rating="634"/>
			# <parry increasePercent="7.03" percent="21.76" rating="318"/>
			# <block increasePercent="0.00" percent="17.96" rating="0"/>
			["dodge", "parry", "block"].each do |stat|
				stat_data = defensive_stats.css(stat)
				add_stat("defensive", stat, stat_data.attr("rating").value, stat_data.attr("percent"))
			end
			
			# Melee/Ranged
			["melee", "ranged"].each do |primary_type|
				primary_stats = character_tab.css(primary_type)
			
				# <power base="756" effective="1950" increasedDps="139.0"/>
				add_stat(primary_type, "attackpower", primary_stats.css("power").attr("effective").value, nil)
				# <hitRating increasedHitPercent="9.70" penetration="239" reducedArmorPercent="17.08" value="318"/>
				misc_hit = primary_stats.css("hitRating")
				add_stat(primary_type, "penetration", misc_hit.attr("penetration").value, misc_hit.attr("reducedArmorPercent").value)
				add_stat(primary_type, "hit", misc_hit.attr("value").value, misc_hit.attr("increasedHitPercent").value)
				# <critChance percent="13.10" plusPercent="7.36" rating="338"/>
				crit = primary_stats.css("critChance")
				add_stat(primary_type, "crit", crit.attr("rating").value, crit.attr("percent").value)
			
				if primary_type == "melee"
					# <expertise additional="10" percent="5.00" rating="85" value="20"/>
					expertise = primary_stats.css("expertise")
					add_stat(primary_type, "expertise", expertise.attr("value").value, expertise.attr("percent").value)

					# <mainHandSpeed hastePercent="6.86" hasteRating="173" value="3.18"/>
					haste = primary_stats.css("mainHandSpeed")
					add_stat(primary_type, "haste", haste.attr("hasteRating").value, haste.attr("hastePercent").value)
				else
					# <speed hastePercent="22.32" hasteRating="732" value="1.55"/>
					haste = primary_stats.css("speed")
					add_stat(primary_type, "haste", haste.attr("hasteRating").value, haste.attr("hastePercent").value)
				end
			end
		
			# Spells
			spell_stats = character_tab.css("spell")
			bonus_damage = spell_stats.css("bonusDamage")
			hit = spell_stats.css("hitRating")
			haste = spell_stats.css("hasteRating")
			crit = spell_stats.css("critChance")
			mana_regen = spell_stats.css("manaRegen")
		
			# <hasteRating hastePercent="25.56" hasteRating="838"/>
			add_stat("spell", "haste", haste.attr("hasteRating").value, haste.attr("hastePercent").value)
			# <manaRegen casting="0.00" notCasting="45.00"/>
			add_stat("spell", "mp5", mana_regen.attr("casting").value, nil)
		
			# <bonusHealing value="3212"/>
			add_stat("spell", "healing", spell_stats.css("bonusHealing").attr("value").value, nil)
			# <hitRating increasedHitPercent="11.28" penetration="0" reducedResist="0" value="296"/>
			add_stat("spell", "hit", hit.attr("value").value, hit.attr("increasedHitPercent").value)
			add_stat("spell", "penetration", hit.attr("reducedResist").value, hit.attr("penetration").value)
		
			#bonusDamage -> <arcane value="3450"/>
			# <critChance rating="164">
			# <arcane percent="29.95"/>
			Stat::SPELL_TYPES.each do |school|
				add_stat("spelldamage", school, bonus_damage.css(school).attr("value").value, nil)
				add_stat("spellcrit", school, crit.attr("rating").value, crit.css(school).attr("percent").value)
			end
		end

		@character.touch
	end
	
	private
	def add_stat(category, stat_type, rating, percent)
		percent ||= 0
		rating ||= 0
		
		stat = @stat_cache[category] && @stat_cache[category][stat_type]
		if stat.nil? 
			@stats.create(:group_id => @talent_group, :rating => rating.to_i, :percent => percent, :category => category, :stat_type => stat_type)
			return
		end
		
		stat.group_id = @talent_group
		stat.rating = rating.to_i
		stat.percent = percent
		stat.save
	end
end