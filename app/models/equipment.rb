class Equipment < ActiveRecord::Base
	has_one :item, :foreign_key => :item_id, :primary_key => :item_id
	has_one :item_gem1, :class_name => "Item", :foreign_key => :item_id, :primary_key => :gem1_id
	has_one :item_gem2, :class_name => "Item", :foreign_key => :item_id, :primary_key => :gem2_id
	has_one :item_gem3, :class_name => "Item", :foreign_key => :item_id, :primary_key => :gem3_id
	has_one :item_enchant, :class_name => "Item", :foreign_key => :item_id, :primary_key => :enchant_item
	has_one :spell_enchant, :class_name => "Enchant", :foreign_key => :enchant_id, :primary_key => :enchant_spell
	
	def slot_name
		return ITEMS["SLOT_ID_NAMES"][self.item.slot_id] || ITEMS["EQUIP_ID_NAMES"][self.equipment_id]
	end
	
	def slot_pluralize
		return ITEMS["SLOT_PLURALIZE"][self.equipment_id]
	end

	def self.slot_name(id)
		return ITEMS["EQUIP_ID_NAMES"][id]
	end
	
	def self.weapon_type(equip_list)
		if equip_list[16].nil? and !equip_list[15].nil?
			# 2h
			return 1 if !equip_list[15].item.nil? && equip_list[15].item.slot_id == 17
		end
		if !equip_list[15].nil?
			#shield
			return 1 if equip_list[15].item.slot_id == 14
			return 2 if !equip_list[16].nil?
		end

		# DW
		return 2
	end

	def self.empty_slot?(equip_list, equipment_id)
		# 16 is the off hand weapon slot
		if equipment_id == 16 and equip_list[16].nil? and !equip_list[15].nil?
			# slot_id == 17 are two handed weapons by Blizzard standard
			return nil if !equip_list[15].item.nil? && equip_list[15].item.slot_id == 17
		end
		
		return equip_list[equipment_id].nil?
	end
	
	def socket_color(index)
		# We have an "official" socket, check the color
		return self.item["gem#{index}_type"] unless self["gem#{index}_id"].blank?
		# No socket, but we have a gem so it has to be a prismatic
		return "prismatic" unless self["gem#{index}_id"].nil?
		# Nothing... so it's nothing!
		return nil
	end
	
	def gem_color_count(color)
		matches = 0
		matches += 1 if self.item["gem1_type"] == color
		matches += 1 if self.item["gem2_type"] == color
		matches += 1 if self.item["gem3_type"] == color
		return matches
	end
	
	# Total number of gems in an item
	def total_gems
		return (self["gem1_id"].blank? ? 0 : 1) + (self["gem2_id"].blank? ? 0 : 1) + (self["gem3_id"].blank? ? 0 : 1)
	end
	
	# Total number of sockets, ensures things like Belt Buckles are included
	def total_sockets
		sockets = (self["gem1_id"].blank? ? 0 : 1) + (self["gem2_id"].blank? ? 0 : 1) + (self["gem3_id"].blank? ? 0 : 1)
		
		return sockets if self.item.nil? || self.item.sockets.nil?
		return sockets > self.item.sockets ? sockets : self.item.sockets
	end
	
	# Gets the extra gem in a socket, if it exists
	def extra_gem
		return nil if self.item.sockets >= self.total_gems
		return self.item_gem3 if self["gem3_id"]
		return self.item_gem2 if self["gem2_id"]
		return self.item_gem1 if self["gem1_id"]
	end
	
	# Summary of gem colors
	def count_colors(summary)
		(1..self.total_sockets).each do |index|
			gem_data = self.send("item_gem#{index}")
			next if gem_data.nil? || gem_data.equip_type == "meta"
			
			if !ITEMS["GEM_COLORS"][gem_data.equip_type].nil?
				ITEMS["GEM_COLORS"][gem_data.equip_type].each do |color|
					summary[color] += 1
				end
			else
				summary[gem_data.equip_type] += 1
			end
		end
	end
	
	# Total number of jeweler only gems
	def total_jeweler_gems
		return 0 if self.total_gems == 0
		found = 0
		
		(1..self.total_sockets).each do |index|
			gem_data = self.send("item_gem#{index}")
			next if gem_data.nil?
				
			ITEMS["JEWELER_ICON"].each do |icon|
				if gem_data.icon.match(icon)
					found += 1
					break
				end
			end
		end	
		
		return found
	end
	
	def pvp?
		return ITEMS["PVP_TYPES"].include?(self.item.spec_type)
	end
	
	def enchantable?(character)
		equip_type = ITEMS["SLOT_TO_TYPE"][self.equipment_id]
		# Belts can be enchanted, but extra_enchantable? handles that. Trinkets can never be enchanted. Nor can type 23 which is offhands
		if( equip_type == "belt" or equip_type == "trinket" or equip_type == "neck" or self.item.item_type == "relic" or self.item.slot_id == 23 )
			return nil
		# Ranged weapons need to be enchanted for a Hunter, we don't care about anyone else
		elsif( equip_type == "range" )
			return character.class_token == "hunter" ? true : nil
		# Everything else can be enchanted
		elsif( equip_type != "ring" )
			return true		
		end
				
		# Enchanters can do ring enchants
		character.professions.each do |prof|
			if prof.profession_id == 333 and prof.current >= 360
				return true
			end
		end
		
		return nil
	end
	
	def extra_enchantable?(character)
		slot = ITEMS["SLOT_TO_ID"][self.equipment_id]
		return nil if slot != "belt" and slot != "wrist" and slot != "hands"

		if character.level >= 70
			return true if slot == "belt"
			
			character.professions.each do |prof|
				if prof.profession_id == 164 and prof.current >= 400
					return true
				end
			end
		end
		
		return nil
	end

	# Basic logic is this:
	# The item has more than one socket, and the total number of gems is equal to the number of detected sockets
	# OR, the item has no gems and no detected sockets
	# Detected sockets as in, an empty belt buckle shows no socket at all, not even an empty one
	# can_have_extra makes sure the item, can in fact, have an extra socket
	def has_extra_socket?(character)
		if self.item.nil? or ( self.item.sockets > 0 and self.total_gems == self.item.sockets ) or ( self.item.sockets == 0 and self.total_gems == 0 )
			return nil
		end
		
		return true
	end
	
	def gem_status(character, index)
		gem_id = self["gem#{index}_id"]
		gem_data = self.send("item_gem#{index}")
		if gem_id.nil? or gem_data.nil?
			return "missing"
		end	
		
		# We have a gem quality requirement, and the gems quality is below our requirement
		if ITEMS["GEM_QUALITIES"][self.item.quality] and gem_data.quality < ITEMS["GEM_QUALITIES"][self.item.quality]
			return "quality"
		end
		
		# Make sure it's a valid spec
		specs = ITEMS["TALENT_ROLES"][character.current_role]
		if specs and specs[gem_data.spec_type].nil?
			return "spec"
		end
		
		return nil
	end
			
	def enchant_status(character)
		# It's a normal enchant
		enchant_data = self.spell_enchant || self.item_enchant
		if enchant_data.nil?
			return "missing"
		end
		
		# This isn't 100%, basically. If they are a Death Knight and you are using an item enchant, you aren't using a rune enchant
		# so we can say you are bad. As Death Knight enchants aren't good until 80ish, we will only check this at 80 or above
		if !self.item_enchant.nil? and character.level >= 80 and character.class_token == "deathknight" and ITEMS["SLOT_TO_TYPE"][self.equipment_id] == "weapon"
			return "deathknight"
		end
		
		specs = ITEMS["TALENT_ROLES"][character.current_role]
		if specs and specs[enchant_data.spec_type].nil?
			return "spec"
		end

		return nil
	end
	
	def enchant_extra_status(character)
		slot = ITEMS["SLOT_TO_ID"][self.equipment_id]
		# Everyone can add buckles
		if slot == "belt"
			return "socket" if self.has_extra_socket?(character).nil?
		# Hands and wrists can have additional sockets if they are blacksmithers
		elsif slot == "wrist" or slot == "hands"
			character.professions.each do |prof|
				if prof.profession_id == 164 and prof.current >= 400
					socket = self.has_extra_socket?(character)

					return "socket" if socket.nil?
					return nil
				end
			end
		end

		return nil
	end
	
	def valid_equip?(character)
		specs = ITEMS["TALENT_ROLES"][character.current_role]
		if specs.nil? or self.item.nil? or specs[self.item.spec_type]
			return true
		end
		
		override = ITEMS["ROLE_OVERRIDES"][character.current_role]
		if override and override[:type] == ITEMS["SLOT_TO_TYPE"][self.equipment_id] and override[:roles][self.item.spec_type]
			return true
		end
		
		return nil
	end
end


