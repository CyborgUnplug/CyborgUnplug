<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
	<title>Cyborg Unplug Configuration</title>
	<link rel="stylesheet" href="style.css">
	<link rel="stylesheet" href="flags.min.css">
    <link type="image/ico" rel="icon" href="img/little-snipper-36.png">
	<script src="zepto-1.2.0.min.js"></script>
	<script>
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

		// Connection Status 
		var icons_wifi = 'icon-wifi icon-wifi-off icon-wifi-error'
		var icons_vpn = 'icon-vpn-connecting icon-vpn-error icon-vpn-tunneled'
		var colors = 'waiting connecting connected tunneled disconnected'
		var img = '<img src="img/blank.png" class="flag flag-ISO">'
		var auto_refresh = setInterval(function() {
			$.getJSON('status.php', function(response) {

  				console.log(response)

				// Wifi & other
				if (response.ssid == "unavailable") {
					var wifi_icon = "icon-wifi-error"
					var wifi_text = "Wifi Unavailable"
				} else {
					var wifi_icon = "icon-wifi"					
					var wifi_text = response.ssid
				}

				$('#your-wifi').find('i')
						.removeClass(icons_wifi)
						.addClass(wifi_icon)
				$('#your-wifi').find('span')
						.html(wifi_text)

				// Connection status
				$('#status_color')
					.removeClass(colors)
					.addClass(response.status)
				$('#status_message').html(response.message)

				if (response.ip_country != 'Unspecified') {
					var flag = img.replace('ISO', response.ip_iso.toLowerCase())
					var route = 'Routed via ' + response.ip_country

					$('#status_flag').html(flag)
					$('#status_route').html(route)
					$('#status_ip').html(response.ip)
				}
			})
    	}, 5000);

		// Wifi Bridge (show / hide password field)
		function checkForPw() {
			var myselect = $("#bridge").val();
			if(myselect.split(",")[3] != 'off') {
				$("#bridgepw").css('visibility', 'visible')
			} else {
				$("#bridgepw").css('visibility', 'hidden');
			}
		}
	</script>
</head>
<body>
	<div id="container">
		<div id="header">
			<div id="header-top">
				<a href="index.php">
					<img src="img/logo.png" alt="Cyborg Unplug" title="Cyborg Unplug" id="logo">
				</a>
				<div id="header-buttons">
					<form method="get" action="wifi.php">
						<button type="submit" id="your-wifi">
							<i class="icon-wifi-off"></i>
							<span>Unavailable</span>
						</button>
					</form>
					<form method="get" action="cgi-bin/config.cgi">
						<button name="reboot" type="submit" value="reboot">
							<i class="icon-reboot"></i>
							Reboot
						</button>
					</form>
					<form action="configure.php">
						<button name="configure" type="submit" value="settings">
							<i class="icon-settings"></i>
							Settings
						</button>
					</form>
				</div>
				<div class="clearfix"></div>
			</div>
			<div id="status">
				<span id="status_color" class="waiting"></span> 
				<span id="status_message">Getting network status...</span>
				<span id="status_flag"></span>
				<span id="status_route"></span>
				<span id="status_ip"></span>
			</div>
		</div>
