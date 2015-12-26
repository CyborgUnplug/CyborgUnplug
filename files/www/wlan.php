<?php include 'header.php';?>
    <center>
	<h1 id="headline">I would like to...</h1>
    </center>
    <br>
	<div id="container_start">
        <form action="wlanconf.php">
			<input name="wlanconf" type="submit" value="configure the access point" class='button'>
        </form>
        <form action="wlanbridge.php">
			<input name="wlanbridge" type="submit" value="set up a wireless bridge" class='button'>
        </form>

	</div>
<? include 'footer.php';?>
