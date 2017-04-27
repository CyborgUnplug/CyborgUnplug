<?php
$page_title = "Select spy devices";
include('header.php');
?>
    <div class="center">
		<h1><i class="icon-scan"></i> Select spy devices</h1>
    </div>
	<div id="container_devices">
	    <script>	
            function checkall(ele) {
                 var checkboxes = document.getElementsByTagName('input');
                 if (ele.checked) {
                     for (var i = 0; i < checkboxes.length; i++) {
                         if (checkboxes[i].type == 'checkbox') {
                             checkboxes[i].checked = true;
                         }
                     }
                 } else {
                     for (var i = 0; i < checkboxes.length; i++) {
                         console.log(i)
                         if (checkboxes[i].type == 'checkbox') {
                             checkboxes[i].checked = false;
                         }
                     }
                 }
             }
        </script>
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
                echo "<div class='device'>";
				echo "<hr>";
                echo "<input type='checkbox' onchange='checkall(this)' id='selectall' class='css-checkbox'>";
                echo "<label for='selectall' class='css-label'>Select all</label>";
                echo "</div>";
                echo "<br><br>";
				fclose($f);
			?>
            <div class="center">
				<input name="devices" type="hidden" id="checkList" value="nothing">
				<button type="submit" value="NEXT" class="btnnext">Next</button>
            </div>
		</form>
	</div>
<?php include('footer.php'); ?>
