class Guild < ActiveRecord::Base
	def expired?
		self.updated_at < config_option("expiration")["guilds"].minutes.ago
	end

	def self.get_hash(region, realm, name)
		return if region.blank? || realm.blank? || name.blank?

		# TW realms can be accessed through the English or the localized form
		# we want to force everything to use the English form so we don't duplicate data
		force_realm = REALM_DATA["#{region}-#{realm}".downcase]
		if !force_realm.nil? && force_realm.is_a?(String)
			realm = force_realm
		end

		return "g:#{region}:#{realm}:#{name}".downcase
	end
end
