require "uri"
require "cgi"
require "open-uri"

class ApiController < ApplicationController
	def experience
		character_hash = Character.get_hash(params["region"], params["realm"], params["name"])
		if character_hash.nil?
			exp_data = {:error => "badInput", }
		else
			character = Character.find(:first, :conditions => {:hash_id => character_hash})
			if character.nil?
				exp_data = {:error => "noCharacter"}
			else
				exp_data = {}
				character.experiences.each do |data|
					exp_data[data[:child_id]] = data.percent
				end
			end
		end
			
		if !params["jsonp"].blank?
			exp_data = "#{params["jsonp"]}(#{exp_data.to_json})"
		end

		respond_to do |wants|
			wants.json { render :json => exp_data }
		end
	end
	
	def multi_base
		if params["regions"] && params["names"] && params["realms"] && params["regions"].size > 0 && params["regions"].size == params["names"].size && params["regions"].size == params["realms"].size
			char_data = []
			char_list = []
			params["regions"].size.times do |id|
				hash = Character.get_hash(params["regions"][id], CGI::unescape(params["realms"][id]), CGI::unescape(params["names"][id]))
				char_list.push(hash) if !hash.nil?
				# Hard cap at 30 characters before exiting
				break if id >= 30
			end
			
			Character.find(:all, :conditions => {:hash_id => char_list}, :include => [:talents]).each do |character|
				# No data yet, meaning they're still queued, meaning get out
				if character.has_achievements.blank? || character.has_talents.blank?
					char_list.delete(character.hash_id)
					next
				end
				
				# Remove them from the list of people needing to be queued for new data
				char_list.delete(character.hash_id) if !character.expired?
				
				row = cache("api/base/#{character.cache_key}/0", :expires_in => 48.hours) do
					data = {:region => character.region, :realm => character.realm, :name => character.name, :equip_percent => character.equip_percent, :gem_percent => character.gem_percent, :enchant_percent => character.enchant_percent, :updated_at => character.updated_at.to_s, :level => character.level, :class_name => character.class_name.downcase, :average_ilvl => character.average_ilvl}

					character.talents.each do |talent|
						key = talent.active.blank? ? :secondary : :primary
						data[key] = {:sum_tree => "#{talent.sum_tree1}/#{talent.sum_tree2}/#{talent.sum_tree3}", :spec_role => talent.role_name}
					end
					
					data
				end
				
				char_data.push(row) if !row.nil?
			end
			
			key = Digest::SHA1.hexdigest("api/queue/#{char_list.sort.to_s}")
	 		if char_list.length > 0 and !read_fragment(key, :raw => true, :expires_in => 1.hour)
				write_fragment(key, "1")
				
				parsed_list = {}
				char_list.each do |character_hash|
					match = character_hash.match(/(.+):(.+):(.+)/)
					next if match.size < 4
					parsed_list[character_hash] = {:region => match[1], :realm => match[2], :name => match[3], :character_hash => character_hash, :priority => PRIORITIES[:character]}
				end
				
				DataManager.mass_queue_characters(true, parsed_list)
			end
		else
			char_data = {:error => "unequal"}
		end
		
		if !params["jsonp"].blank?
			char_data = "#{params["jsonp"]}(#{char_data.to_json})"
		end
		
		respond_to do |wants|
			wants.json { render :json => char_data }
			wants.xml { render :xml => char_data }
		end
	end
	
	def get_character(region, realm, name)
		realm = CGI::unescape(realm)
		name = CGI::unescape(name)
		
		character_hash = Character.get_hash(region, realm, name)
		return {"error" => "badInput", "name" => name, "realm" => realm, "region" => region} if character_hash.blank?

		character = Character.find(:first, :conditions => {:hash_id => character_hash})
		if character.nil? || character.expired?
			DataManager.queue_character(:character_hash => character_hash, :region => region, :realm => realm, :name => name, :recache => true)
			queued = Armory::Job.queue_position({:class_name => ["CharacterJob", "TalentJob"], :name_hash => character_hash})
			
			if character.nil?
				return {"queue" => queued, "name" => name, "realm" => realm, "region" => region}
			end
		else
			queued = 0
		end
		
		return cache("api/base/#{character.cache_key}/#{queued > 0 ? 1 : 0}", :expires_in => 1.hour) do
			# No character, check for errors
			if character.has_talents.blank? || character.has_achievements.blank?
				if queued > 0
					return {"queue" => queued, "name" => name, "realm" => realm, "region" => region}
				end

				error = Armory::Error.find(:first, :conditions => {:name_hash => character_hash, :class_name => ["CharacterJob", "TalentJob"]}, :order => "created_at ASC")
				if !error.blank?
					return {"error" => error.error_type, "name" => name, "realm" => realm, "region" => region}
				end
			
				return {"error" => "noCharacter", "name" => name, "realm" => realm, "region" => region}
			end

			data = {"region" => character.region, "realm" => character.realm, "name" => character.name, "equip_percent" => character.equip_percent || 0, "gem_percent" => character.gem_percent || 0, "enchant_percent" => character.enchant_percent || 0, "updated_at" => character.updated_at.to_s, "level" => character.level, "class_name" => character.class_name.downcase, "class" => character.class_name, "average_ilvl" => character.average_ilvl || 0, "faction" => character.faction_name, "faction_token" => character.faction_token, "class_token" => character.class_token, "guild" => character.guild}
			data["queued"] = queued if queued > 0
			
			character.talents.each do |talent|
				key = talent.active.blank? ? "secondary" : "primary"
				data[key] = {"sum_tree" => "#{talent.sum_tree1}/#{talent.sum_tree2}/#{talent.sum_tree3}", "spec_role" => talent.role_name, "unspent" => talent.unspent}
			end
			
			data
		end
	end

	def base
		data = get_character(params["region"], params["realm"], params["name"])
		
		if !params["jsonp"].blank?
			data = "#{params["jsonp"]}(#{data.to_json})"
		end
		
		respond_to do |wants|
			wants.json { render :json => data }
			wants.xml { render :xml => data }
		end
	end

	def powered
		@data = get_character(params["region"], params["realm"], params["name"])
		render :layout => false
	end
	
	def alt_powered
		@data = get_character(params["region"], params["realm"], params["name"])
		render :layout => false
	end
	
	def population
		if config_option("armories").include?(params["region"].upcase)
			stats = cache("api/stats/#{params["region"].downcase}", :expires_in => 23.hours) do
				data = {}
				PopulationStats.find(:all, :conditions => {:region => params["region"].downcase}).each do |population|
					data[population.realm] = {:horde => population.horde || 0, :alliance => population.alliance || 0}
				end	
				
				data
			end
		else
			stats = {:error => "badRegion"}
		end

		if !params["jsonp"].blank?
			stats = "#{params["jsonp"]}(#{stats.to_json})"
		end

		respond_to do |wants|
			wants.json { render :json => stats }
			wants.xml { render :xml => stats }
		end
	end
	
	def claim
		realms = params["realms"].split(",")
		characters = params["characters"].split(",")
		
		if !params["token"].blank? && realms.size > 0 && realms.size == characters.size
			#http://www.wowarmory.com/feeds/private/calendar.ics?cn=Shadow&r=Mal'Ganis&token=a6f9caa69c164ab0a8009fb4bbad5a06
			begin
				retried = nil
				url = URI.escape("http://#{params["region"]}.wowarmory.com/feeds/private/calendar.ics?cn=#{characters.join(",")}&r=#{realms.join(",")}&token=#{params["token"]}&filter=bg+darkmoon+raidReset+holidayWeekly")			
				content = open(url).read
				
				if content.match(/maintenance\.xml/) || content.match(/maintenancelogo\.gif/)
					response = {:error => "maintenance"}
				elsif content.match(/SUMMARY:/)
					response = {:status => "done", :total => characters.length, :characters => []}

					verified = {}
					characters.each_index do |id|
						name = CGI::unescape(characters[id])
						realm = CGI::unescape(realms[id])
						character_hash = Character.get_hash(params["region"], realm, name)
						if !current_user.nil?
							claim = CharacterClaim.find(:first, :conditions => {:character_hash => character_hash})
							if claim.nil?
								claim = CharacterClaim.new
								claim.user_id = current_user.id
								claim.character_hash = character_hash
								claim.is_public = true
								claim.relationship = "main"
								claim.save

								verified[character_hash] = {:realm => realm, :region => params["region"], :name => name, :character_hash => character_hash, :priority => PRIORITIES[:guild_character]}
								
								# This needs to be a little more efficient, but since claiming won't happen often, I'm not too concerned
								character = Character.find(:first, :conditions => {:hash_id => character_hash})
								if !character.nil?
									character.touch
								end
								
								response[:characters].push({:status => "claimed", :name => name, :realm => realm, :region => params["region"]})
							elsif claim.user_id == current_user.id
								response[:characters].push({:status => "selfClaimed", :name => name, :realm => realm, :region => params["region"]})
							else
								response[:characters].push({:error => "already", :name => name, :realm => realm, :region => params["region"]})
							end
						end
					end
					
					DataManager.mass_queue_characters(nil, verified)
				else
					response = {:error => "invalidAuth"}
				end
			rescue EOFError => e
				response = {:error => "eof"}
				if retried.nil?
					retried = true
					retry
				end
			rescue OpenURI::HTTPError => e
				response = {:error => e.io.status[0]}
			rescue Errno::ECONNRESET, Timeout::Error, SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT, Errno::EHOSTUNREACH => e
				response = {:error => e.message}
			end
		else
			response = {:error => "mismatch"}
		end
		
		if !params["jsonp"].blank?
			response = "#{params["jsonp"]}(#{response.to_json})"
		end

		respond_to do |wants|
			wants.json { render :json => response }
			wants.xml { render :xml => response }
		end
	end
end