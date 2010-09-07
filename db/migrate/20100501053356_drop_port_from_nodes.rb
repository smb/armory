class DropPortFromNodes < ActiveRecord::Migration
  def self.up
    remove_column :nodes, :port
  end

  def self.down
    add_column :nodes, :port, :integer, :default => 80
  end
end
