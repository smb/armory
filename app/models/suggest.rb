class Suggest
	def find(character)
		upgrades = upgrades.merge(find_gems(character, equipment))
		upgrades = upgrades.merge(find_enchants(character, equipment))
		
		return upgrades
	end
	
	def find_gems(character, equipment)
		upgrades = []
		(1..self.total_sockets).each do |index|
			gem_data = self.send("item_gem#{index}")

			status = equipment.gem_status(character, i)
			if status == "missing" or status == "spec"
				Items.find(:all, :conditions => ["equip_type = ? and item_type = ? and spec_type IN (?)", gem_data.equip_type, gem_data.item_type])
			end
		end
		
		return upgrades
	end
	
	def find_enchants(character, equipment)
		upgrades = []
		
		return upgrades
	end
end


