<html>

<?php 
$pagename="sql_search_example.php";
session_start();
$pdo = new PDO('mysql:host=localhost;dbname=search', 'admin1', 'admin_password');

//CREATE DATABASE search;
//USE search;
//CREATE TABLE `entries` ( 
//  `id` INT NOT NULL AUTO_INCREMENT ,
//  `title` VARCHAR(255) NOT NULL ,
//  `abstract` VARCHAR(255) NOT NULL ,
//  `keywords` VARCHAR(255) NOT NULL ,
//  `url` VARCHAR(255) NOT NULL ,
//  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
//  `updated_at` TIMESTAMP on update CURRENT_TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
//  PRIMARY KEY (`id`), UNIQUE (`title`)
//) ENGINE = InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
//INSERT INTO entries (title,abstract,keywords,url) VALUES("test","This is an exemplary test entry","test entry","test.html");
//CREATE USER 'admin1'@'localhost' IDENTIFIED BY 'admin_password';
//GRANT ALL PRIVILEGES ON search.* TO 'admin1'@'localhost' WITH GRANT OPTION;
//FLUSH PRIVILEGES;

?>  

<body>
<h1>Search Engine Example</h1>
<form action="" method="GET" name="">
	<table><tr>
		<td><input type="text" name="k" value="<?php echo isset($_GET['k']) ? $_GET['k'] : ''; ?>" placeholder="Enter search term(s)" /></td>
		<td><input type="submit" name="" value="Search" /></td>
	</tr></table>
</form>

<?php
$k = isset($_GET['k']) ? $_GET['k'] : '';
$query_string = "SELECT * FROM entries WHERE ";
$display_words = "";
$keywords = explode(' ', preg_replace( '/[^A-Za-z0-9 ]/i', '', $k));			
foreach ($keywords as $searchterm){
    $query_string .= "keywords LIKE '%".$searchterm."%' OR ";
    $display_words .= $searchterm.' ';
}
if($_GET['k']=='')$query_string = "SELECT * FROM entries WHERE 1=2";
$query_string = substr($query_string, 0, strlen($query_string)-4);
$display_words = substr($display_words, 0, strlen($display_words)-1);
$result = $pdo->query($query_string);
echo '<table class="results">';
$counter=0;
foreach ($pdo->query($query_string) as $row) {
        $counter=$counter+1;
	echo '<tr><td><h3><a href="'.$row['url'].'">'.$row['title'].'</a></h3></td></tr>
	      <tr><td>'.$row['abstract'].'</td></tr>
              <tr><td><i>'.$row['url'].'</i></td></tr>';
}
echo '</table>';
echo '<br><hr /><div><b><u>'.number_format($counter).'</u></b> results found<br>';
echo 'based on search terms <i>"'.$display_words.'"</i></div><hr />';
?>

</body>
</html>
