class ExperienceController < ApplicationController
	def list
		return unless stale? :etag => [current_user, config_option("version")] 
		unless read_fragment("experience/#{config_option("version")}", :raw => true, :expires_in => 1.week)
			@raids, @parties, @achievements = Experience.allocation
		end
	end
end
