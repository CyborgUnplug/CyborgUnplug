<?php include 'header.php';

// determine current state of VPN connection 
$fn='config/vpnstatus';
if (file_exists($fn)) {
    $f = fopen("config/vpnstatus", "r");
    $g=fgets($f);                                                                                                                              
    if ($g) {
        if (preg_match('/down/', $g) == 1) {
            $vpnup=3;
        }
        else if (preg_match('/unconfigured/', $g) == 1) {
            $vpnup=2;
        }
        else if (preg_match('/up/', $g) == 1) {
            $vpnup=1;
        }
        else if (preg_match('/start/', $g) == 1) {
            $vpnup=0;
        }
        //else if (preg_match('/stop/', $g) == 1) {
        //    $vpnup=3;
        //}
    }
}
fclose($f);
if ($vpnup == 0) {
    echo "<br><br>";
    echo "<div class='warning warning3'>";
    echo "Conversing with server...\n";
    echo "<img src='img/loading.gif'>";
    echo "</div>";
    echo "<form action='vpn.php'>"; 
    echo "<input name='refresh' type='submit' class='button' value='refresh'>";
    echo "</form>";
    $secondsWait = 5;
    echo '<meta http-equiv="refresh" content="'.$secondsWait.'">';
} else if ($vpnup == 1) {
    echo '<meta http-equiv="refresh" content="20">';
    $url = 'https://plugunplug.net/geoip/yourip.php';
    $ch = curl_init();
    $timeout = 5;
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_HEADER, 0); 
    curl_setopt($ch,CURLOPT_URL, $url);
    curl_setopt($ch,CURLOPT_CONNECTTIMEOUT,$timeout);
    curl_setopt($ch,CURLOPT_CAINFO,'/etc/stunnel/server.crt');
    echo "<br>";
    echo "<div class='warning warning3'>";
    echo "<center>";
    echo "VPN is up, now tunneled via <br>";
    curl_exec($ch);
    curl_close($ch);
    echo "<br>Check at <a href='http://checkip.com'>checkip.com</a>";
    $fn='/www/config/vpn';
    if (file_exists($fn)) {
        $f1 = fopen("/www/config/vpn", "r");
        $g=fgets($f1);                                                                                                                              
        if ($g) {
            if (! preg_match('/plugunplug.ovpn/', $g) == 1) {
                echo "<br><br>NOTE: if the status bar reads 'OFFLINE', it may be because this VPN blocks ICMP ('ping') packets. Try browsing to see if you're really online";
            }
        fclose($f1);
        }
    }
    echo "</center>";
    echo "</div>";
    echo "<div class='warning'>";
    echo "<center>";
    echo "Devices connected before VPN was active should immediately reconnect<br>";
    echo "</center>";
    echo "</div>";
    echo "<br>";
    echo "<form method='get' id='stopvpn' action='cgi-bin/config.cgi'>";
    echo "<input name='stopvpn' type='hidden' value='stopvpn'>";
    echo "<input type='submit' value='Stop VPN' class='button'>";
    echo "</form>";
    echo "<form method='get' id='checkvpn' action='cgi-bin/config.cgi'>";
    echo "<input name='checkvpn' type='hidden' value='checkvpn'>";
    echo "<input type='submit' value='Check VPN' class='button'>";
    echo "</form>";
} else if ($vpnup == 3) {
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

} else {
    //Сcheck that we have a file
    if((!empty($_FILES["uploaded_file"])) && ($_FILES['uploaded_file']['error'] == 0)) {
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
    if(!empty($_POST['username']) && !empty($_POST['password'])) {
        $data = $_POST['username']."\n".$_POST['password'];
        $fn ='/tmp/keys/'.$filename.'.auth'; 
        $f = fopen($fn, 'w');
        $ret = fwrite($f, $data);
        fclose($f); 
        if($ret === false) {
            die('There was an error writing this file');
            $authfile=false;

        }
        else {
              echo "<div class='warning warning3'>";
              echo "OpenVPN login data saved.\n";
              //echo "$ret bytes written to auth file";
              echo "</div>";
              //echo "this is the form data ".$data;
              $authfile=true;
        }
    }
    else {
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
        echo "<input type='submit' value='Start VPN' class='button'>";
        echo "</form>";
    }
}
include 'footer.php';?>
