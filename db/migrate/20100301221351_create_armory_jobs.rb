class CreateArmoryJobs < ActiveRecord::Migration
	def self.up
		create_table :nodes do |t|
			t.boolean :enabled, :default => true
			t.boolean :remote, :default => true
			t.string :name
			t.string :url
			t.string :email
			t.string :secret_key
			t.string :locked_by
			t.datetime :locked_at
			t.integer :error_count, :default => 0
			t.integer :version
			t.integer :requests, :default => 0
			t.integer :throttle, :default => 5
			t.timestamps
		end
		
		add_index :nodes, :locked_by
		
		create_table :armory_jobs do |t|
			t.string :class_name
			t.string :json_args
			t.integer :priority
			t.string :locked_by
			t.string :job_type
			t.string :name_hash
			t.string :guild_hash
			t.integer :numerical_id
			t.boolean :local_only
			t.datetime :locked_at
			t.datetime :created_at
		end
		
		add_index :armory_jobs, :locked_by
		
		create_table :armory_errors do |t|
			t.string :error_type
			t.string :trace
			t.string :job_type
			t.string :name_hash
			t.string :guild_hash
			t.integer :numerical_id
			t.datetime :created_at
		end
		
		add_index :armory_errors, :job_type
	end

	def self.down
		drop_table :armory_errors
		drop_table :armory_jobs
		drop_table :nodes
	end
end
