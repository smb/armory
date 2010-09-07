class AddInactiveToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :inactive, :boolean
  end

  def self.down
    remove_column :characters, :inactive
  end
end
