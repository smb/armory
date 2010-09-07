module ApiHelper
	def error_text(code)
		if code == "badInput"
			return "bad character info passed"
		elsif code == "noCharacter"
			return "no character found"
		elsif code == "inactive"
			return "the character is inactive"
		elsif code == "maintenance"
			return "the armory is undergoing maintenance"
		end
		
		return code
	end
	
	def parse_powered(&block)
		html = capture_haml(&block).gsub("\n", '').gsub('\\n', "\n")
		haml_concat "EATooltip(\"#{html}\");"
	end
	
	def talent_info(character)
		if character["primary"]
			if character["primary"]["unspent"] && character["primary"]["unspent"] > 0
				return "(#{character["primary"]["sum_tree"]}) <span class='red'>#{character["primary"]["unspent"]}</span> unspent"
			else
				return "(#{character["primary"]["spec_role"]}) #{character["primary"]["sum_tree"]}"
			end
		else
			return "(0/0/0) Unknown"
		end
	end
end