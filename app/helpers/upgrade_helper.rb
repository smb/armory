module UpgradeHelper
	def parse_tooltip(&block)
		html = capture_haml(&block).gsub("\n", '').gsub('\\n', "\n")
		haml_concat "ttlib.showData(#{{:tooltip => html}.to_json});"
	end
	
	def parse_items(items)
		list = []
		items.each do |item|
			list.push({
				:id => item.item_id,
				:name => item.name,
				:icon => item.icon,
				:tooltip => "#{ResourcedbHelper.link(:item_id => item.item_id)}tooltip/js",
				:quality => item.quality,
				:ilvl => item.real_level(config_option("player")["maxlevel"]),
				:spec => item.spec_name,
				:sources => item.item_sources.length})
		end
		
		return list
	end

	def faction_color(faction_id)
		return "blue" if config_option("factionToken")[faction_id] == "alliance"
		return "red" if config_option("factionToken")[faction_id] == "horde"
	end
	
	def class_color(class_id)
		return config_option("classToken")[class_id]
	end
end
