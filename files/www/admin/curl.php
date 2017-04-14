<?php
		$url = 'https://plugunplug.net/geoip/yourip.php';                                                                       
                $ch = curl_init();
                $timeout = 10;
                curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
                curl_setopt($ch, CURLOPT_HEADER, 0);
                curl_setopt($ch,CURLOPT_URL, $url);
                curl_setopt($ch,CURLOPT_CONNECTTIMEOUT,$timeout);
                curl_setopt($ch,CURLOPT_CAINFO,'/etc/stunnel/server.crt');
                echo curl_exec($ch);
                //echo "unplug SSID: ".$ssid."Status: ONLINE. Tunneled through:".curl_exec($ch);
                curl_close($ch);
?>
