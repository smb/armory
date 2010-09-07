class RenameJobTypeInArmoryErrors < ActiveRecord::Migration
  def self.up
	rename_column :armory_errors, :job_type, :class_name
  end

  def self.down
	rename_column :armory_errors, :class_name, :job_type
  end
end
