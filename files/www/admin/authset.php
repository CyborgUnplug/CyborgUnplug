<?php include 'header.php';

$gtg=1;
if (! isset($_POST['password']) ) {
    echo "<div class='warning'>";
    echo "Nothing entered...nothing to do.\n";
    echo "</div>";
    echo "<form method='get' id='authconf' action='authconf.php'>";
    echo "<input name='authconf' type='hidden' value='authconf'>";
    echo "<input type='submit' value='try again' class='button'>";
    echo "</form>";

} else {
    if(isset($_POST['password'])) {
        $pw = $_POST['password'];
        $min = 8;
        if (strlen($pw) < $min) {
            $gtg=0;
            echo "<div class='warning'>";
            echo "Password too short: must be 8 characters or longer.\n";
            echo "</div>";
            echo "<form method='get' id='authconf' action='authconf.php'>";
            echo "<input name='authconf' type='hidden' value='authconf'>";
            echo "<input type='submit' value='try again' class='button'>";
            echo "</form>";
        } else {
            $fn1 ='/tmp/config/adminpass'; 
            $f1 = fopen($fn1, 'w');
            $ret = fwrite($f1, $pw);
            fclose($f1); 
            if($ret === false) {
                die('There was an error writing this file');
            } 
        }
    }
    if ( $gtg == 1 ){
        echo "<div class='warning warning3'>";
        echo "Admin password saved.\n";
        //echo "$ret bytes written to auth file";
        echo "</div>";
        echo "<div class='warning warning3'>";
        echo "Select reboot below to restart the configuration interface.\n";
        echo "You'll need to log in with the new settings.\n";
        echo "</div>";
        echo "<form method='get' id='authrestart' action='cgi-bin/config.cgi'>";
        echo "<input name='authrestart' type='hidden' value='authrestart'>";
        echo "<input type='submit' value='restart' class='button'>";
        echo "</form>";
    }
}

include 'footer.php';?>
