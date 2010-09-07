NO_RECORDS = "No items found"
function default_sorter() {
	return "ilvl"
}

function build_row(elements, item) {
	elements.name.html("<img src=\"/images/icons/" + item.icon + ".png\" height=\"24\" width=\"24\"><a href=\"/item/" + item.id + "\" class=\"q" + item.quality + "\" rel=\"" + item.tooltip + "\" onmouseover=\"ttlib.startTooltip(this);\" onmouseout=\"ttlib.hide();\">[" + item.name + "]</a>")
	elements.ilvl.html("<span class=\"q" + item.quality + "\">" + item.ilvl + "</span>")
	elements.spec.html(item.spec)
	
	if( item.sources > 0 ) {
		var text = item.sources + (item.sources == 1 ? " source" : " sources")
		elements.sources.html("<div onmouseover=\"ttlib.requestTooltip('/tooltip/source/item/" + item.id + "');\" onmouseout=\"ttlib.hide();\">" + text + "</div>")
	} else {
		elements.sources.html("No sources")
	}
}