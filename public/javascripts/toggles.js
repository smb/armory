function toggle_frames() {
	toggles = $(".atoggle")
	hash = location.href.match(/#(.+)/)
	for( var i=0; i<toggles.length; i++ ) {
		toggle = $(toggles[i])
		frame = $($(toggles[i]).parent().parent().find(".toggle"))
		if( !$.cookie("toggle-" + frame.attr("id")) && ( !hash || hash[1] != frame.attr("id") ) ) {
			frame.addClass("invisible")
			toggle.html("[+]")
			toggles[i].onmouseover = function() { ttlib.showText("Click to view experience.") }
			
			if( hash && hash[1] == frame.attr("id") && !set_hash ) {
				$.cookie("toggle-" + frame.attr("id"), "1")
				set_hash = true
			}
		} else {
			toggle.html("[-]")
			toggles[i].onmouseover = function() { ttlib.showText("Click to hide experience.") }
		}
	}
	
	toggles.click(function() {
		frame = $(this).parent().parent().find(".toggle")
		key = "toggle-" + frame.attr("id")
		if( !$.cookie(key) ) {
			$.cookie(key, "1")
			frame.removeClass("invisible")
			$(this).html("[-]")
			this.onmouseover = function() { ttlib.showText("Click to hide experience.") }
		} else {
			$.cookie(key, null)
			frame.addClass("invisible")
			$(this).html("[+]")
			this.onmouseover = function() { ttlib.showText("Click to view experience.") }
		}

		this.onmouseover()
	})
}