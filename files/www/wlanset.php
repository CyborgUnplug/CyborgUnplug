<?php include 'header.php';

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
        $fn2 ='/tmp/config/wlanpw'; 
        $f2 = fopen($fn2, 'w');
        $ret = fwrite($f2, $pw);
        fclose($f2); 
        if($ret === false) {
            die('There was an error writing this file');
        } 
    }
    if(isset($_POST['channel'])) {
        $channel = $_POST['channel'];
        $fn3 ='/www/config/channel'; 
        $f3 = fopen($fn3, 'w');
        $ret = fwrite($f3, $channel);
        fclose($f3); 
        if($ret === false) {
            die('There was an error writing this file');
        } 
    }
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

include 'footer.php';?>
