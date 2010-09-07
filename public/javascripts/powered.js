var TOOLTIP_MAX_WIDTH = 310
var eatt = {
	init: function() {
		var jstooltip = document.createElement("div")
		jstooltip.id = "ea-tooltip"
		jstooltip.className = "ea-hover"
		document.getElementsByTagName("body")[0].appendChild(jstooltip)
		eatt.jstooltip = jstooltip
		eatt.hide()
		eatt.queue = new Array()
		eatt.currentRequest = null
		eatt.currentMouseover = ""
		eatt.cache = new Object()
		eatt.failureTimer = -1
		document.onmousemove = eatt.mouseMove
		eatt.parseDocument()
	},
	
	mouseMove: function(e) {
		if( eatt.jstooltip.style.visibility == "hidden" ) return
		var cursor = eatt.cursorPosition(e)
		var de = document.documentElement
		var body = document.body
		var y = cursor.y - 15
		var x = cursor.x + 20
		
		// Figure out the true width, by moving the tooltip to the top left where it can resize as much as it needs
		eatt.jstooltip.style.left = "0px"
		eatt.jstooltip.style.top = "0px"
		if( ( eatt.jstooltip.style.width && eatt.jstooltip.style.width > TOOLTIP_MAX_WIDTH ) || ( eatt.jstooltip.offsetWidth && eatt.jstooltip.offsetWidth > TOOLTIP_MAX_WIDTH ) ) {
			eatt.jstooltip.style.width = TOOLTIP_MAX_WIDTH + "px"
		}
		
		// Bottom clamp
		if (cursor.y + eatt.jstooltip.offsetHeight > de.clientHeight + body.scrollTop + de.scrollTop) {
			y += (de.clientHeight+body.scrollTop+de.scrollTop)-(cursor.y+eatt.jstooltip.offsetHeight)
		}
		// Top clamp
		if( y < 0 ) { 
			y = 0
		}
		
		// Right clamp
		if( cursor.x + eatt.jstooltip.offsetWidth > de.clientWidth ) {
			var diff = ((cursor.x + eatt.jstooltip.offsetWidth) - de.clientWidth)
			x -= diff + (de.clientWidth - cursor.x) + 40
		// Simpler form, only for things that aren't actually off screen but are close enough to clipping that they go
		// over the horizontal scroll bar
		} else if( cursor.x + eatt.jstooltip.offsetWidth + 30 > de.clientWidth ) {
			var diff = ((cursor.x + eatt.jstooltip.offsetWidth) - de.clientWidth)
			x -= (de.clientWidth - cursor.x) + 30
		}

		eatt.jstooltip.style.left = x + "px"
		eatt.jstooltip.style.top = y + "px"
	},
	
	request: function(url) {
		var script = document.createElement("script")
		script.type = "text/javascript"
		script.src = url
		eatt.currentRequest["tag"] = script
		document.getElementsByTagName("head")[0].appendChild(script)
	},
	
	queueRequest: function(url) {
		var req = new Object()
		req["url"] = url
		req["cache"] = url
		eatt.queue.push(req)
		eatt.processQueue()
	},
	
	processQueue: function() {
		if (eatt.queue.length > 0 && eatt.currentRequest == null) {
			eatt.currentRequest = eatt.queue.pop()
			eatt.request(eatt.currentRequest["url"])
			eatt.failureTimer = window.setTimeout(eatt.timeoutTooltip, 5000)
		}
	},
	
	getValid: function(url) {
		match = url.match(/elitistarmory\.com\/(us|eu|kr|cn|tw)\/(.+)/i)
		if( match ) {
			return "/" + match[1] + "/" + match[2]
		}
		
		if( typeof(INCLUDE_ARMORY) != "undefined" && INCLUDE_ARMORY ) {
			if( url.match(/(wowarmory|wow-europe)\.com\/character-sheet\.xml?/) ) {
				var region = null;
				if( url.match(/wow-europe/) ) {
					region = "eu"
				} else {
					region = url.match(/(us|eu|kr|cn|tw)\.wowarmory/i)
					region = region ? region[1] : "us"
				}
				
				match = url.match(/xml\?r=(.+)&(n|cn)=(.+)/i)
				if( region != null && match ) {
					return "/" + region + "/" + match[1] + "/" + match[3]	
				}
			}
		}
		
		return ""
	},
	
	startTooltip: function(atag) {
		eatt.currentMouseover = atag["rel"]
		if (eatt.cache[atag["rel"]]) {
			eatt.jstooltip.innerHTML = eatt.cache[atag["rel"]]
		} else {
			eatt.jstooltip.innerHTML = "<div class='eatooltip'><div class='content'>Loading...</div></div>"
			eatt.queueRequest(atag["rel"])
		}
		eatt.show();
	},
	
	parseDocument: function() {
		eatt.parseElement(document)
	},
	
	parseElement: function(element) {
		if (typeof(element.getElementsByTagName) == "undefined") return false;
		var links = element.getElementsByTagName("a")
		var upval
		for(var i = 0; i<links.length; i++) {
			var args = eatt.getValid(links[i].href)
			if( args != "" ) {
				links[i]["rel"] = "http://elitistarmory.com/api/power" + args
				links[i].onmouseover = function(evt) { eatt.startTooltip(this) }
				links[i].onmouseout = function(evt) { eatt.hide() }
				
				if( typeof(OVERWRITE_ARMORY) != "undefined" && OVERWRITE_ARMORY ) {
					links[i].href = "http://elitistarmory.com" + args
				}
			}
		}
	},
	
	cursorPosition: function(e) {
		e = e || window.event
		var cursor = {x:0, y:0}
		if (e.pageX || e.pageY) {
			cursor.x = e.pageX
			cursor.y = e.pageY
		} else {
			var de = document.documentElement
			var b = document.body
			cursor.x = e.clientX + (de.scrollLeft || b.scrollLeft) - (de.clientLeft || 0)
			cursor.y = e.clientY + (de.scrollTop || b.scrollTop) - (de.clientTop || 0)
		}
		return cursor
	},
	
	show: function() {
		if (eatt.jstooltip.style.width > TOOLTIP_MAX_WIDTH || eatt.jstooltip.style.width > TOOLTIP_MAX_WIDTH
			|| eatt.jstooltip.offsetWidth > TOOLTIP_MAX_WIDTH || eatt.jstooltip.offsetWidth > TOOLTIP_MAX_WIDTH) {
			eatt.jstooltip.style.width = TOOLTIP_MAX_WIDTH
		} else {
			eatt["jstooltip"]["style"]["width"] = eatt["jstooltip"]["style"]["width"]
		}
		eatt.jstooltip.style.visibility = "visible"
	},
	
	hide: function() {
		eatt.jstooltip.style.visibility = "hidden"
		eatt.currentMouseover = null
	},
	
	removeChildren: function() {
		var scripts = document.getElementsByTagName("script")
		var head = document.getElementsByTagName("head").item(0)
		for (var i=0; i<scripts.length; i++) {
			var script = scripts[i]
			var src = script.getAttribute("src")
			if(src!=null && src.indexOf("api/power") > 0 && src.indexOf("elitistarmory.com") > 0) {
				head.removeChild(script)
				return
			}
		}	
	},
	
	timeoutTooltip: function() {
		EATooltip("<div class='eatooltip'><div class='content'>Failed to load tooltip</div></div>");
		eatt.failureTimer = -1
	}
}

function EATooltip(str) {
	window.clearTimeout(eatt.failureTimer)
	eatt.failureTimer = -1
	eatt.cache[eatt.currentRequest["cache"]] = str;
	try {
		setTimeout("eatt.removeChildren()", 0)
	} catch (e) {}
	if (eatt.currentMouseover == eatt.currentRequest["cache"]) {
		eatt.jstooltip.style.width = null
		eatt.jstooltip.innerHTML = str
		eatt.show()
	}
	eatt.currentRequest = null
	eatt.processQueue()
}