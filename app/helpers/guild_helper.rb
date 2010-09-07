require "cgi"
module GuildHelper
	def rank_name(rank)
		return "the guild master" if rank == 0
		return "rank #{rank}"
	end
	
	def parse_characters(characters)
		characters.each do |character|
			character[:primary_role] = ".#{character[:primary_unspent]}" if !character[:primary_unspent].nil?
			character[:secondary_role] = ".#{character[:secondary_unspent]}" if !character[:secondary_unspent].nil?
		end
				
		return characters
	end
end