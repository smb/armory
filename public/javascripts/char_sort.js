NO_RECORDS = "No characters found"
function default_sorter() {
	return "rank"
}

function build_row(elements, character) {
	region = ""
	if( typeof(show_region) != "undefined" && show_region ) {
		region = character.region.toUpperCase() + "-"
	}
	
	if( typeof(name_tooltips) != "undefined" ) {
		hookup_tooltip(elements.name, character.name + " of " + character.region.toUpperCase() + "-" + character.realm)
	}
	
	elements.name.html("<a href=\"/" + character.region + "/" + character.realm + "/" + character.name + "\"><span class=\"" + character.class_token + "\">" + region + character.name + "</span>")
	if( character.rank == 0 && typeof(show_gm) != "undefined" ) {
		elements.rank.html("GM")
	} else if( character.rank == -1 ) {
		elements.rank.html("---")
	} else {
		elements.rank.html(character.rank)
	}
	
	setup_talents(elements.primary_role, character.primary_role, character.primary_tree, character.primary_sum, character.primary_unspent)
	setup_talents(elements.secondary_role, character.secondary_role, character.secondary_tree, character.secondary_sum, character.secondary_unspent)
	elements.average.html("<span class=\"" + ilvl_color(character.average) + "\">" + round(character.average) + "</span>")
	elements.equip.html("<span class=\"" + percent_color(character.equip) + "\">" + Math.floor(character.equip * 100) + "%</span>")
	elements.enchant.html("<span class=\"" + percent_color(character.enchant) + "\">" + Math.floor(character.enchant * 100) + "%</span>")
	elements.gem.html("<span class=\"" + percent_color(character.gem) + "\">" + Math.floor(character.gem * 100) + "%</span>")
}