<?php include 'header.php';?>

<center>
<h1 id="headline">Choose A VPN</h1>
</center>
 <div id="container_general">
        <form action="vpnconf.php">
            <input type='submit' value='configure new vpn' class='button'>
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
        <input type='submit' value='use the Unplug VPN' class='button'>
        </form>
    <br>
    <div id="container_caption">
        Routes through Germany<br>
        Traverses firewalls - appears as HTTPS traffic<br>
        No DNS leaks (DNS servers of VPN host)<br>
        By using this VPN you agree to <a href="tos.php">these terms</a>
    </div>

  </div>
    
<?php include 'footer.php';?>
