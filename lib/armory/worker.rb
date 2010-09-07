require "yaml"
begin
	require "system_timer"
	TimeoutGem = SystemTimer
rescue LoadError
	require "timeout"
	TimeoutGem = Timeout
end

module Armory
	class Worker
		SLEEP_TIME = 5
		WAIT_TIME = 1
		MAX_RETRIES = 5
		MAX_ERRORS = 20
		MAX_TIMEOUTS = 5
		REMOTE_TIMEOUT = 60.seconds.to_i
		LOCAL_TIMEOUT = 60.seconds.to_i
		# How often node list should be repulled
		RESYNC_NODES = 1.hour
		
		attr_accessor :name_prefix, :node_failure
		cattr_accessor :logger, :request_retries
		
		self.request_retries = 0
	    self.logger = if defined?(Merb::Logger)
			Merb.logger
		elsif defined?(RAILS_DEFAULT_LOGGER)
			RAILS_DEFAULT_LOGGER
	    end
		
		def name
			result = "#{@name_prefix}:#{Socket.gethostname}/#{Process.pid}" rescue "#{@name_prefix}:#{Process.pid}"
			return result || "No name"
		end
				
		# Run the actual job
		def run_job(job, node)
			return if @shutdown
			retries = 0
			
			timeout = !node.remote.blank? ? REMOTE_TIMEOUT : LOCAL_TIMEOUT
			
			begin
				return if @shutdown
				klass = job.class_name.constantize
				raise NoClassError.new("Job cannot find class #{job.inspect}.") if klass.to_s.empty?
				
				loaded_class = klass.new(YAML::load(job.yaml_args))
				method, url = loaded_class.get_url
				
				# If a hash is passed as the 2nd argument, it's a request that pulls armory data
				if url.is_a?(Hash)
					doc, raw_xml = TimeoutGem.timeout(timeout) do
						doc, raw_xml = node.pull_data(url)
					end
					
					if doc.blank? || raw_xml.blank?
						job.unlock
						return nil
					end
					
					loaded_class.send(method, doc, raw_xml)
				# Otherwise, just call it directly
				else
					node.last_page = nil
					loaded_class.send(method)
				end
				
				job.delete
				return true
			# Shouldn't happen
			rescue Errno::ECONNRESET => e
				say "#{self.name}: Connection reset by peer"
				job.unlock
			# These are bad, it means something is wrong with a node
			rescue Timeout::Error, SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT, Errno::EHOSTUNREACH, Errno::ENETUNREACH => e
				say "#{self.name}: Timeout error #{e.message}"
				job.unlock
				return nil if node.remote.blank?
				
				# Keep track of node errors, if we get too many than shut it down
				timeouts = Rails.cache.read("node/timeout/#{node.id}", :expires_in => 10.minutes, :raw => true)
				if !timeouts.blank? && timeouts.to_i >= MAX_TIMEOUTS
					node.enabled = false
					node.errored = true
					node.save
				else
					Rails.cache.write("node/timeout/#{node.id}", timeouts.to_i + 1, :expires_in => 10.minutes, :raw => true)
				end
									
				if node.enabled.blank?
					log_exception(job, node, "Node shutdown", e)
					
					if node.remote.blank? || node.throttle == 0
						shutdown
					else
						node_failure = true
						#Rails.cache.write("nodes/resync", Armory::Node.db_time_now, :expires_in => 2.minutes, :raw => true)
					end
				end				
			# Handle an error with a remote nodes request
			rescue Armory::RequestNodeError, RequestNodeError => e
				log_exception(job, node, "Remote node", e)
				job.unlock
				
				# Keep track of node errors, if we get too many than shut it down
				errors = Rails.cache.read("node/errors/#{node.id}", :expires_in => 30.minutes, :raw => true)
				if !errors.blank? && errors.to_i >= MAX_ERRORS
					node.enabled = false
					node.save
				else
					Rails.cache.write("node/errors/#{node.id}", errors.to_i + 1, :expires_in => 30.minutes, :raw => true)
				end
									
				if node.enabled.blank?
					log_exception(job, node, "Shutdown remote", e)
					
					if node.remote.blank? || node.throttle == 0
						shutdown
					else
						node_failure = true
						#Rails.cache.write("nodes/resync", Armory::Node.db_time_now, :expires_in => 5.minutes, :raw => true)
					end
				end
			# Armory temporarily unavailable, not too big of a deal
			rescue TemporarilyUnavailableError => e
				say "#{job.region && job.region.upcase || "??"} Armory temporarily unavailable (#{e.message}) (try ##{job.retries})"
				if loaded_class.respond_to?("handle_temporary")
					error = loaded_class.handle_temporary(node.error_code, job.retries)
					if !error.nil?
						Armory::Error.new(:error_type => error, :class_name => job.class_name, :name_hash => job.name_hash, :guild_hash => job.guild_hash, :numerical_id => job.numerical_id).save
						job.delete
						return nil
					end
				end
				
				# At >= 5 retries, do a priority bump
				job.retries ||= 0
				job.retries += 1
				if job.retries >= 5
					job.retries = 0
					job.bump_priority
				else
					job.unlock
				end

			# Failure in parsing the armory
			rescue ArmoryParseError => e
				say "Armory error in #{job.class_name}, #{e.message} for #{job.name_hash} (#{job.guild_hash}) ##{job.numerical_id}"
				#log_exception(job, node, "Parse exception", e)
				Armory::Error.new(:error_type => e.message, :class_name => job.class_name, :name_hash => job.name_hash, :guild_hash => job.guild_hash, :numerical_id => job.numerical_id).save
				if e.message == "maintenance"
					job.bump_priority
				else
					if loaded_class.respond_to?("handle_error")
						loaded_class.handle_error(e.message)
					end
					job.delete
				end
			rescue ActiveRecord::StatementInvalid => e
				log_exception(job, node, "MySQL Exception", e)
				job.unlock
			# Generic catch-all
			rescue Exception => e
				log_exception(job, node, "Exception", e)
				
				job.retries ||= 0
				job.retries += 1
				
				if job.retries >= 10
					job.bump_priority
				elsif job.retries >= 50
					job.delete
				else
					job.unlock
				end
			end

			return nil
		end
		
		# Lock and get jobs ready to run
		def find_and_lock_job(node, region)
			Armory::Job.find_job(node, region).each do |job|
				return job if job.aquire_lock?(self.name)
			end
			
			return nil
		end
		
		def speedy_worker(node)
			job = find_and_lock_job(node, nil)
	
			loop do
				node.ping
				break if @shutdown || node.enabled.blank?
				
				request_time = nil
				
				if !job.nil?
					start = Time.now.to_f
					self.request_retries = 0
					finished = self.run_job(job, node)
										
					request_time = (Time.now.to_f - start) - node.request_time
					if !finished.nil?
						say "#{name}: Ran #{job.class_name} (#{job.region}), took %.2f seconds (%.2f http, %.2f inflate)" % [Time.now.to_f - start, node.request_time, node.inflate_time]
					else
						say "#{name}: Failed to run #{job.class_name} (#{job.region})"
					end
				# No jobs, so just wait
				else
					say "#{name}: Sleeping for #{SLEEP_TIME} (wait for recheck)"
					sleep SLEEP_TIME
				
					job = find_and_lock_job(node, nil)
					next
				end
				
				# This job had a region and a throttle, try and find a job that bypasses the limits
				if request_time <= WAIT_TIME && !job.region.blank? && node.last_has_throttle?
					job = find_and_lock_job(node, job.region)
				else
					job = nil
				end
				
				# No job found, grab the next then
				if job.nil?
					# No luck grabbing a job, so try again
					if node.last_has_throttle? && ( request_time.nil? || request_time <= WAIT_TIME )
						say "#{name}: Sleeping for #{WAIT_TIME} (throttled page)"
						sleep WAIT_TIME
					end
					
					job = find_and_lock_job(node, nil)
				end
			end
		end
		
		def multi_worker(node_list)
			next_resync = Time.now + RESYNC_NODES + rand(5).minutes
			job, resynced_on, node = nil, nil, nil
			failed_resyncs = 0
			
			# Don't resync if we're starting back up
			resync = Rails.cache.read("nodes/resync", :expires_in => 2.minutes, :raw => true)
			if !resync.blank?
				resync_on = resync
			end
			
			loop do
				break if @shutdown
				
				# Something is triggering a resync of all workers
				force_resync = Rails.cache.read("nodes/resync", :expires_in => 2.minutes, :raw => true)
				if ( !force_resync.blank? && resynced_on != force_resync ) || !node_failure.nil?
					node_failure = nil
					resynced_on = force_resync
					node_list = Armory::Node.find_available()
					next_resync = Time.now + RESYNC_NODES
					
					if !node_list.nil?
						Notifier.deliver_alert("#{self.name} (Resync)", "Resync of all nodes was forced with ID #{force_resync}. Found #{node_list.length} nodes.")
						say "#{self.name}: Resync forced, #{force_resync}, found #{node_list.length} nodes."
					else
						Notifier.deliver_alert("#{self.name} (Resync/No nodes)", "Resync of all nodes was forced with ID #{force_resync}. Could not found any nodes.")
						say "#{self.name}: Resync forced, #{force_resync}, no nodes found, shutting down."
						shutdown
						return
					end
					
				# Times up, need to manually resync
				elsif next_resync < Time.now
					total_nodes = node_list.length
					node_list = Armory::Node.find_available()
					if node_list.nil?
						break if failed_resyncs >= 10

						failed_resyncs += 1
						next
					end
					
					next_resync = Time.now + RESYNC_NODES
					failed_resyncs = 0
					
					
					if node_list.length != total_nodes
						Notifier.deliver_alert("#{self.name} (Ping)", "While pinging, the total nodes changed from #{total_nodes} to #{node_list.length}")
						say "#{self.name}: Total nodes changed while pinging, was #{total_nodes} now #{node_list.length}"
					elsif node_list.length == 0
						Notifier.deliver_alert("#{self.name} (Ping/No nodes)", "Pinging and we didn't find any available nodes, shutting down.")
						say "#{self.name}: Pinged, no nodes found. Shutting down..."
						shutdown
						return
					end
				end
				
				# We have a node list so will be cycling them
				if job.nil?
					# Find a node we can work on
					last_node = node
					node = Armory::Node.rotate(node_list)
					
					if node.nil?
						say "#{self.name}: No nodes found still, retrying in 1 second"
						sleep 1
						retry
					end
					
					if node != last_node
						last_request = Rails.cache.read("node/last/#{node.id}", :expires_in => 2.minutes, :raw => true)
						if !last_request.blank?
							say "#{self.name}: Switched node #{node.name} (#{node.version}) (%.2f ago, %d throttle)" % [Armory::Node.db_time_now.to_f - last_request.to_f, node.throttle]
						else
							say "#{self.name}: Switched node #{node.name} (#{node.version})"
						end
					end
					
					# Now try and grab a job
					job = find_and_lock_job(node, nil)
				end
				
				node.ping
				
				# Found a job, process it
				if !job.nil?
					start = Time.now.to_f
					self.request_retries = 0
					finished = self.run_job(job, node)
										
					if !finished.nil?
						say "#{self.name}: Ran #{job.class_name} (#{job.region}), took %.2f seconds (%.2f http, %.2f inflate)" % [Time.now.to_f - start, node.request_time, node.inflate_time]
					else
						say "#{self.name}: Failed to run #{job.class_name} (#{job.region})"
					end
					
					job = nil
					retry
				end

				# No jobs, wait and try agan
				say "#{self.name}: Sleeping for #{SLEEP_TIME} (wait for recheck)"
				sleep SLEEP_TIME
			end
		end
			
		# Monitor and basically dispatch jobs
		def start
			say "#{self.name}: Starting up..."
			startup
						
			begin
				node = Armory::Node.find_speedy(self.name)
				if node.is_a?(Armory::Node)
					say "#{self.name}: Starting speedy worker #{node.name} (#{node.version})"
				else
					node_list = Armory::Node.find_available()
					
					if node_list.nil?
						say "#{self.name}: No available nodes found, including local"
						return
					else
						say "#{self.name}: Starting multi node, found #{node_list.size} nodes"
					end
				end
			rescue Exception => e
				log_exception(nil, node, "Node lock", e)
			end
			
			unless node or node_list
				say "#{self.name} Failed to find nodes"
				return
			end

			retries = 0
			begin
				if !node.nil?
					self.speedy_worker(node)
				else
					self.multi_worker(node_list)
				end
			# Something bad happened :(
			rescue Exception => e
				log_exception(nil, node, "Catch-all (#{retries})", e)
				
				# Reset our locks, will retry 5 times before we give up
				Armory::Job.clear_locks!(self.name)
				Armory::Node.clear_locks!(self.name)
				
				retries += 1
				retry if retries <= 5
			ensure
				Armory::Job.clear_locks!(self.name)
				Armory::Node.clear_locks!(self.name)
			end
			
			say "#{self.name}: Finished"
		end

	    # Runs all the methods needed when a worker begins its lifecycle.
	    def startup
			enable_gc_optimizations
			register_signal_handlers
			
			if @name_prefix == "armory_worker0"
				Armory::Node.clear_locks!(self.name)
				Armory::Job.clear_locks!(self.name)
			end
	    end

	    def enable_gc_optimizations
			if GC.respond_to?(:copy_on_write_friendly=)
				GC.copy_on_write_friendly = true
			end
		end
		
		def register_signal_handlers
			trap('TERM') { shutdown! }
			trap('INT') { shutdown! }

			begin
				trap('QUIT') { shutdown }
			rescue ArgumentError
			end
		end

	    # Schedule this worker for shutdown. Will finish processing the
	    # current job.
	    def shutdown
			say "#{name}: Exiting..."
			@shutdown = true
	    end

	    # Kill the child and shutdown immediately.
	    def shutdown!
	      shutdown
	    end

		def log_exception(job, node, type, except)
			trace = ActiveSupport::JSON.decode(except.backtrace.inspect.to_s)
			if !job.nil?
				job = job.inspect
			else
				job = "<No job>"
			end
			
			last_url = "<No url>"
			if node.is_a?(Armory::Node)
				last_url = node.last_url if !node.last_url.blank?
			end
			
			say "#{except.class}: #{except.message}"
			say last_url
			say job if !job.nil?
			say trace.join("\n")
			say "---------------------"
			
			if RAILS_ENV == "production"
				Notifier.deliver_alert("#{name} (#{type})", "Job #{job}\n\nURL #{last_url}\n\nNode #{node.inspect}\n\n#{except.class}: #{except.message}\n#{trace.join("\n")}")
			end
		end
		
		def say(text)
			puts text unless @quiet
			logger.info text if logger
		end
	end
end
