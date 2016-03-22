<?php include 'header.php';?>

  <center>
  <h1 id="headline">Configure a VPN</h1>
  Load in a file ending in <em>.ovpn</em> from<br>a VPN provider
  like <a href="http://vpnbook.com">VPNBook</a> or 
    <a href="http://ipredator.se">IPredator</a>.
  </center>
 <div id="container_general">
  <form enctype="multipart/form-data" action="vpn.php" method="post">
    <input type="hidden" name="MAX_FILE_SIZE" value="100000" />
    <center>
    <label class="upload button">
        <input name="uploaded_file" type="file" required \>
        <span>load config</span>
    </label>
    </center>
    <br>
    <input name="username" type="text" placeholder="username" />
    <br><br>
    <input name="password" type="text" placeholder="password" />
    <br><br>
    <input type="submit" value="save" />
    </div>
  </form>
  </div>
    
<?php include 'footer.php';?>
