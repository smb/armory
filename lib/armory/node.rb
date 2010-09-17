require "zlib"
require "nokogiri"
require "open-uri"
	
module Armory
	class Node < ActiveRecord::Base
		NODE_CHECK_TIMEOUT = 20.seconds
		NODE_VERSION = 2
		# After this time, ignore a node lock
		MAX_PING_TIME = 30.minutes
		REPING_TIME = 10.minutes
		
		set_table_name :nodes

		attr_accessor :error_code
		cattr_accessor :request_time, :inflate_time, :node_name, :last_page, :last_url
		
		self.node_name = Socket.gethostname
		self.request_time = 0
		self.inflate_time = 0
		
		def after_initialize
			@error_code = 0
		end
				
		# Clear our instances locks
		def self.clear_locks!(worker_name)
			update_all("locked_by = null, locked_at = null", ["locked_by = ?", worker_name])
		end
		
		# Clear all locks by host + worker, but not the pid
		def self.clear_process_locks!(process_name)
			update_all("locked_by = null, locked_at = null", ["locked_by LIKE ?", "#{process_name}:#{self.node_name}%"])
		end
		
		# Clear all locks by the host
		def self.clear_host_locks!
			update_all("locked_by = null, locked_at = null", ["locked_by LIKE ?", "%#{self.node_name}%"])
		end
		
		# Throttling!
		# Each region has it's own throttle limits, so you can request an US and an EU character page without hitting throttles
		# item_info, item_tooltip, arena_ladder, model, feed are not throttled
		# arena team, guild listing, character, reputation, talents, achievements, model are throttled
		PAGE_THROTTLES = {:character => true, :talents => true, :achievements => true, :statistics => true, :guild => true, :battlegroups => true, :reputation => true, :arena_team => true}
		
		def last_has_throttle?
			return nil if self.last_page.nil?
			return PAGE_THROTTLES[self.last_page] || nil
		end
		
		def ping
			if self.locked_at && self.locked_at.to_i < (Node.db_time_now.to_i - REPING_TIME.to_i)
				self.locked_at = Node.db_time_now
				self.save
			end
		end
		
		def inflate_response(response)
			if response.meta["content-encoding"] != "gzip"
				self.inflate_time = -1
				return response.read
			end
			
			begin
				start = Time.now.to_f
				content = Zlib::GzipReader.new(StringIO.new(response.read)).read
				self.inflate_time = Time.now.to_f - start
			# This really shouldn't happen, but if it does, return normally
			rescue Zlib::GzipFile::Error => e
				return response.read
			end
			
			return content
		end
		
		def pull_local_data(args)
			self.last_url = ArmoryHelper.build_url(args)
			return inflate_response(open(self.last_url, "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6", "Accept-Encoding" => "gzip,deflate"))
		end
		
		# Remote nodes only
		def is_up?
			return true if self.remote.blank?
		
			secret_key = self.secret_key.blank? ? "" : "&key=#{self.secret_key}"
			
			self.last_url = "#{self.url}/ea_mirror.php?ping=true&version=#{self.version}#{secret_key}"
			begin
				 content = TimeoutGem.timeout(NODE_CHECK_TIMEOUT) do
					open(self.last_url).read
				end
			rescue Exception => e
				return nil
			end
			
			if content.match(/ERROR:(.-)/)
				raise RequestNodeError.new("Request error: #{content.match(/ERROR:(.-)/)[1]}")
			end

			return content.match(/^PONG/) ? true : nil
		end
		
		def pull_remote_data(args, retried)
			if !self.secret_key.blank?
				args[:key] = self.secret_key
			end
			
			args[:region] = args[:region].downcase
			args[:version] = NODE_VERSION
			
			self.last_url = "#{self.url}/ea_mirror.php?#{ArmoryHelper.build_args(args)}"
			content = inflate_response(open(self.last_url, "Accept-Encoding" => "gzip,deflate"))

			match = !content.blank? && content.match(/RESPONSE:([0-9]+):DATA:(.+)/m)
			if content.blank?
				raise MalformedResponseError.new("No response found")
			elsif content.match(/ERROR:(.-)/)
				raise RequestNodeError.new("Request error: #{content.match(/ERROR:(.-)/)[1]}")
			elsif content.match(/RESPONSE:0:DATA/) && retried.nil?
				raise MalformedResponseError.new("Malformed content: #{content.to_s}")
			elsif match.nil? || match.size <= 1 || match[1].blank? || match[2].blank?
				raise MalformedResponseError.new("Malformed content: #{content.to_s}")
			end
			
			response, data = match[1].to_i, match[2]
			if response.blank?
				raise MalformedResponseError.new("Malformed response code: #{response.to_s}")
			# If a 302 found is given and it's trying to send us to maintenace.xml, it's maintenance!
			elsif response == 302 and ( content.match(/maintenance\.xml/) || content.match(/maintenance.htm/) )
				raise ArmoryParseError.new("maintenance")
			elsif response >= 400
				self.error_code = response
				return nil
			# Given we're parsing XML, if we don't find a single < or >, someting is wrong
			elsif !content.match(/<|>/)
				raise MalformedResponseError.new("Malformed data, no actual content found")
			elsif data.blank?
				raise MalformedResponseError.new("Malformed data: #{data.to_s}")
			end
				
			return data
		end
		
		def pull_data(args)
			self.last_page = args[:page]
			self.error_code = nil
			
			# Keep track of how many requests we have, this will get written when the node pings
			retries = 0
			
			start = Time.now.to_f
			begin
				if self.remote.blank?
					data = pull_local_data(args)
				else
					data = pull_remote_data(args, nil)
				end
			rescue EOFError => e
				return nil
			rescue OpenURI::HTTPError => e
				self.error_code = e.io.status[0]
				raise TemporarilyUnavailableError.new("Code: #{e.io.status[0]} / #{e.message}")
			rescue MalformedResponseError => e
				retries += 1
 				sleep 2
				retry if retries <= 3
			ensure
				self.request_time = Time.now.to_f - start
				if !self.remote.blank?
					now = Node.db_time_now.to_f
					Rails.cache.write("node/last/#{self.id}", now, :expires_in => 2.minutes, :raw => true)
					
					# Reset the throttle, since it should be from the last request
					if self.throttle > 0
						Rails.cache.write("node/lock/#{self.id}", now + self.throttle - 0.5, :expires_in => self.throttle, :raw => true)
					end
				end
			end
			
			# Trying to get around this stupid ban bug
			if self.error_code == 500
				raise TemporarilyUnavailableError.new("Remote code: 500")
			else
				raise RequestNodeError.new("Remote code: #{self.error_code}") unless self.error_code.nil?
			end
			
			# Check the data, make sure the armory isn't under maintenance or the character info is messed
			if !data.blank?
				start = Time.now.to_f
				#The site is down for maintenance. We'll be back soon!
				if data.match(/maintenancelogo\.gif/) || data.match(/thermaplugg\.jpg/)
					raise ArmoryParseError.new("maintenance")
				end
				
				doc = Nokogiri::XML(data)
				if doc.blank?
					self.error_code = 500
					raise TemporarilyUnavailableError.new("500")
				end
				
				if doc.css("errorhtml").length > 0
					raise ArmoryParseError.new(doc.css("errorhtml").attr("type").to_s || "unknown")
				end
				
				character_info = doc.css("characterInfo")
				if character_info.length > 0 && !character_info.attr("errCode").nil?
					error = character_info.attr("errCode").value
					# noCharacter error + basic metadata, means it's an inactive character
					if error == "noCharacter" && character_info.css("character").length > 0
						error = "inactive"
					end
					
					raise ArmoryParseError.new(error)
				end
				
				return doc, data
			end
		end
		
		# Find a speedy node and try to lock it
		def self.find_speedy(worker_name)
			now = self.db_time_now
			
			node = find(:first, :conditions => ["enabled = ? and ( remote = ? or throttle = 0 ) and version >= ? and url = ? and (locked_by is null or locked_at < ?)", true, false, NODE_VERSION, node_name, MAX_PING_TIME.ago])
			return nil if node.nil?
			
			now = Node.db_time_now
			
			# Try and lock the node
			affected_rows = update_all(["locked_by = ?, locked_at = ?", worker_name, now], ["id = ? and locked_by is null", node.id])
			if affected_rows == 1
				node.locked_at = now
				node.locked_by = worker_name
				return node
			end
			
			return nil
		end
		
		def self.find_available
			# So we can figure out when a request was last done, makes it easier to monitor what is running and what isn't
			update_all(["locked_at = ?", Node.db_time_now], ["(enabled = ? or errored = ? ) and remote = ? and version >= ? and throttle > 0", true, true, true, NODE_VERSION])

			nodes = find(:all, :conditions => ["( enabled = ? or errored = ? ) and remote = ? and version >= ? and throttle > 0", true, true, true, NODE_VERSION], :order => "throttle DESC")
			node_list = []
			errored_list = []
			nodes.each do |node|
				if node.is_up?
					node_list.push(node)
					
					if !node.errored.blank?
						node.enabled = true
						node.errored = false
						errored_list.push(node.id)
					end
				end
			end
			
			if errored_list.length > 0
				update_all(["enabled = ?, errored = ?", true, false], ["id in (?)", errored_list])
			end
			
			return node_list if node_list.size > 0
		end
		
		# Handle figuring out what node to use
		def self.rotate(node_list)
			now = self.db_time_now.to_f
			ready_soonest, ready_node = nil, nil
			
			node_list.each do |node|
				# First, check if we have any records
				results = Rails.cache.write("node/lock/#{node.id}", now + node.throttle, :expires_in => node.throttle, :unless_exist => true, :raw => true)
				if !results.blank?
					return node
				end
				
				# Otherwise try and find whatever is going to be ready the soonest
				ready_at = Rails.cache.read("node/lock/#{node.id}", :expires_in => node.throttle, :raw => true)
				# Something changed between the last... split second, rey locking it again
				if ready_at.blank?
					results = Rails.cache.write("node/lock/#{node.id}", self.db_time_now.to_f + node.throttle, :raw => true, :expires_in => node.throttle, :unless_exist => true) 
					return node if !results.blank?
				elsif ready_soonest.nil? || ready_soonest > ready_at.to_f
					ready_soonest = ready_at.to_f
					ready_node = node
				end
			end
			
			if !ready_node.nil?
				# We know a node is going to be ready in a set period of time, so wait for it
				sleep ready_soonest - now if now < ready_soonest
				# Now try and lock it, this will need more improvements to try and multi lock
				results = Rails.cache.write("node/lock/#{ready_node.id}", self.db_time_now.to_f + ready_node.throttle, :raw => true, :expires_in => ready_node.throttle, :unless_exist => true) 
				return ready_node if !results.blank?
			end
			
			return nil
		end

		def self.inspect
			if self.remote
				return "{Node(Remote) #{self.name} | #{self.url} | #{self.throttle}}"
			else
				return "{Node(Local) #{self.name}}"
			end
		end
		
		def self.db_time_now
			(ActiveRecord::Base.default_timezone == :utc) ? Time.now.utc : Time.zone.now
	    end
	end
end
