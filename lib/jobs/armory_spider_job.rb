require "nokogiri"

class ArmorySpiderJob < Struct.new(:args)
	def get_url
		return "parse", {:page => :arena_ladder, :ts => args[:bracket], :region => args[:region], :b => args[:battlegroup], :p => args[:page]}
	end
	
	def parse(doc, raw_xml)
		# Queue up spiders for every page
		result_doc = doc.css("arenaLadderPagedResult")
		if args[:page].to_i == 1
			DataManager.mass_queue_spiders(:region => args[:region], :battlegroup => args[:battlegroup], :bracket => args[:bracket], :max_pages => result_doc.attr("maxPage").to_s.to_i)
		end
		
		team_queue = {}
		doc.css("arenaTeams arenaTeam").each do |arena_team|
			DataManager.queue_arena_spider(:region => args[:region], :battlegroup => args[:battlegroup], :bracket => args[:bracket], :team_name => arena_team.attr("name"), :realm => arena_team.attr("realm"))
		end
	end
end