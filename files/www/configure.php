<?php include 'header.php';?>

    <center>
	<h1 id="headline">Configure Little Snipper</h1>
    </center>
    <br>
	<div id="container_general">
        <form action="wlan.php">
			<input name="wifi" type="submit" value="wifi" class='button'>
        </form>
        <form action="update.php">
			<input name="updates" type="submit" value="updates" class='button'>
        </form>
        <form action="alerts.php">
			<input name="alerts" type="submit" value="alerts" class='button'>
        </form>
	</div>
<?php include 'footer.php';?>
