<?php
// PHP File Tree code by Cory LaViska, adapts code from here:
//   http://abeautifulsite.net/notebook.php?article=21
include 'header.php';
include("php_file_tree.php");
?>
    <head>                                                                                                                                                     
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
        <link href="style.css" rel="stylesheet" type="text/css" media="screen" />
        <script src="php_file_tree.js" type="text/javascript"></script>
    </head>
    <body>
    <center>
	<h1 id="headline">Share files wirelessly</h1>
    </center>
		<?php
		$g = "usb/empty";
        if (file_exists($g)){
            echo "<br>";
            echo "<div class='warning warning3'>";
            echo "Insert USB stick to start sharing";
            echo "</div>"; 
            echo "<form method='get' id='sharerefresh' action='cgi-bin/config.cgi'>";
			echo "<center><input name='sharerefresh' type='submit' value='refresh' class='button'></center>";
            echo "</form>";
        }
        else {
            echo "<div class='warning warning3'>";
            echo "Devices connected to this network can now download the following files:";
            echo "</div>"; 
            echo "<div id='container_files'>";
            echo "<form method='get' id='start' action='cgi-bin/config.cgi'>";
            echo "<br>";
            echo php_file_tree("/www/share/usb", "[link]");
            echo "</div>"; 
            echo "<hr>";
			echo "<center><input name='umount' type='submit' value='eject usb stick' class='button'></center>";
            echo "</form>";
        }
		?>
    </div>
    </body>
<br>
<?php include 'footer.php';?>
