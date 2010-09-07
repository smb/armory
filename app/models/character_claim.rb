class CharacterClaim < ActiveRecord::Base
	has_one :character, :foreign_key => "hash_id", :primary_key => "character_hash"
end
