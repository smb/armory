class HomeController < ApplicationController
	def index
		#return unless stale? :etag => [@posts, @current_user, flash[:error], flash[:message]]
	end
		
	def faq
		return unless stale? :etag => [config_option("version")]
	end

	def powered
		return unless stale? :etag => [config_option("version")]
	end

	def api
		return unless stale? :etag => [config_option("version")]
	end
	
	def stats
		return unless stale? :etag => [config_option("version")]
	end
	
	def mirror
		return unless stale? :etag => [config_option("version")]
	end	
	
	def donate
		return unless stale? :etag => [config_option("version")]
	end
end
