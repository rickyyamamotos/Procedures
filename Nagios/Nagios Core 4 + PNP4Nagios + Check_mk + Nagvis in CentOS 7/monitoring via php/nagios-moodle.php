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

$i_id = $_GET["id"];
if ($i_id == "Rick") {
      echo ("Hi");
   }
else if ($i_id == "DiskSpace") {
   $df = disk_free_space("/");
   if ($df < 10000000000) {
         echo ("LowDiskSpace");
      }
   else {
         echo ("DiskSpaceHigherThan10Gb");
       }
   }
else if ($i_id == 'MySQL') {
   $array = file("config.php");
   foreach($array as $line) {
      if (strlen($line) > 23){
         if ((substr($line,0,1) <> "#") and (substr($line,0,1) <> "/")) {
            if (strpos($line, "CFG->dbhost")) {
               $vardbhost1 = getvar1 ($line, "CFG->dbhost");
               }
            else if (strpos($line, "CFG->dbname")) {
               $vardbname1 = getvar1 ($line, "CFG->dbname");
               }
            else if (strpos($line, "CFG->dbuser")) {
               $<Username> = getvar1 ($line, "CFG->dbuser");
               }
            else if (strpos($line, "CFG->dbpass")) {
               $vardbpass1 = getvar1 ($line, "CFG->dbpass");
               }
            }
         }
      }
   $link = mysqli_connect($vardbhost1, $<Username>, $vardbpass1) or die("Error: Unable to Connect to MYSQL Server: $vardbhost1");
   mysqli_select_db($link, $vardbname1) or die("Error: Unable to open the db: $vardbname1");
   echo ("OK");
   }
else {
   # unauthorized access
   header("Location: index.php");
   die();
   }
?>
</BODY>
</HTML>