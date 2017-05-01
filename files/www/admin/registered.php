<?php
$page_title = "Setup Completed";
include('header.php');
if (! isset($_POST['email']) ) {
?>
<div class="warning">
	No email entered...nothing to do.
</div>
<form method="get" id="email" action="registered.php">
	<input name="email" type="text" placeholder="jack@nsa.gov">
	<br><br>
	<button type="submit" value="save">Save</button>
</form>
<?php } else { 
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
?>
<div class="center">
	<h1>Setup Completed</h1>
</div>
<div class="warning warning3">
	<p>Your email address was successfully saved. You are now ready to start
using Little Snipper.</p>
</div>
<div>
<form method="get" id="registered" action="cgi-bin/config.cgi">
	<input name="registered" type="hidden" value="registered">
	<button type="submit" value="go" class="button">Go</button>
</form>
</div>
<?php } else { ?>
<div class="center">
	<h1>Setup your Little Snipper</h1>
</div>
<div class="warning warning1">
	<p>Oops, that does not appear to be a valid email address.</p>
</div>
<div>
<form method="get" id="again" action="start.php">
	<button type="submit" value="try again" class="button">Try Again</button>
</form>
</div>
<?php
        }
    
    }
}
include('footer.php'); ?>
