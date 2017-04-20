<?php include 'header.php';?>
    <center>
	<h1 id="headline">Configuration</h1>
    </center>
	<div id="container_general">
        <form action="wlanconf.php">
			<input name="wifi" type="submit" value="wifi hotspot setup" class='button'>
        </form>
        <form action="authconf.php">
			<input name="auth" type="submit" value="admin password" class='button'>
        </form>
        <form action="alertsconf.php">
			<input name="alerts" type="submit" value="alert emails" class='button'>
        </form>
        <form action="updateconf.php">
			<input name="updates" type="submit" value="software updates" class='button'>
        </form>
	</div>
<?php include 'footer.php';?>
