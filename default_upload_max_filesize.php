<?php

$dbhost=exec("cat /var/www/html/config/config_db.php | grep dbhost | awk '{print $4}' | cut -d\"'\" -f2");
//echo $dbhost ." - " ;

$dbuser=exec("cat /var/www/html/config/config_db.php | grep dbuser | awk '{print $4}' | cut -d\"'\" -f2");
//echo $dbuser ." - " ;

$dbpassword=exec("cat /var/www/html/config/config_db.php | grep dbpassword | awk '{print $4}' | cut -d\"'\" -f2");
//echo $dbpassword ." - " ;

$dbdefault=exec("cat /var/www/html/config/config_db.php | grep dbdefault | awk '{print $4}' | cut -d\"'\" -f2");
//echo $dbdefault ." - " ;

$link = mysqli_connect($dbhost, $dbuser, $dbpassword, $dbdefault);

if($link === false){
    die("ERROR: Could not connect. " . mysqli_connect_error());
}

$sql = "UPDATE $dbdefault.glpi_configs SET value = 2 WHERE glpi_configs.id = 220";

if(mysqli_query($link, $sql)){
    echo "Records were updated successfully.";
} else {
    echo "ERROR: Could not able to execute $sql. " . mysqli_error($link);
}
 
mysqli_close($link);
?>
