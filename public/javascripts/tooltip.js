var URL_MATCHES = {
	"^http://www\\.wowhead\\.com/(item|spell|quest|object|npc|achievement|statistic)=(.+)": function(match) { return "http://www.wowhead.com/" + match[1] + "=" + match[2] + "&power" },
	"^http://armory\\.db6\\.org/item/([0-9]+)": function(match) { return "http://www.wowhead.com/item=" + match[1] + "&power" }
}

var cursor = {x: 0, y: 0}
var ttlib = {
	init: function() {
		var tooltip = document.createElement("div")
		tooltip.className = "ea-tooltip"
		ttlib.jstooltip = tooltip
		ttlib.hide()

		ttlib.queue = []
		ttlib.cache = {}
		ttlib.currentRequest = null
		ttlib.jstooltip.maxWidth = null
		
		document.onmousemove = ttlib.mouseMove
		document.getElementsByTagName("body")[0].appendChild(tooltip)
		ttlib.parseDocument()
	},

	// Functions for managing visibility or showing tooltips
	show: function() {
		if( !ttlib.jstooltip ) return

		ttlib.jstooltip.style.width = null
		ttlib.jstooltip.style.visibility = "visible"
		ttlib.mouseMove()
	},
	showText: function(text) {
		if( !ttlib.jstooltip ) return

		ttlib.jstooltip.maxWidth = 310
		ttlib.jstooltip.innerHTML = "<div class='border text'>" + text + "</div>"
		ttlib.show()
	},
	showCachedData: function(data) {
		if( !ttlib.jstooltip ) return

		ttlib.jstooltip.maxWidth = data.tooltip_enus ? 370 : null
		ttlib.jstooltip.innerHTML = data.tooltip
		ttlib.show()
	},
	showData: function(data) {
		if( !ttlib.jstooltip ) return

		data.tooltip = "<div class='border'>" + data.tooltip + "</div>"
		ttlib.cache[ttlib.currentRequest] = data

		if( ttlib.currentMouseover == ttlib.currentRequest ) {
			ttlib.showCachedData(data)
		}

		ttlib.currentRequest = null
		ttlib.processQueue()
	},
	showError: function() {
		if( !ttlib.jstooltip ) return

		ttlib.currentRequest = null
		ttlib.showText("Error loading tooltip.")
	},
	hide: function() {
		if( !ttlib.jstooltip ) return

		ttlib.jstooltip.style.visibility = "hidden"
		ttlib.currentMouseover = null
	},
	
	// Tooltip positioning
	mouseMove: function(e) {
		var cursor = ttlib.cursorPosition(e)
		var de = document.documentElement
		var body = document.body
		var y = cursor.y - 15
		var x = cursor.x + 20

		// Figure out the true width, by moving the tooltip to the top left where it can resize as much as it needs
		ttlib.jstooltip.style.left = "0px"
		ttlib.jstooltip.style.top = "0px"
		if( ( ttlib.jstooltip.style.width && ttlib.jstooltip.style.width > ttlib.jstooltip.maxWidth ) || ( ttlib.jstooltip.offsetWidth && ttlib.jstooltip.offsetWidth > ttlib.jstooltip.maxWidth ) ) {
			ttlib.jstooltip.style.width = ttlib.jstooltip.maxWidth + "px"
		}
		
		// Bottom clamp
		if (cursor.y + ttlib.jstooltip.offsetHeight > de.clientHeight + body.scrollTop + de.scrollTop) {
			y += (de.clientHeight + body.scrollTop + de.scrollTop) - (cursor.y + ttlib.jstooltip.offsetHeight)
		}
		// Top clamp
		if( y < 0 ) { 
			y = 0
		}

		// Right clamp
		if( cursor.x + ttlib.jstooltip.offsetWidth > de.clientWidth ) {
			var diff = (cursor.x + ttlib.jstooltip.offsetWidth) - de.clientWidth
			x -= diff + (de.clientWidth - cursor.x) + 40
		// Simpler form, only for things that aren't actually off screen but are close enough to clipping that they go
		// over the horizontal scroll bar
		} else if( cursor.x + ttlib.jstooltip.offsetWidth + 30 > de.clientWidth ) {
			var diff = (cursor.x + ttlib.jstooltip.offsetWidth) - de.clientWidth
			x -= (de.clientWidth - cursor.x) + 30
		}
		
		ttlib.jstooltip.style.left = x + "px"
		ttlib.jstooltip.style.top = y + "px"
	},
	cursorPosition: function(e) {
		var event = e || window.event
		if( !event || event.type != "mousemove" ) return cursor
		
		if( event.pageX || event.pageY ) {
			cursor.x = event.pageX
			cursor.y = event.pageY
		} else {
			var de = document.documentElement
			var b = document.body
			cursor.x = event.clientX + (de.scrollLeft || b.scrollLeft) - (de.clientLeft || 0)
			cursor.y = event.clientY + (de.scrollTop || b.scrollTop) - (de.clientTop || 0)
		}
		
		return cursor
	},
		
	// Queue management
	requestTooltip: function(url) {
		ttlib.currentMouseover = url
		ttlib.jstooltip.style.width = null

		if( ttlib.cache[url] ) {
			ttlib.showCachedData(ttlib.cache[url])
		} else {
			ttlib.queueRequest(url)
			ttlib.showText("Loading tooltip...")
		}
	},
	queueRequest: function(url) {
		if( ttlib.currentRequest != url ) {
			ttlib.queue.push(url)
			ttlib.processQueue()
		}
	},
	processQueue: function() {
		if( ttlib.queue.length == 0 || ttlib.currentRequest ) return
		
		ttlib.currentRequest = ttlib.queue.pop()
		
		$.ajax({
			url: ttlib.currentRequest,
			dataType: "script",
			error: ttlib.showError
		})
	},
	
	// URL detection
	getAPIURL: function(url) {
		for( var pattern in URL_MATCHES ) {
			var match = url.match(pattern)
			if( match ) {
				return URL_MATCHES[pattern](match)
			}
		}
		
		return null
	},
	parseDocument: function() {
		var links = document.getElementsByTagName("a")
		for( var i = 0; i < links.length; i++ ) {
			var api_url = ttlib.getAPIURL(links[i].href)
			if( api_url && ( typeof(links[i].onmouseover) == "undefined" || links[i].onmouseover == null ) ) {
				links[i].rel = api_url
				links[i].onmouseover = function(evt) { ttlib.requestTooltip(this.rel) }
				links[i].onmouseout = ttlib.hide
			}
		}
	},
	
	// Wowhead fun!
	wowheadTooltip: function(id, showIcon, data) {
		data.tooltip = data.tooltip_enus
		ttlib.showData(data)
	}
}

// Wowhead compatibility function
var $WowheadPower = {
	registerItem: ttlib.wowheadTooltip,
	registerSpell: ttlib.wowheadTooltip,
	registerAchievement: ttlib.wowheadTooltip,
	registerStatistic: ttlib.wowheadTooltip,
	registerNpc: ttlib.wowheadTooltip,
	registerObject: ttlib.wowheadTooltip,
	registerQuest: ttlib.wowheadTooltip
}

$(document).ready(ttlib.init)
