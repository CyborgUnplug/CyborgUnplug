<?php                                                                                                                                   
/*  Resourced via an AJAX call in header.php
    - Returns JSON response
*/

// Headers
header('Content-Type: application/json;charset=utf-8');
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

include('network-status.php');
$network = get_network_status();

echo json_encode($network);
?>
