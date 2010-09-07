module Armory
	class Error < ActiveRecord::Base
		set_table_name :armory_errors
	end
end
