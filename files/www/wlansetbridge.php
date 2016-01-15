<?php include 'header.php';

if (! isset($_POST['ssid']) || ! isset($_POST['password']) || ! isset($_POST['channel'])) {
    echo "<div class='warning'>";
    echo "Nothing entered...nothing to do.\n";
    echo "</div>";
    echo "<form method='get' id='wlanbridge' action='wlanbridge.php'>";
    echo "<input name='wlanbridge' type='hidden' value='wlanbridge'>";
    echo "<input type='submit' value='try again' class='button'>";
    echo "</form>";

} else {
    if(isset($_POST['ssid'])) {
        $ssid = $_POST['ssid'];
        $fn1 ='/www/config/ssid'; 
        $f1 = fopen($fn1, 'w');
        $ret = fwrite($f1, $ssid);
        fclose($f1); 
        echo "This is the new ESSID: ".$ssid;
        if($ret === false) {
            die('There was an error writing this file');
        }
    }
    if(isset($_POST['password'])) {
        $pw = $_POST['password'];
        $fn2 ='/www/config/wlanbridgepw'; 
        $f2 = fopen($fn2, 'w');
        $ret = fwrite($f2, $pw);
        fclose($f2); 
        echo "This is the new password: ".$pw;
        if($ret === false) {
            die('There was an error writing this file');
        } 
    }
    echo "<div class='warning warning3'>";
    echo "WLAN bridge data saved.\n";
    //echo "$ret bytes written to auth file";
    echo "</div>";
    echo "<div class='warning warning3'>";
    echo "Please note that after pressing the button below\n";
    echo "you'll no longer be able to connect by WiFi. Use your Ethernet cable
to connect your laptop or device to the LAN port on Little Snipper \n";
    echo "</div>";
    echo "<form method='get' id='wlanrestart' action='cgi-bin/config.cgi'>";
    echo "<input name='wlanrestart' type='hidden' value='wlanrestart'>";
    echo "<input type='submit' value='reboot wifi' class='button'>";
    echo "</form>";
}

include 'footer.php';?>
