<?php
$page_title = "Arming Little Snipper";
include('header.php');
?>
	<div class="center">
	    <h1><i class="icon-scan"></i> Arming Little Snipper</h1>
	</div>
	<div class="warning">
		<img src="img/loading.gif" alt="" title="" class="loading" width="10" height="10" />
        <p>Please standby while settings are applied...</p>
    </div>
    <?php 
        $f = fopen("config/mode", "r");
        $g=fgets($f);                                                                                                                              
        if ($g) {
            if (preg_match('/sweep/', $g) == 1) {
                echo "<div class='warning warning3'>";
                echo "A sweep should take a little over a minute. During that time the WiFi will go down. Just reconnect in a minute and refresh this page";
                </div>
        }
	?>
	<div class="warning warning3">
		<p>Unplug and re-plug to re-configure. You will no longer be able to connect to the device wirelessly while it is in the armed state.</p>
	</div>
<?php include('footer.php'); ?>
