require "cgi"
class SuggestController < ApplicationController
	def character
		hash = CGI::unescape(params["character_hash"])
		
		
	end
end