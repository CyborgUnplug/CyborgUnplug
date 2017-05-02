<?php
$page_title = "Setup";
include('header.php');
?>
<div class="center">
	<h1>Setup your Little Snipper</h1>
</div>
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
		<p>Before we begin, please ensure that Little Snipper is online. To do so, connect the Ethernet cable provided to the WAN port on Little Snipper and the other end to your router at home or work.</p>
		<p>Note that the status bar at the top of this page will tell you when Little Snipper is online</p>
		<button type="submit" value="refresh">Refresh</button>
	</form>
</div>
<?php } else { ?>
<div id="container_general">
	<form enctype="multipart/form-data" action="registered.php" method="post">
		<p>Great, it seems we're online! Please enter an email address so that
your device can send you email alerts and updates when it detects spying
devices. Rest assured, we won't use it for anything else.</p>
		<input name="email" type="text" placeholder="you@yourdomain.com">
        <br><br>
		<button type="submit" value="save">Save</button>
	</form>
</div>
<?php
        }
    }
}
include('footer.php'); ?>
