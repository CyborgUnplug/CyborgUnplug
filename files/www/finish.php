<?php include 'header.php';?>

    <center>
    <h1 id="headline">Review Settings</h1>
    </center>
    <br>
    <ul class='toggle-view'>
        <li>
            <a href='#devices' class='navLink'><h4 class='toggle-title'>devices to detect</h4></a>
            <div id='devices' class='page'>
                <form id="devices"> 
                    <div class="config_container">
                        <?php
                            $f = fopen("config/targets", "r");
                            while(!feof($f)) { 
                                $g=fgets($f);
                                if ($g) {
                        	    $parts=explode(',',$g);
                                    echo "$parts[0]<br/>";
                                }
                            }
                            fclose($f);
                        ?> 
                    </div>
                </form>
            </div>
        </li>
   
        <li>
            <a href='#networks' class='navLink'><h4 class='toggle-title'>networks to watch</h4></a>
            <div id='networks' class='page'>
                <form id="networks"> 
                    <div class="config_container">
                        <?php
                            $f = fopen("config/networks", "r");
                            while(!feof($f)) {
                                $g=fgets($f);
                                if ($g) {
                                    $parts=explode(',',$g);
                                    echo "$parts[1]<br/>";
                                }
                            }
                            fclose($f);
                        ?>
                    </div>
                </form>
            </div>
        </li>
    </ul>

    <form method="get" id="armed" action="cgi-bin/config.cgi">
        <input name="armed" type="hidden" id="armed" value="standby">
        <center>
        <input type="submit" value="ARM DEVICE" class='btnarm'>
        </center>
    </form>

<?php include 'footer.php';?>
