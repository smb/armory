require "yaml"
require "cgi"

class Character < ActiveRecord::Base
	has_many :equipment, :dependent => :destroy
	has_many :professions, :dependent => :destroy
	has_many :achievements, :dependent => :destroy
	has_many :experiences, :dependent => :destroy
	has_many :stats, :dependent => :destroy
	has_many :talents, :dependent => :destroy
	has_many :pet_talents, :dependent => :destroy
	has_many :glyphs, :dependent => :destroy
	has_many :arena_characters, :class_name => "ArenaCharacter", :foreign_key => :character_hash, :primary_key => :hash_id, :dependent => :destroy
	#has_many :reputations
	has_one :active_talent, :class_name => "Talent", :conditions => ["active = ?", true]
	has_many :exp_achievements, :class_name => "Achievement", :conditions => ["child_id is not null"]
	
	def self.realm_name(region, realm)
		force_realm = REALM_DATA["#{region}-#{realm}".downcase]
		if !force_realm.nil? && force_realm.is_a?(String)
			return force_realm
		end
		
		return realm
	end

	def self.get_hash(region, realm, name)
		return if region.blank? || realm.blank? || name.blank?
		
		# TW realms can be accessed through the English or the localized form
		# we want to force everything to use the English form so we don't duplicate data
		force_realm = REALM_DATA["#{region}-#{realm}".downcase]
		if !force_realm.nil? && force_realm.is_a?(String)
			realm = force_realm
		end
		
		return nil if force_realm.nil?
		return CGI::unescape("#{region}:#{realm}:#{name}".downcase)
	end

	def self.get_partial_hash(region, realm)
		return if region.blank? || realm.blank?
		# TW realms can be accessed through the English or the localized form
		# we want to force everything to use the English form so we don't duplicate data
		force_realm = REALM_DATA["#{region}-#{realm}".downcase]
		if !force_realm.nil? && force_realm.is_a?(String)
			realm = force_realm
		end
		
		return nil if force_realm.nil?
		return "#{region}:#{realm}:".downcase
	end
	
	def get_mains
		base = CharacterClaim.find(:first, :conditions => {:character_hash => self.hash_id, :is_public => true})
		return [] if base.nil?
		return CharacterClaim.find(:all, :conditions => ["user_id = ? and is_public = ? and relationship = ? and id not in (?)", base.user_id, true, "main", base.id], :limit => config_option("claim")["limit"], :include => :character)
	end
	
	def get_stats
		talent_base = TALENTS[:base][self.current_role]
		# Cache stat data, except for the the maxs for performance reasons
		categories = ["character", "base"]
		categories.push("melee", "defensive") if talent_base[:primary] == "tank"
		categories.push("ranged") if talent_base[:type] == "range"
		categories.push("spell", "spellcrit") if talent_base[:type] == "caster"
		categories.push("melee", "spell") if talent_base[:type] == "physical" && talent_base[:primary] != "tank"
		
		@cache_stats = {}
		self.stats.all(:conditions => {:group_id => self.current_group, :category => categories}).each do |stat|
			@cache_stats[stat.category] ||= {}
			@cache_stats[stat.category][stat.stat_type] = stat
		end
		
		# Now calculate
		stat_data = []
		stat_data.push(:text => "Health", :amount => "%d", :stat => get_stat("character", "health"), :tooltip_stat => get_stat("base", "stamina"), :tooltip_text => "Stamina", :tooltip_type => :rating)
		
		if( talent_base[:primary] == "tank" )
			stat_data.push(:text => "Hit", :amount => "%.2f%", :is_rating => true, :stat => get_stat("melee", "hit"))
			stat_data.push(:text => "Expertise", :amount => "%.2f%", :stat => get_stat("melee", "expertise"))

			defense = get_stat("defensive", "defense")
			resilience = get_stat("defensive", "resilience")
			
			# Druids get 6% resilience due to Survival of the Fittest
			if( self.current_role == "bear-druid" )
				resilience[:percent] = resilience[:percent] + 6.0
			end

			dodge = get_stat("defensive", "dodge")
			# Druids are a special case, as they do not benefit from Parry
			parry = self.current_role != "bear-druid" ? get_stat("defensive", "parry") : 0
			# Death Knights can't block, due to well, no shield
			block = self.current_role != "tank-dk" ? get_stat("defensive", "block") : 0
			
			# Only class this really applies to are Druids, who won't have parry or block
			if parry[:percent] == 0 and block[:percent] == 0
				stat_data.push(:text => "Dodge", :amount => "%.2f%", :is_rating => true, :stat => dodge)
			elsif
				stat_data.push(:text => "Avoidance", :amount => "%.2f%" % (dodge[:percent] + parry[:percent]), :stats => {"Dodge" => dodge, "Parry" => parry, "Block" => block})
			end
			
			stat_data.push(:text => "Armor", :amount => "%.2f%", :stat => get_stat("defensive", "armor"), :tooltip_type => :rating)
			stat_data.push(:text => "Defense", :amount => "%d", :is_rating => true, :stat => defense)
			stat_data.push(:text => "Resilience", :amount => "%.2f%", :is_rating => true, :stat => resilience)

			# Figure out if they are crittable
			crittable = (5.6 - resilience[:percent]) - ((self.level * 5 - defense[:percent]).abs * 0.04)
	 		if( crittable <= 0 )
				stat_data.push(:text => "Uncrittable!", :color => "green", :tooltip => "Cannot be crit by level #{self.level + 3} mobs.")
			else
				stat_data.push(:text => "Below crit cap", :color => "red", :tooltip => "%.2f%% chance to be crit by level #{self.level + 3} mobs" % crittable, :color => "red")
			end
			
		# Hunters	
		elsif( talent_base[:type] == "range" )
			stat_data.push(:text => "Attack power", :amount => "%d", :stat => get_stat("ranged", "attackpower"), :no_tooltip => true)
			stat_data.push(:text => "Haste", :amount => "%.2f%", :is_rating => true, :stat => get_stat("ranged", "haste"))
			stat_data.push(:text => "Crit", :amount => "%.2f%", :is_rating => true, :stat => get_stat("ranged", "crit"))
			stat_data.push(:text => "Armor pen", :amount => "%.2f%", :is_rating => true, :stat => get_stat("ranged", "penetration"))
			stat_data.push(:text => "Hit", :amount => "%.2f%", :is_rating => true, :stat => get_stat("ranged", "hit"))
		# Rogues, Ret Paladins, Fury/Arms Warriors, Non-Tank Death Knights, Ench Shamans, Cat Druids
		elsif( talent_base[:type] == "physical" )
			stat_data.push(:text => "Attack power", :amount => "%d", :stat => get_stat("melee", "attackpower"), :tooltip_stat => get_stat("base", "strength"), :tooltip_text => "Strength", :tooltip_type => :rating)
			stat_data.push(:text => "Armor pen", :amount => "%.2f%", :is_rating => true, :stat => get_stat("melee", "penetration"))
			stat_data.push(:text => "Crit", :amount => "%.2f%", :is_rating => true, :stat => get_stat("melee", "crit"))
			stat_data.push(:text => "Haste", :amount => "%.2f%", :is_rating => true, :stat => get_stat("melee", "haste"))

			# hit stuff...
			meleehit = get_stat("melee", "hit")
                        spellhit = get_stat("spell", "hit")
                        
			meleetype, secondary_type = get_melee_type(talent_base)
                        
			#bonusPercent = shown_talent().get_bonus(self.class_id, meleetype)

                        bonusPercent = get_bonus(meleetype);

			meleehit = stat_add_p(meleehit, meleetype, bonusPercent[:total][:percent])

                        tooltip, color = tooltip_hit(meleehit, meleetype, bonusPercent, true)

			stat_data.push(:text => "Hit", :amount => "%.2f%", :is_rating => true, :stat => meleehit, :color => color, :tooltip => tooltip)

			if !secondary_type.nil?			
				#bonusSec = shown_talent().get_bonus(self.class_id, secondary_type)
                                bonusSec = get_bonus(secondary_type)
				spellhit = stat_add_p(spellhit, secondary_type, bonusSec[:total][:percent])
				
				# tseting new tooltip function
				tooltip, color = tooltip_hit(spellhit, secondary_type, bonusSec, false)
				stat_data.push(:text => "Spellhit", :amount => "%.2f%", :stat => spellhit, :color => color, :tooltip => tooltip)
			end

			expertise = get_stat("melee", "expertise")
			if expertise[:rating] > 26
				stat_data.push(:text => "Expertise", :amount => "%.2f%", :stat => expertise, :color => "red", :tooltip => "Expertise cap is <span class='green'>26</span>, player is <span class='red'>%d</span> expertise (<span class='red'>%.1f</span> rating) over the cap." % [expertise[:rating] - 26, (expertise[:rating] - 26).to_f * 8.2])
			else
				stat_data.push(:text => "Expertise", :amount => "%.2f%", :stat => expertise)
			end
			
		# Healers / Casters
		elsif( talent_base[:type] == "caster" )
			stat_data.push(:text => "Mana", :amount => "%d", :stat => get_stat("character", "mana"), :tooltip_stat => get_stat("base", "intellect"), :tooltip_text => "Intellect", :tooltip_type => :rating)
			
			stat_data.push(:text => "Spell power", :amount => "%d", :stat => get_stat("spell", "healing"), :no_tooltip => true)
			if talent_base[:mp5_healer].nil?
				stat_data.push(:text => "Spirit", :amount => "%d", :stat => get_stat("base", "spirit"), :no_tooltip => true)
			end
			stat_data.push(:text => "Mana per 5", :amount => "%d", :stat => get_stat("spell", "mp5"), :no_tooltip => true)
			stat_data.push(:text => "Haste", :amount => "%.2f%", :is_rating => true, :stat => get_stat("spell", "haste"))
			stat_data.push(:text => "Crit", :amount => "%.2f%", :is_rating => true, :stat => get_highest_stat("spellcrit", "percent"))
                        
			if talent_base[:primary] == "dps"
				#stat_data.push(:text => "Hit", :amount => "%.2f%", :is_rating => true, :stat => get_stat("spell", "hit"))
				# Caster Hit-Cap
				# smb / 17.09.2010
				casterhit = get_stat("spell", "hit")
				#bonusPercent = shown_talent().get_bonus(self.class_id, "SPELLHIT")
                                bonusPercent = get_bonus("SPELLHIT")
                                #
				#casterhit[:percent] = casterhit[:percent] + bonusPercent
				# shadowpriest / druid, +3%
				#casterhit[:percent] = casterhit[:percent] + 3


				casterhit = stat_add_p(casterhit, "SPELLHIT", bonusPercent[:total][:percent])
				#casterhit = stat_add_p(casterhit, "SPELLHIT", 3)

                                tooltip,color = tooltip_hit(casterhit, "SPELLHIT", bonusPercent, true)
                                stat_data.push(:text => "Hit", :amount => "%.2f%", :is_rating => true, :stat => casterhit, :color => color, :tooltip => tooltip)

				if casterhit[:percent] > get_cap_p("SPELLHIT")
					#stat_data.push(:text => "Hit", :amount => "%.2f%", :is_rating => true, :stat => casterhit, :color => "red", :tooltip => "Caster hit cap is <span class='green'>%.1f%</span>, player is <span class='red'>%.1f%</span> hit (<span class='red'>%.1f</span> rating) over the cap (includes bonus hit from raidbuffs/-debuffs)" % [ 	get_cap_p("SPELLHIT").to_f, (casterhit[:percent] - get_cap_p("SPELLHIT")).to_f, (casterhit[:rating] - get_cap_r("SPELLHIT")).to_f ] )
                                        #stat_data.push(:text => "Hit", :amount => "%.2f%", :is_rating => true, :stat => casterhit, :color => color, :tooltip => tooltip)
				else
					#stat_data.push(:text => "Hit", :amount => "%.2f%", :is_rating => true, :stat => casterhit,
					#:tooltip => "%d rating. Includes Bonus hit from talents: <span class='green'>+%.1f%</span> (<span class='green'>+%.1f</span> rating) and raidbuffs/-debuffs" % 
					#[ casterhit[:rating], bonusPercent, p2r(bonusPercent, "SPELLHIT").to_i ])
				end
			end
		end

		return stat_data
	end
	
	def tooltip(child_id)
		# Cache all of the experience info
		experience = self.experiences.find(:first, :conditions => {:child_id => child_id})
		return {:title => "No achievement data found"} if experience.nil?
		
		# Grab general data we need no matter what
		exp_percent = experience.percent || 0
		exp_percent = exp_percent > 1 ? 1 : exp_percent
		exp_required = 0
		
		EXPERIENCE.each do |type, dungeons|
			dungeons.each do |parent|
				parent[:children].each do |child|
					if( child[:data_id] == child_id )
						exp_required = child[:experienced]
						break
					end
				end

				break if exp_required > 0
			end

			break if exp_required > 0
		end

		summary = "Points required: <span class='green'>%d</span> (<span class='%s'>%d%</span> done)" % [exp_required, get_color(exp_percent), (exp_percent * 100)]
		
		# No experience data found, just return the basic data
		#return {:title => summary, :data => "No boss kills found"} if exp_percent == 0
			
		achievement_list = []
		experience.achievement.all(:conditions => {:character_id => self.id, :child_id => child_id}, :include => :achievement_data).each do |data|
			next if data.achievement_data.nil?
			points = data.points
			
			if( data.achievement_data.is_statistic )
				achievement_list.push({:points => points, :kills => data.count, :data => "<span class='green'>#{data.count}</span> #{data.count > 1 ? "kills" : "kill"} (+#{points} points), #{data.achievement_data.name}"})
			else
				achievement_list.push({:achievement => true, :points => points, :data => "<span class='green'>+#{points}</span> points, #{data.achievement_data.name}"})
			end
		end
		
		return {:title => summary, :data => "No stats or achievements found"} if achievement_list.length == 0
		
		achievement_list = achievement_list.sort{ |a, b|
			if a[:achievement] && !b[:achievement]
				-1
			elsif b[:achievement] && !a[:achievement]
				1
			elsif a[:achievement] && b[:achievement]
				a[:points] > b[:points] && -1 || a[:points] < b[:points] && 1 || 0
			else
				a[:kills] > b[:kills] && -1 || a[:kills] < b[:kills] && 1 || 0
			end
		}
				
		achievement_array = []
		achievement_list.each do |list|
			achievement_array.push(list[:data])
		end
		
		return {:title => summary, :data => achievement_array.join("<br />")}
	end
	
	def get_experience
		raid_data, party_data, exp_cache = [], [], {}
		
		# Cache all of the experience info
		self.experiences.each do |data|
			exp_cache[data[:child_id]] = data.percent
		end

		# Now figure out the main stat will show
		# Raid/dungeon data
		EXPERIENCE.each do |type, dungeons|
			# Instance data
			dungeons.each do |parent|
				data = {:name => parent[:name], :icon => parent[:icon], :normal => {}, :heroic => {}}
				
				# Specific 5/10/25 heroic/none heroic data
				is_party = nil
				parent[:children].each do |child|
					percent = exp_cache[child[:data_id]] || 0
					percent = percent > 1 ? 1 : percent
					
					mode_data = data[child[:heroic] && :heroic || :normal]
					mode_data[child[:players]] = {:percent => "%d%" % (percent * 100), :id => child[:data_id], :decimal => percent}
					
					is_party = true if child[:players] == 5
				end
			
				if is_party
					party_data.push(data)
				else
					raid_data.push(data)
				end
			end
		end

		return raid_data.reverse, party_data.reverse
	end
	
	def get_professions
		professions = []
		self.professions.all(:order => "profession_id ASC").each do |profession|
			prof_data = Rails.cache.fetch("char/prof/#{profession.profession_id}", :expires_in => 1.week) do
				{:icon => profession.profession_data.icon, :name => profession.profession_data.name, :profession_id => profession.profession_id}
			end
			
			professions.push({:current => profession.current}.merge(prof_data))
		end
		
		return professions
	end
	
	def get_glyphs
		glyphs_major, glyphs_minor = [], []
		return glyphs_major, glyphs_minor if @talents.length == 0
		
		self.glyphs.all(:conditions => {:group_id => self.current_group}).each do |glyph|
			data = Rails.cache.fetch("char/glyph/#{glyph.glyph_id}", :expires_in => 1.week) do
				{:glyph_id => glyph.glyph_id,
				:name => glyph.glyph_data.name,
				:icon => glyph.glyph_data.icon,
				:is_major => glyph.glyph_data.is_major,
				:spec_type => glyph.glyph_data.spec_type,
				:item_id => glyph.glyph_data.item_id}
			end
					
			if( data[:is_major] ) then
				glyphs_major.push(data)
			else
				glyphs_minor.push(data)
			end
		end
				
		return glyphs_major, glyphs_minor
	end

	def get_equipment
		equip_list = []
				
		item_sets = {}
		equip_hash = {}
		self.equipment.all(:conditions => {:group_id => self.current_group}, :include => [:item, :item_gem1, :item_gem2, :item_gem3, :item_enchant, :spell_enchant]).each do |equipment|
			if equipment.item.nil? || equipment.item.name.nil?
				equip_hash[equipment.equipment_id] = {:error => true}
				equip_list.push({:type => "noData", :slot_id => equipment.equipment_id, :item_id => equipment.item_id})
				next
			end
						
			equip_hash[equipment.equipment_id] = equipment
			
			if !equipment.item.set_name.blank?
				item_sets[equipment.item.set_name] ||= []
				item_sets[equipment.item.set_name].push(equipment.item_id)
			end
		end
		
		ITEMS["ORDERED_SLOTS"].each do |slot_id|
			next if equip_hash[slot_id] && equip_hash[slot_id][:error]
			
			# Empty slot :(
			if Equipment.empty_slot?(equip_hash, slot_id)
				equip_list.push({:type => "missing", :slot_id => slot_id})
				next
			elsif equip_hash[slot_id].nil?
				next
			end
			
			set_name = equip_hash[slot_id].item.set_name
			equip_list.push({:type => "item", :equip => equip_hash[slot_id], :set => set_name && item_sets[set_name]})
		end
						
		return equip_list
	end
	
	def equip_warnings
		# Check profession to find out if they can have Jewelcraft gems
		jc_profession = nil
		self.professions.each do |prof|
			if prof.profession_id == 755 and prof.current >= 370
				jc_profession = true
				break
			end
		end
		
		# Check equipment
		total_gems = 0
		gem_colors = {"red" => 0, "blue" => 0, "yellow" => 0}
		meta_gem = nil

		self.equipment.all(:conditions => {:group_id => self.current_group}, :include => [:item, :item_gem1, :item_gem2, :item_gem3]).each do |equipment|
			# Figure out total # of JC gems
			total_gems += equipment.total_jeweler_gems if !jc_profession.nil?
			
			# Figure out # of each color
			equipment.count_colors(gem_colors)
			if ITEMS["SLOT_TO_ID"][equipment.equipment_id] == "head" && equipment.item_gem1 && equipment.item_gem1.equip_type == "meta"
				meta_gem = MetaGem.find(:first, :conditions => {:item_id => equipment.gem1_id})
			end
		end
		
		# Figure out what to warn for
		warnings = {}

		# Warn for unactivated metas
		if !meta_gem.nil?
			requirements = YAML::load(meta_gem.requirements)
			reqs_failed = []

			requirements.each do |req|
				if req[:type] == "more" and gem_colors[req[:more]] < gem_colors[req[:than]]
					reqs_failed.push({:more => gem_colors[req[:more]], :than => gem_colors[req[:than]], :than_color => req[:than], :more_color => req[:more]})
				elsif req[:type] == "exactly" and gem_colors[req[:exact]] != req[:count]
					if gem_colors[req[:exact]] > req[:count]
						reqs_failed.push({:less => gem_colors[req[:exact]] - req[:count], :color => req[:exact]})
					else
						reqs_failed.push({:more => req[:count] - gem_colors[req[:exact]], :color => req[:exact]})
					end
				elsif req[:type] == "least" and gem_colors[req[:least]] < req[:count]
					reqs_failed.push({:more => req[:count] - gem_colors[req[:least]], :color => req[:least]})
				end
			end
			
			if reqs_failed.length > 0
				warnings["meta"] = reqs_failed
			end
		end
		
		# Add a slight failure if they aren't using all possible jeweler gems
		if !jc_profession.nil? && total_gems < ITEMS["JEWELER_GEM"][:max]
			warnings["jeweler"] = {:found => total_gems}
		end
				
		return warnings
	end

	def get_melee_type(talent_base)
		equip_hash = {}
		meele_type = nil
		secondary_type = nil

		self.equipment.all(:conditions => {:group_id => self.current_group}, :include => [:item]).each do |equipment|
			equip_hash[equipment.equipment_id] = equipment
		end

		# hunter
		if talent_base[:type] == "range"
			melee_type = "MELEEHIT"
		else
			melee_type = Equipment.weapon_type(equip_hash) == 1 ? "MELEEHIT" : "MELEEHITDW"
		end

                if( self.current_role == "enhance-shaman" or
                    self.current_role == "assass-rogue" or 
                    self.current_role == "combat-rogue" or
                    self.current_role == "subtlety-rogue")
                        secondary_type = "SPELLHIT"
                end
                

		return melee_type, secondary_type
	end
	
	def equip_summary
		equip_hash = {}
		
		pvp_total, ilvl_total, equip_total, equip_passed = 0, 0, 0, 0
		gem_total, gem_passed, enchant_total, enchant_passed = 0, 0, 0, 0
		
		self.equipment.all(:conditions => {:group_id => self.current_group}, :include => [:item, :item_gem1, :item_gem2, :item_gem3, :item_enchant, :spell_enchant]).each do |equipment|
			next if equipment.item.nil?
			
			equip_total += 1
			equip_passed += 1 if equipment.valid_equip?(self)
			ilvl_total += equipment.item.score(self.level)
			pvp_total += 1 if equipment.pvp?
			
			if equipment.enchantable?(self)
				enchant_total += 1
				enchant_passed += 1 if equipment.enchant_status(self).blank?
			end
			if equipment.extra_enchantable?(self)
				enchant_total += 1
				enchant_passed += 1 if equipment.enchant_extra_status(self).blank?
			end
			
			gem_total += equipment.total_sockets
			for i in 1..equipment.total_sockets
				gem_passed += 1 if equipment.gem_status(self, i).blank?
			end
			
			equip_hash[equipment.equipment_id] = equipment
		end
		
		# Generate based off any warnings
		warnings = equip_warnings()
		gem_total += 1 if !warnings["jeweler"].nil?
		gem_total += 1 if !warnings["meta"].nil?
		
		# Empty slot :(
		ITEMS["ORDERED_SLOTS"].each do |slot_id|
			if Equipment.empty_slot?(equip_hash, slot_id)
				equip_total += 1
			end
		end
		
		pvp_percent = equip_total > 0 ? (pvp_total / equip_total.to_f) : 0
				
		summary = {}
		summary[:average_ilvl] = equip_total > 0 ? (ilvl_total / equip_total) : 0
		summary[:equip_percent] = equip_total > 0 ? (equip_passed / equip_total.to_f) : 0
		summary[:gem_percent] = gem_total > 0 ? (gem_passed / gem_total.to_f) : 0
		summary[:enchant_percent] = enchant_total > 0 ? (enchant_passed / enchant_total.to_f) : 0
		summary[:is_pvp] = pvp_percent >= config_option("player")["pvpPercent"].to_f ? true : false
		return summary
	end

	def current_group=(group)
		@current_group = group
	end

	def current_group
		return self.active_group if !defined?(@current_group)
		return @current_group
	end	
	
	def current_role=(role)
		@current_role = role
	end
	
	def current_role
		return self.spec_role if !defined?(@current_role)
		return @current_role
	end

	def expired?
		self.inactive.blank? && self.updated_at < config_option("expiration")["characters"].minutes.ago
	end

	def role_name
		base = TALENTS[:base][self.spec_role]
		return TALENTS[:role_names]["unknown"] if base.nil?
		return TALENTS[:role_names][base[:name]]
	end
	
	def role_archetype
		base = TALENTS[:base][self.spec_role]
		return nil if base.nil?
		return "mp5-healer" if !base[:mp5_healer].nil?
		return "spirit-healer" if base[:name] == "healer"
		return base[:name]
	end
	
	def class_token
		return config_option("classToken")[self.class_id]
	end
	
	def class_name
		return config_option("class")[self.class_id]
	end
	
	def faction_name
		return config_option("faction")[self.faction_id]
	end
	
	def faction_token
		return config_option("factionToken")[self.faction_id]
	end
	
	def race_name
		return config_option("race")[self.race_id]
	end
	
	def race_token
		return config_option("raceToken")[self.race_id]
	end
	
	private
	def get_color(percent)
		return percent >= 0.90 && "green" || percent >= 0.60 && "yellow" || percent >= 0.40 && "orange" || "red"
	end

	def get_stat(category, type)
		return !@cache_stats[category].nil? && @cache_stats[category][type] || {:percent => 0, :rating => 0}
	end
	
	def get_highest_stat(category, type)
		return 0 if @cache_stats[category].nil?
		
		highest_stat = nil
		@cache_stats[category].each do |stat_type, stat|
			if highest_stat.nil? || stat[type] > highest_stat[type]
				highest_stat = stat
			end
		end
		
		return !highest_stat.nil? && highest_stat || 0
	end

	def p2r(val, type)
		rating = STATS[:ratings][type][:rating] ?  STATS[:ratings][type][:rating] : 0
		cap = rating * val
		return cap.ceil
	end

	def r2p(val, type)
		rating = STATS[:ratings][type][:rating] ?  STATS[:ratings][type][:rating] : 0
		if rating != 0
			return (val / rating).ceil
		else
			return 0
		end
	end

	def get_cap_p(type)
		return STATS[:caps][type][:percent]
	end

	def get_cap_r(type)
		return STATS[:caps][type][:rating]
	end

	def get_cap_v(type)
		return STATS[:caps][type][:value]
	end

	def statmap(type)
		return STATS[:caps][type][:map] ? STATS[:caps][type][:map] : type
	end

        def shown_talent()
                return self.talents.find(:first, :conditions => {:group => self.current_group})
        end

	def stat_add_p(mystat, type, val)
		mystat[:percent] = mystat[:percent] + val
		mystat[:rating] = mystat[:rating] + p2r(val, statmap(type))

                return mystat
	end

        def bonus_text(data)
                text =  "%s: <span class='green'>+%.1f%% (%.1f rating)</span>" % [ data[:name], data[:percent], data[:rating] ]
                return text
        end

	def get_bonus(type)
		bonus = {}
                bonus[:total] = {}
		bonus[:talent_data] = Array.new(0)
                bonus[:buff_data] = Array.new(0)
                bonus[:talent_total] = {}
                bonus[:buff_total] = {}

		total = 0

		# talent bonus
		bonusRet = shown_talent().get_bonus(self.class_id, type)
		bonusRet.each do |it|
			bhash = it
			bhash[:rating] = p2r(bhash[:percent], statmap(type))

			total = total + bhash[:percent]

			bonus[:talent_data].push(bhash)
		end

		# buff bonus
                if statmap(type) == "SPELLHIT"
        		bonus[:buff_data].push({:percent => 3, :rating => 78, :name => "TestRaidBuff" })
                end

		bonus[:talent_total][:percent] = total
		bonus[:talent_total][:rating] = p2r(total, statmap(type))

		bonus[:buff_total][:percent] = 3
		bonus[:buff_total][:rating] = 79

                bonus[:total][:percent] = bonus[:talent_total][:percent] + bonus[:buff_total][:percent]
                bonus[:total][:rating] = bonus[:talent_total][:rating] +  bonus[:buff_total][:rating]

		return bonus
	end

	def tooltip_hit(hit, type, bonus, primary)
		tooltip = nil
		color = "green"

		if hit[:percent] > get_cap_p(type)
			tooltip = "Hit cap is <span class='green'>%.1f%</span>, player is <span class='red'>%.1f%</span> hit (<span class='red'>%.1f</span> rating) over the cap<br />" % [ get_cap_p(type).to_f, (hit[:percent] - get_cap_p(type)).to_f, (hit[:rating] - get_cap_r(type)).to_f ]

			if(primary)
                                color = "red"
                        else
                                color = "yellow"
                        end
		else
                        tooltip = "%d rating<br />" % [ hit[:rating] ]

			color = "green"
		end

                if bonus[:talent_data].size > 0
                        tooltip << "<br />talent modifiers:<br />"
                        bonus[:talent_data].each do |it|
                                tooltip << bonus_text(it) << "<br />"
                        end
                end

                if bonus[:buff_data].size > 0
                        tooltip << "<br />buff modifiers:<br />"
                        bonus[:buff_data].each do |it|
                                tooltip << bonus_text(it) << "<br />"                                
                        end
                end


		return tooltip, color
	end
end
 
