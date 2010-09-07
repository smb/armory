module ResourcedbHelper
	def self.talent_link(class_token, compressed_data)
		return "http://www.wowhead.com/?talent##{class_token}-#{compressed_data}"
	end
	
	def self.smart_link(args)
		if args.is_a?(Item)
			return "http://www.wowhead.com/item=#{args[:item_id]}"
		elsif args.is_a?(Enchant)
			return args.spell_id.blank? ? "http://www.wowhead.com/search?q=#{args[:name]}" : "http://www.wowhead.com/spell=#{args[:spell_id]}"
		elsif args[:type] == "statistic" || args[:is_statistic]
			return "http://www.wowhead.com/statistic=#{args[:achievement_id] || args[:id]}"
		elsif args[:type] == "achievement" || args[:achievement_id]
			return "http://www.wowhead.com/achievement=#{args[:achievement_id] || args[:id]}"
		elsif args[:type] == "object"
			return "http://www.wowhead.com/object=#{args[:id]}"
		elsif args[:type] == "craft"
			return "http://www.wowhead.com/spell=#{args[:id]}"
		elsif args[:type] == "vendor"
			return "http://www.wowhead.com/npc=#{args[:id]}"
		elsif args[:type] == "quest"
			return "http://www.wowhead.com/quest=#{args[:id]}"
		elsif args[:type] == "drop" && args[:search]
			return "http://www.wowhead.com/search?q=#{args[:name]}#npcs"
		elsif args[:type] == "drop"
			return "http://www.wowhead.com/npc=#{args[:id]}"
		end
	end

	def self.link(args)
		if args[:item_id]
			return "http://www.wowhead.com/item=#{args[:item_id]}"
		elsif args[:statistic_id]
			return "http://www.wowhead.com/statistic=#{args[:statistic_id]}"
		elsif args[:achievement_id]
			return "http://www.wowhead.com/achievement=#{args[:achievement_id]}"
		elsif args[:quest_id]
			return "http://www.wowhead.com/quest=#{args[:quest_id]}"
		elsif args[:npc_id]
			return "http://www.wowhead.com/npc=#{args[:npc_id]}"
		elsif args[:object_id]
			return "http://www.wowhead.com/object=#{args[:object_id]}"
		elsif args[:area_id]
			return "http://www.wowhead.com/zone=#{args[:area_id]}"
		elsif args[:profession_id]
			return "http://www.wowhead.com/skill=#{args[:profession_id]}"
		elsif args[:spell_id]
			return "http://www.wowhead.com/spell=#{args[:spell_id]}"
		end
	end
	
	def self.item_link(character, equipment, item_set)
		# Enchants
		extra = "&"
		
		unless equipment.enchant_spell.blank?
			extra += "ench=#{equipment.enchant_spell}&"
		end
		
		# Gems
		gems = ""
		gems += "#{equipment.gem1_id}:" if equipment.gem1_id
		gems += "#{equipment.gem2_id}:" if equipment.gem2_id
		gems += "#{equipment.gem3_id}:" if equipment.gem3_id
		
		unless gems.blank?
			extra += "gems=#{gems.chop}&"
		end
		
		# Extra gem
		socket_gem = equipment.extra_gem
		if socket_gem
			extra += "sock=#{socket_gem.item_id}&"
		end
		
		# Random suffixes
		unless equipment.random_suffix.blank?
			extra += "rand=#{equipment.random_suffix}&"
		end
		
		# Part of a set
		if item_set
			extra += "pcs=#{item_set.join(":")}&"
		end
		
		# Player level
		extra += "lvl=#{character.level}&"
		
		# Durability
		#if equipment.durability
		#	extra += "durability=#{equipment.durability}&"
		#end
		
		# Professions
		#professions = ""
		#character.professions.each do |data|
		#	professions += "#{data[:profession_id]}:#{data[:current]},"
		#end
		
		# Add runeforging for Death Knights
		#if character.class_token == "deathknight"
		#	professions += "776:1,"
		#end

		#if !professions.blank?
		#	extra += "skills=#{professions}&"
		#end
		
		return "http://www.wowhead.com/item=#{equipment.item_id}#{extra.chop}"
	end
end
