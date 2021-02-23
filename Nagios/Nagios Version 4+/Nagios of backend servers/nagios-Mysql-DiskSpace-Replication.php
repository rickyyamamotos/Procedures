<HMTL>
<BODY>
<?php
# script name: nagios.php
# cant user "require_once('config.php');" because it will not show if the mysql is down
# on the moodle server, do the following:
#    cp nagios.php to /var/www/html
#    chmod 774 nagios.php
# on the nagios server, do the following:
#    nano /usr/local/nagios/etc/objects/h_hosts.cfg
#               define host{
#                       use                     t_<Site>-http-check-disk-space
#                     # if server is only https accessible, then use t_<Site>-https-check-disk-space in the above line
#                       host_name               h_SERVERURL-DiskSpace
#                       # replace SERVERURL with the url address of the server. I.E. <Domain>
#                       address                 SERVERURL
#                       parents                 h_SERVERURL
#                       icon_image              disk.png
#                       statusmap_image         disk.gd2
#                       }
#               define host{
#                       use                     t_<Site>-http-check-mysql
#                     # if server is only https accessible, then use t_<Site>-http-check-mysql in the above line
#                       host_name               h_SERVERURL-MYSQL
#                       # replace SERVERURL with the url address of the server. I.E. <Domain>
#                       address                 SERVERURL
#                       parents                 h_SERVERURL
#                       icon_image              mysql.png
#                       statusmap_image         mysql.gd2
#                       }

function getvar1 ($var1, $var2) {
   $var2 = substr($var1, strpos($var1, "'")+1);
   $var2 = substr($var2, 0, strpos($var2, "'"));
   return $var2;
   }

#$i_id = $_GET["id"];
#   Unfiltered
$i_id = filter_input(INPUT_GET, 'id', FILTER_SANITIZE_SPECIAL_CHARS);
#   Filtered input

if ($i_id == "Rick") {
      echo ("Hi");
   }
else if ($i_id == "DiskSpace") {
   $df = disk_free_space("/");
   if ($df < 5000000000) {
         echo ("LowDiskSpace");
      }
   else {
         echo ("DiskSpaceHigherThan5Gb");
       }
   }
else if ($i_id == 'MySQL') {
   $vardbhost1 = "127.0.0.1";
   $vardbname1 = "v";
   $<Username> = "<DBName>";
   $vardbpass1 = "<Password>";
   $link = mysqli_connect($vardbhost1, $<Username>, $vardbpass1) or die("Error: Unable to Connect to MYSQL Server: $vardbhost1");
   mysqli_select_db($link, $vardbname1) or die("Error: Unable to open the db: $vardbname1");
   mysql_close($link);
   echo ("OK");
   }
else if ($i_id == 'Replication') {
   $vardbhost1 = "127.0.0.1";
   $vardbname1 = "v";
   $<Username> = "<DBName>";
   $vardbpass1 = "<Password>";
   $errors = "";
   $link = mysql_connect($server, $username, $password);
   if($link) {
      $res = mysql_query("SHOW SLAVE STATUS", $link);
      $row = mysql_fetch_assoc($res);
      if($row['Slave_IO_Running'] == 'No') {
         $errors .= "Slave IO not running on $server\n";
         $errors .= "Error number: {$row['Last_IO_Errno']}\n";
         $errors .= "Error message: {$row['Last_IO_Error']}\n\n";
      }
      if($row['Slave_SQL_Running'] == 'No') {
         $errors .= "Slave SQL not running on $server\n";
         $errors .= "Error number: {$row['Last_SQL_Errno']}\n";
         $errors .= "Error message: {$row['Last_SQL_Error']}\n\n";
      }
   mysql_close($link);
   }
   else {
      $errors .= "Could not connect to $server\n\n";
   }
   if ($errors == "") {
      $errors = "OK";
   }
   echo ($errors);
   }
else {
   # unauthorized access
   header("Location: index.php");
   die();
   }
?>
</BODY>
</HTML>


