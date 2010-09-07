function relative_time(from) {
	now = (new Date).getTime() / 1000
    var distance_in_minutes = Math.floor((now - from) / 60)
   	if (distance_in_minutes <= 0) { return '<1 minute'; }
    if (distance_in_minutes == 1) { return '1 minute ago'; }
    if (distance_in_minutes < 45) { return distance_in_minutes + ' minutes ago'; }
    if (distance_in_minutes < 90) { return '1 hour ago'; }
    if (distance_in_minutes < 1440) { return  Math.floor(distance_in_minutes / 60) + ' hours ago'; }
    if (distance_in_minutes < 2880) { return '1 day ago'; }
    if (distance_in_minutes < 43200) { return Math.floor(distance_in_minutes / 1440) + ' days ago'; }
    if (distance_in_minutes < 86400) { return '1 month ago'; }
    if (distance_in_minutes < 525960) { return Math.floor(distance_in_minutes / 43200) + ' months ago'; }
    if (distance_in_minutes < 1051199) { return '1 year ago'; }
 
    return 'over ' + Math.floor(distance_in_minutes / 525960) + ' years ago';
}

$(document).ready(function() {
	$('#character_realm').autocomplete(servers, {tab_to: '#character_name', max: 8})
	$('#guild_realm').autocomplete(servers, {tab_to: '#guild_name', max: 8})

	$("input[type=text]").focusin(function() {
		$(this).addClass("focused")
	})
	$("input[type=text]").focusout(function() {
		$(this).removeClass("focused")
	})
	$("div.menu > ul > .dropdown").mouseenter(function(event) {
		$(this).find(".arrow").removeClass("down").addClass("up")
		$(this).find(".text").addClass("highlight")
		$(this).find("ul").removeClass("invisible")
	})
	$("div.menu > ul > .dropdown").mouseleave(function(event) {
		$(this).find(".arrow").removeClass("up").addClass("down")
		$(this).find(".text").removeClass("highlight")
		$(this).find("ul").addClass("invisible")
	})
	$("div.tabs > span").mouseenter(function(event) {
		$(this).addClass("highlight")
	})
	$("div.tabs > span").mouseleave(function(event) {
		$(this).removeClass("highlight")
	})
	$("div.tabs > span").click(function(event) {
		$("div.search > div").addClass("invisible")
		$("div.tabs > span").removeClass("selected")

		$(this).addClass("selected")
		$("#f-" + this.id).removeClass("invisible")
	})
})