<?php include 'header.php';?>

    <center>
	<h1 id="headline">Configuration</h1>
    </center>
	<div id="container_general">
        <form action="alertsconf.php">
			<input name="alerts" type="submit" value="alerts" class='button'>
        </form>
        <form action="authconf.php">
			<input name="auth" type="submit" value="auth" class='button'>
        </form>
        <form action="updateconf.php">
			<input name="updates" type="submit" value="updates" class='button'>
        </form>
        <form action="wlanconf.php">
			<input name="wifi" type="submit" value="wifi" class='button'>
        </form>
        <form method="get" action="cgi-bin/config.cgi">
			<input name="bridgechoose" type="submit" value="bridge" class='button'>
        </form>
	</div>
<?php include 'footer.php';?>
