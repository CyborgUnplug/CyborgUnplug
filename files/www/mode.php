<?php include 'header.php';?>

    <h1 id="headline">Select Mode</h1>
    <form method="get" id="mode" action="cgi-bin/config.cgi">
        <input name="mode1" type="submit" value="Territorial" class="btn">
        <br><br>
        <input name="mode2" type="submit" value="All Out" class="btn">
        <br><br>
        <input name="mode3" type="submit" value="Report Only" class="btn">
    </form>
    
<?php include 'footer.php';?>