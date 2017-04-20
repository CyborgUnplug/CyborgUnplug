<?php
/* Resourced via an AJAX call in header.php
 - Checks files on disk for various states
 - GeoIP status updates end-to-end encrypted 
 - Returns JSON response
*/

// Headers
header('Content-Type: application/json;charset=utf-8');
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

// Default
$response = [
	"ssid" => "unknown",
	"status" => "waiting", 
	"message" => "Waiting to connect",
	"ip" => "0.0.0.0",
	"ip_country" => "Unspecified",
	"ip_iso" => "NONE"	
];

// Get Device Info
$f1 = fopen("/www/admin/config/ssid", "r");
$response["ssid"] = fgets($f1);
fclose($f1);

// Get Network Info
$fn='/www/admin/config/networkstate';
if (file_exists($fn)) {

	$f2 = fopen("/www/admin/config/networkstate", "r");
	$g=fgets($f2);
	if ($g) {
		if (preg_match('/online/', $g) == 1) {
			$parts_state = explode('online', $g);
			$parts = explode(' ', $parts_state[1]);

			$response["status"] = "connected";
			$response["message"] = "Connected to the internet";
			$response["ip"] = $parts[1];
			$response["ip_country"] = $parts[2];
			$response["ip_iso"] = str_replace(array("(", ")"), "", $parts[3]);

			// VPN Status
			$vpnstatus = fopen("/www/admin/config/vpnstatus", "r");
			$h=fgets($vpnstatus);
			if (preg_match('/up/', $h) == 1) {

				$response["status"] = "tunneled";
				$response["message"] = "VPN tunneled via ".$parts[2];
			}
			else {
				$response["status"] = "connected";
				$response["message"] = "Connected via ".$parts[2];
			}
			fclose($vpnstatus);
		}
		else if (preg_match('/offline/', $g) == 1) {
			$response["status"] = "disconnected";
			$response["message"] = "Not connected to the internet";
		}
		else {
			$response["status"] = "connecting";
			$response["message"] = "Connecting to the internet";
		}
	}
	fclose($f2);
	echo json_encode($response);
}
?>
