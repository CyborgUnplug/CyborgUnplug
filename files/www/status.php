<?php
/*Resourced by header.php
GeoIP status updates end-to-end encrypted */

    $f1 = fopen("config/ssid", "r");
    $ssid=fgets($f1);                                                                                                                              
    $fn2='config/networkstate';
    if (file_exists($fn2)) {
        $f2 = fopen("config/networkstate", "r");
        $g=fgets($f2);                                                                                                                              
        if ($g) {
            if (preg_match('/online/', $g) == 1) {
                $url = 'http://wtfismyip.com/text';
                $ch = curl_init();
                $timeout = 5;
                curl_setopt($ch,CURLOPT_URL, $url);
                curl_setopt($ch,CURLOPT_CONNECTTIMEOUT,$timeout);
                echo $ssid." <b>Status</b> ONLINE "; 
                $vpnstatus = fopen("config/vpnstatus", "r");
                $h=fgets($vpnstatus);
                if (preg_match('/up/', $h) == 1) {
                    echo "<b>Tunneled via</b> ";
                } 
                else {
                    echo "<b>Routed via</b> ";
                }
                curl_exec($ch);
                //echo "unplug SSID: ".$ssid."Status: ONLINE. Tunneled through:".curl_exec($ch);
                curl_close($ch);
            }
            else if (preg_match('/offline/', $g) == 1) {
                echo $ssid."<b>Status</b> OFFLINE";
            }
        }
    }
?>
