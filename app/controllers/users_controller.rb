class UsersController < ApplicationController
	before_filter :require_no_user, :only => [:new, :create]
	before_filter :require_user, :only => [:show, :edit, :update, :update_char, :delete_char]

	def new
		@user = User.new
	end

	def create
		@user = User.new(params[:user])
		if( !verify_recaptcha )
			if( flash[:recaptcha_error] == "incorrect-captcha-sol" ) then
				@user.errors.add("Captcha", "was incorrect")
			else
				@user.errors.add("Captcha", "unknown response code #{flash[:recaptcha_error]}")
			end

			render :action => "new"
			return
		end
		
		@user.save
		if !@user.save.blank?
			flash[:message] = "Account created!"
			redirect_to root_url
		else
			render :action => "new"
		end
		return
	end

	def update_char
		if !params["claims"].nil?
			params["claims"].each do |id, claim|
				record = CharacterClaim.find(:first, :conditions => {:character_hash => claim["character_hash"], :user_id => current_user.id})
				record.is_public = claim["is_public"] == "public" ? true : false
				record.relationship = claim["relationship"]
				record.save
			end
		end
		
		flash[:message] = "Updated claimed characters"
		redirect_to account_url
		return
	end
	
	def delete_char
		CharacterClaim.destroy_all(["character_hash = ? and user_id = ?", params["character_hash"], current_user.id])
		
		flash[:message] = "Removed claimed character"
		redirect_to account_url
		return
	end
	
	def show
		@claims = []
		CharacterClaim.all(:conditions => {:user_id => current_user.id}, :include => :character, :order => "relationship DESC").each do |claim|
			@claims.push(claim)
		end
	end

	def edit
	end

	def update
		@current_user.email = params[:user][:email]
		
		unless params[:user][:password].blank? && params[:user][:password_confirmation].blank?
			@current_user.password = params[:user][:password]
			@current_user.password_confirmation = params[:user][:password_confirmation]
		end
		
		if @current_user.save
			flash[:message] = "Account information updated!"
			redirect_to edit_account_path
		else
			render :action => :edit
			return
		end
	end
end
