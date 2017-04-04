<?php include 'header.php';?>

<center>
<h1 id="headline">Choose a VPN</h1>
</center>
 <div id="container_general">
<?php 
$fn='config/networkstate';
if (file_exists($fn)) {
    $f = fopen("config/networkstate", "r");
    $g=fgets($f);
    if ($g) {
        if (preg_match('/online/', $g) != 1) {
             echo "<div id='container_general'>";
             echo "<form enctype='multipart/form-data' action='index.php' method='post'>";
             echo "<p>";
             echo "<center>";
             echo "<div class='warning warning1'>";
             echo "Before starting the VPN service, please ensure that Little Snipper is online.
             <br>To do so, connect an Ethernet cable provided to the WAN
             port on Little Snipper <br>and the other end to a LAN port on your router.
             <br>Alternatively, configure a 'wireless bridge' in the configuration menu, <br>
            to connect Little Snipper to a local WiFi network."; 
             echo "</div>";
             echo "<br><br>";
             echo "<input type='submit' value='refresh' />";
             echo "</form>";
             echo "</center>";
             echo "</div>";
        } else {
            echo "<form method='get' id='unplugvpn' action='cgi-bin/config.cgi'>
            <input name='unplugvpn' type='hidden' value='unplugvpn'>
            <input type='submit' value='use the unplug vpn' class='button'>
            </form>";
            echo "<br>";
            echo "<div id='container_caption'>Routes through Germany<br>
            Traverses firewalls - appears as HTTPS traffic<br>
            No DNS leaks (DNS servers of VPN host)<br>
            By using this VPN you agree to <a href='tos.php'>these terms</a></div>";
            echo "</div>";
            echo "<hr>";
            echo "<form action='vpnconf.php'>";
            echo "<input type='submit' value='configure new vpn' class='button'>";
            echo "</form>";
            echo "<br>";
            echo "<div id='container_caption'>
            Load in a file ending in <em>.ovpn</em> from<br>a VPN provider like <a href='http://vpnbook.com'>VPNBook</a> or 
            <a href='http://ipredator.se'>IPredator</a>.</div>";
        }
    }
}
?>
    
<?php include 'footer.php';?>
