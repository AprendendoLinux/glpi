<?php

$dbhost=exec("cat /var/www/html/config/config_db.php | grep dbhost | awk '{print $4}' | cut -d\"'\" -f2");
//echo $dbhost ." - " ;

$dbuser=exec("cat /var/www/html/config/config_db.php | grep dbuser | awk '{print $4}' | cut -d\"'\" -f2");
//echo $dbuser ." - " ;

$dbpassword=exec("cat /var/www/html/config/config_db.php | grep dbpassword | awk '{print $4}' | cut -d\"'\" -f2");
//echo $dbpassword ." - " ;

$dbdefault=exec("cat /var/www/html/config/config_db.php | grep dbdefault | awk '{print $4}' | cut -d\"'\" -f2");
//echo $dbdefault ." - " ;

$valor=exec("cat /etc/php/7.4/apache2/php.ini | grep max_filesize | awk '{print $3}' | cut -d'M' -f1");
//echo $valor ." - " ;

$link = mysqli_connect($dbhost, $dbuser, $dbpassword, $dbdefault);

if($link === false){
    die("ERROR: Could not connect. " . mysqli_connect_error());
}

$sql = "UPDATE $dbdefault.glpi_configs SET value = $valor WHERE glpi_configs.id = 220";

if(mysqli_query($link, $sql)){
    echo "Records were updated successfully.";
} else {
    echo "ERROR: Could not able to execute $sql. " . mysqli_error($link);
}
 
mysqli_close($link);
?>
