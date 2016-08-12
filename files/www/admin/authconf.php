<?php include 'header.php';?>

    <center>
    <h1 id="headline">Change admin password</h1>
    </center>
    <br>
     <div id="container_general">
    <center>
    Set a new password for the configuration menu
    </center>
	<div class='warning'>
    For added security ensure no one else is connected to Little Snipper during this step. 
    If you forget your new password you'll have to either log into the device
using a command line utility or reset it. See <a href="https://plugunplug.net/guides">https://plugunplug.net/guides</a>
	</div>
        <br>
      <form enctype="multipart/form-data" action="authset.php" method="post">
        <input name="password" type="text" placeholder="plugunplug" />
        <br><br>
        <input type="submit" value="save" />
      </form>
      </div>
<?php include 'footer.php';?>
