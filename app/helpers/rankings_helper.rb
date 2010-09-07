module RankingsHelper
	def smart_round(number)
		return number if number.floor == number
		return "%.2f" % number
	end
end