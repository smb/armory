class GroupController < ApplicationController
	def make_session
		realms = params["realms"].split(",")
		names = params["names"].split(",")
		if realms.length > 1 && realms.length != names.length
			flash[:error] = "Unbalanced realms and names passed, an equal amount of realms and character names should be passed, separated with a comma."
			redirect_to root_path
			return
		end
		
		character_hashes = []
		names.length.times do |id|
			realm = realms.length == 1 ? realms.first : realms[id]
			hash = Character.get_hash(params["region"], realm, names[id])

			if hash.nil?
				flash[:error] = "Failed to find the realm #{params["region"].upcase}-#{realm.camelize} for #{names[id].capitalize}."
				redirect_to root_path
				return
			end
			
			character_hashes.push(hash)
		end
		
		if character_hashes.length > config_option("group")["cap"]
			flash[:error] = "You can only show #{config_option("group")["cap"]} characters at once using the group feature."
			redirect_to root_path
			return
		end
		
		character_hashes = character_hashes.sort
		session_id = Digest::SHA1.hexdigest(character_hashes.to_s)
		session = GroupSession.find(:first, :conditions => {:session_id => session_id}) || GroupSession.new
		if session.new_record?
			session.session_id = session_id
			session.character_hashes = character_hashes.join("|")
			session.touch
		end
		
		redirect_to group_sum_path(session_id)
		return
	end
	
	def experience
		session = GroupSession.find(:first, :conditions => {:session_id => params["session"]})
		if session.nil?
			render :json => {:error => "noSession"}
			return
		end
		
		dungeon_map = DUNGEONS[:child_maps][params["dungeon"]]
		if dungeon_map.nil?
			render :json => {:error => "noDungeon"}
			return
		end
		
		exp_data = {:data => {}}
		exp_data[:normal_key] = dungeon_map.first
		exp_data[:heroic_key] = dungeon_map.last if dungeon_map.length > 0 
		
		Experience.find(:all, :conditions => ["character_id IN (?) and child_id IN (?)", session.character_ids.split("|"), dungeon_map]).each do |exp|
			exp_data[:data][exp.character_id] ||= []
			
			if exp.child_id == exp_data[:normal_key]
				exp_data[:data][exp.character_id][0] = exp.percent
			else
				exp_data[:data][exp.character_id][1] = exp.percent
			end
		end
		
		render :json => exp_data
	end
	
	def queue
		session = GroupSession.find(:first, :conditions => {:session_id => params["session"]})
		if session.nil?
			render :json => {:error => "noSession"}
			return
		elsif session.queued_hashes.blank?
			render :json => {:count => 0}
			return
		end
		
		queue = {}
		queued_hashes = session.queued_hashes.split("|")

		Armory::Error.count(:all, :conditions => ["name_hash IN (?)", queued_hashes], :group => "error_type").each do |error|
			queue[:multi_errors] ||= []
			queue[:multi_errors].push({:type => error[0], :count => error[1]})
		end
		
		queue[:count] = Armory::Job.queue_position(["class_name IN (?) and name_hash IN (?)", ["CharacterJob", "TalentJob", "AchievementJob"], queued_hashes])
		render :json => queue
	end
	
	def summary
		session = GroupSession.find(:first, :conditions => {:session_id => params["session"]})
		if session.nil?
			flash[:error] = "Invalid group session passed."
			redirect_to root_path
			return
		elsif session.character_hashes.blank? && session.queued_hashes.blank?
			flash[:error] = "No characters found in session."
			redirect_to root_path
			session.delete
			return
		end
		
		@page_hash = Digest::SHA1.hexdigest("group/#{params["session"]}")

		if !session.queued_hashes.blank? && fragment_exist?(@page_hash, :expires_in => 1.hour)
			@queued = Armory::Job.queue_position(["class_name IN (?) and name_hash IN (?)", ["CharacterJob", "TalentJob", "AchievementJob"], session.queued_hashes.split("|")])
			if @queued == 0
				session.queued_hashes = nil
				expire_fragment(@page_hash)
			end
		end
		
		unless read_fragment(@page_hash, :raw => true, :expires_in => 1.hour)
			@characters = []
			char_map = {}
			character_hashes = session.character_hashes.split("|")
			
			Character.find(:all, :select => "id, region, realm, name, hash_id, class_id, average_ilvl, equip_percent, gem_percent, enchant_percent", :conditions => ["hash_id IN (?) AND has_talents = ? AND has_achievements = ?", character_hashes, true, true], :include => :talents).each do |character|
				data = {
					:id => character.id,
					:hash_id => character.hash_id,
					:region => character.region,
					:realm => character.realm,
					:name => character.name,
					:class_token => character.class_token,
					:average => character.average_ilvl,
					:equip => character.equip_percent,
					:gem => character.gem_percent,
					:enchant => character.enchant_percent,
				}
								
				if character.talents.length > 0
					character.talents.each do |talent|
						if !talent.active.blank?
							data[:primary_unspent] = talent.unspent if talent.unspent > 0
							data[:primary_sum] = "#{talent.sum_tree1}/#{talent.sum_tree2}/#{talent.sum_tree3}" if talent.unspent == 0
							data[:primary_tree] = talent.main_tree
							data[:primary_role] = talent.role_name if talent.unspent == 0
						else
							data[:secondary_unspent] = talent.unspent if talent.unspent > 0
							data[:secondary_sum] = "#{talent.sum_tree1}/#{talent.sum_tree2}/#{talent.sum_tree3}" if talent.unspent == 0
							data[:secondary_tree] = talent.main_tree
							data[:secondary_role] = talent.role_name if talent.unspent == 0
						end
					end
				end
				
				char_map[character.id] = data
				character_hashes.delete(character.hash_id)
				@characters.push(char_map[character.id])		
			end
			
			# Check for errors, if we found any that are related to the character not being found
			# then we delete their queue
			if character_hashes.length > 0
				valid_characters = session.character_hashes.split("|")
				Armory::Error.find(:all, :conditions => ["name_hash IN (?) and error_type IN (?)", character_hashes, ["noCharacter", "inactive"]]).each do |error|
					character_hashes.delete(error.name_hash)
					valid_characters.delete(error.name_hash)
				end
				
				session.character_hashes = valid_characters.join("|")
				session.queued_hashes = nil if character_hashes.length == 0
			end
			
			if character_hashes.length > 0
				session.queued_hashes = character_hashes.join("|")
			
				queue = {}
				character_hashes.each do |hash_id|
					region, realm, name = hash_id.split(":")
					queue[hash_id] = {:region => region, :realm => realm, :name => name, :priority => PRIORITIES[:group_character], :character_hash => hash_id}
				end
				
				@queued = DataManager.mass_queue_characters(nil, queue)
			end
			
			session.character_ids = char_map.keys.join("|")
			session.save
		end
		
		if session.character_hashes.blank? && session.queued_hashes.blank?
			flash[:error] = "No characters found in session."
			redirect_to root_path
			session.delete
		elsif session.character_ids.blank?
			render :template => "group/_loading"
			return
		end
	end
end