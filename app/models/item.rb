class Item < ActiveRecord::Base
	has_many :item_sources, :foreign_key => :item_id, :primary_key => :item_id
	has_many :item_reagents, :foreign_key => :item_id, :primary_key => :item_id
	
	def quality_name
		return ITEMS["QUALITIES"][self.quality]
	end
	
	def spec_name
		return ITEMS["NAMES"][self.spec_type] || "Unknown"
	end
		
	def real_level(char_level)
		item_level = self.level
		# Figure out heirlooms item level
		if( self.quality == ITEMS["QUALITY_HEIRLOOM"] )
			item_level = char_level * ITEMS["HEIRLOOM_LEVEL"]
		end
		
		return item_level
	end
	
	def score(char_level)
		item_level = self.level
		# Figure out heirlooms item level
		if( self.quality == ITEMS["QUALITY_HEIRLOOM"] )
			item_level = char_level * ITEMS["HEIRLOOM_LEVEL"]
		end
		
		if( ITEMS["ILVL_MODS"][self.quality] )
			return (ITEMS["ILVL_MODS"][self.quality] * item_level) || 0
		end
		
		return item_level || 0
	end
	
	def self.search(args)
		text = ""
		matches = {}
		if !args[:name].blank?
			text += "name LIKE :name"
			matches[:name] = "%#{args[:name]}%"
		end
		
		if !args[:archetype].blank? && args[:archetype] != "all"
			spec_types = [args[:archetype]]
			ITEMS["SIMILAR_TYPES"][args[:archetype]].each do |spec|
				spec_types.push(spec)
			end
			
			text += " AND " if !text.blank?
			text += "spec_type IN (:types)"
			matches[:types] = spec_types.uniq
		end
		
		total_results = Item.count(:all, :conditions => !text.blank? && [text, matches], :limit => 500)
		return total_results, [] if total_results == 0
		
		items = Item.find(:all, :conditions => !text.blank? && [text, matches], :include => [:item_sources], :order => "level DESC", :limit => (args[:limit] or 50))
		return total_results, items
	end
	
	def get_sources
		source_types = {}
		self.item_sources.all.each do |source|
			source_types[source.source_type] = source
		end
		
		source_totals = {}
		self.item_sources.all(:select => "COUNT(*) as total, source_type", :group => "source_type", :order => "total ASC").each do |source|
			source_totals[source.source_type] = source.total
		end
		
		parsed_sources = []
		source_totals.each do |type, total|
			source = source_types[type]
			heroic = nil
			if source.source_type != "vendor" && source.source_type != "craft"
				heroic = source.is_heroic
			end
			
			parsed_sources.push({	:total => total.to_i,
									:source_type => source.source_type,
									:players => source.players,
									:heroic => heroic,
									:area => source.area,
									:name => source.name,
									:npc_id => source.npc_id})
		end
		
		return parsed_sources
	end
			
	def get_sources_tooltip
		tooltip = []
		overall_total = 0
		last_type = ""
		totals = {}
		
		self.item_sources.all(:order => "source_type ASC, name DESC").each do |source|
			if totals[source.source_type].nil? || totals[source.source_type] <= 10
				if last_type != source.source_type
					total = self.item_sources.count(:all, :conditions => {:source_type => source.source_type})
					overall_total += total
					tooltip.push({:header => true, :total => total, :source_type => source.source_type})
					last_type = source.source_type
				end
				
				tooltip.push({:source_type => source.source_type, :is_heroic => source.is_heroic, :name => source.name, :players => source.players, :area => source.area})
				
				totals[source.source_type] ||= 0
				totals[source.source_type] += 1
			end
		end
		
		return {:data => tooltip}
	end
	
	def get_similar_type(filters)
		similar_types = []
		sim_data = ITEMS["SIMILAR_TYPES"][self.spec_type]
		
		if !sim_data.nil?
			sim_data.each do |spec|
				if spec != self.spec_type
					similar_types.push(spec)
				end
			end
		end

		if filters[:archetype]
			similar_types.push(filters[:archetype])
			if ITEMS["SIMILAR_TYPES"][filters[:archetype]]
				ITEMS["SIMILAR_TYPES"][filters[:archetype]].each do |spec|
					if spec != self.spec_type
						similar_types.push(spec)
					end
				end
			end
		end
				
		text = "spec_type in (:similar_types)"
		matches = {:similar_types => similar_types.uniq}
		return get_item_list(filters, text, matches)
	end

	def get_same_type(filters)
		text = "spec_type = :spec_type"
		matches = {:spec_type => self.spec_type}
		return get_item_list(filters, text, matches)
	end
  
	def get_item_list(filters, text, matches)
		text += " and items.slot_id = :slot_id and items.item_id not in (:item_id) and items.level >= :level"
		matches[:slot_id] = self.slot_id
		matches[:level] = self.level
		matches[:item_id] = self.item_id
		
		if !self.equip_type.blank?
			text += " and items.equip_type = :equip_type"
			matches[:equip_type] = self.equip_type
		end
		
		if !self.faction_id.blank?
			text += " and (items.faction_id is null or items.faction_id = :faction_id)"
			matches[:faction_id] = self.faction_id
		end

		if !self.class_id.blank?
			text += " and (items.class_id is null or items.class_id = :class_id)"
			matches[:class_id] = self.class_id
		end
		
		if !filters[:within].nil? && !self.level.nil?
			text += " and items.level <= :max_level"
			matches[:max_level] = self.level + filters[:within]
		end
		
		if filters[:dungeons] && ( filters[:dungeons][:fiveman] != 1 || filters[:dungeons][:tenman] != 1 || filters[:dungeons][:tfman] != 1 )
			join = :item_sources
			
			text += " and item_sources.players IN (:players)"
			matches[:players] = []
			matches[:players].push(5) if filters[:dungeons][:fiveman] == 1
			matches[:players].push(10) if filters[:dungeons][:tenman] == 1
			matches[:players].push(25) if filters[:dungeons][:tfman] == 1
		else
			join = nil
		end
		
		item_list = []
		item_ids = []
		Item.find(:all, :conditions => [text, matches], :order => "level DESC", :joins => join, :limit => 10).each do |item|
			item_list.push({
				:real_level => item.real_level(config_option("player")["maxlevel"]),
				:item_id => item.item_id,
				:quality => item.quality,
				:icon => item.icon,
				:name => item.name,
				:is_heroic => item.is_heroic,
				:source_total => 0})
			item_ids.push(item.item_id)
		end

		ItemSource.count(:all, :conditions => ["item_id in (?)", item_ids], :group => :item_id).each do |source|
			item_list.each do |item|
				if item[:item_id] == source[0]
					item[:source_total] = source[1]
				end
			end
		end
		
		return item_list
	end
end
