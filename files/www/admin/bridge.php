<?php include 'header.php';?>
    <center>
    <h1 id="headline">Create a Wifi bridge</h1>
    <?php
        $d = fopen("config/vpnstatus", "r");
        $e=fgets($d);
        if (preg_match('/up/', $e) == 1) {
            echo "<br>";
            echo "<div class='warning'>";
            echo "Seems there's a VPN running. Please stop it before creating a bridge, then start it again once the bridge is up and you're online";
            echo "</div>"; 
            echo "<br>";
            echo "<form method='get' id='stopvpn' action='cgi-bin/config.cgi'>";
            echo "<input name='stopvpn' type='hidden' value='stopvpn'>";
            echo "<input type='submit' value='stop vpn' class='button'>";
            echo "</form>";
            fclose($d);
        } else {
            echo "<form enctype='multipart/form-data' action='bridgeset.php' method='post'>";
            echo "</center>";
            echo "<select class='networks' name='bridge' onchange='checkForPw()' id='bridge'>";
            echo "<option class='networks' id='nothing'>Choose a network...</option>"; 
            $f = fopen("data/networks", "r");
            while(!feof($f)) { 
                $g=fgets($f);
                $parts = explode(',', $g);
                if ($parts[1]) {
                    $data=$parts[0].','.$parts[1].','.$parts[2].','.$parts[3];
                    echo "<option id=$data name=$data value=$data>".base64_decode($parts[1])."</option>"; 
                    /*
                    if ($parts[3] == '1') {
                        echo "<input name='n$data' for=$data min='8' max='63' id='pw$data' type='text' placeholder='password' style='visibility:hidden' >";
                    }
                    */
                }
            }
            fclose($f);
            echo "</select>";
            echo "<div id='bridgepw' style='visibility:hidden'>";
            echo "<br>";
            echo "<input name='password'min='8' max='63' type='text' value='' placeholder='enter wifi passphrase' >";
            echo "</div>";
            echo "<input type='checkbox' name='save' id='save' class='css-checkbox'>";
            echo "<label for='save' class='css-label'>Save this network</label>";
            echo "<input type='checkbox' name='defaultroute' id='defaultroute' class='css-checkbox'>";
            echo "<label for='defaultroute' class='css-label'>Make this my default connection</label>";
            echo "<center>";
            echo "<input type='submit' value='NEXT' class='btnnext'>";
            echo "</form>";
            echo "<br>";
            $fn = "config/savedbridge";
            if (file_exists($fn)) {
                $f = fopen($fn, "r");
                $g = fgets($f);
                $parts = explode(',', $g);
				$ssid = base64_decode($parts[1]);
		        $ap = $parts[0].','.$ssid;
                echo "<hr>";
                echo "<br>";
                echo "<h1>Choose a saved wifi network</h1>"; 
                echo "<form method='get' id='savedbridge' action='cgi-bin/config.cgi'>";
                echo "<input name='savedbridge' type='hidden' value='savedbridge'>";
				echo '<button class=button" value="'.$ap.'" type="submit">'.$ssid.'</button>';
                echo "</form>";
                fclose($f);
                echo "</center>";
           }
        }
    ?>
<?php include 'footer.php';?>
