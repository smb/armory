ActionController::Routing::Routes.draw do |map|
	map.view_guild_filter "/g/:region/:realm/:name/:min/:max", :controller => "guild", :action => "characters"
	map.view_guild "/g/:region/:realm/:name", :controller => "guild", :action => "characters"
	map.suggest_char "/suggest/:character_hash", :controller => "suggest", :action => "character"
	
	map.rawr_item "/rawr/item/:item_id", :controller => "rawr", :action => "item"
	map.rawr_queue "/rawr/queue/:region/:realm/:name", :controller => "rawr", :action => "queue"
	map.rawr_char "/rawr/char/:region/:realm/:name", :controller => "rawr", :action => "character"
	map.rawr_req "/rawr/req/:region/:realm/:name/:recache", :controller => "rawr", :action => "request_char"
	
	map.api_alt_powered "/api/alt_power/:region/:realm/:name", :controller => "api", :action => "alt_powered"
	map.api_powered "/api/power/:region/:realm/:name", :controller => "api", :action => "powered"
	map.api_base_multi "/api/base/multi.:format", :controller => "api", :action => "multi_base"
	map.api_base "/api/base/:region/:realm/:name.:format", :controller => "api", :action => "base"
	map.api_exp "/api/exp/:region/:realm/:name.:format", :controller => "api", :action => "experience"
	map.api_claim "/api/claim/:token/:region/:realms/:characters.:format", :controller => "api", :action => "claim"
	map.api_population "/api/population/:region.:format", :controller => "api", :action => "population"
	
	#map.open_id_complete 'session', :controller => "user_sessions", :action => "create", :requirements => { :method => :get }
	map.resource :password_reset
	map.edit_password_reset "/password_reset/edit/:token", :controller => "password_resets", :action => "edit", :requirements => { :method => :get }
	map.resource :login, :controller => "user_sessions"
	map.resource :account, :controller => "users"
	map.account_char "/account/char", :controller => "users", :action => "update_char", :conditions => {:method => :post}
	map.char_del "/account/char/del/:character_hash", :controller => "users", :action => "delete_char"
	map.resources :users

	#map.register "/register/:activation_code", :controller => "activations", :action => "new"
	#map.activate "/activate/:id", :controller => "activations", :action => "create"

	map.post_destroy "/post/destroy/:post_id", :controller => "posts", :action => "destroy"
	map.post_edit "/post/edit/:post_id", :controller => "posts", :action => "edit"
	map.post_new "/post/new", :controller => "posts", :action => "new"
	map.post_create "/post/create", :controller => "posts", :action => "create", :conditions => {:method => :post}
	map.post_update "/post/update", :controller => "posts", :action => "update", :conditions => {:method => :put}

	map.admin_spider "/admin/spider/:region", :controller => "admin", :action => "spider"
	map.admin_node_add "/admin/node/add", :controller => "admin", :action => "add_node"
	map.admin_node_update "/admin/node/update", :controller => "admin", :action => "update_node"
	map.admin_node_status "/admin/node/status", :controller => "admin", :action => "node_status"
	map.admin_nodes "/admin/node", :controller => "admin", :action => "nodes"
	map.admin_bgs "/admin/battlegroups", :controller => "admin", :action => "battlegroups"
	map.admin_recache "/admin/items", :controller => "admin", :action => "recache_items"
	map.admin "/admin", :controller => "admin", :action => "index"
	
	map.rank_players_region_old "/rankings/:region", :controller => "rankings", :action => "characters"
	map.rank_players_old "/rankings", :controller => "rankings", :action => "characters"

	map.rank_players_region "/rank/players/:region", :controller => "rankings", :action => "characters"
	map.rank_players "/rank/players", :controller => "rankings", :action => "characters"
	map.rank_realms_region "/rank/realms/:region", :controller => "rankings", :action => "realms"
	map.rank_realms "/rank/realms", :controller => "rankings", :action => "realms"
	map.rank_realm "/rank/realm/:region/:realm", :controller => "rankings", :action => "realm"
	map.rank_regions "/rank/regions", :controller => "rankings", :action => "regions"
		
	map.donate "/donate", :controller => "home", :action => "donate"
	map.experience "/experience", :controller => "experience", :action => "list"
	map.faq "/faq", :controller => "home", :action => "faq"
	map.api "/api", :controller => "home", :action => "api"
	map.stats "/stats", :controller => "home", :action => "stats"
	map.proxy "/proxy", :controller => "home", :action => "mirror"
	map.mirror "/mirror", :controller => "home", :action => "mirror"
	map.powered "/powered", :controller => "home", :action => "powered"
	
	map.get_group_session "/gs/:region/:realms/:names", :controller => "group", :action => "make_session"
	map.group_exp "/group/exp/:session/:dungeon", :controller => "group", :action => "experience"
	
	map.logout "/logout", :controller => "user_sessions", :action => "destroy"
	map.group_sum "/group/:session", :controller => "group", :action => "summary"
	map.item_restrict "/item/restrict", :controller => "item", :action => "filter_upgrade", :conditions => {:method => :post}
	map.item_filter "/item/:item_id/:archetype", :controller => "item", :action => "item"
	map.item "/item/:item_id", :controller => "item", :action => "item"
	map.item_search "/item", :controller => "item", :action => "search", :conditions => { :method => :post }
	map.load_guild "/guild", :controller => "guild", :action => "load_guild", :conditions => { :method => :post }
	map.load_char "/request", :controller => "character", :action => "load_char", :conditions => { :method => :post }
	map.achievement_tooltip "/tooltip/achievement/:child_id/:character_hash", :controller => "character", :action => "tooltip"
	map.source_item_tooltip "/tooltip/source/item/:item_id", :controller => "item", :action => "item_tooltip"
	map.queue_char "/queue/char/:hash_id", :controller => "character", :action => "queue"
	map.queue_guild "/queue/guild/:hash", :controller => "guild", :action => "queue"
	map.queue_group "/queue/group/:session", :controller => "group", :action => "queue"
	map.char_profile_group "/:region/:realm/:name/:group", :controller => "character", :action => "character"
	map.char_profile "/:region/:realm/:name", :controller => "character", :action => "character"

	map.root :controller => "home"

	# The priority is based upon order of creation: first created -> highest priority.

	# Sample of regular route:
	#   map.connect "products/:id", :controller => "catalog", :action => "view"
	# Keep in mind you can assign values other than :controller and :action

	# Sample of named route:
	#   map.purchase "products/:id/purchase", :controller => "catalog", :action => "purchase"
	# This route can be invoked with purchase_url(:id => product.id)

	# Sample resource route (maps HTTP verbs to controller actions automatically):
	#   map.resources :products

	# Sample resource route with options:
	#   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

	# Sample resource route with sub-resources:
	#   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

	# Sample resource route with more complex sub-resources
	#   map.resources :products do |products|
	#     products.resources :comments
	#     products.resources :sales, :collection => { :recent => :get }
	#   end

	# Sample resource route within a namespace:
	#   map.namespace :admin do |admin|
	#     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
	#     admin.resources :products
	#   end

	# You can have the root of your site routed with map.root -- just remember to delete public/index.html.
	# map.root :controller => "welcome"

	# See how all your routes lay out with "rake routes"

	# Install the default routes as the lowest priority.
	# Note: These default routes make all actions in every controller accessible via GET requests. You should
	# consider removing or commenting them out if you"re using named routes and resources.
	#map.connect ":controller/:action/:id"
	#map.connect ":controller/:action/:id.:format"
end
