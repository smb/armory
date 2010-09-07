class AdminController < ApplicationController
	before_filter :require_admin_access
	
	def index
	end
	
	def node_status
		@nodes = Armory::Node.all(:order => "locked_at DESC")
	end
	
	def recache_items
		DataManager.recache_items
		flash[:message] = "Requeued every item"
		redirect_to admin_url
	end
	
	def spider
		battlegroups = YAML::load(File.open("#{RAILS_ROOT}/config/battlegroups.yml").read)
		list = []
		battlegroups[params["region"].downcase].each do |battlegroup|
			list.push(battlegroup)
		end
		
		list.sort_by{ rand() }.each do |battlegroup|
			[2,3,5].sort_by{ rand() }.each do |bracket|
				DataManager.queue_spider(:region => params["region"].downcase, :battlegroup => battlegroup, :bracket => bracket, :page => 1)
			end
		end
		
		flash[:message] = "Arena spider starting for region #{params["region"].upcase}"
		redirect_to admin_url
	end
	
	def add_node
		@node = Armory::Node.new
	end
	
	def update_node
		if params["commit"] == "Delete"
			node = Armory::Node.find_by_id(params["armory_node"]["id"])
			node.destroy

			# Force all the workers to instantly resync
			Rails.cache.write("nodes/resync", Armory::Node.db_time_now, :expires_in => 5.minutes, :raw => true)
			
			flash[:message] = "Deleted node #{node.name}"
			redirect_to admin_nodes_url
			return
		end
		
		if !params["armory_node"]["id"].blank?
			node = Armory::Node.find_by_id(params["armory_node"]["id"])
			node.attributes = params["armory_node"]
		else
			node = Armory::Node.new
			params["armory_node"].each do |k, v|
				next if k == "id"
				node[k] = v
			end
		end
		
		node.save
		
		flash[:message] = "Updated node #{node.name}!"
		redirect_to admin_nodes_url
	end
	
	def nodes
		@nodes = Armory::Node.all
	end
		
	def battlegroups
		config_option("armories").each do |region|
			DataManager.queue_battlegroups(:region => region.downcase, :name_hash => region.downcase)
		end
		
		flash[:message] = "Queued up battlegroup jobs"
		redirect_to admin_url
	end
end


