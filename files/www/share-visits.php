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
    <br>
		<?php
        $f = fopen("config/ssid", "r");
        $ssid = fgets($f);
        fclose($f);
		$g = "usb/empty";
        if (file_exists($g)){
            echo "<div class='warning warning3'>";
            echo "Insert USB stick to share files.";
            echo "</div>"; 
            echo "<form method='get' id='sharerefresh' action='cgi-bin/config.cgi'>";
			echo "<center><input name='sharerefresh' type='submit' value='Refresh' class='button'></center>";
            echo "</form>";
        }
        else {
            echo "<div class='warning warning3'>";
            echo "The following files are available for download";
            echo "</div>"; 
            echo "<hr>";
            echo "<div id='container_files'>";
            echo "<form method='get' id='start' action='cgi-bin/config.cgi'>";
            echo "<br>";
            echo php_file_tree($_SERVER['DOCUMENT_ROOT']."/usb", "[link]");
            echo "</div>"; 
            echo "<hr>";
			echo "<center><input name='umount' type='submit' value='Safely remove USB stick' class='button'></center>";
            echo "</form>";
        }
		?>
    </div>
    </body>
<br>
<?php include 'footer.php';?>
