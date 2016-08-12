<?php include 'header-no-status.php';?>

    <center>
    <?php 
        $f = fopen("config/mode", "r");
        $g=fgets($f);                                                                                                                              
        if ($g) {
            if (preg_match('/sweep/', $g) == 1) {
                echo "<h1 id='headline'>Sweeping for devices...</h1>";
                echo "<br>";
                echo "<div class='warning'>";
                echo "A sweep should take a little over 80 seconds. During this time your WiFi connection to Little Snipper will go down. Reconnect and refresh this page in a couple of minutes to read a report.<br>In the interim, check email for alerts.";
                echo "</div>";
            }
            else if (preg_match('/NULL/', $g) == 1) {
                echo "<h1 id='headline'>Sweep complete...</h1>";
                echo "<br>";
                echo "<div class='warning'>";
                echo "View report below and/or check email for alerts<br>";
                echo "</div>";
                echo "<br>";
                echo "<form action='index.php'>";
			    echo "<input name='detect' type='submit' value='return to main menu' class='button'>";
                echo "</form>";
            }
            else {
                echo "<h1 id='headline'>The detector is active</h1>";
                echo "<br>";
                echo "<div class='warning'>";
                echo "WiFi access disabled during detection<br>";
                echo "Alerts sent by email<br>";
                echo "Connect by Ethernet to read reports<br>";
                echo "</div>";
                echo "<br>";
                echo "<div class='warning warning3'>";
                echo "To reconfigure, unplug/replug Little Snipper<br>";
                echo "</div>";
            }
        }
    ?>
        <br>
        </center>
	<ul class='toggle-view'>
        <li>
            <a href='#reports' class='navLink'><h4 class='toggle-title'>reports</h4></a>
            <div id='reports' class='page'>
                <form id="reports"> 
                    <div class="config_container">
	                    <div id="reports_container">
							 <?php
                                function getDeviceName($mac){
                                    $f = fopen("data/devices", "r");
                                    $str;
                                    while(!feof($f)) {
                                        $g=fgets($f);
                                        if ($g) {
                                            if (strpbrk($g,'(')) {
                                            }
                                            else if (strpbrk($g, ')')) {
                                            }
                                            else {
                                                $parts = explode("," ,$g);
                                                //$data=base64_encode($parts[0]. ',' . $parts[1] . ' ');
                                                
                                                $dbMac = $parts[1];
                                                //echo "MAC: " . $mac . " part1: " . $dbMac . "<br/>";
                                                
                                                if(trim($parts[1]) == $mac){
                                                    return $parts[0];
                                                }
                                            }
                                        }
                                    }
                                    return $mac;
                                }
							 	   
                                if (!file_exists("logs/detected")) {
                                    $date = shell_exec('date');
                                    echo "<div class='reports_entry'>No targets seen as of: $date</div>";
                                }
                                else {

                                $f = fopen("logs/detected", "r");
                                while(!feof($f)) {
                                    $g=fgets($f);
                                    if ($g) {
                                        $parts=explode("\n",$g);
                                        $part = explode(",",$parts[0]);
                                        $part2 = explode(" ",$part[1]);
                                        $mac1 = getDeviceName($part2[2]);
                                        $mac2 = getDeviceName($part2[4]);
                                        $returnText = $part[0] . "<br> ------ " . $part2[1] . " <strong>" . $mac1 . "</strong> " . $part2[3] . " <strong>" . $mac2 . "</strong>";
                                        echo "<div class='reports_entry'><br><center>$returnText</center></div>";
                                    }
                                }
                                fclose($f);
                            }
					        ?>
						</div>
                   
                    </div>
                </form>
            </div>
        </li>
    </ul>

<?php include 'footer.php';?>
