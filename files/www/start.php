<?php include 'header.php';?>

  <h1 id="headline">Welcome to Little Snipper</h1>

 <div id="container_general">
  <form enctype="multipart/form-data" action="registered.php" method="post">
    <p>
    Email is the only way you can be updated live about spy devices discovered by Little Snipper.  Please enter an
email address for alerts from this device (we won't use it for anything else!). 
    <br><br> 
    <input name="email" type="text" placeholder="jack@nsa.gov" />
    <br><br>
    <input type="submit" value="save" />
  </form>
    <br><br>
  </div>
    
<?php include 'footer.php';?>
