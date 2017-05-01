<?php
$page_title = "Admin Password";
include('header.php');
?>
    <div class="center">
	    <h1><i class="icon-settings"></i> Admin Password</h1>
    </div>
    <div id="container_general">
    <center>
    Set a new password for the configuration menu
    </center>
	<div class="warning">
    For added security ensure no one else is connected to Little Snipper during this step. 
    If you forget your new password you'll have to either log into the device
using the command line utility <em>ssh</em> or reset it. See <a href="https://plugunplug.net/guides">https://plugunplug.net/guides</a>
	</div>
    <form enctype="multipart/form-data" action="authset.php" method="post">
    	<input name="password" type="text" placeholder="plugunplug" />
        <br><br>
        <button type="submit" value="save">Save</button>
	</form>
	</div>
<?php include('footer.php'); ?>
