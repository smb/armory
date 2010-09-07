NO_RECORDS = "No realms found"
function default_sorter() {
	return "rank"
}

function build_row(elements, realm) {
	region = show_region ? realm.region.toUpperCase() + "-" : ""
	alliance_ratio = 1
	horde_ratio = 1
	
	if( realm.totall > realm.tothorde ) {
		alliance_ratio = realm.totall / realm.tothorde
	} else if( realm.tothorde > realm.totall ) {
		horde_ratio = realm.tothorde / realm.totall
	}
	
	if( realm.totall == 0 || realm.tothorde == 0 ) {
		elements.ratio.html("---")
	} else {
		elements.ratio.html("<span class='alliance'>" + round(alliance_ratio) + "</span> : <span class='horde'>" + round(horde_ratio) + "</span>")
	}
	
	if( round(realm.change) == 0 ) {
		elements.change.html("---")
	} else {
		elements.change.html("<span class='" + (realm.change > 0 ? "green" : "red") + "'>" + round(realm.change) + "</span>")
	}
	
	if( display_type == "region" ) {
		elements.name.html("<a href=\"/rank/realms/" + realm.region + "\">" + region + realm.name + "</a>")
	} else if( display_type == "realm" ) {
		elements.name.html("<a href=\"/rank/realm/" + realm.region + "/" + realm.name + "\">" + region + realm.name + "</a>")
	}
	
	elements.rank.html(realm.rank)
	elements.totall.html("<span class='alliance'>" + realm.totall + "</span>")
	elements.tothorde.html("<span class='horde'>" + realm.tothorde + "</span>")
	elements.ilvl.html("<span class='" + ilvl_color(realm.ilvl) + "'>" + round(realm.ilvl) + "</span>")
}