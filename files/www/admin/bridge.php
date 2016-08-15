<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	 <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">

	<title>Cyborg Unplug Configuration</title>
	<link rel="stylesheet" href="style.css"/>
	<script src="jquery-1.11.1.min.js"></script>
	<script> 
		var $checkboxes;
		function chooser() {         
		    var choices = $checkboxes.map(function() {
		        if(this.checked) return this.id;
		    }).get().join(' ');
		    document.getElementById("checkList").value = choices;
		}
		$(function() {
		    $checkboxes = $('input:checkbox').change(chooser);
	
			$('.navLink').on('click', function(e){
			    e.preventDefault();
			    var targetDiv = $($(this).attr('href'));
			    if(!targetDiv.is(':visible')){
			        $('.page').slideUp(100);
			        targetDiv.slideDown(100);
			    }
			    else{
			        $('.page').slideUp(0);
			    }
			});
		});
	</script>
<script> 
    var auto_refresh = setInterval(
    function()
    {
        $('#status').fadeOut('slow').load('status.php').fadeIn("slow");
    }, 5000);
</script>
<script>
        var $r;
        function checkForPw() {
                var myselect = document.getElementById("bridge");
                var rid=myselect.id;
                console.log(rid);
                if(myselect.value.slice(-1) != 'off') {
                        document.getElementById("bridgepw").style.visibility = "visible";
                } else {
                        document.getElementById("bridgepw").style.visibility = "hidden";
                }
                
        }
</script>


</head>
<body>
	<div id="container">
        <div id="status" class="container_status">
        Awaiting status...
        </div>
        <center>
        <br>
        <a href="index.php">
		<img src="img/logo.png" alt="unplug" title="" width="510" height="166" id="logo" />
        </a>
        </center>
    <center>
    <h1 id="headline">Setup WiFi bridge</h1>
    <?php
        $d = fopen("config/vpnstatus", "r");
        $e=fgets($d);
        if (preg_match('/up/', $e) == 1) {
            echo "<br>";
            echo "<div class='warning'>";
            echo "Seems there's a VPN running. Please stop it before creating a bridge, then start it again once the bridge is up and you're online";
            echo "</div>"; 
            echo "<br>";
            echo "<form method='get' id='stopvpn' action='cgi-bin/config.cgi'>";
            echo "<input name='stopvpn' type='hidden' value='stopvpn'>";
            echo "<input type='submit' value='stop vpn' class='button'>";
            echo "</form>";
            fclose($d);
        } else {
            echo "<form enctype='multipart/form-data' action='bridgeset.php' method='post'>";
            echo "</center>";
            echo "<select class='networks' name='bridge' onchange='checkForPw()' id='bridge'>";
            echo "<option class='networks' id='nothing'>Choose a network...</option>"; 
            $f = fopen("data/networks", "r");
            while(!feof($f)) { 
                $g=fgets($f);
                $parts = explode(',', $g);
                if ($parts[1]) {
                    $data=$parts[0].','.$parts[1].','.$parts[2].','.$parts[3];
                    echo "<option id=$data name=$data value=$data>".base64_decode($parts[1])."</option>"; 
                    /*
                    if ($parts[3] == '1') {
                        echo "<input name='n$data' for=$data min='8' max='63' id='pw$data' type='text' placeholder='password' style='visibility:hidden' >";
                    }
                    */
                }
            }
            fclose($f);
            echo "</select>";
            echo "<div id='bridgepw' style='visibility:hidden'>";
            echo "<input name='password'min='8' max='63' type='text' value='' placeholder='wifi passphrase' >";
            echo "</div>";
            echo "<center>";
            echo "<input type='submit' value='NEXT' class='btnnext'>";
            echo "</form>";
            echo "</center>";
        }
    ?>

<?php include 'footer.php';?>
