<?php include 'header.php';?>

    <h1 id="headline">Configure The WiFi LAN</h1>
     <div id="container_general">
      <form enctype="multipart/form-data" action="wlanset.php" method="post">
        <br><br>
        Set new Access Point name (ESSID): 
        <input name="ssid" type="text" placeholder="network name" />
        <br><br>
        Set a new WPA2 PSK password: 
        <input name="password" type="text" placeholder="password" />
        <br><br>
        Set a new channel: 
        <input name="channel" type="text" placeholder="channel" />
        <br><br>
        <input type="submit" value="save" />
      </form>
        <br><br>
      </div>
<?php include 'footer.php';?>
