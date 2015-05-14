<?php include 'header.php';?>

    <h1 id="headline" class="headline_net">Networks to protect</h1>

	<form method="get" id="networks" action="cgi-bin/config.cgi">
		<?php
			$f = fopen("data/networks", "r");
			while(!feof($f)) { 
			    $g=fgets($f);
			    $parts = explode(',', $g);
			    if ($parts[1]) {
				    $data=base64_encode($parts[0].','.$parts[1].','.$parts[2]);
				    echo "<input type='checkbox' class='css-checkbox' id=$data>
				    <label for=$data class='css-label css-label-narrow'> $parts[1]<macaddr><br></label><br/>";
			    }
			}
			fclose($f);
			?>
		<br/><br/>
		<div class="warning";>Please check local laws before selecting networks you do not control or administer</div>
		<br/>
		<input name="finish1" type="hidden" id="checkList" value="nothing">
		<input type="submit" value="NEXT" class='btnnext'>
	</form>

<?php include 'footer.php';?>