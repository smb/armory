var ttcss = document.createElement("link")
ttcss.type = "text/css"
ttcss.rel = "stylesheet"
ttcss.href = "http://elitistarmory.com/stylesheets/powered.css"
head = document.getElementsByTagName("head")[0]
head.appendChild(ttcss)
var ttjs = document.createElement("script")
ttjs.type = "text/javascript"
ttjs.src = "http://elitistarmory.com/javascripts/powered.js"
head.appendChild(ttjs)

var orig_onload = window.onload
var ea_loaded
window.onload = function() {
	if( typeof(orig_onload) != "undefined" && orig_onload ) {
		orig_onload()
	}
	
	eatt.init()
	ea_loaded = true
}

function EATooltipConfig(include, overwrite) {
	INCLUDE_ARMORY = include
	OVERWRITE_ARMORY = overwrite
	
	if( ea_loaded ) {
		eatt.parseDocument()
	}
}

