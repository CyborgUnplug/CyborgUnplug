<?php include 'header.php';?>

    <center>
	<h1 id="headline">I would like to...</h1>
    </center>
    <br><br>
	<div id="container_start">
		<form method="get" id="start" action="cgi-bin/config.cgi">
			<input name="detect" type="submit" value="detect" class='button'>
            <br><br>
			<input name="encrypt" type="submit" value="encrypt" class='button'>
            <br><br>
			<input name="configure" type="submit" value="configure" class='button'>
            <br><br>
			<input name="share" type="submit" value="share" class='button'>
        </form>

	</div>

<?php include 'footer.php';?>
