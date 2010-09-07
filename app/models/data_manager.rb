require "yaml"

class DataManager
	def self.mass_queue_spiders(args)
		ActiveRecord::Base.transaction do
			list = []
			args[:max_pages].times do |page|
				if page > 1
					list.push(page)
				end
			end
			
			list.sort_by{ rand() }.each do |page|
				args[:page] = page
				Armory::Job.enqueue(ArmorySpiderJob, :passed_args => args, :priority => PRIORITIES[:spider_arena], :name_hash => args[:region])
			end
		end
	end

	def self.queue_spider(args)
		hash = "#{args[:region]}:#{args[:battlegroup]}:#{args[:bracket]}".downcase
		queued = Armory::Job.find(:first, :conditions => {:class_name => "ArmorySpiderJob", :name_hash => hash, :numerical_id => args[:page]})	
		if !queued.nil?
			return
		end
		
		Armory::Job.enqueue(ArmorySpiderJob, :passed_args => args, :priority => PRIORITIES[:spider_arena], :name_hash => args[:region])
	end
	
	def self.queue_guild_spider(args)
		# Bump the priority up to the character level
		priority = args[:priority] || (args[:active].blank? ? PRIORITIES[:spider_guild] : PRIORITIES[:character])

		queued = Armory::Job.find(:first, :conditions => {:class_name => "GuildSpiderJob", :guild_hash => args[:guild_hash]})	
		if !queued.nil?
			if queued.priority < priority
				queued.priority = priority
				queued.yaml_args = args.to_yaml
				queued.save
			end
			return
		end
		
		if !args[:active].blank?
			Armory::Error.destroy_all(:guild_hash => args[:guild_hash])
		end
		
		Armory::Job.enqueue(GuildSpiderJob, :passed_args => args, :priority => priority, :guild_hash => args[:guild_hash])
	end

	def self.queue_arena_spider(args)
		hash = "#{args[:region]}:#{args[:battlegroup]}:#{args[:team_name]}:#{args[:realm]}:#{args[:bracket]}".downcase
		queued = Armory::Job.find(:first, :conditions => {:class_name => "ArenaSpiderJob", :name_hash => hash})
		if !queued.nil?
			return
		end
		
		Armory::Job.enqueue(ArenaSpiderJob, :passed_args => args, :priority => PRIORITIES[:spider], :name_hash => args[:region])
	end
	
	def self.queue_battlegroups(args)
		queued = Armory::Job.find(:first, :conditions => {:class_name => "BattlegroupJob", :name_hash => args[:name_hash]})	
		if !queued.nil?
			return
		end
		
		Armory::Job.enqueue(BattlegroupJob, :passed_args => args, :priority => PRIORITIES[:battlegroup], :name_hash => args[:name_hash], :local_only => true)
	end

	# Queues are by hash when I have access to id because the hash an index on it, while the ids do not
	def self.mass_queue_characters(recache, characters)
		return nil if characters.length == 0
		ActiveRecord::Base.transaction do
			# Remove anything who hasn't expired yet, if we aren't forcing a recache
			if recache.blank?
				Character.find(:all, :conditions => {:hash_id => characters.keys}).each do |char|
					if !char.expired?
						characters.delete(char.hash_id)
					end
				end
			end
		
			return nil if characters.length == 0
			
			# Remove anything who is already queued, also bump priorities and update our metadata if we have an existing queue
			Armory::Job.find(:all, :conditions => {:class_name => ["CharacterJob", "TalentJob"], :name_hash => characters.keys}).each do |job|
				args = characters[job.name_hash]
				if args && ( job.guild_hash.blank? || job.priority < args[:priority] )
					job.guild_hash = args[:guild_hash]
					job.priority = args[:priority] if job.priority < args[:priority]
					job.yaml_args = args.to_yaml
					job.save
				end

				characters.delete(job.name_hash)
			end
		
			return nil if characters.length == 0

			Armory::Error.destroy_all(:name_hash => characters.keys)
			characters.each do |character_hash, args|
				Armory::Job.enqueue(CharacterJob, :passed_args => args, :name_hash => character_hash, :guild_hash => args[:guild_hash], :priority => args[:priority] || PRIORITIES[:spider_character])
			end
			
			return true
		end
	end
	
	def self.queue_character(args)
		character = Character.find(:first, :conditions => {:hash_id => args[:character_hash]})
		# We have character data, it's not expired, and we aren't forcing a recache
		if character and !character.expired? and args[:recache].blank?
			return
		end

		if args[:priority].nil?
			args[:priority] = args[:guild_hash] ? PRIORITIES[:guild_character] : PRIORITIES[:character]
		else
			args[:check_login] = true
		end
		
		queued = Armory::Job.find(:first, :conditions => {:class_name => "CharacterJob", :name_hash => args[:character_hash]})	
		if !queued.nil?
			# If the queued priority is lower, force the character into a higher priority
			if queued.priority.nil? || queued.priority < args[:priority]
				queued.priority = args[:priority]
				queued.guild_hash ||= args[:guild_hash]
				queued.yaml_args = args.to_yaml
				queued.save
			end
			return
		# If we have another job that's related to the players original queue then don't bother requeuing, as it's a waste.
		elsif Armory::Job.exists?(["class_name in (?) and name_hash = ?", ["AchievementJob", "TalentJob"], args[:character_hash]])
			# Force them into a higher priority bracket if they aren't already
			Armory::Job.update_all(["priority = ?", args[:priority]], ["class_name in (?) and name_hash = ? and priority < ?", ["AchievementJob", "TalentJob"], args[:character_hash], args[:priority]])
			return
		end
		
		Armory::Error.destroy_all(:name_hash => args[:character_hash])
		#Armory::Job.destroy_all(:job_type => ["achievements", "statistics", "talents"], :name_hash => args[:character_hash])
		Armory::Job.enqueue(CharacterJob, :passed_args => args, :priority => args[:priority], :name_hash => args[:character_hash], :guild_hash => args[:guild_hash])
	end
	
	def self.queue_achievements(args)
		queued = Armory::Job.find(:first, :conditions => {:job_type => "achievements", :name_hash => args[:character_hash]})	
		if !queued.nil?
			return
		end
		
		args[:job_type] = "achievements"
		Armory::Job.enqueue(AchievementJob, :passed_args => args, :job_type => "achievements", :priority => args[:priority] || PRIORITIES[:achievements], :name_hash => args[:character_hash], :guild_hash => args[:guild_hash])
	end
	
	def self.queue_statistics(args)
		queued = Armory::Job.find(:first, :conditions => {:job_type => "statistics", :name_hash => args[:character_hash]})	
		if !queued.nil?
			return
		end
		
		args[:job_type] = "statistics"
		Armory::Job.enqueue(AchievementJob, :passed_args => args, :job_type => "statistics", :priority => args[:priority] || PRIORITIES[:achievements], :name_hash => args[:character_hash], :guild_hash => args[:guild_hash])
	end
	
	# Jobs are removed after parsing, if we have 2 jobs, then we're not done, if we have 1 then we're done cause it'll be removed on finish
	def self.achievements_done?(character_hash)
		count = Armory::Job.count("class_name", :conditions => ["class_name = ? and name_hash = ?", "AchievementJob", character_hash])	
		return count == 1 ? true : false
	end
	
	def self.queue_reputation(args)
		queued = Armory::Job.find(:first, :conditions => {:class_name => "ReputationJob", :name_hash => args[:character_hash]})	
		if !queued.nil?
			return
		end
		
		Armory::Job.enqueue(ReputationJob, :passed_args => args, :priority => args[:priority] || PRIORITIES[:reputation], :name_hash => args[:character_hash])
	end
		
	def self.queue_talents(args)
		queued = Armory::Job.find(:first, :conditions => {:class_name => "TalentJob", :name_hash => args[:character_hash]})	
		if !queued.nil?
			return
		end
		
		Armory::Job.enqueue(TalentJob, :passed_args => args, :priority => args[:priority] || PRIORITIES[:talents], :name_hash => args[:character_hash], :guild_hash => args[:guild_hash])
	end
	
	def self.recache_items
		ActiveRecord::Base.transaction do
			items = Item.all
			items.each do |item|
				Armory::Job.enqueue(ItemIdentifyJob, :passed_args => {:item_id => item.item_id}, :priority => PRIORITIES[:active_spider], :numerical_id => item.item_id, :local_only => true)
				Armory::Job.enqueue(ItemJob, :passed_args => {:item_id => item.item_id}, :priority => PRIORITIES[:active_spider], :numerical_id => item.item_id, :local_only => true)
			end
		end
	end
	
	def self.mass_queue_reagents(item_list)
		return if item_list.size == 0
		
		ActiveRecord::Base.transaction do
			# First, remove anything that we already queued. If either jobs exist then we've already done a check recently
			queue_list = Armory::Job.find(:all, :conditions => ["job_type = ? and numerical_id in (?)", "item-base", item_list.keys])
			queue_list.each do |queue|
				item_list.delete(queue.numerical_id)
			end
			
			# We have nothing left to check
			return if item_list.size == 0
			
			# Now remove anything we have data on
			items = Item.find(:all, :conditions => ["item_id in (?)", item_list.keys])
			items.each do |item|
				# The only time that one check will trigger and the other one doesn't is I manually reset a little piece of data
				if !item.icon.blank?
					item_list.delete(item.item_id)
				end
			end
			
			# Finally, queue up everything we have left
			item_list.each do |item_id, val|
				Armory::Job.enqueue(ItemJob, :passed_args => {:item_id => item_id}, :priority => PRIORITIES[:item], :numerical_id => item_id, :local_only => true)
			end
		end
	end
	
	def self.mass_queue_items(item_list)
		return if item_list.size == 0
		
		ActiveRecord::Base.transaction do
			# First, remove anything that we already queued. If either jobs exist then we've already done a check recently
			queue_list = Armory::Job.find(:all, :conditions => ["class_name in (?) and numerical_id in (?)", ["ItemJob", "ItemIdentifyJob"], item_list.keys])
			queue_list.each do |queue|
				item_list.delete(queue.numerical_id)
			end
			
			# We have nothing left to check
			return if item_list.size == 0
			
			# Now remove anything we have data on
			items = Item.find(:all, :conditions => ["item_id in (?)", item_list.keys])
			items.each do |item|
				# The only time that one check will trigger and the other one doesn't is I manually reset a little piece of data
				if !item.spec_type.blank? && !item.icon.blank?
					item_list.delete(item.item_id)
				end
			end
			
			# Annnd nothing left!
			return if item_list.size == 0
			
			# Finally, queue up everything we have left
			item_list.each do |item_id, key|
				args = {:item_id => item_id, :random => key == 2 ? true : nil}
				Armory::Job.enqueue(ItemIdentifyJob, :passed_args => args, :priority => PRIORITIES[:item], :numerical_id => item_id, :local_only => true)
				Armory::Job.enqueue(ItemJob, :passed_args => args, :priority => PRIORITIES[:item], :numerical_id => item_id, :local_only => true)
			end
		end
	end
	
	def self.queue_item(args)
		return if args[:item_id].nil?
				
		item = Item.find(:first, :conditions => {:item_id => args[:item_id]})
		if item.nil? || item.spec_type.blank? || item.stat_hash.blank? || args[:debug]
			queued = Armory::Job.find(:first, :conditions => {:class_name => "ItemIdentifyJob", :numerical_id => args[:item_id]})	
			if queued.nil?
				Armory::Job.enqueue(ItemIdentifyJob, :passed_args => args, :priority => PRIORITIES[:item], :numerical_id => args[:item_id], :local_only => true)
			end
		end

		if item.nil? || item.icon.blank? || args[:force]
			queued = Armory::Job.find(:first, :conditions => {:class_name => "ItemJob", :numerical_id => args[:item_id]})	
			if queued.nil?
				Armory::Job.enqueue(ItemJob, :passed_args => args, :priority => PRIORITIES[:item], :numerical_id => args[:item_id], :local_only => true)
			end
		end
	end
	
	def self.mass_queue_enchants(enchant_list)
		return if enchant_list.size == 0
		
		ActiveRecord::Base.transaction do
			enchants = Enchant.find(:all, :conditions => ["enchant_id in (?)", enchant_list.keys])
			enchants.each do |enchant|
				if !enchant.spec_type.blank? && !enchant.stat_hash.blank?
					enchant_list.delete(enchant.enchant_id)
				end
			end
			
			return if enchant_list.size == 0
			
			enchant_list.each do |enchant_id, args|
				ItemIdentifyJob.new(args).identify_enchant
			end
		end
	end

	# In reality, this is different from the others, but for the sake of consistency, I'm going to stick it here
	def self.queue_enchant(args)
		return if args[:enchant_id].nil?
		
		enchant = Enchant.find(:first, :conditions => {:enchant_id => args[:enchant_id]})
		if !enchant.nil? and !enchant.spec_type.blank?
			return
		end
		
		ItemIdentifyJob.new(args).identify_enchant
	end
end
