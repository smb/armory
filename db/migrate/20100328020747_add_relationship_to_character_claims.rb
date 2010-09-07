class AddRelationshipToCharacterClaims < ActiveRecord::Migration
  def self.up
    add_column :character_claims, :relationship, :string
    add_column :character_claims, :is_public, :boolean
	remove_column :character_claims, :area
	remove_column :character_claims, :pose_key
  end

  def self.down
    remove_column :character_claims, :is_public
    remove_column :character_claims, :relationship
	add_column :character_claims, :pose_key, :string
	add_column :character_claims, :area, :string
  end
end
