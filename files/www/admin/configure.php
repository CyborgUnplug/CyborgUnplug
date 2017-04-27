<?php 
$page_title = "Settings";
include('header.php');
?>
<div class="text-center">
	<h1><i class="icon-settings"></i> Settings</h1>
	<form action="wlanconf.php">
		<input name="wifi" type="submit" value="Wifi Hotspot Setup">
	</form>
	<form action="authconf.php">
		<input name="auth" type="submit" value="Admin Password">
	</form>
	<form action="alertsconf.php">
		<input name="alerts" type="submit" value="Alert Emails">
	</form>
	<form action="updateconf.php">
		<input name="updates" type="submit" value="Software Updates">
	</form>
</div>
<?php include('footer.php'); ?>
