<?php include 'header.php';?>

<h1 id="headline">Choose A VPN</h1>
 <div id="container_general">
    <br>
        <form method='get' id='vpnconf' action='cgi-bin/config.cgi'>
        <input name='conf' type='hidden' value='vpnconf'>
        <input type='submit' value='Configure new VPN' class='button'>
        </form>
    <br>
    <div id="container_caption">
        Load in a file ending in <em>.ovpn</em> from<br>a VPN provider
        like <a href="http://vpnbook.com">VPNBook</a> or 
    <a href="http://ipredator.se">IPredator</a>.
    </div>
    <hr>
        <form method='get' id='unplugvpn' action='cgi-bin/config.cgi'>
        <input name='unplugvpn' type='hidden' value='unplugvpn'>
        <input type='submit' value='Use the Unplug VPN' class='button'>
        </form>
    <br>
    <div id="container_caption">
        Routes through Germany<br>
        Undetectable VPN traffic<br>
        No P2P traffic<br>
    </div>

  </div>
    
<?php include 'footer.php';?>
