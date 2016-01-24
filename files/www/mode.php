<?php include 'header.php';?>

    <center>
    <h1 id="headline">Select Mode</h1>
    </center>
    <form method="get" id="mode" action="cgi-bin/config.cgi">
        <input name="mode1" type="submit" value="continuous" class="btn">
        <br><br>
<<<<<<< HEAD
        <input name="mode2" type="submit" value="quick sweep" class="btn">
=======
        <input name="mode2" type="submit" value="all out" class="btn">
        <br><br>
        <input name="mode3" type="submit" value="alerts only" class="btn">
        <br><br>
        <input name="mode4" type="submit" value="sweep and report" class="btn">
>>>>>>> parent of e6b1790... Added an email notification in the case target devices are not detected within
    </form>
    
<?php include 'footer.php';?>
