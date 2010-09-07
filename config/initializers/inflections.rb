# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format 
# (all these examples are active by default):
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

ActiveSupport::Inflector.inflections do |inflect|
	inflect.irregular 'new', 'news'
	inflect.irregular 'post', 'posts'
	inflect.irregular 'glyph_data', 'glyph_data'
	inflect.irregular 'achievement_data', 'achievement_data'
	inflect.irregular 'achievement_criteria', 'achievement_criteria'
	inflect.irregular 'profession_data', 'profession_data'
	inflect.irregular 'reputation_data', 'reputation_data'
end