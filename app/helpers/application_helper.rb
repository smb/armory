require "cgi"
module ApplicationHelper
	def is_mobile_ua?
		return nil if request.user_agent.nil?
		return request.user_agent.match(/Mobile|BlackBerry|Android|Windows CE|CLDC|Opera Mini|Palm|Pre\/1\.0/i) ? true : nil
	end

	def cache_unless(condition, key, *args)
		if !condition.nil?
			yield
		else
			cache(key, *args) do
				yield
			end
		end
	end
	
	def create_unknown_link(character_hash)
		region, realm, name = character_hash.split(":", 3)
		
		return link_to "#{name.capitalize} - #{realm.camelize}", char_profile_path(region, realm, name), {:onmouseout => tooltip_hide, :onmouseover => tooltip_text("Character data is loading")}
	end
	
	def smart_realm
		if !@character.nil?
			return @character.realm
		elsif !@guild.nil?
			return @guild.realm
		else
			return params["guild"] && params["guild"]["realm"] || params["character"] && params["character"]["realm"] || params["realm"]
		end
	end
	
	def smart_region
		region = nil
		if !@character.nil?
		 	region = @character.region
		elsif !@guild.nil?
			region = @guild.region.downcase
		else
			region = params["region"] || params["guild"] && params["guild"]["region"] || params["character"] && params["character"]["region"]
		end
		
		return region.downcase if !region.blank?
	end
	
	def smart_character
		if !@character.nil?
			return @character.name
		elsif params["controller"] == "character"
			return params["name"]
		else
			return params["character"] && params["character"]["name"]
		end
	end
	
	def smart_guild
		if !@character.nil? && !@character.guild.blank?
			return @character.guild
		elsif !@guild.nil?
			return @guild.name
		elsif params["controller"] == "guild"
			return params["name"]
		else
			return params["guild"] && params["guild"]["name"]
		end
	end
	
	def smart_archetype
		#params["item"] && !params["item"]["spec_type"].blank? && params["item"]["spec_type"] || "all"
		if @character.nil?
			return "all" if params["item"].nil? || params["item"]["spec_type"].blank?
			return params["item"]["spec_type"]
		else
			return @character.role_archetype
		end
	end
	
	def is_active?(type)
		if flash[:tab_type]
			return flash[:tab_type] == type
		end
		
		return true if params["controller"] == type
		return true if type == "name" && params["controller"] != "upgrade" && params["controller"] != "guild"
	end


	def percent_color(percent)
		return nil if percent.nil?
		return percent >= 0.9 && "green" || percent >= 0.6 && "yellow" || percent >= 0.4 && "orange" || "red"
	end
	
	def talent_color(talent, is_active)
		return "green" unless is_active.nil?
		return "red" if talent.unspent > 0
	end
	
	def ilvl_color(ilvl)
		return ITEMS["QUALITY_COMMON"] if ilvl.nil?
		return ilvl >= 270 && ITEMS["QUALITY_LEGENDARY"] || ilvl >= 200 && ITEMS["QUALITY_EPIC"] || ilvl >= 180 && ITEMS["QUALITY_RARE"] || ilvl >= 140 && ITEMS["QUALITY_UNCOMMON"] || ITEMS["QUALITY_COMMON"]
	end
	
	
	def tooltip_text(msg)
		return "ttlib.showText('#{escape_javascript(msg)}');"
	end
	
	def tooltip_ajax(url)
		return "ttlib.requestTooltip('#{escape_javascript(url)}');"
	end
	
	def tooltip_hide
		return "ttlib.hide();"
	end
end