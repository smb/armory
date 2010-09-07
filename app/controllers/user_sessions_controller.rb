class UserSessionsController < ApplicationController
	before_filter :require_no_user, :only => [:new, :create]
	before_filter :require_user, :only => :destroy
	
	def new
		@user_session = UserSession.new
	end
	
	def create
		@user_session = UserSession.new(params[:user_session])
		@user_session.save do |result|
			if result
				flash[:message] = "You have been logged in!"
				redirect_to root_path
			else
				render :action => :new
			end
		end
	end

	def destroy
		current_user_session.destroy
		flash[:message] = "You have been logged out."
		redirect_to "/"
	end
end
