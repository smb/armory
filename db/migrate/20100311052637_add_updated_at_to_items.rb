class AddUpdatedAtToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :updated_at, :datetime
  end

  def self.down
    remove_column :items, :updated_at
  end
end
