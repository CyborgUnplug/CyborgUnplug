<?php include 'header.php';?>

    <center>
    <h1 id="headline">Configure updates</h1>
    </center>
	<div id="container_general">
        <form method="get" id="updatenow" action="cgi-bin/config.cgi">
            <input name="updatenow" type="hidden" value="nothing">
            <input type="submit" value="UPDATE NOW" class="btnnext">
        </form>
        <div class='warning'>
            Before pressing this button, ensure Little Snipper is online. Once
            pressed, do not unplug Little Snipper. It will reboot and apply updates,
            if any.
        </div>
        <br>

        <hr>
		<form method="get" id="autoupdate" action="cgi-bin/config.cgi">
			<?php
                $fn='config/autoupdate';
                if (file_exists($fn)) {
                    $f = fopen("config/autoupdate", "r");
                    $g=fgets($f);                                                                                                                              
                    if ($g) {
                        if (preg_match('/enabled/', $g) == 1) {
                            echo "<center><h3>Auto updates are enabled</h3></center>";
                            echo "<br>";
                            echo "<form method='get' id='autoupdate' action='cgi-bin/config.cgi'>";
                            echo "<input name='autoupdate' type='hidden'value='disabled'>";
                            echo "<input type='submit' value='disabled' class='button'>";
                            echo "</form>";
                        } else {
                            echo "<center><h3>Auto updates are disabled</h3></center>";
                            echo "<br>";
                            echo "<form method='get' id='autoupdate' action='cgi-bin/config.cgi'>";
                            echo "<input name='autoupdate' type='hidden'value='enabled'>";
                            echo "<input type='submit' value='enabled' class='button'>";
                            echo "</form>";
                        }
                    }
                }
			?>
            <br>
            By default, Little Snipper will check for updates every Sunday, at
            midnight. The updates are applied on the next reboot.
            <br>
    </div>

<?php include 'footer.php';?>
