class PasswordResetsController < ApplicationController
	before_filter :require_no_user, :only => [:new, :create]
	before_filter :load_user_using_perishable_token, :only => [:update, :edit]
	
	def new
	end

	def create
		@user = User.find(:first, :conditions => {:email => params[:password_resets][:email]})
		if @user.nil?
			flash[:error] = "Cannot find an account assocated with the email \"#{params[:password_resets][:email]}\""
			render :action => :new
		else
			flash[:message] = "Password reset sent, check for an email from noreply@elitistarmory.com in the next few minutes."
		
			@user.reset_perishable_token!
			Notifier.deliver_forgot_password(@user, request.remote_ip)
			redirect_to root_path
		end
	end
			
	def edit
	end
	
	def update
		@user.password = params[:user][:password]  
		@user.password_confirmation = params[:user][:password_confirmation]  
		if @user.save
			flash[:message] = "Password changed!"
			redirect_to account_path
		else
			render :action => :edit
			return
		end
	end
	
	private
	def load_user_using_perishable_token 
		@user = User.find_using_perishable_token(params[:token], 3.days)
		unless @user
			flash[:error] = "Cannot find the account, it's possible you entered the URL incorrectly. After 3 days, the password reset link will expire."
			redirect_to root_url
		end
	end
end
