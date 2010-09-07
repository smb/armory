require "yaml"

SITE_CONFIG = YAML::load(File.open("#{RAILS_ROOT}/config/site_config.yml").read)
def config_option(key, env = nil)
	env ||= RAILS_ENV
	if env == "development" && key == "version"
		return Time.now
	end
	SITE_CONFIG[env] && SITE_CONFIG[env][key] || nil
end

REALM_DATA = YAML::load(File.open("#{RAILS_ROOT}/config/realms.yml").read)
