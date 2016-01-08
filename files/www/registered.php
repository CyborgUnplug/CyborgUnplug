<?php include 'header.php';

if (! isset($_POST['email']) ) {
    echo "<div class='warning'>";
    echo "No email entered...nothing to do.\n";
    echo "</div>";
    echo "<form method='get' id='email' action='registered.php'>";
    echo "<input name='email' type='text' placeholder='jack@nsa.gov' />";
    echo "<br><br>";
    echo "<input type='submit' value='save' />";
    echo "</form>";

} else {
    if(isset($_POST['email'])) {
        if (filter_var($_POST['email'], FILTER_VALIDATE_EMAIL)) {
                $email = $_POST['email'];
                $fn1 ='/www/config/email'; 
                $f1 = fopen($fn1, 'w');
                $ret = fwrite($f1, $email);
                fclose($f1); 
                if($ret === false) {
                    die('There was an error writing this file');
                }
                echo "<div class='warning warning3'>";
                echo "Email data saved.\nYou're now ready to start using Little Snipper";
                echo "</div>";
                echo "<div>";
                echo "<form method='get' id='registered' action='cgi-bin/config.cgi'>";
                echo "<input name='registered' type='hidden' value='registered'>";
                echo "<input type='submit' value='Go' class='button'>";
                echo "</form>";
                echo "</div>";
    //echo "$ret bytes written to auth file";
        } else {
            echo "<div class='warning warning1'>";
            echo "<p>That doesn't appear to be a valid email address.</p>";
            echo "</div>";
            echo "<div>";
            echo "<form method='get' id='again' action='start.php'>";
            echo "<input type='submit' value='Try again' class='button'>";
            echo "</form>";
            echo "</div>";
        }
    
    }
}

include 'footer.php';?>
