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
	<h1 id="headline">Share Files</h1>
	<div id="container_files">
		<?php
        $f = fopen("config/ssid", "r");
        $ssid = fgets($f);
        fclose($f);
		$g = "usb/empty";
        if (file_exists($g)){
            echo "<h2>Insert USB stick to wirelessly share files <br>on the <em>".$ssid."</em> network</h2>";
            echo "<form method='get' id='start' action='cgi-bin/config.cgi'>";
			echo "<center><input name='refresh-share' type='submit' value='Refresh' class='button'></center>";
            echo "</form>";
        }
        else {
            echo "<h2>Found the following files</h2>";
            echo "<h3>Other computers can join the <em>".$ssid."</em> network</br>and download files</h3>";
            echo "<hr>";
            echo "<form method='get' id='start' action='cgi-bin/config.cgi'>";
            echo php_file_tree($_SERVER['DOCUMENT_ROOT']."/usb", "[link]");
            echo "<hr>";
			echo "<center><input name='umount' type='submit' value='Safely remove USB stick' class='button'></center>";
            echo "</form>";
        }
		?>
    </div>
    </body>
<?php include 'footer.php';?>
