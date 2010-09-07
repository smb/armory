class RemoveUserIdFromCharacters < ActiveRecord::Migration
  def self.up
	remove_column :characters, :user_id
  end

  def self.down
	add_column :characters, :user_id, :integer
  end
end
