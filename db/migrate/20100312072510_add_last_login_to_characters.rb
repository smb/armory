class AddLastLoginToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :last_login, :integer
  end

  def self.down
    remove_column :characters, :last_login
  end
end
