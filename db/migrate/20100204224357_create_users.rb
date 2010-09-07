class CreateUsers < ActiveRecord::Migration
	def self.up
		create_table :users do |t|
			t.string    :username
			t.string    :email
			t.string    :password_hash
			t.string    :password_salt
			t.string    :persistence_token
			t.string    :perishable_token
			t.string	:openid_identifier
			t.integer   :failed_login_count, :default => 0
			t.string    :last_login_ip 
			t.boolean   :admin, :default => nil
			t.boolean   :mod, :default => nil
		end
		
		add_index :users, :username
	end

	def self.down
		drop_table :users
	end
end
