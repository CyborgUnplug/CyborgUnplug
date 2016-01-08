<?php include 'header.php';?>
    <center>
	<h1 id="headline">I want to configure...</h1>
    </center>
    <br>
	<div id="container_start">
        <form action="wlanconf.php">
			<input name="wlanconf" type="submit" value="the access point" class='button'>
        </form>
        <form action="wlanbridge.php">
			<input name="wlanbridge" type="submit" value="a wireless bridge" class='button'>
        </form>
	</div>
<?php include 'footer.php';?>
