<?php
$page_title = "Wi-Fi Bridge Saved";
include('header.php');

$gtg=0;

if (! isset($_POST['bridge'])) {
    echo "<div class='warning'>";
    echo "Nothing entered...nothing to do.\n";
    echo "</div>";
    echo "<form method='get' id='bridge' action='bridge.php'>";
    echo "<input name='bridge' type='hidden' value='bridge'>";
    echo "<input type='submit' value='try again' class='button'>";
    echo "</form>";
    $gtg=0;

} else {
    $parts=$_POST['bridge'];
    $save=0;
    $defaultroute=0;
    if (isset($_POST['save'])) {
        $save=1;
    }
    if (isset($_POST['defaultroute'])) {
        $defaultroute=1;
    }
    if(isset($_POST['password'])) {
        $pw = $_POST['password'];
        $min = 8;
        $max = 63;
        if (strlen($pw) > $max ) {
            $gtg=0;
            echo "<div class='warning'>";
            echo "Password too long: must not be longer than 63 characters.\n";
            echo "</div>";
            echo "<form method='get' id='bridge' action='bridge.php'>";
            echo "<input name='bridge' type='hidden' value='bridge'>";
            echo "<input type='submit' value='try again' class='button'>";
            echo "</form>";
        } elseif (strlen($pw) < $min) {
            $gtg=0;
            echo "<div class='warning'>";
            echo "Password too short: must be 8 characters or longer.\n";
            echo "</div>";
            echo "<form method='get' id='bridge' action='bridge.php'>";
            echo "<input name='bridge' type='hidden' value='bridge'>";
            echo "<input type='submit' value='try again' class='button'>";
            echo "</form>";
        } else {
            // encode after we've check pw for length, rather than do it in bridge.php
            $pw=base64_encode($pw);
            //$parts=$parts.','.$pw;
            $parts=$parts.','.$pw.','.$save.','.$defaultroute;
        }
    }
    $fn ='/www/config/bridge'; 
    $f = fopen($fn, 'w');
    $ret = fwrite($f, $parts);
    fclose($f); 
    if($ret === false) {
        die('There was an error writing this file');
    } else {
        $gtg=1; // this is ridiculous, fix it 
    }
    if ( $gtg == 1 ){ // ...and here...
        echo "<div class='center'>";
        echo "<h1>Wi-Fi Bridge Saved</h1>";
        echo "</div>";
        echo "<div class='warning warning3'>";
        echo "Select reboot below to restart the Wi-Fi.\n";
        echo "Please wait while Little Snipper brings up the bridge. If the
status bar reports that you're offline, check the password used with the network
you selected and try again";
        echo "</div>";
        echo "<form method='get' id='bridgeset' action='cgi-bin/config.cgi'>";
        echo "<input name='bridgeset' type='hidden' value='bridgeset'>";
        echo "<button type='submit' value='Start bridge' class='button'>Start bridge</button>";
        echo "</form>";
    }
}
include('footer.php'); ?>
