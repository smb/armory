class PopulationStats < ActiveRecord::Base
	def region_name
		return config_option("region")[self.region.downcase]
	end
	
	def alliance_ratio
		return 1 if self.alliance < self.horde or self.horde == 0
		return self.alliance / self.horde.to_f
	end
	
	def horde_ratio
		return 1 if self.horde < self.alliance or self.alliance == 0
		return self.horde / self.alliance.to_f
	end
end
