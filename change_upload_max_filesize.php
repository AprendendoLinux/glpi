<?php

$dbhost=exec("cat /var/www/html/config/config_db.php | grep dbhost | awk '{print $4}' | cut -d\"'\" -f2");

$dbuser=exec("cat /var/www/html/config/config_db.php | grep dbuser | awk '{print $4}' | cut -d\"'\" -f2");

$dbpassword=exec("cat /var/www/html/config/config_db.php | grep dbpassword | awk '{print $4}' | cut -d\"'\" -f2");

$dbdefault=exec("cat /var/www/html/config/config_db.php | grep dbdefault | awk '{print $4}' | cut -d\"'\" -f2");

$valor=exec("cat /etc/php/8.2/apache2/php.ini | grep max_filesize | awk '{print $3}' | cut -d'M' -f1");

$link = mysqli_connect($dbhost, $dbuser, $dbpassword, $dbdefault);

if($link === false){
    die("ERROR: Could not connect. " . mysqli_connect_error());
}

$sql = "UPDATE $dbdefault.glpi_configs SET value = $valor WHERE glpi_configs.name = 'document_max_size'";

if(mysqli_query($link, $sql)){
    echo "Records were updated successfully.";
} else {
    echo "ERROR: Could not able to execute $sql. " . mysqli_error($link);
}
 
mysqli_close($link);
?>
