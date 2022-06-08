<html>
<?php
$pagename="sql_chat_example.php";
$pdo = new PDO('mysql:host=localhost;dbname=chat', 'admin1', 'admin_password');

//CREATE DATABASE chat;
//USE chat;
//CREATE USER 'admin1'@'localhost' IDENTIFIED BY 'admin_password';
//GRANT ALL PRIVILEGES ON chat.* TO 'admin1'@'localhost' WITH GRANT OPTION;
//FLUSH PRIVILEGES;
//CREATE TABLE `history` ( 
//  `id` INT NOT NULL AUTO_INCREMENT ,
//  `username` VARCHAR(255) NOT NULL ,
//  `message` VARCHAR(255) NOT NULL ,
//  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
//  `updated_at` TIMESTAMP on update CURRENT_TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
//  PRIMARY KEY (`id`)
//) ENGINE = InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

if (isset($_POST['submit'])){
  $statement = $pdo->prepare("INSERT INTO history (username, message) VALUES (:username,:message);");
  $query = $statement->execute(array('username' => $_REQUEST['username'], 'message' => $_REQUEST['message']));
}

?>

<head>
<style>
*{
	box-sizing:border-box;
}
body{
	background-color:#67a2be;
	font-family:Calibri;
}
#container{
	width:400px;
	height:600px;
	background:white;
	margin:0 auto;
	font-size:0;
	border-radius:5px;
	overflow:hidden;
}
main{
	display:inline-block;
	font-size:15px;
	vertical-align:top;
}
main header{
	height:30px;
	padding:10px 10px 40px 10px;
	background-color:#005578;
}

main header h1{
	font-size:30px;
	margin-top:5px;
	color:black;
}
main header h2{
	font-size:20px;
	margin-top:5px;
	text-align:center;
	color:white;
}
main .inner_div{
	padding-left:0;
	margin:0;
	list-style-type:none;
	position:relative;
	overflow:auto;
	height:80%;
   	background-position:center;
	background-repeat:no-repeat;
	background-size:cover;
	position: relative;
	border-top:2px solid #fff;
	border-bottom:2px solid #fff;
	
}
main .triangleL{
	width: 0;
	height: 0;
	border-style: solid;
	border-width: 0 8px 8px 8px;
	border-color: transparent transparent #005578 transparent;
	margin-left:20px;
	clear:both;
}
main .messageL{
	padding:10px;
	color:#000;
	margin-left:15px;
	background-color:#005578;
	line-height:20px;
	max-width:90%;
	display:inline-block;
	text-align:left;
	border-radius:5px;
	clear:both;
}
main .triangleR{
	width: 0;
	height: 0;
	border-style: solid;
	border-width: 0 8px 8px 8px;
	border-color: transparent transparent #67a2be transparent;
	margin-right:20px;
	float:right;
	clear:both;
}
main .messageR{
	padding:10px;
	color:#000;
	margin-right:15px;
	background-color:#67a2be;
	line-height:20px;
	max-width:90%;
	display:inline-block;
	text-align:left;
	border-radius:5px;
	float:right;
	clear:both;
}
main footer{
	background-color:#005578;
	height:100%;
}
main footer .user{
	resize:none;
	border:100%;
	display:block;
	width:120%;
	height:60px;
	border-radius:3px;
	padding:20px;
	font-size:11px;
	margin-bottom:13px;
}
main footer .message{
	resize:none;
	border:100%;
	display:block;
	width:140%;
	height:60px;
	border-radius:3px;
	padding:20px;
	font-size:11px;
	margin-bottom:13px;
	margin-left:20px;
}
main footer .submit{
	resize:none;
	border:100%;
	display:block;
	width:40%;
	height:60px;
	border-radius:3px;
	padding:20px;
	font-size:13px;
	margin-bottom:13px;
	margin-left:100px;
	color:white;
	text-align:center;
	background-color:black;
	border: 2px solid white;
}
}
main footer textarea::placeholder{
	color:#ddd;
}
</style>

<script>
function scroll(){
  var element = document.getElementById("history");
  element.scrollTop = element.scrollHeight;
}
</script>

<body onload="scroll()">
<h1>Test</h1>
<div id="container">
	<main>
		<header><div><h2>Chat Demo</h2></div></header>
        <form action=<?php echo $pagename; ?> method="POST" >
        <div class="inner_div" id="history">

<?php
$i=0;
$hist=$pdo->query("SELECT * FROM history");
foreach ($pdo->query("SELECT * FROM history") as $row){
if($i==0){
  $i=5;
  $first=$row;
?>

       <div class="triangleL"></div>
       <div class="messageL">
       <span style="color:white;float:right;">
       <?php echo $row['message']; ?></span> <br/>
       <div>
       <span style="color:black;float:left;font-size:10px;clear:both;">
	   <?php echo $row['username']; ?>,
	   <?php echo $row['created_at']; ?>
       </span>
       </div>
       </div>
       <br/><br/>
<?php
} else{
if($row['username']==$first['username']){
?>
       <div class="triangleL"></div>
       <div class="messageL">
       <span style="color:white;float:left;">
       <?php echo $row['message']; ?>
       </span> <br/>
       <div>
       <span style="color:black;float:right;font-size:10px;clear:both;">
       <?php echo $row['username']; ?>,
	   <?php echo $row['created_at']; ?>
       </span>
       </div>
       </div>
       <br/><br/>
<?php
} else {
?>
       <div class="triangleR"></div>
       <div class="messageR">
       <span style="color:white;float:right;">
       <?php echo $row['message']; ?>
       </span> <br/>
       <div>
       <span style="color:black;float:left;font-size:10px;clear:both;">
       <?php echo $row['username']; ?>,
	   <?php echo $row['created_at']; ?>
       </span>
       </div>
       </div>
       <br/><br/>
<?php
}}
}
?>
       </div>
	   <footer>
		 <table>
		 <tr>
		 <th><input class="user" type="text" name="username" placeholder="From?"></th>
		 <th><textarea class="message" name="message" rows='3' cols='50' placeholder="Type your message..."></textarea></th>
		 <th><input class="submit" type="submit" name="submit" value="send"></th>			
		 </tr>
		 </table>			
	   </footer>
       </form>
     </main>
     </div>
  </body>
</html>

