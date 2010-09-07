class AddErroredToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :errored, :boolean
	remove_column :nodes, :requests
	remove_column :nodes, :error_count
  end

  def self.down
    remove_column :nodes, :errored
  end
end
