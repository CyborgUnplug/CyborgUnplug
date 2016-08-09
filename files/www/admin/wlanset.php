<?php include 'header.php';

$gtg=1;
if (! isset($_POST['ssid']) || ! isset($_POST['password']) || ! isset($_POST['channel'])) {
    echo "<div class='warning'>";
    echo "Nothing entered...nothing to do.\n";
    echo "</div>";
    echo "<form method='get' id='wlanconf' action='wlanconf.php'>";
    echo "<input name='wlanconf' type='hidden' value='wlanconf'>";
    echo "<input type='submit' value='try again' class='button'>";
    echo "</form>";

} else {
    if(isset($_POST['ssid'])) {
        $ssid = $_POST['ssid'];
        $fn1 ='/www/config/ssid'; 
        $f1 = fopen($fn1, 'w');
        $ret = fwrite($f1, $ssid);
        fclose($f1); 
        if($ret === false) {
            die('There was an error writing this file');
        }
    }
    if(isset($_POST['password'])) {
        $pw = $_POST['password'];
        $min = 8;
        $max = 63;
        if (strlen($pw) > $max ) {
            $gtg=0;
            echo "<div class='warning'>";
            echo "Password too long: must not be longer than 63 characters.\n";
            echo "</div>";
            echo "<form method='get' id='wlanconf' action='wlanconf.php'>";
            echo "<input name='wlanconf' type='hidden' value='wlanconf'>";
            echo "<input type='submit' value='try again' class='button'>";
            echo "</form>";
        } elseif (strlen($pw) < $min) {
            $gtg=0;
            echo "<div class='warning'>";
            echo "Password too short: must be 8 characters or longer.\n";
            echo "</div>";
            echo "<form method='get' id='wlanconf' action='wlanconf.php'>";
            echo "<input name='wlanconf' type='hidden' value='wlanconf'>";
            echo "<input type='submit' value='try again' class='button'>";
            echo "</form>";
        } else {
            $fn2 ='/tmp/config/wlanpw'; 
            $f2 = fopen($fn2, 'w');
            $ret = fwrite($f2, $pw);
            fclose($f2); 
            if($ret === false) {
                die('There was an error writing this file');
            } 
        }
    }
    if(isset($_POST['channel'])) {
        $channel = $_POST['channel'];
        $max = 13;
        if ($channel > $max) {
            $gtg=0;
            echo "<div class='warning'>";
            echo "Channels cannot be higher than 13. Please choose a lower number.\n";
            echo "</div>";
            echo "<form method='get' id='wlanconf' action='wlanconf.php'>";
            echo "<input name='wlanconf' type='hidden' value='wlanconf'>";
            echo "<input type='submit' value='try again' class='button'>";
            echo "</form>";
        } else {
            $fn3 ='/www/config/channel'; 
            $f3 = fopen($fn3, 'w');
            $ret = fwrite($f3, $channel);
            fclose($f3); 
            if($ret === false) {
                die('There was an error writing this file');
            } 
        }
    }
    if ( $gtg == 1 ){
        echo "<div class='warning warning3'>";
        echo "WLAN data saved.\n";
        //echo "$ret bytes written to auth file";
        echo "</div>";
        echo "<div class='warning warning3'>";
        echo "Select reboot below to restart the WiFi.\n";
        echo "You'll need to log in with the new settings.\n";
        echo "</div>";
        echo "<form method='get' id='wlanrestart' action='cgi-bin/config.cgi'>";
        echo "<input name='wlanrestart' type='hidden' value='wlanrestart'>";
        echo "<input type='submit' value='reboot wifi' class='button'>";
        echo "</form>";
    }
}

include 'footer.php';?>
