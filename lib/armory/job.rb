require "yaml"
module Armory
	class Job < ActiveRecord::Base
		MAX_RUN_TIME = 60
		JOB_RANDOM_LIMIT = 30
		set_table_name :armory_jobs
		
		def delete_all
			destroy_all()
		end
		
		def self.clear_locks!(worker_name)
			update_all("locked_by = null, locked_at = null", ["locked_by = ?", worker_name])
		end
		
		def self.queue_position(conditions)
			# Find the record we want the queue position of so we have the initial info
			queue = Armory::Job.find(:first, :conditions => conditions, :order => "created_at DESC")
			return 0 if queue.nil?
			
			# Found all the records at our priority level created before us, or those that have a higher priority
			return Armory::Job.count(:all, :conditions => ["(priority = ? and created_at <= ?) or (priority > ?)", queue.priority, queue.created_at, queue.priority])
		end
		
		def unlock
			begin
				self.class.update(self.id, :locked_by => nil, :locked_at => nil, :priority => self.priority, :retries => self.retries)
			rescue ActiveRecord::RecordNotFound
			end
		end
		
		def bump_priority
			# Don't let them get bumped below 2
			self.priority -= 1 if self.priority > 2
			self.unlock
		end
		
		def lock_exclusively!(worker_name)
			# Reduce the chance for conflict errors by indicating we are working on a record
			return nil if Rails.cache.read("worker/#{self.id}", :raw => true, :expires_in => 3.seconds)
			Rails.cache.write("worker/#{self.id}", "1", :raw => true, :expires_in => 3.seconds)
			
			now = self.class.db_time_now
			# We don't own the job, so lock it that we do, provided it's unlocked or it timed out on another worker
			affected_rows = if self.locked_by != worker_name
				self.class.update_all(["locked_at = ?, locked_by = ?", now, worker_name], ["id = ? and (locked_at is null or locked_at < ?)", self.id, now - MAX_RUN_TIME])
			# We own the job already, but it must have crashed. Refresh our lock
			else
				self.class.update_all(["locked_at = ?", now], ["id = ? and locked_by = ?", self.id, worker_name])
			end
						
			# We secured the lock, so lock it to us
			if affected_rows == 1
				self.locked_at = now
				self.locked_by = worker_name
				return true
			end

			Rails.cache.delete("worker/#{self.id}")
			return nil
		end
		
		def aquire_lock?(worker_name)
			#logger.info "#{worker_name}: aquiring lock on #{self.class_name} ##{self.id}"

			# Make sure we got the lock
			unless lock_exclusively!(worker_name)
				logger.warn "#{worker_name}: failed to aquire exclusive lock for #{self.class_name} ##{self.id}"
				return nil
			end
						
			return true
		end
						
		def self.enqueue(klass, args)
			raise NoClassError.new("Jobs must be given a class.") if klass.to_s.empty?
			if args[:priority].nil?
				Notifier.deliver_alert("Nil job priority", "Class: #{klass.to_s}\n\nJob: #{args.to_json}")
			end
						
			create(:region => args[:passed_args] && args[:passed_args][:region], :class_name => klass.to_s, :yaml_args => args[:passed_args].to_yaml, :priority => args[:priority], :job_type => args[:job_type], :name_hash => args[:name_hash], :guild_hash => args[:guild_hash], :numerical_id => args[:numerical_id], :local_only => args[:local_only].nil? ? false : true, :retries => 0)
		end
		
		def self.find_job(node, region)
			text = "(locked_at is null or locked_at < :locked_at)"
			matches = {:locked_at => self.db_time_now - MAX_RUN_TIME}
			
			if !node.remote.blank? && node.trusted.blank?
				text += " and local_only = :local"
				matches[:local] = false
			end
			
			if !region.blank?
				text += " and (region is null or region != :region)"
				matches[:region] = region
			end
			
			records = find(:all, :conditions => [text, matches] , :order => "priority DESC, created_at ASC", :limit => JOB_RANDOM_LIMIT)
			
			# If we can randomize results to reduce conflicts, will do it. But we can only do it if all the results we have are on the same priority scale
			# For the time being, disable the auto unrandomizer
			priority = -1
			records.each do |record|
				if record[:priority] != priority
					if priority >= 0
						return records
					end
					
					priority = record[:priority]
				end
			end
			
			records.sort {|a, b| a.priority <=> b.priority}
			#return records.sort_by{ rand() }
		end


		def inspect
			return "(Job{%s} %s | %s | %s)" % [self.class_name, self.name_hash, self.guild_hash, self.yaml_args.inspect]
		end
	    
		def self.db_time_now
			(ActiveRecord::Base.default_timezone == :utc) ? Time.now.utc : Time.zone.now
	    end
	end
end