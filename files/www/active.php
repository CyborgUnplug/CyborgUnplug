<?php include 'header.php';?>

    <center>
    <h1 id="headline" style="color:#82cc51;">The detector is active</h1>
	
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


 		<div class='warning warning3'>
			Unplug/replug to re-configure
		</div>
        </center>
            <center>
            <a href='#reports' class='navLink'><h4 class='toggle-title'>reports</h4></a>
            </center>
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
                                        $returnText = $part[0] . " - " . $part2[1] . " <strong>" . $mac1 . "</strong> " . $part2[3] . " <strong>" . $mac2 . "</strong>";
                                        echo "<div class='reports_entry'>$returnText</div>";
                                    }
                                }
                                fclose($f);
                            }
					        ?>
						</div>
                   
                    </div>
                </form>
            </div>
    </ul>
    

<?php include 'footer.php';?>
