<?php include 'header.php';?>

  <center>
  <h1 id="headline">Configure a VPN</h1>
  </center>

 <div id="container_general">
  <form enctype="multipart/form-data" action="vpn.php" method="post">
    <input type="hidden" name="MAX_FILE_SIZE" value="1000000" />
    <center>
    Choose an OpenVPN configuration file
    (<em>ending in .ovpn</em>) to upload
    </center>
    <br><br>
    <center>
    <label class="upload button">
        <input name="uploaded_file" type="file" required \>
        <span>load config</span>
    </label>
    </center>

    <br><br> 
    <input name="username" type="text" placeholder="username" />
    <br><br>
    <input name="password" type="text" placeholder="password" />
    <br><br>
    <input type="submit" value="save" />
  </form>
    <br><br>
  </div>
    
<?php include 'footer.php';?>
