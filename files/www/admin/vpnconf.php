<?php include 'header.php';?>

  <center>
  <h1 id="headline">Configure a VPN</h1>
  </center>

 <div id="container_general">
    <?php 
    $fn='config/networkstate';
    if (file_exists($fn)) {
        $f = fopen("config/networkstate", "r");
        $g=fgets($f);
        if ($g) {
            if (preg_match('/online/', $g) != 1) { 
    ?>
    <div id="container_general">
        <form enctype="multipart/form-data" action="index.php" method="post">
        <p>
        <center>
        <div class="warning warning1">
        Before starting the VPN service, please ensure that Little Snipper is online. <br>
        To do so, connect an Ethernet cable provided to the WAN port on Little Snipper <br>
        and the other end to a LAN port on your router.<br>
        Alternatively, configure a 'wireless bridge' in the configuration menu,<br>
        to connect Little Snipper to a local Wi-Fi network. 
        </div>
        <br><br>
        <input type="submit" value="refresh">
        </form>
        </center>
    </div>
    <?php } else { ?>
      <form enctype="multipart/form-data" action="vpn.php" method="post">
        <input type="hidden" name="MAX_FILE_SIZE" value="100000" />
        <center>
        Upload an OpenVPN configuration file (<em>ends in .ovpn</em>). If
        required, be sure to also enter the username and password given to you by the
        VPN service provider.
        </center>
        <div class="warning warning2">
            Don't have a VPN provider yet? You may wish to try <a href="https://vpnbook.com">VPNBook</a>, <a href="https://ipredator.se">IPredator</a>, or <a href="https://mullvad.net">Mullvad</a>.
            <br>
            Please understand we cannot guarantee any are a safe choice. 
        </div>
        <div class="warning warning1">
            Be aware many VPN providers<a href="https://dnsleaktest.com"> leak DNS</a>.
        </div>
        <br>
        <label class="upload">
            <input name="uploaded_file" type="file" required \>
            <span>load config</span>
        </label>
        <input name="username" type="text" placeholder="username" />
        <br><br>
        <input name="password" type="text" placeholder="password" />
        <br><br>
        <input type="submit" value="Save" />
      </form>
  </div>
<?php
        }
    }
}
    
include 'footer.php';?>
