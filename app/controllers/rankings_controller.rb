class RankingsController < ApplicationController
	def regions
		return unless stale? :etag => Rails.cache.fetch("rank/timer/global", :expires_in => 24.hours) do Time.now end
		unless read_fragment("rank/regions", :raw => true, :expires_in => 24.hours)
			@regions = []
			rank = 0
			PopulationStats.find(:all, :select => "region, SUM(horde) as horde, SUM(alliance) as alliance, AVG(average_ilvl) as average_ilvl, AVG(ilvl_change) as ilvl_change", :order => "average_ilvl DESC", :group => "region").each do |ranking|
				next if ranking.region == "cn"
				
				rank += 1
				@regions.push({
					:rank => rank,
					:name => ranking.region_name,
					:region => ranking.region,
					:tothorde => ranking.horde,
					:totall => ranking.alliance,
					:ilvl => ranking.average_ilvl,
					:ratio => ranking.alliance_ratio + ranking.horde_ratio,
					:change => ranking.ilvl_change})
			end
		end
	end
	
	def realm
		@region = params["region"].downcase
		@realm = Character.realm_name(@region, params["realm"])
		return unless stale? :etag => Rails.cache.fetch(Digest::SHA1.hexdigest("rank/realm/timer/#{@region}/#{@realm}"), :expires_in => 24.hours) do Time.now end

		@page_hash = Digest::SHA1.hexdigest("rank/realm/#{@region}/#{@realm}")
		@population = PopulationStats.find(:first, :conditions => {:region => @region, :realm => @realm})
			
		if @population.nil?
			flash[:error] = "Cannot find the realm #{params["region"].upcase}-#{params["realm"].camelize}"
			redirect_to root_path
			return
		end
		
		unless read_fragment(@page_hash, :raw => true, :expires_in => 24.hours)
			@characters = []
			rank = 0
			
			Character.find(:all, :select => "id, region, realm, name, class_id, average_ilvl * ((equip_percent + gem_percent + enchant_percent) / 3) as modified_ilvl, equip_percent, gem_percent, enchant_percent", :conditions => ["region = ? and realm = ? and has_talents = ? and has_achievements = ?", @region, @realm, true, true], :order => "modified_ilvl DESC", :limit => config_option("ranking")["cap"], :include => :talents).each do |character|
				rank += 1
				
				data = {
					:region => character.region,
					:realm => character.realm,
					:name => character.name,
					:rank => rank,
					#:class_name => character.class_name,
					:class_token => character.class_token,
					#:spec_role => character.spec_role,
					:average => character.modified_ilvl.to_f,
					:equip => character.equip_percent,
					:gem => character.gem_percent,
					:enchant => character.enchant_percent
				}
								
				if character.talents.length > 0
					character.talents.each do |talent|
						if !talent.active.blank?
							data[:primary_unspent] = talent.unspent if talent.unspent > 0
							data[:primary_sum] = "#{talent.sum_tree1}/#{talent.sum_tree2}/#{talent.sum_tree3}" if talent.unspent == 0
							data[:primary_tree] = talent.main_tree
							data[:primary_role] = talent.role_name if talent.unspent == 0
							#data[:primary_icon] = talent.icon
							#data[:primary_compressed] = talent.compressed_data
						else
							data[:secondary_unspent] = talent.unspent if talent.unspent > 0
							data[:secondary_sum] = "#{talent.sum_tree1}/#{talent.sum_tree2}/#{talent.sum_tree3}" if talent.unspent == 0
							data[:secondary_tree] = talent.main_tree
							data[:secondary_role] = talent.role_name if talent.unspent == 0
							#data[:secondary_icon] = talent.icon
							#data[:secondary_compressed] = talent.compressed_data
						end
					end
				end
									
				@characters.push(data)				
			end
		end
	end

	def realms
		@region = !params["region"].blank? ? params["region"].downcase : "global"
		return unless stale? :etag => Rails.cache.fetch(Digest::SHA1.hexdigest("rank/realms/timer/#{@region}"), :expires_in => 24.hours) do Time.now end
		
		unless read_fragment("rank/realms/#{@region}", :raw => true, :expires_in => 24.hours)
			query = @region == "global" ? ["region != ?", "cn"] : {:region => @region}
			
			@realms = []
			rank = 0
			PopulationStats.find(:all, :conditions => query, :order => "average_ilvl DESC").each do |ranking|
				alliance_ratio, horde_ratio = 1, 1
				if ranking.alliance > ranking.horde
					alliance_ratio = ranking.alliance / ranking.horde.to_f
				elsif ranking.horde > ranking.alliance
					horde_ratio = ranking.horde / ranking.alliance.to_f
				end
				
				rank += 1
				@realms.push({
					:rank => rank,
					:name => ranking.realm,
					:region => ranking.region,
					:tothorde => ranking.horde,
					:totall => ranking.alliance,
					:ilvl => ranking.average_ilvl,
					:ratio => alliance_ratio + horde_ratio,
					:change => ranking.ilvl_change})
			end
		end
	end
	
	def characters
		@region = !params["region"].blank? ? params["region"].downcase : "global"
		return unless stale? :etag => Rails.cache.fetch(Digest::SHA1.hexdigest("rank/char/timer/#{@region}"), :expires_in => 24.hours) do Time.now end
		unless read_fragment("rank/char/#{@region}", :raw => true, :expires_in => 24.hours)
			@characters = []
			Rankings.find(:all, :conditions => ["primary_rank = ? and region = ?", "character", @region], :include => [{:character => :talents}]).each do |ranking|
				next if ranking.character.nil?
				character = ranking.character

				data = {
					:region => character.region,
					:realm => character.realm,
					:name => character.name,
					:rank => ranking.rank,
					#:class_name => character.class_name,
					:class_token => character.class_token,
					#:spec_role => character.spec_role,
					:average => ranking.average_ilvl,
					:equip => ranking.equip_percent,
					:gem => ranking.gem_percent,
					:enchant => ranking.enchant_percent
				}

				if character.talents.length > 0
					character.talents.each do |talent|
						if !talent.active.blank?
							data[:primary_unspent] = talent.unspent if talent.unspent > 0
							data[:primary_sum] = "#{talent.sum_tree1}/#{talent.sum_tree2}/#{talent.sum_tree3}" if talent.unspent == 0
							data[:primary_tree] = talent.main_tree
							data[:primary_role] = talent.role_name if talent.unspent == 0
							#data[:primary_icon] = talent.icon
							#data[:primary_compressed] = talent.compressed_data
						else
							data[:secondary_unspent] = talent.unspent if talent.unspent > 0
							data[:secondary_sum] = "#{talent.sum_tree1}/#{talent.sum_tree2}/#{talent.sum_tree3}" if talent.unspent == 0
							data[:secondary_tree] = talent.main_tree
							data[:secondary_role] = talent.role_name if talent.unspent == 0
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
