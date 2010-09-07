class Achievement < ActiveRecord::Base
	has_one :achievement_data, :primary_key => :achievement_id, :foreign_key => :achievement_id
	has_many :achievement_criteria, :primary_key => :achievement_id, :foreign_key => :achievement_id
	
	def points
		points = ACHIEVEMENTS[:tracked][self.achievement_id] * self.count
		cap = ACHIEVEMENTS[:caps][self.achievement_id]
		
		return cap if !cap.nil? && points > cap
		return points
	end
end
