<?php include 'header.php';?>

    <center>
    <h1 id="headline">All Out Mode</h1>
    </center>
	<div class='warning'>
		NOTE that using All Out Mode may not be legal in your jurisdiction as it broadly disrupts any network connection from
		any of the devices you've prohibited.
		<br>
		Use with caution and understand that by pressing the AGREE below you are admonishing
		the makers of this device from any responsibility, harm, complaints, fines or otherwise.
	</div>
	<form method="get" id="mode" action="cgi-bin/config.cgi">
		<input name="finish2" type="hidden" value="nothing">
		<input type="submit" value="AGREE" class="btnnext">
	</form>

<?php include 'footer.php';?>
