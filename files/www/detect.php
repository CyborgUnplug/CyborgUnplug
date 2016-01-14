<?php include 'header.php';?>

    <center>
	<h1 id="headline">Select devices to detect</h1>
    </center>
	<div id="container_devices">
		
		<form method="get" id="devices" action="cgi-bin/config.cgi">
			<?php
				$f = fopen("data/devices", "r");
				$num=0;
				while(!feof($f)) { 
				    $g=fgets($f);
				    if ($g) {
					    if (strpbrk($g,'(')) {
						    $title=substr($g, 0, -2);
						    $num++;
						    echo "<ul class='toggle-view'>";
						    echo "<li>";
						    echo "<a href='#div$num' class='navLink'><h4 class='toggle-title'>$title</h4></a>";
						    echo "<div id='div$num' class='page'>";
					    }
					    else if (strpbrk($g, ')')) {
					    	echo "</div>";
						    echo "</li>";
						    echo "</ul>";
					    }
					    else {
						    $parts=explode("," ,$g);
						    $data=base64_encode($parts[0]. ',' . $parts[1] . ' ');
						    echo "<div class='device'><input type='checkbox' class='css-checkbox' id=$data>
						    <label for=$data class='css-label'>$parts[0]</label></div>";
						}
				    }
				}
				fclose($f);
			?>
			<input name="devices" type="hidden" id="checkList" value="nothing">
			<input type="submit" value="NEXT" class='btnnext'>
		</form>

	</div>

<?php include 'footer.php';?>
