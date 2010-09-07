class Experience < ActiveRecord::Base
	has_many :achievement, :foreign_key => :child_id, :primary_key => :child_id
	
	def self.allocation
		raids, parties = [], []
		achievements = {}
		merge_heroic_names = {}
		
		AchievementData.find(:all, :conditions => ["achievement_id IN (?)", ACHIEVEMENTS[:tracked].keys]).each do |achievement|
			achievements[achievement.achievement_id] = achievement
			achievements[achievement.name] ||= achievement
		end
		
		index = 0
		
		# Raid/party data
		EXPERIENCE.each do |type, dungeons|
			# Instance data
			dungeons.each do |parent|
				index += 1
				summary = {:id => "d#{index}", :name => parent[:name], :icon => parent[:icon], :achievements => {}, :info => {}}
				
				# Specific 5/10/25 heroic/none heroic data
				is_party = nil
				parent[:children].each do |child|
					is_party = true if child[:players] == 5

					child[:achievements].each do |achievement_id, points|
						achievement = achievements[achievement_id]
						next if achievement.nil?

						key = "#{child[:players]}:#{child[:heroic] ? "heroic" : "normal"}"
						summary[:info][key] = {:players => child[:players], :heroic => child[:heroic], :name => parent[:name], :cascade => child[:cascade], :experienced => child[:experienced]}

						summary[:order] ||= []
						summary[:order].push(achievement.name)
						
						summary[:achievements] ||= {}
						summary[:achievements][achievement.name] ||= {}
						summary[:achievements][achievement.name][key] = {:points => points, :achievement_id => achievement_id}
					end
				end
			
				summary[:order] = summary[:order].uniq
				summary[:order] = summary[:order].sort{ |a, b|
					a_data = achievements[a]
					b_data = achievements[b]
					a_points = ACHIEVEMENTS[:tracked][a_data.achievement_id]
					b_points = ACHIEVEMENTS[:tracked][b_data.achievement_id]
					
					if a_data[:is_statistic].blank? && !b_data[:is_statistic].blank?
						-1
					elsif b_data[:is_statistic].blank? && !a_data[:is_statistic].blank?
						1
					else
						 a_points > b_points && -1 || a_points < b_points && 1 || 0
					end
				}
				
				if is_party
					parties.push(summary)
				else
					raids.push(summary)
				end
			end
		end
		
		return raids.reverse, parties.reverse, achievements
	end
end
