<?php include 'header.php';

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
            $parts=$parts.','.$pw;
        }
    }
    $fn ='/www/config/bridge'; 
    $f = fopen($fn, 'w');
    $ret = fwrite($f, $parts);
    fclose($f); 
    if($ret === false) {
        die('There was an error writing this file');
    } else {
        $gtg=1;
    }
    if ( $gtg == 1 ){
        echo "<div class='warning warning3'>";
        echo "Bridge data saved.\n";
        //echo "$ret bytes written to auth file";
        echo "</div>";
        echo "<div class='warning warning3'>";
        echo "Select reboot below to restart the WiFi.\n";
        echo "Be sure to check you are online. If not, check the password used
with the selected network\n";
        echo "</div>";
        echo "<form method='get' id='bridgeset' action='cgi-bin/config.cgi'>";
        echo "<input name='bridgeset' type='hidden' value='bridgeset'>";
        echo "<input type='submit' value='reboot wifi' class='button'>";
        echo "</form>";
    }
}

include 'footer.php';?>
