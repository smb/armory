# Settings specified here will take precedence over those in config/environment.rb

config.cache_store = nil
#config.cache_store = :mem_cache_store, "127.0.0.1:1100"
#config.cache_store = :mem_cache_store, ["localhost:11000"] 

#require "memcache"
#WorkerCache = MemCache.new(:namespace => "worker")
#WorkerCache.servers = ["localhost:11000"]

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.action_mailer.default_url_options = {:host => "localhost:3000"}

Sass::Plugin.options[:cache] = true
#Sass::Plugin.options[:always_update] = true
Sass::Plugin.options[:style] = :compressed
Haml::Template.options[:ugly] = true


# Settings specified here will take precedence over those in config/environment.rb
# #config.gem "slim-attributes"
config.gem "smurf"
config.gem "slim_scrooge"
#config.gem "SystemTimer"
#
# #config.cache_store = :mem_cache_store, ["127.0.0.1:11000"]
#
# #require "memcache"
# #WorkerCache = MemCache.new(:namespace => "worker")
# #WorkerCache.servers = ["72.14.191.151:11000", "72.14.187.10:11000"]
#
# # The production environment is meant for finished, "live" apps.
# # Code is not reloaded between requests
config.cache_classes = true
#
 # Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true
#
