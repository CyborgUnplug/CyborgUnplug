<?php 
$page_title = "All Out Mode";
include('header.php');
?>
    <div class="center">
	    <h1><i class="icon-scan"></i> All Out Mode</h1>
    </div>
	<div class="warning">
		<p>NOTE that using All Out Mode may not be legal in your jurisdiction as
it broadly disrupts any network connection from any of the devices you've
prohibited.
		</p>
		<p>Use with caution and understand that by pressing the AGREE below you
are admonishing the makers of this device from any responsibility, harm,
complaints, fines or otherwise.
		</p>
	</div>
	<form method="get" id="mode" action="cgi-bin/config.cgi">
		<input name="finish2" type="hidden" value="nothing">
        <div class="center">
			<input type="submit" value="AGREE" class="btnnext">
        </div>
	</form>
<?php include('footer.php'); ?>
