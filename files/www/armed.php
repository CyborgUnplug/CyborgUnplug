<?php include 'header.php';?>

    <h1 id="headline"></h1>
	<div class='warning'>
		<img src="img/loading.gif" alt="" title="" class="loading" width="10" height="10" />
        <br/>
        Please standby while settings are applied...
		<br/>
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
	<div class='warning warning3'>
		Unplug and re-plug to re-configure. You will no longer be able
        to connect to the device wirelessly while it is in the armed state.
	</div>

<?php include 'footer.php';?>
