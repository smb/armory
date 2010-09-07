require "cgi"
class GuildController < ApplicationController
	def load_guild
		realm = CGI::unescape(params["guild"]["realm"])
		name = CGI::unescape(params["guild"]["name"])
		
		if params["guild"].nil? || name.blank? || params["guild"]["region"].blank? || realm.blank?
			flash[:error] = "Make sure you fill out every field."
		elsif name.mb_chars.length > 24
			flash[:error] = "Guild names cannot be over 24 characters long."
		elsif REALM_DATA["#{params["guild"]["region"]}-#{realm}".downcase].nil?
			flash[:error] = "Unknown realm #{params["guild"]["region"].upcase}-#{realm.camelize}"
		end

		if !flash[:error].blank?
			flash[:tab_type] = "guild"
			redirect_to root_path
			return
		end

		# If the min is higher than the max, silently switch them
		min = params["min"].to_i
		max = params["max"].to_i
		if min > max
			min, max = max, min
		end
		
		if !params["guild"]["recache"].blank?
			DataManager.queue_guild_spider(:region => params["guild"]["region"], :realm => realm, :name => name, :min => min, :max => max, :recache => true, :active => true, :guild_hash => Guild.get_hash(params["guild"]["region"], realm, name))
		end
		
		redirect_to view_guild_filter_path(params["guild"]["region"].upcase, realm.camelize, name.capitalize, min, max)
	end
	
	def queue
		# If we have an error, don't bother we any other queries
		error = Armory::Error.find(:first, :conditions => {:guild_hash => params["hash"], :class_name => "GuildSpiderJob"}, :order => "created_at ASC")
		if !error.nil?
			 render :json => {:error => error[:error_type]}
			 return
		end
		
		queue = {}
		Armory::Error.count(:all, :conditions => {:guild_hash => params["hash"]}, :group => "error_type").each do |error|
			queue[:multi_errors] ||= []
			queue[:multi_errors].push({:type => error[0], :count => error[1]})
		end

		queue[:count] = Armory::Job.queue_position({:class_name => ["GuildSpiderJob", "CharacterJob", "TalentJob", "AchievementJob"], :guild_hash => params["hash"]})
		render :json => queue
	end
	
	def characters
		min = params["min"].to_i || 0
		max = params["max"].blank? ? 9 : params["max"].to_i
		realm = CGI::unescape(params["realm"])
		name = CGI::unescape(params["name"])
		
		if name.blank? || params["region"].blank? || realm.blank?
			flash[:error] = "Make sure you fill out every field."
		elsif name.mb_chars.length > 24
			flash[:error] = "Guild names cannot be over 24 characters long."
		elsif REALM_DATA["#{params["region"]}-#{realm}".downcase].nil?
			flash[:error] = "Unknown realm #{params["region"].upcase}-#{realm.camelize}"
		elsif min.to_i < 0 or min.to_i > 9 or max.to_i > 9
			flash[:error] = "Bad minimum or maximum guild ranks"
		# Silently swap the min/max if one is higher than the other
		elsif min > max
			min, max = max, min
		end
		
		if !flash[:error].blank?
			flash[:tab_type] = "guild"
			redirect_to root_path
			return
		end
				
		@guild_hash = Guild.get_hash(params["region"], realm, name)
		@guild = Guild.find(:first, :conditions => {:hash_id => @guild_hash})
		# If someone views a guild profile, and we have an internal queue on their guild, bump them up to the forefront automatically
		if @guild.nil? || @guild.expired? || Armory::Job.exists?(["guild_hash = ? and priority = ?", @guild_hash, PRIORITIES[:spider]])
			DataManager.queue_guild_spider(:region => params["region"], :realm => realm, :name => name, :min => min, :max => max, :active => true, :guild_hash => @guild_hash)
		end
		
		@queued = Armory::Job.exists?(:guild_hash => @guild_hash)
		if @guild.nil?
			@new_guild = true
			render :template => "guild/_loading"
			return
		end
		
		return unless stale? :etag => [@guild.cache_key, @queued, current_user, config_option("version")]

		@min_rank, @max_rank = min, max
		@extra_id = @queued ? 1 : @guild.updated_at.to_i
		unless read_fragment("#{@guild.id}/#{@extra_id}/#{min}/#{max}", :raw => true, :expires_in => 1.hour)
			if min == 0 and max == 9
				conditions = ["guild_hash = ? and has_achievements = ? and has_talents = ?", @guild_hash, true, true]
			else
				conditions = ["guild_hash = ? and guild_rank >= ? and guild_rank <= ? and has_achievements = ? and has_talents = ?", @guild_hash, min, max, true, true]
			end
			
			@characters = []
			Character.find(:all, :conditions => conditions, :include => [:talents]).each do |character|
				data = {
					:region => character.region,
					:realm => character.realm,
					:name => character.name,
					:rank => character.guild_rank || -1,
					#:class_name => character.class_name,
					:class_token => character.class_token,
					#:spec_role => character.spec_role,
					:average => character.average_ilvl,
					:equip => character.equip_percent,
					:gem => character.gem_percent,
					:enchant => character.enchant_percent,
				}
			
				if character.talents.length > 0
					character.talents.each do |talent|
						if !talent.active.blank?
							data[:primary_unspent] = talent.unspent if talent.unspent > 0
							data[:primary_sum] = "#{talent.sum_tree1}/#{talent.sum_tree2}/#{talent.sum_tree3}"
							data[:primary_tree] = talent.main_tree
							data[:primary_role] = talent.role_name
							#data[:primary_icon] = talent.icon
							#data[:primary_compressed] = talent.compressed_data
						else
							data[:secondary_unspent] = talent.unspent if talent.unspent > 0
							data[:secondary_sum] = "#{talent.sum_tree1}/#{talent.sum_tree2}/#{talent.sum_tree3}"
							data[:secondary_tree] = talent.main_tree
							data[:secondary_role] = talent.role_name
							#data[:secondary_icon] = talent.icon
							#data[:secondary_compressed] = talent.compressed_data
						end
					end
				end
				
				@characters.push(data)				
			end
		end
	end
end
