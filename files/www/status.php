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
                $url = 'https://plugunplug.net/geoip/yourip.php';
                $ch = curl_init();
                $timeout = 5;
                curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                curl_setopt($ch, CURLOPT_HEADER, 0); 
                curl_setopt($ch,CURLOPT_URL, $url);
                curl_setopt($ch,CURLOPT_CONNECTTIMEOUT,$timeout);
                curl_setopt($ch,CURLOPT_CAINFO,'/etc/stunnel/server.crt');
                echo "<b>ESSID</b> ".$ssid."<b>Status</b> ONLINE "; 
                $vpn='config/vpn';
                if (file_exists($vpn)) {
                    echo "<b>Tunneled through</b> ";
                } 
                else {
                    echo "<b>Routed through</b> ";
                }
                curl_exec($ch);
                //echo "unplug SSID: ".$ssid."Status: ONLINE. Tunneled through:".curl_exec($ch);
                curl_close($ch);
            }
            else if (preg_match('/offline/', $g) == 1) {
                echo "<b>SSID</b> ".$ssid."<b>Status</b> OFFLINE";
            }
        }
    }
?>
