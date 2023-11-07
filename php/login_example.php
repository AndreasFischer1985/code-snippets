<!DOCTYPE html>
<html>
<body>
<h1>Login Demo</h1>
<div>
  <?php
  session_start(); 
  $showFormular = false;
  echo $_SESSION['userid'];
  if (!isset($_SESSION['userid'])) { 	
	$showFormular = true;
	//echo "Session-ID not set!<br>";
	if(isset($_GET['login'])) {	
		$name = $_POST['name'];
		$password = $_POST['password'];
		if ($name == 'user' && $password == 'password') {
			$_SESSION['userid'] = $name;
			echo 'Login successful.<br><br>';
			header("Refresh:0; url=".$pagename."?login=1");
			$showFormular = false;
		} else {
			echo'Username oder Passwort ungültig.<br><br>';
			if(isset($_POST['name']))header("Refresh:0; url=".$pagename."?login=2"); 
			$showFormular = true;
		}
	}
  }
  if($showFormular) { 
  ?>
	<h2>Login</h2>
	<form action="?login=1" method="post">
	Name:<br>
	<input size="40" maxlength="250" name="name"><br><br>
	Password:<br>
	<input type="password" size="40"  maxlength="250" name="password"><br><br>
	<input type="submit" value="Abschicken">
	</form>
  <?php
	}
  ?>
  <?php
	if(isset($_SESSION['userid']) && isset($_GET['logout'])) {	
		session_start();
		session_destroy();
		header("Refresh:0; url=".$pagename);
	}
	if(isset($_SESSION['userid'])){					
			echo "<h1>Private Section</h1>";
			echo "<h2>Login successful</h2>";
			echo "<p>Private content.</p>";
  ?>
   		<form action="?logout=0" method="POST">
        		<input type="submit" name="logout" class="button" value="Logout" />
    		</form>
    		<br><br>
   <?php
	}
  ?>

</div>

</body>
</html>
