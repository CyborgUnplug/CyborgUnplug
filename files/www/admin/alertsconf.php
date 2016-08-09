<?php include 'header.php';?>

<center>
<h1 id="headline">Change your alerts email</h1>
</center>

<?php
    $fn='/www/config/email';
    if (file_exists($fn)) {
        $f = fopen("/www/config/email", "r");
        $g=fgets($f);                                                                                                                              
        if ($g) {
            echo "<br>";
            echo "<div class='warning warning3'>";
            echo "The email we have for you is: ";
            echo "<center>". $g ."</center>";
            echo "</div>";
            echo "<div id='container_general'>";
            echo "<form enctype='multipart/form-data' action='emailconf.php' method='post'>";
            echo "<p>";
            echo "<center>";
            echo "Enter a new email address on which to receive email alerts and notifications from Little Snipper";
            echo "</center>";
            echo "<br>";
            echo "<input name='email' type='text' placeholder='". $g ."' />";
            echo "<br><br>";
            echo "<input type='submit' value='save' />";
            echo "</form>";
            echo "</div>";
        }
    }
include 'footer.php';?>
