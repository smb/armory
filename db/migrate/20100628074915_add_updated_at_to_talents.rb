class AddUpdatedAtToTalents < ActiveRecord::Migration
  def self.up
    add_column :talents, :updated_at, :datetime
  end

  def self.down
    remove_column :talents, :updated_at
  end
end
