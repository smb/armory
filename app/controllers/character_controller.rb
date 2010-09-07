require "cgi"
class CharacterController < ApplicationController
	def load_char
		name = CGI::unescape(params["character"]["name"])
		realm = CGI::unescape(params["character"]["realm"])
		
		if params["character"].nil? || name.blank? || params["character"]["region"].blank? || realm.blank?
			flash[:error] = "Make sure you fill out every field."
		elsif name.mb_chars.length > 12
			flash[:error] = "Names cannot be over 12 characters long."
		elsif REALM_DATA["#{params["character"]["region"]}-#{realm}".downcase].nil?
			flash[:error] = "Unknown realm #{params["character"]["region"].upcase}-#{realm.camelize}"
		end

		if !flash[:error].blank?
			flash[:tab_type] = "name"
			redirect_to root_path
			return
		end

		if !params["character"]["recache"].blank?
			character_hash = Character.get_hash(params["character"]["region"], realm, name)
			DataManager.queue_character(:character_hash => character_hash, :region => params["character"]["region"], :realm => realm, :name => name, :recache => true)
		end
		
		redirect_to char_profile_path(params["character"]["region"].upcase, realm.camelize, name.capitalize)
	end

	def queue
		# If we have an error, don't bother we any other queries
		hash_id = CGI::unescape(params["hash_id"])
		error = Armory::Error.find(:first, :conditions => {:name_hash => hash_id, :class_name => ["CharacterJob", "TalentJob", "AchievementJob"]}, :order => "created_at ASC")
		if !error.nil?
			 render :json => {:error => error[:error_type]}
			 return
		end
		
		position = Armory::Job.queue_position({:class_name => ["CharacterJob", "TalentJob", "AchievementJob"], :name_hash => hash_id})
		render :json => {:count => position}
	end
	
	def tooltip
		character = Character.find(:first, :conditions => {:hash_id => CGI::unescape(params["character_hash"])})
		if !character.nil?
			@tooltip = character.tooltip(params["child_id"])
		else
			@tooltip = {:title => "No player data found"}
		end
		
		render :layout => false, :template => "layouts/tooltip"
	end
	
	def character
		# Validate the input first
		#name = Iconv.conv('utf-8', 'iso-8859-1', CGI::unescape(params["name"]))
		name = CGI::unescape(params["name"])
		realm = CGI::unescape(params["realm"])
		
		if name.blank? || params["region"].blank? || realm.blank? 
			flash[:error] = "Make sure you fill out every field."
		elsif name.mb_chars.length > 12
			flash[:error] = "Names cannot be over 12 characters long."
		elsif REALM_DATA["#{params["region"]}-#{realm}".downcase].nil?
			flash[:error] = "Unknown realm #{params["region"]}-#{realm}"
		end
		
		if !flash[:error].blank?
			flash[:tab_type] = "name"
			redirect_to root_path
			return
		end
		
		@character_hash = Character.get_hash(params["region"], realm, name)
		@character = Character.find(:first, :conditions => {:hash_id => @character_hash})
		
		# Check if we need to requeue
		if @character.nil? || @character.has_talents.blank? || @character.has_achievements.blank?
			DataManager.queue_character(:character_hash => @character_hash, :region => params["region"], :realm => realm, :name => name, :recache => true)
			@new_user = true
			render :template => "character/_loading"
			return
		elsif @character.expired?
			DataManager.queue_character(:character_hash => @character_hash, :region => params["region"], :realm => realm, :name => name, :recache => true)
		end
		
		@queued = Armory::Job.exists?(:class_name => ["AchievementJob", "CharacterJob", "TalentJob"], :name_hash => @character_hash, :priority => PRIORITIES[:character])
		@active_group = params["group"].to_i > 0 ? params["group"].to_i : @character.active_group
		@active_group = (@active_group > 2 || @active_group < 1) && @character.active_group || @active_group
		
		return unless stale? :etag => [@character.cache_key, @active_group, @queued, current_user, config_option("version")] 
		unless read_fragment("#{@active_group}/#{@character.cache_key}", :raw => true, :expires_in => 1.hour)
			@have_data = @character.equipment.exists?(:group_id => @character.active_group == 1 ? 2 : 1)
			@active_group = @character.active_group if @have_data.blank?
			
			@talents = []
			@active_talents = nil
			@character.talents.all(:order => "active DESC").each do |talent|
				@talents.push(talent)

				if talent.group == @active_group
					@active_talents = talent
					@character.current_group = talent.group
					@character.current_role = talent.spec_role
				end
			end
			
			@title = Rails.cache.fetch("char/title/#{@character.title_id}", :expires_in => 24.hours) do
				title = Title.find_by_title_id(@character.title_id)
				{:location => title.location, :name => title.name}
			end
			
			@equip_summary = @active_talents || {:average_ilvl => 0, :equip_percent => 0, :gem_percent => 0, :enchant_percent => 0}
			@equip_warnings = @character.equip_warnings
			@professions = @character.get_professions
			@equip_list = @character.get_equipment
			@stats = @character.get_stats
			@raid_data, @party_data = @character.get_experience
			@glyphs_major, @glyphs_minor = @character.get_glyphs
			@mains = @character.get_mains
		end
	end
end
