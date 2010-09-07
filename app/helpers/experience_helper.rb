module ExperienceHelper
	def achievement_icon(achievement)
		return achievement.icon.blank? ? "inv_misc_coin_01" : achievement.icon
	end
	
	def achievement_points(data)
		if data.blank?
			return content_tag(:span, "---")
		end
		
		achievement = @achievements[data[:achievement_id]]
		cap = ACHIEVEMENTS[:caps][achievement.achievement_id]
		points = data[:points]
		
		if points > 0 && !cap.nil?
			return content_tag(:span, points, :class => "orange", :onmouseout => tooltip_hide, :onmouseover => tooltip_text("<span class='green'>#{points}</span> points gained per kill, up to a maximum of <span class='green'>#{cap}</span> points."))
		elsif points > 0
			if achievement.is_statistic.blank?
				message = "One time bonus of <span class='green'>#{points}</span> points."
			else
				message = "<span class='green'>#{points}</span> points gained per kill."
			end
			
			return content_tag(:span, points, :class => "green", :onmouseout => tooltip_hide, :onmouseover => tooltip_text(message))
		else
			return content_tag(:span, 0, :class => "red", :onmouseout => tooltip_hide, :onmouseover => tooltip_text("No points are awarded for this achievement."))
		end
	end
	
	def has_cascading?(list)
		list[:info].each do |key, dungeon|
			return true if !dungeon[:cascade].blank?
		end
		
		return nil
	end
	
	def previous_tier(dungeon)
		return "normal #{dungeon[:players]}-man"
	end
	
	def current_tier(dungeon)
		if dungeon[:heroic]
			return "heroic #{dungeon[:players]}-man #{dungeon[:name]}"
		else
			return "normal #{dungeon[:players]}-man #{dungeon[:name]}"
		end
	end
	
	def experienced_text(dungeon)
		if dungeon.nil?
			return content_tag(:span, "---")
		else
			return content_tag(:span, dungeon[:experienced], :class => "green", :onmouseout => tooltip_hide(), :onmouseover => tooltip_text("It takes <span class='green'>#{dungeon[:experienced]}</span> points to be experienced in this dungeon."))
		end
	end
	
	def cascade_text(dungeon)
		if dungeon.nil?
			return content_tag(:span, "---")
		elsif !dungeon[:cascade].blank?
			return content_tag(:span, "Yes", :class => "green", :onmouseout => tooltip_hide(), :onmouseover => tooltip_text("Points gained in #{current_tier(dungeon)} will be carried over the #{previous_tier(dungeon)} dungeon"))
		else
			return content_tag(:span, "No", :class => "red", :onmouseout => tooltip_hide(), :onmouseover => tooltip_text("Points gained in #{current_tier(dungeon)} do not carry over to another."))
		end
	end
end