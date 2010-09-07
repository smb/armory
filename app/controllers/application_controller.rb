# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	helper :all
	helper_method :current_user_session, :current_user, :relative_time, :current_user_is_admin?
	before_filter :activate_authlogic
	
	if RAILS_ENV == "production"
		rescue_from Exception, :with => :render_error
		rescue_from ActionController::UnknownAction, :with => :render_404
		rescue_from ActionController::RoutingError, :with => :render_404
		rescue_from ActionController::MethodNotAllowed, :with => :render_home
		rescue_from ActiveRecord::RecordNotFound, :with => :render_404
	end
	
	private
	def render_home
		flash[:message] = "Only POST requests are allowed on this URL"
		redirect_to root_path
	end
	
	def render_404
		activate_authlogic
		render :template => "errors/404", :status => 404
	end
	
	def render_error(except)
		activate_authlogic

		env = []
		encoded_env = []
		begin
			for header in request.env.select {|k,v| v.is_a?(String)}
				if header[0] and !header[0].match(/^rack/)
					env.push(header.to_json)
					
					if header[0] == "REQUEST_URI" or header[0] == "PATH_INFO" then
						encoded_env.push(([header[0], Base64.encode64(header[1])]).to_json)
					end
				end
			end
			
			raise env.join("\n<br />")
		rescue Exception => e
		end
		
		trace = ActiveSupport::JSON.decode(except.backtrace.inspect.to_s)
		Notifier.deliver_alert("Exception #{except.message}", "Env:<br />#{env}<br /><br />Encoded env:<br />#{encoded_env}<br /><br />Exception: #{except.message}<br /><br />#{trace.join("<br />")}")
		render :template => "errors/500", :status => 500
	end

	def relative_time(time, options = {})
		start_date = Time.new
		delta_minutes = (start_date.to_i - time.to_i).floor / 60
		if delta_minutes.abs <= (8724*60) # eight weeks… I’m lazy to count days for longer than that
			distance = distance_of_time_in_words(delta_minutes);
			if delta_minutes < 0
				"#{distance} from now"
			else
				"#{distance} ago"
			end
		else
			return "on #{time.to_date.to_formatted_s(:db)}"
		end
	end

	def distance_of_time_in_words(minutes)
		case
			when minutes < 1
				"<1 minute"
			when minutes < 50
				minutes > 1 && "#{minutes} minutes" || "#{minutes} minute"
			when minutes < 90
				"about one hour"
			when minutes < 1080
				"#{(minutes / 60).round} hours"
			when minutes < 1440
				"one day"
			when minutes < 2880
				"about one day"
		else
			"#{(minutes / 1440).round} days"
		end
	end

	def current_user_session
		return @current_user_session if defined?(@current_user_session)
		@current_user_session = UserSession.find
	end

	def current_user
		return @current_user if defined?(@current_user)
		@current_user = current_user_session && current_user_session.record
	end
	
	def current_user_is_admin?
		return current_user && !current_user.admin.blank? 
	end
	
	def require_admin_access
		if current_user.nil? || current_user.admin.blank?
			flash[:error] = "You need to be an admin to access this page."
			redirect_to root_path
			return false
		end
		
		return true
	end

	def require_mod_access
		if current_user.nil? || current_user.mod.blank?
			flash[:error] = "You need to be a moderator to access this page."
			redirect_to root_path
			return false
		end
		
		return true
	end
	
	def require_user
		if current_user.nil?
			store_location
			flash[:error] = "You must be logged in to access this page"
			redirect_to "#{login_path}/new"
			return false
		end
	end

	def require_no_user
		if current_user
			redirect_to root_path
			return false
		end
	end

	def store_location
		session[:return_to] = request.request_uri
	end

	def redirect_back_or_default(default)
		redirect_to(session[:return_to] || default)
		session[:return_to] = nil
	end
end
