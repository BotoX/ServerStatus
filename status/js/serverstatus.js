// serverstatus.js
var error = 0;
var d = 0;

function timeSince(date) {
	if(date == 0)
		return "never.";

	var seconds = Math.floor((new Date() - date) / 1000);
	var interval = Math.floor(seconds / 31536000);

	if (interval > 1)
		return interval + " years ago.";
	interval = Math.floor(seconds / 2592000);
	if (interval > 1)
		return interval + " months ago.";
	interval = Math.floor(seconds / 86400);
	if (interval > 1)
		return interval + " days ago.";
	interval = Math.floor(seconds / 3600);
	if (interval > 1)
		return interval + " hours ago.";
	interval = Math.floor(seconds / 60);
	if (interval > 1)
		return interval + " minutes ago.";
	/*if(Math.floor(seconds) >= 5)
		return Math.floor(seconds) + " seconds";*/
	else
		return "a few seconds ago.";
}

function uptime() {
	$.getJSON("json/stats.json", function(result) {
		$("#loading-notice").remove();
		if(result.reload)
			setTimeout(function() { location.reload(true) }, 1000);

		for (var i = 0; i < result.servers.length; i++) {
			var TableRow = $("#servers tr#r" + i);
			if (!TableRow.length) {
				$("#servers").append(
					"<tr id=\"r" + i + "\">" +
					"<td id=\"online4\"><div class=\"progress\"><div style=\"width: 100%;\" class=\"progress-bar progress-bar-warning\"><small>Loading</small></div></div></td>" +
					"<td id=\"online6\"><div class=\"progress\"><div style=\"width: 100%;\" class=\"progress-bar progress-bar-warning\"><small>Loading</small></div></div></td>" +
					"<td id=\"name\">Loading...</td>" +
					"<td id=\"type\">Loading...</td>" +
					"<td id=\"host\">Loading...</td>" +
					"<td id=\"location\">Loading...</td>" +
					"<td id=\"uptime\">Loading...</td>" +
					"<td id=\"load\">Loading...</td>" +
					"<td id=\"cpu\"><div class=\"progress progress-striped active\"><div style=\"width: 100%;\" class=\"progress-bar progress-bar-warning\"><small>Loading...</small></div></div></td>" +
					"<td id=\"memory\"><div class=\"progress progress-striped active\"><div style=\"width: 100%;\" class=\"progress-bar progress-bar-warning\"><small>Loading...</small></div></div></td>" +
					"<td id=\"hdd\"><div class=\"progress progress-striped active\"><div style=\"width: 100%;\" class=\"progress-bar progress-bar-warning\"><small>Loading...</small></div></div></td>"
				);
				TableRow = $("#servers tr#r" + i);
			}
			TableRow = TableRow[0];

			// Online4
			if (result.servers[i].online4) {
				TableRow.children["online4"].children[0].children[0].className = "progress-bar progress-bar-success";
				TableRow.children["online4"].children[0].children[0].innerHTML = "<small>Up</small>";
			} else {
				TableRow.children["online4"].children[0].children[0].className = "progress-bar progress-bar-danger";
				TableRow.children["online4"].children[0].children[0].innerHTML = "<small>Down</small>";
			}
			// Online6
			if (result.servers[i].online6) {
				TableRow.children["online6"].children[0].children[0].className = "progress-bar progress-bar-success";
				TableRow.children["online6"].children[0].children[0].innerHTML = "<small>Up</small>";
			} else {
				TableRow.children["online6"].children[0].children[0].className = "progress-bar progress-bar-danger";
				TableRow.children["online6"].children[0].children[0].innerHTML = "<small>Down</small>";
			}
			// Name
			TableRow.children["name"].innerHTML = result.servers[i].name;
			// Type
			TableRow.children["type"].innerHTML = result.servers[i].type;
			// Host
			TableRow.children["host"].innerHTML = result.servers[i].host;
			// Location
			TableRow.children["location"].innerHTML = result.servers[i].location;
			if (!result.servers[i].online4 && !result.servers[i].online6) {
				if (TableRow.children["uptime"].innerHTML != "<div class=\"progress progress-striped active\"><div style=\"width: 100%;\" class=\"progress-bar progress-bar-danger\"><small>Down</small></div></div>") {
					TableRow.children["uptime"].innerHTML = "<div class=\"progress progress-striped active\"><div style=\"width: 100%;\" class=\"progress-bar progress-bar-danger\"><small>Down</small></div></div>";
					TableRow.children["load"].innerHTML = "<div class=\"progress progress-striped active\"><div style=\"width: 100%;\" class=\"progress-bar progress-bar-danger\"><small>Down</small></div></div>";
					TableRow.children["cpu"].children[0].children[0].className = "progress-bar progress-bar-danger";
					TableRow.children["cpu"].children[0].children[0].style.width = "100%";
					TableRow.children["cpu"].children[0].children[0].innerHTML = "<small>Down</small>";
					TableRow.children["memory"].children[0].children[0].className = "progress-bar progress-bar-danger";
					TableRow.children["memory"].children[0].children[0].style.width = "100%";
					TableRow.children["memory"].children[0].children[0].innerHTML = "<small>Down</small>";
					TableRow.children["hdd"].children[0].children[0].className = "progress-bar progress-bar-danger";
					TableRow.children["hdd"].children[0].children[0].style.width = "100%";
					TableRow.children["hdd"].children[0].children[0].innerHTML = "<small>Down</small>";
				}
			} else {
				// Uptime
				TableRow.children["uptime"].innerHTML = result.servers[i].uptime;
				// Load
				TableRow.children["load"].innerHTML = result.servers[i].load;
				// CPU
				if (result.servers[i].cpu >= 90)
					TableRow.children["cpu"].children[0].children[0].className = "progress-bar progress-bar-danger";
				else if (result.servers[i].cpu >= 80)
					TableRow.children["cpu"].children[0].children[0].className = "progress-bar progress-bar-warning";
				else
					TableRow.children["cpu"].children[0].children[0].className = "progress-bar progress-bar-success";
				TableRow.children["cpu"].children[0].children[0].style.width = result.servers[i].cpu + "%";
				TableRow.children["cpu"].children[0].children[0].innerHTML = result.servers[i].cpu + "%";
				// Memory
				if (result.servers[i].memory >= 90)
					TableRow.children["memory"].children[0].children[0].className = "progress-bar progress-bar-danger";
				else if (result.servers[i].memory >= 80)
					TableRow.children["memory"].children[0].children[0].className = "progress-bar progress-bar-warning";
				else
					TableRow.children["memory"].children[0].children[0].className = "progress-bar progress-bar-success";
				TableRow.children["memory"].children[0].children[0].style.width = result.servers[i].memory + "%";
				TableRow.children["memory"].children[0].children[0].innerHTML = result.servers[i].memory + "%";
				// HDD
				if (result.servers[i].hdd >= 90)
					TableRow.children["hdd"].children[0].children[0].className = "progress-bar progress-bar-danger";
				else if (result.servers[i].hdd >= 80)
					TableRow.children["hdd"].children[0].children[0].className = "progress-bar progress-bar-warning";
				else
					TableRow.children["hdd"].children[0].children[0].className = "progress-bar progress-bar-success";
				TableRow.children["hdd"].children[0].children[0].style.width = result.servers[i].hdd + "%";
				TableRow.children["hdd"].children[0].children[0].innerHTML = result.servers[i].hdd + "%";
			}
		};

		d = new Date(result.updated*1000);
		error = 0;
	}).fail(function(update_error) {
		if (!error) {
			$("#servers > tr").each(function(i) {
				var TableRow = $("#servers tr").eq(i)[0];
				TableRow.children["online4"].children[0].children[0].className = "progress-bar progress-bar-error";
				TableRow.children["online4"].children[0].children[0].innerHTML = "<small>Error</small>";
				TableRow.children["online6"].children[0].children[0].className = "progress-bar progress-bar-error";
				TableRow.children["online6"].children[0].children[0].innerHTML = "<small>Error</small>";
				TableRow.children["uptime"].innerHTML = "<div class=\"progress progress-striped active\"><div style=\"width: 100%;\" class=\"progress-bar progress-bar-error\"><small>Error</small></div></div>";
				TableRow.children["load"].innerHTML = "<div class=\"progress progress-striped active\"><div style=\"width: 100%;\" class=\"progress-bar progress-bar-error\"><small>Error</small></div></div>";
				TableRow.children["cpu"].children[0].children[0].className = "progress-bar progress-bar-error";
				TableRow.children["cpu"].children[0].children[0].style.width = "100%";
				TableRow.children["cpu"].children[0].children[0].innerHTML = "<small>Error</small>";
				TableRow.children["memory"].children[0].children[0].className = "progress-bar progress-bar-error";
				TableRow.children["memory"].children[0].children[0].style.width = "100%";
				TableRow.children["memory"].children[0].children[0].innerHTML = "<small>Error</small>";
				TableRow.children["hdd"].children[0].children[0].className = "progress-bar progress-bar-error";
				TableRow.children["hdd"].children[0].children[0].style.width = "100%";
				TableRow.children["hdd"].children[0].children[0].innerHTML = "<small>Error</small>";
			});
		}
		error = 1;
		$("#updated").html("Update error.");
	});
}

function updateTime() {
	if (!error)
		$("#updated").html("Last updated: " + timeSince(d));
}

uptime();
updateTime();
setInterval(uptime, 2000);
setInterval(updateTime, 500);


// styleswitcher.js
function setActiveStyleSheet(title) {
	var i, a, main;
	for(i=0; (a = document.getElementsByTagName("link")[i]); i++) {
		if(a.getAttribute("rel").indexOf("style") != -1 && a.getAttribute("title")) {
			a.disabled = true;
			if(a.getAttribute("title") == title) a.disabled = false;
		}
	}
}

function getActiveStyleSheet() {
	var i, a;
	for(i=0; (a = document.getElementsByTagName("link")[i]); i++) {
		if(a.getAttribute("rel").indexOf("style") != -1 && a.getAttribute("title") && !a.disabled)
			return a.getAttribute("title");
	}
	return null;
}

function getPreferredStyleSheet() {
	var i, a;
	for(i=0; (a = document.getElementsByTagName("link")[i]); i++) {
		if(a.getAttribute("rel").indexOf("style") != -1	&& a.getAttribute("rel").indexOf("alt") == -1 && a.getAttribute("title"))
			return a.getAttribute("title");
	}
return null;
}

function createCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ')
			c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0)
			return c.substring(nameEQ.length,c.length);
	}
	return null;
}

window.onload = function(e) {
	var cookie = readCookie("style");
	var title = cookie ? cookie : getPreferredStyleSheet();
	setActiveStyleSheet(title);
}

window.onunload = function(e) {
	var title = getActiveStyleSheet();
	createCookie("style", title, 365);
}

var cookie = readCookie("style");
var title = cookie ? cookie : getPreferredStyleSheet();
setActiveStyleSheet(title);
