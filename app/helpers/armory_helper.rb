require "uri"
module ArmoryHelper
	@pages = {
		:character => "character-sheet.xml",
		:model => "character-model.xml",
		:talents => "character-talents.xml",
		:achievements => "character-achievements.xml",
		:statistics => "character-statistics.xml",
		:item_tooltip => "item-tooltip.xml",
		:item_info => "item-info.xml",
		:guild => "guild-info.xml",
		:battlegroups => "battlegroups.xml",
		:reputation => "character-reputation.xml",
		:arena_team => "team-info.xml",
		:feed => "character-feed.xml",
		:arena_ladder => "arena-ladder.xml",
	}
		
	def self.build_args(args)
		extra = ""
		args.each do |key, value|
			if !value.nil?
				extra = "#{extra}#{key}=#{URI.escape(value.to_s)}&"
			end
		end
		
		if !extra.blank?
			extra = extra.slice(0, extra.length - 1)
		end
		
		return extra
	end
		
	def self.build_url(args)
		url = "http://#{args[:region].downcase}.wowarmory.com/#{@pages[args[:page]]}?"

		extra = ""
		args.each do |key, value|
			if !value.nil? && key != :page && key != :region
				extra = "#{extra}#{key}=#{URI.escape(value.to_s)}&"
			end
		end
		
		if !extra.blank?
			extra = extra.slice(0, extra.length - 1)
		end
		
		return "#{url}#{extra}"
	end
end
