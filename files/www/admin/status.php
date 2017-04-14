<?php
/*Resourced by header.php
GeoIP status updates end-to-end encrypted */

    $f1 = fopen("/www/admin/config/ssid", "r");
    $ssid=fgets($f1);
    fclose($f1);
    $fn='/www/admin/config/networkstate';
    if (file_exists($fn)) {
        $f2 = fopen("/www/admin/config/networkstate", "r");
        $g=fgets($f2);
        if ($g) {
            if (preg_match('/online/', $g) == 1) {
                $parts = explode('online', $g);
                echo $ssid."<b> Status</b> ONLINE "; 
                $vpnstatus = fopen("/www/admin/config/vpnstatus", "r");
                $h=fgets($vpnstatus);
                if (preg_match('/up/', $h) == 1) {
                    echo "<b>Tunneled via</b>.$parts[1]";
                } 
                else {
                    echo "<b>Routed via</b>.$parts[1]";
                }
                fclose($vpnstatus);
            }
            else if (preg_match('/offline/', $g) == 1) {
                echo $ssid."<b>Status</b> OFFLINE";
            }
        }
        fclose($f2);
    }
?>
