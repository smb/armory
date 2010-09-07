class Glyph < ActiveRecord::Base
	has_one :glyph_data, :foreign_key => :glyph_id, :primary_key => :glyph_id
end
