class AddPortToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :port, :integer, :default => 80
  end

  def self.down
    remove_column :nodes, :port
  end
end
