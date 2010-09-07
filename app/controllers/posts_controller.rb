class PostsController < ApplicationController
	before_filter :require_admin_access
		
	def new
		@post = Post.new
	end

	def destroy
		post = Post.find_by_id(params[:post_id])
		if( post.nil? )
			flash[:message] = "Cannot find post #{params[:post_id]}, already been deleted?"
		elsif( post.user_id != current_user.id )
			flash[:message] = "Cannot delete post. You can only delete your own posts."
		else
			Post.destroy_all(:id => params[:post_id])
			flash[:message] = "Deleted post ##{post.id}, \"#{post.title}\"!"
		end
		
		expire_fragment("news")
		redirect_to "/"
	end
	
	def create
		post = Post.new(:title => params[:post][:title], :body => params[:post][:body].gsub("\n", "<br />"), :user_id => current_user.id)
		if( post.save )
			expire_fragment("news")
			flash[:message] = "Posted \"#{post.title}\"!"
			redirect_to "/"
		else
			render :action => :new
		end
	end

	def edit
		@post = Post.find_by_id(params[:post_id])
		@post.body = @post.body.gsub("<br />", "\n")
		expire_fragment("news")
	end

	def update
		post = Post.find_by_id(params[:post][:id])
		if( post.nil? || !post.update_attributes(:title => params[:post][:title], :body => params[:post][:body].gsub("\n", "<br />")) )
			flash[:message] = "Failed to update post post"
		else
			flash[:message] = "Updated post \"#{params[:post][:title]}\""
		end
		
		expire_fragment("posts")
		redirect_to "/"
	end
end


