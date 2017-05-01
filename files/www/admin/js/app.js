// Cyborg Unplug - Little Snipper
// Javascript used throughout the admin interface

var updateStatus = function(response) {

	var css_wifi       = 'wifi wifi-off wifi-error'
	var icons_wifi     = 'icon-wifi icon-wifi-off icon-wifi-error'
	var icons_vpn      = 'icon-vpn-connecting icon-vpn-error icon-vpn-tunneled'
	var colors         = 'waiting connecting connected tunneled disconnected'
	var status_icon    = "icon-connection-error"
	var status_message = response.message
	var flag_img       = '<img src="/img/blank.png" class="flag flag-ISO">'

	// Wifi & other
	if (response.ssid == "unavailable") {
		var wifi_css  = "wifi-error"
		var wifi_icon = "icon-wifi-error"
		var wifi_text = "Wifi Unavailable"
	} else {
		var wifi_css  = "wifi"
		var wifi_icon = "icon-wifi"					
		var wifi_text = response.ssid
	}

	$wifi = $('#your-wifi')
	$wifi.removeClass(css_wifi).add(wifi_css)
	$wifi.find('i').removeClass(icons_wifi).addClass(wifi_icon)
	$wifi.find('span').html(wifi_text)

	// Connection Status
	if (response.status == "tunneled" && response.vpn == "up") {
		var status_icon = "icon-vpn-tunneled"
	} else if (response.status == "connecting" && response.vpn == "start") {
		var status_icon = "icon-vpn-connecting"
	} else if (response.status == "connecting") {
		var status_icon = "icon-connecting"
	} else if (response.status == "connected") {
		var status_icon = "icon-connected"
	} else if (response.status == "disconnected") {
		var status_icon = "icon-disconnected"
	}

	$('#status_icon')
		.removeClass(colors)
		.addClass(response.status)
		.html('<i class="'+ status_icon + '"></i>')
	$('#status_message').html(status_message)

	// Connection Route
	if (response.ip_country == 'Unspecified') {
		$('#status-type').css('text-align', 'center')	
		$('#status-route').hide()
	} else {
		var flag = flag_img.replace('ISO', response.ip_iso.toLowerCase())
		var route = response.ip_country + ' <em>' + response.ip + '</em>'
		$('#status-route').find('span.flag').html(flag)
		$('#status-route').find('span.country').html(route)
		$('#status-route').show()
	}

	// Footer Device
	$('footer').find('li:nth-child(2)').html('Little Snipper ' + response.version)
	$('footer').find('li:nth-child(3)').html('ID: ' + response.mac)
	$('footer').find('li:nth-child(4)').html('Version: ' + response.rev)
}

// Wifi Bridge (show / hide password field)
function checkForPw() {
	var myselect = $("#bridge").val();
	if(myselect.split(",")[3] != 'off') {
		$("#bridgepw").css('visibility', 'visible')
	} else {
		$("#bridgepw").css('visibility', 'hidden');
	}
}

var $checkboxes
function chooser() {         
	var choices = $checkboxes.map(function() {
		if (this.checked) {
			return this.id
		}
	}).get().join(' ')
	document.getElementById("checkList").value = choices
}

$(function() {
	$checkboxes = $('input[type=checkbox]').change(chooser)

	$('.navLink').on('click', function(e){
		e.preventDefault()
		var targetDiv = $($(this).attr('href'))
		if (targetDiv.css('visibility') == 'visible'){
			$('.page').css('display', 'none')
			targetDiv.css('display', 'inline')
		}
		else {
			$('.page').css('display', 'none')
		}
	})
})
