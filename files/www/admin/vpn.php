<?php
$page_title = "VPN";
include('header.php');
include('network-status.php');
$network = get_network_status();

// Connecting to VPN
if ($network["vpn"] == "start") {
    echo "<br><br>";
    echo "<div class='warning warning3'>";
    echo "Connecting to VPN...\n";
    echo "<img src='../img/loading.gif'>";
    echo "</div>";
    echo "<form action='vpn.php'>"; 
    echo "<input name='refresh' type='submit' class='button' value='refresh'>";
    echo "</form>";
    // TODO: make this work via JavaScript instead
    $secondsWait = 5;
    echo '<meta http-equiv="refresh" content="'.$secondsWait.'">';

// Successfully tunneled
} else if ($network["status"] == "tunneled" && $network["vpn"] == "up") {
	if ($network["status"] == "tunneled") {
		echo "<div class='warning warning3'>";
		echo "<b>The VPN is up.</b>";
		echo "<br>Check your IP via <a href='http://checkip.com'>checkip.com</a> before browsing.";
		echo "</div>";
		// Load specified VPN file
		$fn='/www/config/vpn';
		if (file_exists($fn)) {
			$f1 = fopen("/www/config/vpn", "r");
			$g=fgets($f1);
				if ($g) {

					echo "<div class='warning'>";
					echo "<center>";
					echo "Devices connected before VPN was active should immediately reconnect<br>";
					echo "</center>";
					echo "</div>";
					echo "<form method='get' id='stopvpn' action='cgi-bin/config.cgi'>";
					echo "<input name='stopvpn' type='hidden' value='stopvpn'>";
					echo "<input type='submit' value='Stop vpn' class='button'>";
					echo "</form>";
					echo "<form method='get' id='checkvpn' action='cgi-bin/config.cgi'>";
					echo "<input name='checkvpn' type='hidden' value='checkvpn'>";
					echo "<input type='submit' value='Check vpn' class='button'>";
					echo "</form>";

					// Use Custom VPN
					$savedvpn='/www/config/savedvpn';
					if (file_exists($savedvpn)) {
							// see if our current VPN is a saved VPN
							if (sha1_file($fn) == sha1_file($savedvpn)) {
                                echo "<br>";
                                echo "<hr>";
								echo "<h3>This is your default VPN</h3>";
								echo "<form method='get' id='removevpn' action='cgi-bin/config.cgi'>";
								echo "<input name='removevpn' type='hidden' value='removevpn'>";
								echo "<input type='submit' value='Unset as default' class='button'>";
								echo "</form>";
							} else {
								echo "<form method='get' id='savevpn' action='cgi-bin/config.cgi'>";
								echo "<input name='savevpn' type='hidden' value='savevpn'>";
								echo "<input type='submit' value='Make this vpn my default' class='button'>";
								echo "</form>";
							}
					} else {
						// TODO: messy double up here. fix
						echo "<form method='get' id='savevpn' action='cgi-bin/config.cgi'>";
						echo "<input name='savevpn' type='hidden' value='savevpn'>";
						echo "<input type='submit' value='Make this vpn my default' class='button'>";
						echo "</form>";
					}

					$vpnlog='/var/log/openvpn.log';
					if (file_exists($vpnlog)) {
						$f3 = fopen("/var/log/openvpn.log", "r");
						echo "<hr>";
						echo "<h3>VPN Debug Output</h3>";
						echo "<div class='stdout'>";
						while(! feof($f3)) {
							echo fgets($f3). "<br />";
						}
						echo "</div>";
					fclose($f3);
					}
			fclose($f1);
			}
		}

	} else {

		echo "<div class='warning'>";
		echo "It seems you are currently offline.<br>";
		echo "Please check any Ethernet cables and that the device "; 
		echo "you are connected to is online. <br>";
		echo "Please note that it will time out shortly...";
		echo "</div>";
	}

} else if ($network["status"] == "tunneled" && $network["vpn"] == "down") {
    echo "<br>";
    echo "<div class='warning'>";
    echo "The VPN is not running\n";
    echo "<br>";
    echo "</div>";
    echo "<form method='get' id='newvpn' action='cgi-bin/config.cgi'>";
    echo "<input name='newvpn' type='hidden' value='newvpn'>";
    echo "<input type='submit' value='Start over' class='button'>";
    echo "</form>";
    echo "<div class='warning warning3'>";
    echo "If you've just tried to connect and it failed, check usernames and passwords (if any).\n";
    echo "Also, be sure an ethernet cable is connected from the WAN port to\n";
    echo "your wired Internet connection.\n";
    echo "</div>";
    $vpnlog='/var/log/openvpn.log';
    if (file_exists($vpnlog)) {
        $f3 = fopen("/var/log/openvpn.log", "r");
        echo "<hr>";
        echo "<h3>Debug output</h3>";
        echo "<div class='stdout'>";
        while(! feof($f3)) {
            echo fgets($f3). "<br />";
        }
        echo "</div>";
	    fclose($f3);
    }

} else {
    // Сheck that we have a VPN file
    if ((!empty($_FILES["uploaded_file"])) && ($_FILES['uploaded_file']['error'] == 0)) {
      $filename = basename($_FILES['uploaded_file']['name']);
      $ext = substr($filename, strrpos($filename, '.') + 1);
      if ($_FILES["uploaded_file"]["size"] < 20000) {
        //Determine the path to which we want to save this file
          $newname = '/tmp/keys/'.$filename;
          //Check if the file with the same name is already exists on the server
          if (!file_exists($newname)) {
            //Attempt to move the uploaded file to it's new place
            if ((move_uploaded_file($_FILES['uploaded_file']['tmp_name'],$newname))) {
              echo "<div class='warning warning3'>";
              echo "OpenVPN config uploaded.";
              echo "</div>";
              $conffile=true;
            } else {
              echo "<div class='warning warning2'>";
              echo "Error uploading. Please check file permissions.";
              echo "</div>";
              $conffile=false;
            }
          } else {
              echo "<div class='warning'>";
              echo "Overwriting file of the same name: ".$_FILES["uploaded_file"]["name"];
              echo "</div>";
              echo "<br>";
              $conffile=true;
          }
      } else {
          echo "<div class='warning'>";
          echo "Error: No file uploaded";
          echo "</div>";
          $conffile=false;
     }
    }
    if (!empty($_POST['username']) && !empty($_POST['password'])) {
        $data = $_POST['username']."\n".$_POST['password'];
        $fn ='/tmp/keys/'.$filename.'.auth'; 
        $f = fopen($fn, 'w');
        $ret = fwrite($f, $data);
        fclose($f); 
        if ($ret === false) {
            die('There was an error writing this file');
            $authfile=false;

        } else {
              echo "<div class='warning warning3'>";
              echo "OpenVPN login data saved.\n";
              //echo "$ret bytes written to auth file";
              echo "</div>";
              //echo "this is the form data ".$data;
              $authfile=true;
        }
    } else {
        echo '<meta http-equiv="refresh" content="10">';
        echo "<br>";
        echo "<div class='warning'>";
        echo "The VPN is not running\n";
        echo "</div>";
        echo "<br>";
        echo "<form method='get' id='newvpn' action='cgi-bin/config.cgi'>";
        echo "<input name='newvpn' type='hidden' value='newvpn'>";
        echo "<input type='submit' value='Start over' class='button'>";
        echo "</form>";
        echo "<form action='index.php'>";
        echo "<input type='submit' value='Main menu' class='button'>";
        echo "</form>";
    }

    if (!$conffile == false) {
        if (($authfile === true) && ($conffile === true)) {
            $_extvpn="1 ".$filename;
        }
        elseif ($conffile === true) {
            $_extvpn="0 ".$filename;
        }
        $extvpn=base64_encode($_extvpn);
        
        echo "<form method='get' id='extvpn' action='cgi-bin/config.cgi'>";
        echo "<input name='extvpn' type='hidden' value=".$extvpn.">";
        echo "<input type='submit' value='start vpn' class='button'>";
        echo "</form>";
    }
}
include('footer.php');?>
