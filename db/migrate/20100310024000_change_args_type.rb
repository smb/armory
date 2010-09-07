class ChangeArgsType < ActiveRecord::Migration
  def self.up
	change_column :armory_jobs, :json_args, :text
  end

  def self.down
	change_column :armory_jobs, :json_args, :string
  end
end
