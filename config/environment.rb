# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

ENV['RECAPTCHA_PUBLIC_KEY']  = '6LehCr0SAAAAAIUMKG_VwdinnKKDGnyLanO8g5dq'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LehCr0SAAAAAC3UmoL4Dt_rxwJnc1wZZexSkaAF'

Rails::Initializer.run do |config|
	config.load_paths += Dir["#{RAILS_ROOT}/app/models/**/*.rb"]
	config.load_paths += Dir["#{RAILS_ROOT}/lib/**/*.rb"]
	config.gem "nokogiri"
	config.gem "authlogic"  
	config.gem "haml"
	config.gem "daemons"
		
	config.action_mailer.delivery_method = :sendmail
	config.time_zone = 'UTC'
end
