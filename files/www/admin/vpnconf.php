<?php include 'header.php';?>

  <center>
  <h1 id="headline">Configure a VPN</h1>
  </center>

 <div id="container_general">
  <form enctype="multipart/form-data" action="vpn.php" method="post">
    <input type="hidden" name="MAX_FILE_SIZE" value="100000" />
    <center>
    Upload an OpenVPN configuration file
    (<em>ends in .ovpn</em>)
    <br>
    If required, be sure to also enter the username and password given to you by
    the VPN service provider.
    </center>
    <br>
    <label class="upload">
        <input name="uploaded_file" type="file" required \>
        <span>load config</span>
    </label>
    <input name="username" type="text" placeholder="username" />
    <br><br>
    <input name="password" type="text" placeholder="password" />
    <br><br>
    <input type="submit" value="save" />
  </form>
  </div>
    
<?php include 'footer.php';?>
