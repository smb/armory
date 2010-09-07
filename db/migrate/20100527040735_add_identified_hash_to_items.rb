class AddIdentifiedHashToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :stat_hash, :string
	add_index :items, :stat_hash
  end

  def self.down
    remove_column :items, :stat_hash
	remove_index :items, :stat_hash
  end
end
