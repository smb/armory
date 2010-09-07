class Profession < ActiveRecord::Base
	has_one :profession_data, :foreign_key => :profession_id, :primary_key => :profession_id
end
