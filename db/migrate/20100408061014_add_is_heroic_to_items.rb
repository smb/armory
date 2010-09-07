class AddIsHeroicToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :is_heroic, :boolean, :default => false
  end

  def self.down
    remove_column :items, :is_heroic
  end
end
