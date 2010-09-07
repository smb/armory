class RenameUsernameToLogin < ActiveRecord::Migration
  def self.up
	rename_column :users, :username, :login
	remove_index :users, :username
	add_index :users, :login
  end

  def self.down
	rename_column :users, :username, :username
	remove_index :users, :login
	add_index :users, :username
  end
end
