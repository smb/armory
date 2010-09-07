NO_RECORDS = "No characters found"
function default_sorter() {
	return "ilvl"
}

function build_row(elements, character) {
	hookup_tooltip(elements.name, character.name + " of " + character.region.toUpperCase() + "-" + character.realm)
	elements.name.html("<a href=\"/" + character.region + "/" + character.realm + "/" + character.name + "\"><span class=\"" + character.class_token + "\">" + character.name + "</span>")

	setup_talents(elements.primary_role, character.primary_role, character.primary_tree, character.primary_sum, character.primary_unspent)
	setup_talents(elements.secondary_role, character.secondary_role, character.secondary_tree, character.secondary_sum, character.secondary_unspent)
	elements.average.html("<span class=\"" + ilvl_color(character.average) + "\">" + character.average + "</span>")
	elements.equip.html("<span class=\"" + percent_color(character.equip) + "\">" + Math.floor(character.equip * 100) + "%</span>")
	elements.enchant.html("<span class=\"" + percent_color(character.enchant) + "\">" + Math.floor(character.enchant * 100) + "%</span>")
	elements.gem.html("<span class=\"" + percent_color(character.gem) + "\">" + Math.floor(character.gem * 100) + "%</span>")
		
	if( typeof(character.expn) != "number" ) {
		elements.expn.html("---")
	} else {
		character.expn = character.expn > 1 ? 1 : character.expn
		elements.expn.mouseover(function() { ttlib.requestTooltip("/tooltip/achievement/" + normal_dungeon + "/" + character.hash_id) })
		elements.expn.mouseout(ttlib.hide)
		elements.expn.html("<span class=\"" + percent_color(character.expn) + "\">" + Math.floor(character.expn * 100) + "%</span>")
	}

	if( typeof(character.exph) != "number" ) {
		elements.exph.html("---")
	} else {
		character.exph = character.exph > 1 ? 1 : character.exph
		elements.exph.mouseover(function() { ttlib.requestTooltip("/tooltip/achievement/" + heroic_dungeon + "/" + character.hash_id) })
		elements.exph.mouseout(ttlib.hide)
		elements.exph.html("<span class=\"" + percent_color(character.exph) + "\">" + Math.floor(character.exph * 100) + "%</span>")
	}
}