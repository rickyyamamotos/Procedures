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
      if (substr($line,1,5) == "cfg->") {
         if (strpos($line, "cfg->dbhost")) {
            $vardbhost1 = getvar1 ($line, "cfg->dbhost");
            }
         else if (strpos($line, "cfg->dbname")) {

            $vardbname1 = getvar1 ($line, "cfg->dbname");
            }
         else if (strpos($line, "cfg->dbuser")) {
            $<Username> = getvar1 ($line, "cfg->dbuser");
            }
         else if (strpos($line, "cfg->dbpass")) {
            $vardbpass1 = getvar1 ($line, "cfg->dbpass");
            }
         }
      }
   if (!$link = pg_connect ("host=$vardbhost1 dbname=$vardbname1 user=$<Username> password=$vardbpass1")) {
      $error1 = error_get_last();
      echo "Error connection failed: ". $error1['message']. "<BR>";
      }
   else {
      echo ("OK");
      }
   }
else {
   # unauthorized access
   header("Location: index.php");
   die();
   }
?>
</BODY>
</HTML>
