class AddIndexToCharacterClaims < ActiveRecord::Migration
  def self.up
	add_index :character_claims, :character_hash
	add_index :character_claims, :user_id
  end

  def self.down
	remove_index :character_claims, :character_hash
	remove_index :character_claims, :user_id
  end
end
