<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
	<title>Cyborg Unplug Configuration</title>
	<link rel="stylesheet" href="style.css"/>
	<link rel="stylesheet" href="flags.min.css">
	<script src="zepto-1.2.0.min.js"></script>
	<script> 
		var $checkboxes;
		function chooser() {         
		    var choices = $checkboxes.map(function() {
		        if(this.checked) return this.id;
		    }).get().join(' ');
		    document.getElementById("checkList").value = choices;
		}

		$(function() {
		    $checkboxes = $('input[type=checkbox]').change(chooser);
	
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
			});
		});

		// Connection Status 
		var statuses = 'waiting connecting connected tunneled disconnected'
		var img = '<img src="img/blank.png" class="flag flag-ISO">'
		var auto_refresh = setInterval(function() {
			$.getJSON('status.php', function(response) {
  				//console.log(response)

				var flag = img.replace('ISO', response.ip_iso.toLowerCase())
				var content = flag + " " + response.message

				$('#status')
					.removeClass(statuses)
					.addClass(response.status)
					.html(content)
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
        <div id="status" class="container_status waiting">
        Getting network status...
        </div>
        <center>
        <a href="index.php">
			<img src="img/logo.png" alt="Cyborg Unplug" title="" width="510" height="166" id="logo">
        </a>
        </center>
