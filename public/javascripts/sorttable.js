var rows = []
var sort_id = "rank"
var per_page = 50
var current_page = 1
var sort_asc = 0

function percent_color(percent) {
	return percent >= 0.9 && "green" || percent >= 0.6 && "yellow" || percent >= 0.4 && "orange" || "red"
}

function ilvl_color(ilvl) {
	return ilvl >= 270 && "q5" || ilvl >= 200 && "q4" || ilvl >= 180 && "q3" || ilvl >= 140 && "q2" || "q1"
}

function round(number) {
	if( number == Math.floor(number) ) {
		return number
	}
	
	return number.toFixed(2)
}

function setup_talents(row, role, name, sum, unspent) {
	if( !role ) {
		row.html("<span class='red'>None</span>")
		hookup_tooltip(row, "No talents found.")
	} else if( typeof(unspent) == "undefined" ) {
		row.html(role)
		hookup_tooltip(row, name + ": " + sum)
	} else {
		name = name != "Unknown" ? name + ": " : "";
		
		row.html("<span class='red'>" + unspent + " unspent</span>")
		if( unspent > 1 ) {
			hookup_tooltip(row, name + unspent + " unspent talent points")
		} else {
			hookup_tooltip(row, name + unspent + " unspent talent point")
		}
	}
}

function hookup_tooltip(row, text) {
	row[0].onmouseover = function() { ttlib.showText(text) }
	row[0].onmouseout = ttlib.hide
}

function update_table() {
	var parent = $("#sortlist")
	var total_rows = table_data.length
	var total_rows = total_rows > per_page ? per_page : total_rows
	if( total_rows == 0 ) {
		if( $(".norows").length == 0 ) {
			$("<div class='norows fillrow'>" + NO_RECORDS + "</div>").appendTo(parent)
			$("<div class='norows clearb'></div>").appendTo(parent)
		}
		
		$(".loading").addClass("invisible")
		return
	} else {
		$(".norows").addClass("invisible")
	}
	
	var offset = (current_page - 1) * per_page
	for( var i=0; i < total_rows; i++ ) {
		if( !rows[i] ) {
			var background = i % 2 == 0 ? "darkbg" : "lightbg"
			
			var elements = {}
			var headers = $("div#sortlist > .header")
			for( var j=0; j < headers.length; j++ ) {
				elements[headers[j].id] = $("<div class='" + background + " " + headers[j].id + "' onmouseout='ttlib.hide();'>&nbsp;</div>")
				elements[headers[j].id].appendTo(parent)
			}
			
			$("<div id='clear" + i + "' class='clearb'></div>").appendTo(parent)
			if( i < (total_rows - 1) ) {
				$("<div id='div" + i + "' class='rowdiv'></div>").appendTo(parent)
			}
			
			rows[i] = elements
		} else {
			var elements = rows[i]
		}
		
		var data_row = table_data[i + offset]
		if( data_row ) {
			$("#clear" + i).removeClass("invisible")
			$("#div" + i).removeClass("invisible")
			for( var element in elements ) {
				$(element).removeClass("invisible")
			}

			build_row(elements, data_row)
		} else {
			$("#clear" + i).addClass("invisible")
			$("#div" + i).addClass("invisible")
			
			for( var element in elements ) {
				$(element).addClass("invisible")
			}
		}
	}
	
	$(".loading").addClass("invisible")
}

function update_pagination(page) {
	current_page = page
	var max_pages = Math.ceil(table_data.length / per_page)
	var next_page = current_page < max_pages ? current_page + 1 : 0
	var last_page = current_page > 1 ? current_page - 1 : 0
	
	if( max_pages == 0 ) {
		$(".paginate-top").addClass("invisible")
		$(".paginate-bottom").addClass("invisible")
		return
	}
	
	var html = ""
	if( last_page > 0 ) {
		html = html + "<a href='#p1s" + sort_id + ":" + sort_asc + "' onclick='update_pagination(1); update_table();' title='First page'>&#171;</a>"
		html = html + " <a href='#p" + last_page + "s" + sort_id + ":" + sort_asc + "' onclick='update_pagination(" + last_page + "); update_table();' class='single' title='Page #" + last_page + "'>&lt;</a>&nbsp;&nbsp;"
	}
	
	html = html + current_page + " of " + max_pages
	
	if( next_page > 0 ) {
		html = html + "&nbsp;&nbsp;<a href='#p" + next_page + "s" + sort_id + ":" + sort_asc + "' onclick='update_pagination(" + next_page + "); update_table();' class='single' title='Page #" + next_page + "'>&gt;</a>"
		html = html + " <a href='#p" + max_pages + "s" + sort_id + ":" + sort_asc + "' onclick='update_pagination(" + max_pages + "); update_table();' title='Last page'>&#187;</a>"
	}
	
	paginate = $(".paginate")
	for( var i=0; i < paginate.length; i++ ) {
		$(paginate).html(html)
	}
	
	$(".paginate-top").removeClass("invisible")
	$(".paginate-bottom").removeClass("invisible")
}

function setup_table() {
	var jsdata = location.href.match("#(.+)")
	jsdata = jsdata ? jsdata[1] : ""

	var page = jsdata.match("p([0-9]+)")
	update_pagination(page ? parseInt(page[1]) : 1)
	
	var sort = jsdata.match("s([a-z]+):(0|1)")
	if( sort ) {
		sort_id = $("#" + sort[1]).length > 0 ? sort[1] : default_sorter()
		sort_asc = parseInt(sort[2])
	} else {
		sort_id = default_sorter()
		sort_asc = 1
	}
	
	sort_table($("#" + sort_id), sort_asc || 0)
}

var previous_column = null
function sort_table(header, asc) {
	if( previous_column ) {
		$("." + previous_column).removeClass("ascbg").removeClass("descbg")
	}
		
	if( asc ) {
		$("." + header.attr("id")).addClass("ascbg")
	} else {
		$("." + header.attr("id")).addClass("descbg")
	}
		
	previous_column = header.attr("id")
	table_data.sort(function(a, b) {
		a_val = a[header.attr("id")]
		b_val = b[header.attr("id")]
		
		if( a_val == parseInt(a_val) || a_val == parseFloat(a_val) ) {
			return asc ? a_val - b_val : b_val - a_val
		} else if( a_val == b_val ) {
			if( a.name < b.name ) {
				return asc ? -1 : 1
			} else if( a.name > b.name ) {
				return asc ? 1 : -1
			} else {
				return 0
			}
		} else if( a_val < b_val ) {
			return asc ? -1 : 1
		} else if( a_val > b_val ) {
			return asc ? 1 : -1
		}
		
		return 0
	})
	
	update_table()
}

$(document).ready(function() {
	$("div#sortlist > .header").mouseenter(function(event) {
		$(this).addClass("highlight")
	})
	$("div#sortlist > .header").mouseleave(function(event) {
		$(this).removeClass("highlight")
	})
	$("div#sortlist > .header").click(function(event) {
		if( table_data.length == 0 ) {
			return
		}
		
		$("div#sortlist > .header").removeClass("selected")
		$(this).addClass("selected")
		
		if( sort_id != this.id ) {
			sort_asc = 0
			sort_id = this.id
		} else if( sort_asc == 1 ) {
			sort_asc = 0
		} else {
			sort_asc = 1
		}
		
		update_pagination(current_page)
		sort_table($(this), sort_asc == 1)
		
		var url = location.href.match("(.+)#")
		url = url ? url[1] : location.href
		
		location.href = url + "#p" + current_page + "s" + sort_id + ":" + sort_asc + (typeof(extra_meta) != "undefined" && extra_meta || "")
	})
})
