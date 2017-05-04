<?php include('header.php'); ?>
<center>
	<h1 id="headline">Choose a VPN</h1>
</center>
<div id="container_general">
<?php 
$fn='config/networkstate';
if (file_exists($fn)) {
    $f = fopen("config/networkstate", "r");
    $g=fgets($f);
    if ($g) {
        if (preg_match('/online/', $g) != 1) { 
?>
<div id="container_general">
	<form enctype="multipart/form-data" action="index.php" method="post">
	<p>
	<center>
	<div class="warning warning1">
	Before starting the VPN service, please ensure that Little Snipper is online. <br>
	To do so, connect an Ethernet cable provided to the WAN port on Little Snipper <br>
	and the other end to a LAN port on your router.<br>
	Alternatively, configure a 'wireless bridge' in the configuration menu,<br>
	to connect Little Snipper to a local Wi-Fi network. 
	</div>
	<br><br>
	<input type="submit" value="refresh">
	</form>
	</center>
</div>
<?php } else { ?>
	<form method="get" id="unplugvpn" action="cgi-bin/config.cgi">
		<input name="unplugvpn" type="hidden" value="unplugvpn">
		<input type="submit" value="Cyborg Unplug VPN" class="button">
	</form>
	<br>
	<div id="container_caption">
		Routes through Germany<br>
		Traverses firewalls - appears as HTTPS traffic<br>
		No DNS leaks (DNS servers of VPN host)<br>
		By using this VPN you agree to <a href="tos.php">these terms</a></div>
	</div>
	<hr>
	<form action="vpnconf.php">
		<input type="submit" value="Configure new VPN" class="button">
	</form>
	<br>
	<div id="container_caption">
		Load a file ending in <strong>.ovpn</strong> from a VPN provider or your own VPN server.<br> 
		You may wish to try the following providers <a
href="https://vpnbook.com">VPNBook</a>, <a
href="https://ipredator.se">IPredator</a>, or <a
href="https://mullvad.net">Mullvad</a>.
<br>
Please understand we cannot guarantee any are a safe choice. 
<br>
Be aware many VPN providers<a href="https://dnsleaktest.com"> leak DNS</a>.
	</div>
<?php
        }
    }
}
include('footer.php'); ?>
