class Enchant < ActiveRecord::Base
	def spec_name
		return ITEMS["NAMES"][self.spec_type]
	end
end
