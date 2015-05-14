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
		$f = "usb/empty";
        if (file_exists($f)){
            echo "<h2>Insert USB stick to share files</h2>";
        }
        else {
            echo php_file_tree($_SERVER['DOCUMENT_ROOT']."/usb", "[link]");
        }
		?>
    </div>
    </body>
<?php include 'footer.php';?>
