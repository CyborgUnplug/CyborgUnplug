<?php include 'header.php';?>

    <center>
	<h1 id="headline">I would like to...</h1>
    </center>
    <br>
	<div id="container_start">
        <form action="detect.php">
			<input name="detect" type="submit" value="detect" class='button'>
        </form>
		<form method="get" id="encrypt" action="cgi-bin/config.cgi">
			<input name="encrypt" type="submit" value="encrypt" class='button'>
        </form>
        <form action="admin/configure.php">
			<input name="configure" type="submit" value="configure" class='button'>
        </form>
        <form action="share.php">
			<input name="share" type="submit" value="share" class='button'>
        </form>

	</div>

<?php include 'footer.php';?>
