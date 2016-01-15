<?php include 'header.php';?>

  <center>
  <h1 id="headline">Welcome!</h1>
  </center>
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
             echo "Before we begin, please ensure that Little Snipper is online.<br><br>To do so,
             connect the Ethernet cable provided to the WAN port on Little Snipper and the
             other end to your router at home or work. <br><br>Note that the status bar at the top of this page will tell you when Little Snipper is online";
             echo "<br><br>";
             echo "<input type='submit' value='Refresh' />";
             echo "</form>";
             echo "</div>";
        }
        else {
             echo "<div id='container_general'>";
             echo "<form enctype='multipart/form-data' action='registered.php' method='post'>";
             echo "<p>";
             echo "Great, it seems we're online. Now enter an email address on which to
             receive email alerts and updates from Little Snipper. Rest assured,
             we won't use it for anything else!";
             echo "</center>";
             echo "<br><br>";
             echo "<input name='email' type='text' placeholder='jack@nsa.gov' />";
             echo "<br><br>";
             echo "<input type='submit' value='save' />";
             echo "</form>";
             echo "<br><br>";
             echo "</div>";
        }
    }
}
include 'footer.php';?>
