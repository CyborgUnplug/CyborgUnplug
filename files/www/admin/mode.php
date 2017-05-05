<?php include 'header.php';?>

    <center>
    <h1 id="headline">Select Mode</h1>
    </center>
    <form method="get" id="mode" action="cgi-bin/config.cgi">
        <input name="mode1" type="submit" value="Continuous scan" class="btn">
        <br><br>
        <input name="mode2" type="submit" value="Quick sweep" class="btn">
    </form>
    
<?php include 'footer.php';?>
