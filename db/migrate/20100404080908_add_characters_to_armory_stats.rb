class AddCharactersToArmoryStats < ActiveRecord::Migration
  def self.up
    add_column :armory_stats, :characters, :integer
  end

  def self.down
    remove_column :armory_stats, :characters
  end
end
