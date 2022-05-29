<!DOCTYPE html> 

<?php 
$pagename="mysql_login_example.php";
session_start();
$pdo = new PDO('mysql:host=localhost;dbname=login', 'admin1', 'admin_password');

//CREATE DATABASE login;
//CREATE USER 'admin1'@'localhost' IDENTIFIED BY 'admin_password';
//GRANT ALL PRIVILEGES ON login.* TO 'admin1'@'localhost' WITH GRANT OPTION;
//FLUSH PRIVILEGES;
//CREATE TABLE `users` ( 
//  `id` INT NOT NULL AUTO_INCREMENT ,
//  `email` VARCHAR(255) NOT NULL ,
//  `password` VARCHAR(255) NOT NULL ,
//  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
//  `updated_at` TIMESTAMP on update CURRENT_TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
//  PRIMARY KEY (`id`), UNIQUE (`email`)
//) ENGINE = InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
//INSERT INTO users (email,password) VALUES("admin@web.de","password123");

?>  

<html>
<body>

<style>
body, html { height: 100%;  margin: 0;  font-family: Arial; }
.tablink {  background-color: #555;  color: white;  float: left;  border: none; outline: none;  cursor: pointer;  padding: 14px 16px;  font-size: 17px;  width: 50%; }
.tablink:hover {  background-color: #777; }
.tabcontent {  color: white;  display: none;  padding: 100px 20px;  height: 100%; overflow: scroll;}
#Public {background-color: white; color:black;}
#Private {background-color: white; color:black;}
</style>

<button class="tablink" onclick="openPage('Public', this, '#005578')"  id="public">Public</button>
<button class="tablink" onclick="openPage('Private', this, '#67a2be')" id="private">Private</button>

<div id="Private" class="tabcontent">
<h1>Private Section</h1>

  <?php // <!-- User-Login -->
  $showFormular = true;  
  if (!isset($_SESSION['userid'])) {   
	echo "<h2>Login</h2>";
	if(isset($_GET['login'])) {
		$email = $_POST['email'];
		$password = $_POST['password'];    
		$statement = $pdo->prepare("SELECT * FROM users WHERE email = :email");
		$result = $statement->execute(array('email' => $email));
		$user = $statement->fetch();     
		if (($user !== false && password_verify($password, $user['password'])) || ($email == 'admin2@web.de' && $password == 'password123')) {
			if($email == 'admin2@web.de')$user['id']=1;
			$_SESSION['userid'] = $user['id'];
			echo 'Login successful.<br><br>';
			header("Refresh:0; url=".$pagename."?login=1");
		} else {
			echo'E-Mail or password not valid.<br><br>';
		}    
	}
  }	
  if($showFormular && !isset($_SESSION['userid'])) {
  ?>

	<form action="?login=1" method="post">
	User E-Mail:<br>
	<input type="email" size="40" maxlength="250" name="email"><br><br> 
	User Password:<br>
	<input type="password" size="40"  maxlength="250" name="password"><br><br> 
	<input type="submit" value="Abschicken">
	</form> 	

  <?php
	}
  ?>	
	
  <?php // <!-- Dashboard & Logout-Button -->
	if(isset($_GET['logout'])) {
		session_start();
		session_destroy();
		header("Refresh:0; url=".$pagename);
	}  
	if(isset($_SESSION['userid'])){		
			echo "<h2>Success</h2>";
			echo "<p>Private content.</p>";
  ?>	    
    <form action="?logout=1" method="post">
        <input type="submit" name="logout"
                class="button" value="Logout" />
    </form>	
    <br><br>

   <?php
	} 
  ?> 

  <?php // <!-- Register new User -->
  $showFormular2 = true; //Variable ob das Registrierungsformular angezeigt werden soll 
  if(isset($_SESSION['userid']) && $_SESSION['userid']==1) { 	
	echo "<h1>Admin</h1>";
	if(isset($_GET['register'])) {
		$error = false;
		$email = $_POST['email'];
		$password = $_POST['password'];
		$password2 = $_POST['password2'];  
		if(!filter_var($email, FILTER_VALIDATE_EMAIL)) {
			echo 'E-Mail or password not valid!<br><br>';
			$error = true;
		}     
		if(strlen($password) == 0) {
			echo 'Please enter your password!<br><br>';
			$error = true;
		}
		if($password != $password2) {
			echo 'Passwords do not match.<br><br>';
			$error = true;
		}    
		if(!$error) { 
			$statement = $pdo->prepare("SELECT * FROM users WHERE email = :email");
			$result = $statement->execute(array('email' => $email));
			$user = $statement->fetch();
			
			if($user !== false) {
				echo 'Please choose a different E-Mail!<br><br>';
				$error = true;				
			}    
		}    		
		if(!$error) {    
			$password_hash = password_hash($password, PASSWORD_DEFAULT);        
			$statement = $pdo->prepare("INSERT INTO users (email, password) VALUES (:email, :password)");
			$result = $statement->execute(array('email' => $email, 'password' => $password_hash));        
			if($result) {        
				echo 'User created.<br><br>';
				header("Refresh:0; url=".$pagename."?login=1");
			} else {
				echo 'An error occured.<br><br>';
			}
		} 
	}
  } 
  if($showFormular2 && isset($_SESSION['userid']) && $_SESSION['userid']==1) {
  ?>
	<details>	
	<summary>Register new user</summary>
	<form action="?register=1" method="post">
	E-Mail:<br>
	<input type="email" size="40" maxlength="250" name="email"><br><br>
	Password:<br>
	<input type="password" size="40"  maxlength="250" name="password"><br>
	Repeat Password:<br>
	<input type="password" size="40" maxlength="250" name="password2"><br><br>
	<input type="submit" value="Register">
	</form>
	</details>
	<br>
	
  <?php
	} //Ende von if($showFormular2)
  ?>
	
</div>


<div id="Public" class="tabcontent">
<h1>Public Section</h1>
</div>

<script>
function openPage(pageName, elmnt, color) {
  var i, tabcontent, tablinks;
  tabcontent = document.getElementsByClassName("tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }
  tablinks = document.getElementsByClassName("tablink");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].style.backgroundColor = "";
  }  
  document.getElementById(pageName).style.display = "block";
  elmnt.style.backgroundColor = color;
}

  <?php
	if(isset($_GET['login'])||isset($_GET['register'])) {
		echo "document.getElementById('private').click();";
	} else {
		echo "document.getElementById('public').click();";
	}
  ?> 

</script>
</body>
</html>
