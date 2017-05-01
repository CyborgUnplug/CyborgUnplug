<?php
/*	Determine the following:
 	- Checks files on disk for various status
	- GeoIP status updates end-to-end encrypted
	- SSID
	- network state
	- VPN status
*/

function get_network_status() {

	// Default
	$response = [
		"ssid" => "unknown",
		"status" => "waiting", 
		"message" => "Waiting to connect",
		"ip" => "0.0.0.0",
		"ip_country" => "Unspecified",
		"ip_iso" => "none",
		"vpn" => "none"
	];

	// Get Device Info
	$f1 = fopen("/www/admin/config/ssid", "r");
	$response["ssid"] = fgets($f1);
	fclose($f1);

	if (file_exists("/www/admin/config/armed")) {
		$respone["ssid"] = "unvailable";
	}

	// Get Network Info
	$fn='/www/admin/config/networkstate';
	if (file_exists($fn)) {

		$f2 = fopen("/www/admin/config/networkstate", "r");
		$g=fgets($f2);
		if ($g) {
			if (preg_match('/online/', $g) == 1) {
				$parts_state = explode('online', $g);
				$parts = explode(' ', $parts_state[1]);

				// Waiting to verify IP
				if (preg_match('/Waiting/', $g1) == 1) {
					$response["status"] = "connecting";
					$response["message"] = "Connecting to internet";
				} else {
					$response["status"] = "connected";
					$response["message"] = "Connected to internet";
					$response["ip"] = $parts[1];
                    //TODO need a fix for country names with multiple words
					$response["ip_country"] = array_slice($parts,2,-1);
					$response["ip_iso"] = str_replace(array("(", ")"), "", end($parts));
				}

				// Determine VPN Status (up, down, start, stop, failed)
				$vpnstatus = fopen("/www/admin/config/vpnstatus", "r");
				$h=fgets($vpnstatus);

				if (preg_match('/up/', $h) == 1) {
					$response["status"] = "tunneled";
					$response["message"] = "VPN tunneled";
					$response["vpn"] = "up";
				}
				else if (preg_match('/down/', $h) == 1) {
					$response["vpn"] = "down";
				}
				else if (preg_match('/start/', $h) == 1) {
					$response["status"] = "connecting";
					$response["message"] = "Connecting to VPN";
					$response["vpn"] = "start";
				}
				else if (preg_match('/stop/', $h) == 1) {
					$response["status"] = "connecting";
					$response["message"] = "VPN is stopping";
					$response["vpn"] = "stop";
				}
				else if (preg_match('/unconfigured/', $h) == 1) {
					$response["vpn"] = "unconfigured";
				}
				else if (preg_match('/failed/', $h) == 1) {
					$response["vpn"] = "failed";
				}
				else {
					$response["vpn"] = "error";
				}

				fclose($vpnstatus);
			}
			else if (preg_match('/offline/', $g) == 1) {
				$response["status"] = "disconnected";
				$response["message"] = "No internet connection";
			}
			else {
				$response["status"] = "connecting";
				$response["message"] = "Connecting to internet";
			}
		}
		fclose($f2);
	}

	return $response;
}
?>
