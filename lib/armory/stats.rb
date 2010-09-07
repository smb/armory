module Armory
	class Stats < ActiveRecord::Base
		set_table_name :armory_stats
		
		def self.update
			config_option("armories").each do |region|
				stat = find(:first, :conditions => ["region = ? and date = ?", region, self.date]) || self.new
				stat.date = self.date
				stat.region = region
				stat.characters = Character.count(:all, :conditions => ["hash_id LIKE ?", "#{region.downcase}:%"])
				stat.save(false)
				
				puts
			end
		end
		
		def self.date
			return Armory::Node.db_time_now.strftime("%m/%d/%Y")
		end
	end
end
