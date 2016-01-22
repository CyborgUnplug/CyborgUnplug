<?php include '../header.php';?>

    <center>
    <h1 id="headline">Change admin password</h1>
    </center>
     <div id="container_general">
    <center>
    Change the password used to protect the configuration menu
    </center>
    <br>
	<div class='warning'>
    For added security, ensure no one else is connected to Little Snipper during this step. 
    If you forget your new password you'll have to either log into the device using the command line utility <i>ssh</i> or reset it, using the reset button. Visit <a href="https://plugunplug.net/guides/littlesnipper">https://plugunplug.net/guides/littlesnipper</a> for more.
	</div>
      <form enctype="multipart/form-data" action="authset.php" method="post">
        Set new admin password 
        <input name="password" type="text" placeholder="plugunplug" />
        <br><br>
        <input type="submit" value="save" />
      </form>
        <br><br>
      </div>
<?php include '../footer.php';?>
