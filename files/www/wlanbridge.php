<?php include 'header.php';?>

    <center>
    <h1 id="headline">Configure a WiFi Bridge</h1>
    </center>
     <div id="container_general">
      <form enctype="multipart/form-data" action="wlansetbridge.php" method="post">
        <br>
        Enter the name of a WiFi network to connect to 
        <input name="bridgessid" type="text" placeholder="5tarbucks" />
        <br><br>
        Enter its password (blank for open networks)
        <input name="bridgepassword" type="text" placeholder="password" />
        <br><br>
        <input type="submit" value="save" />
        </form>
        <br><br>
      </div>
<?php include 'footer.php';?>
