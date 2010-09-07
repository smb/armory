#require 'rubygems'
require 'daemons'
require 'optparse'

module Armory
	class Command
		SIGNAL = (RUBY_PLATFORM =~ /win32/ ? 'KILL' : 'TERM')

		attr_accessor :worker_count

		def initialize(args)
			@files_to_reopen = []
			@options = {:quiet => true}

			@worker_count = 1

			opts = OptionParser.new do |opts|
				opts.banner = "Usage: #{File.basename($0)} [options] start|stop|run"

				opts.on('-h', '--help', 'Show this message') do
					puts opts
					exit 1
				end
				opts.on('-n', '--number_of_workers=workers', "Number of unique workers to spawn") do |worker_count|
					@worker_count = worker_count.to_i rescue 1
				end
				opts.on("-i", "--worker_index=index", "Worker number to spawn") do |index|
					@index = index.to_i rescue 1
				end
			end
			@args = opts.parse!(args)
		end
		
		def stop_daemon(index)
			#process_name = index == 1 ? "armory_worker" : "armory_worker#{index}"
			process_name = "armory_worker#{index}"
			Armory::Node.clear_process_locks!(process_name)
			
			path = "#{RAILS_ROOT}/tmp/pids/#{process_name}.pid"
			return if !File.exists?(path)
			# Process is still active
			pid = File.new(path, "r").read.to_i
			return if pid == 0 || !Daemons::Pid.running?(pid)
			
			# Kill it
			begin
				Process.kill(SIGNAL, pid)
			rescue Errno::ESRCH => e
				puts "#{e} #{pid}"
				puts "deleting pid-file."
			end
			
			# Poll until we see it's shut down
			30.times do
				break if !Daemons::Pid.running?(pid)
				sleep 1
			end
			
			# Remove the pid ourselves in case something went wrong
			begin
				puts "Trying to delete #{path}"
				File.unlink(path)
			rescue ::Exception
			end
		end
		
		def start_daemon(index)
			ActiveRecord::Base.connection.reconnect!
			stop_daemon(index)
			
			# Now we're good, start the process up
			#process_name = index == 1 ? "armory_worker" : "armory_worker#{index}"
			process_name = "armory_worker#{index}"
			Daemons.run_proc(process_name, :dir => "#{RAILS_ROOT}/tmp/pids", :dir_mode => :normal, :ARGV => @args) do |*args|
				run process_name
			end
			
			# Sleep a second to space out the sleep-and-rechecks, avoids node conflict errors
			sleep 1
		end

		def daemonize
			ObjectSpace.each_object(File) do |file|
				@files_to_reopen << file unless file.closed?
			end
			
			# Figure out what has to be unlocked
			if @args[0] == "start" or @args[0] == "run"
				if @index.nil?
					puts "Spinning up #{@worker_count} workers"
					Armory::Node.clear_host_locks!
				else
					puts "Spinning up worker ##{@index}"
				end
			# Use our own method of killing processes if we're dealing with a specific stop
			elsif @args[0] == "stop"
				if @index.nil?
					puts "Stopping all workers"
					Dir["#{RAILS_ROOT}/tmp/pids/*.pid"].each do |path|
						worker = File.basename(path, ".pid")
						index = 1
						if worker.match(/([0-9]+)$/)
							index = worker.match(/([0-9]+)/)[1].to_i	
						end
						
						puts "Stopping worker #{index}"
						stop_daemon(index)
					end
				else
					puts "Stopping specific worker #{@index}"
					stop_daemon(@index)
				end
				return
			end
			
			if @index.nil?
				worker_count.times do |worker_index|
					start_daemon(worker_index)
				end
			else
				start_daemon(@index)
			end
		end

		def run(worker_name = nil)
			# Re-open file handles
			@files_to_reopen.each do |file|
				begin
					file.reopen File.join(RAILS_ROOT, 'log', 'armory_worker.log'), 'a+'
					file.sync = true
					rescue ::Exception
				end
			end

			Armory::Worker.logger = RAILS_DEFAULT_LOGGER
			Armory::Worker.logger.auto_flushing = true
			ActiveRecord::Base.connection.reconnect!
			worker = Armory::Worker.new
			worker.name_prefix = "#{worker_name}"
			worker.start
		rescue => e
			RAILS_DEFAULT_LOGGER.fatal e
			STDERR.puts e.message
			exit 1
		end
	end
end
