<?php
// PHP File Tree code by Cory LaViska, adapts code from here:
//   http://abeautifulsite.net/notebook.php?article=21
$page_title = "Share files over Wi-Fi";
include('/www/admin/header.php');
include("/www/share/php_file_tree.php");
?>
	<script src="/share/php_file_tree.js" type="text/javascript"></script>
	<div class="center">
		<h1><i class="icon-file-share"></i> Share files over Wi-Fi</h1>
	</div>
<?php
    // The revision file is used in 'start.sh' to derive a unique filename we can
    // test against - in the mountpoint folder - to know for sure if a USB stick is
    // actually accessible (pulled out and yet '/bin/mount' still reports it's mounted, etc.
    $f = fopen("/www/config/rev", "r");
    $g="usb/".trim(fgets($f));
    fclose($f);
	if (file_exists($g)) {
		echo "<br>";
		echo "<div class='warning warning3'>";
		echo "Insert USB stick to start sharing. For best results use a stick
with just the files you need to share; too many files takes a long time for
Little Snipper to read and present to you";
		echo "</div>"; 
		echo "<div class='warning'>";
		echo "Note that during USB stick sharing mode there is no access to the main and configuration menus until the USB stick is ejected and an authenticated user logs in";
		echo "</div>"; 
		echo "<form method='get' id='sharerefresh' action='cgi-bin/config.cgi'>";
		echo "<div class='center'>";
        echo "<input name='sharerefresh' type='submit' value='Refresh' class='button'>";
        echo "</div>";
		echo "</form>";
	} else {
		echo "<div class='warning warning3'>";
		echo "Devices connected to this network can now download the following files:";
		echo "</div>"; 
		echo "<div id='container_files'>";
		echo "<form method='get' id='start' action='cgi-bin/config.cgi'>";
		echo "<br>";
		echo php_file_tree("/www/share/usb", "[link]");
		echo "</div>"; 
		echo "<hr>";
		echo "<center>";
        echo "<input name='umount' type='submit' value='Eject USB stick' class='button'>";
        echo "</center>";
		echo "</form>";
	}
include('/www/admin/footer.php'); ?>
