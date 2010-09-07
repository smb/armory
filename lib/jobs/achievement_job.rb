require "nokogiri"

class AchievementJob < Struct.new(:args)
	def get_url
		if args[:job_type] == "statistics"
			return "parse", {:region => args[:region], :page => :statistics, :r => args[:realm], :cn => args[:name], :c => 14807}
		else
			return "parse", {:region => args[:region], :page => :achievements, :r => args[:realm], :cn => args[:name], :c => 168}
		end
	end
	
	def parse(doc, raw_xml)
		if args[:job_type] == "statistics"
			parse_statistics(doc)
		else
			parse_achievements(doc)
		end
		
		if DataManager.achievements_done?(args[:character_hash]) && !@character.nil?
			calculate_exp
		end
	end
	
	def parse_achievements(doc)
		achievement_doc = doc.css("category")
				
		ActiveRecord::Base.transaction do 
			added_ids = []

			@character = Character.find(:first, :conditions => {:hash_id => args[:character_hash]})
			return if @character.nil?
			
			@achieve_cache = {}
			@character.achievements.all(:conditions => ["earned_on is not null"]).each do |data|
				@achieve_cache[data.achievement_id] = data
			end

			#criteria_cache = {}
			#AchievementCriteria.all(:conditions => {:character_id => @character.id}).each do |criteria|
			#	criteria_cache[criteria.meta_id] ||= {}
			#	criteria_cache[criteria.meta_id][criteria.achievement_id] = criteria
			#end
			
			@achieve_data = {}
			AchievementData.all(:conditions => ["is_statistic = ?", false]).each do |data|
				@achieve_data[data.achievement_id] = data
			end
				
			# dateCompleted is not present if it's not been completed
			# <achievement categoryId="168" dateCompleted="2009-12-31T20:39:00-06:00" desc="Use the Dungeon tool to finish random heroic dungeons until you have grouped with 100 random players total." icon="achievement_arena_5v5_3" id="4478" points="30" reward="Reward: Perky Pug" title="Looking For Multitudes">
			# <criteria id="10100" name="Orbit-uary (10 player)"/>
			achievement_doc.css("achievement").each do |achievement|
				achievement_id = achievement.attr("id").to_i
				next if achievement_id == 0 || ACHIEVEMENTS[:tracked][achievement_id].nil?
				
				add_achievement_data(:achievement_id => achievement_id, :name => achievement.attr("title"), :icon => achievement.attr("icon"))
				
				#Grab the criteria to see how far off they are
				# achievement.css("criteria").each do |doc|
					# quantity = doc.attr("quantity").to_i
					# max_quantity = doc.attr("maxQuantity").to_i
					# if max_quantity == 0 or quantity > 0
						# criteria_id = doc.attr("id").to_i
						# criteria = criteria_cache[achievement_id] && criteria_cache[achievement_id][criteria_id] || AchievementCriteria.new
						# criteria.meta_id = achievement_id
						# criteria.achievement_id = criteria_id
						# criteria.character_id = @character.id
						# criteria.quantity = quantity
						# criteria.max_quantity = max_quantity
						# criteria.save
					# end
				# end
			
				# Completed!
				if achievement.attr("dateCompleted")
					add_achievement(:child_id => ACHIEVEMENTS[:relationships][achievement_id], :achievement_id => achievement_id, :earned_on => achievement.attr("dateCompleted"), :count => 1)
					added_ids.push(achievement_id)
				end
			end

			# It's rare that this happens, but clear out any deleted achievements/statistics if they got taken away
			@character.achievements.all(:conditions => ["achievement_id not in (?) and earned_on is not null", added_ids]).each do |achievement|
				achievement.destroy
			end
		end
	end

	def parse_statistics(doc)
		statistic_doc = doc.css("statistic")
		
		ActiveRecord::Base.transaction do 
			added_ids = []

			@character = Character.find(:first, :conditions => {:hash_id => args[:character_hash]})
			return if @character.nil?

			@achieve_cache = {}
			@character.achievements.all(:conditions => ["earned_on is null"]).each do |data|
				@achieve_cache[data.achievement_id] = data
			end
			
			@achieve_data = {}
			AchievementData.all(:conditions => ["is_statistic = ?", true]).each do |data|
				@achieve_data[data.achievement_id] = data
			end
			
			# <statistic id="4047" name="Times completed the Trial of the Grand Crusader (25 player)" quantity="--"/>
			# <statistic id="4074" name="Koralon the Flame Watcher kills (Wintergrasp 10 player)" quantity="5"/>
			# Same ID, different labels/quantities
			# <statistic id="1467" name="Lich King 5-player bosses killed" quantity="833"/>
			# <statistic highest="Prince Keleseth" id="1467" name="Lich King 5-player boss killed the most" quantity="37"/>
			statistic_doc.each do |statistic|
				statistic_id = statistic.attr("id").to_i
				# Bigglesworth is a statistic with no id
				next if statistic_id == 0 || !statistic.attr("highest").blank? || ACHIEVEMENTS[:tracked][statistic_id].nil?
				
				killed = statistic.attr("quantity").to_i
				add_achievement_data(:is_statistic => true, :achievement_id => statistic_id, :name => statistic.attr(:name))

				if killed > 0
					add_achievement(:child_id => ACHIEVEMENTS[:relationships][statistic_id], :achievement_id => statistic_id, :count => killed)
					added_ids.push(statistic_id)
				end
			end

			# It's rare that this happens, but clear out any deleted achievements/statistics if they got taken away
			@character.achievements.all(:conditions => ["achievement_id not in (?) and earned_on is null", added_ids]).each do |achievement|
				achievement.destroy
			end
		end
	end
	
	def calculate_exp
		ActiveRecord::Base.transaction do 
			achievement_list = {}
			@character.achievements.all(:conditions => ["child_id is not null"]).each do |data|
				achievement_list[data.achievement_id] = data
			end

			# Now the fun part, calculate it all
			experience_sum = {}
			EXPERIENCE.each do |key, types|
				types.each do |instance|
					instance[:children].each do |child|
						experience_sum[child[:data_id]] = {:amount => 0, :experienced => child[:experienced]}
						summary = experience_sum[child[:data_id]]

						child[:achievements].each do |achievement_id, amount|
							if achievement_list[achievement_id]
								summary[:amount] = summary[:amount] + achievement_list[achievement_id].points
							end
						end

						if child[:cascade]
							experience_sum[child[:cascade]][:amount] = experience_sum[child[:cascade]][:amount] + summary[:amount]
						end
					end
				end
			end
			
			# Cascading means I have to calculate the percentages after the fact, but will want to add it right now
			exp_cache = {}
			@character.experiences.each do |experience|
				exp_cache[experience.child_id] = experience
			end
			
			experience_sum.each do |child_id, experience_data|
				experience = exp_cache[child_id] || @character.experiences.new
				experience.child_id = child_id
				experience.percent = experience_data[:amount] > 0 ? experience_data[:amount] / experience_data[:experienced].to_f : 0
				experience.save
			end
			
			@character.has_achievements = true
			@character.touch
		end
	end

	private
	def add_achievement(args)
		achievement = @achieve_cache[args[:achievement_id]] || @character.achievements.new
		achievement.achievement_id = args[:achievement_id]
		achievement.earned_on = args[:earned_on]
		achievement.child_id = args[:child_id]
		achievement.count = args[:count]
		achievement.save
	end
	
	def add_achievement_data(args)
		return if @character.region != "us" and @character.region != "eu"
		
		args[:name] ||= ""
		
		players = args[:name].match(/([0-9]+) player/i)
		
		data = @achieve_data[args[:achievement_id]] || AchievementData.new
		data.achievement_id = args[:achievement_id]
		data.name = args[:name].gsub(/\(.+\)$/, "").strip()
		data.icon = args[:icon]
		data.players = players ? players[1].to_i : nil
		data.is_heroic = args[:name].match(/\(heroic/i).nil? ? false : true
		data.is_meta = args[:criteria] && args[:criteria].length > 0 ? true : false
		data.is_statistic = args[:is_statistic].nil? ? false : true
		data.save
	end
end