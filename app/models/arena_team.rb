class ArenaTeam < ActiveRecord::Base
	has_many :arena_characters, :dependent => :destroy

	def self.get_hash(region, realm, bracket, name)
		return if region.blank? || realm.blank? || name.blank? || bracket.blank?

		# TW realms can be accessed through the English or the localized form
		# we want to force everything to use the English form so we don't duplicate data
		force_realm = REALM_DATA["#{region}-#{realm}".downcase]
		if !force_realm.nil? && force_realm.is_a?(String)
			realm = force_realm
		end

		return "a:#{region}:#{realm}:#{bracket}:#{name}".downcase
	end
end
