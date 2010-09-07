class AddActiveGroupToCharacters < ActiveRecord::Migration
  def self.up
    add_column :characters, :active_group, :integer
  end

  def self.down
    remove_column :characters, :active_group
  end
end
