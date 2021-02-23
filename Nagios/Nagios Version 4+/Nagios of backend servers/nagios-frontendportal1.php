<HMTL>
<BODY>
<?php
# script name: nagios.php
# On the frontendportal1.<Site> server, do the following
#    cp nagios.php to /var/www/html/
#    chmod 774 nagios.php
# on the nagios server, do the following:
# nano c_command.cfg
#	define command{
#	        command_name    c_check_http-frontendport1
#	        command_line    $<Username>$/check_http -H $HOSTADDRESS$ -u /nagios.php?id=frontendportal1 -s "UP"
#	        }
# nano h_hosts.cfg
#	define host{
#	        name                    t_<Site>-http-check-frontendportal1
#	        use                     <Site>-WEB
#	        check_period            24x7
#	        check_interval          15
#	        retry_interval          5
#	        max_check_attempts      3
#	        check_command           c_check_http-frontendportal1
#	        notification_period     24x7
#	        notification_interval   0
#	        notification_options    d,u,r,f
#	        contact_groups          <Username>s
#	        <Site>                0
#	}
#    nano /usr/local/nagios/etc/objects/h_hosts.cfg
# 	define host{
#	        use                     t_<Site>-http-check-frontendportal1
#	        host_name               h_frontendportal.connect4educaton.org
#	        address                 frontendportal.<Site>
#	        parents                 h_sonicwall-XXX.XXX.XXX.228
#	        icon_image              vm-host.png
#	        statusmap_image         vm-host.gd2
#	        }
function checkOnline($domain) {

   $curlInit = curl_init($domain);

   curl_setopt($curlInit,CURLOPT_CONNECTTIMEOUT,1);

   curl_setopt($curlInit,CURLOPT_TIMEOUT,1);

   curl_setopt($curlInit,CURLOPT_HEADER,true);

   curl_setopt($curlInit,CURLOPT_NOBODY,true);

   curl_setopt($curlInit,CURLOPT_RETURNTRANSFER,true);

   $response = curl_exec($curlInit);

   curl_close($curlInit);

   if ($response) { return "UP"; }

   else { return "DOWN"; }

   }


#$i_id = $_GET["id"];
#   Unfiltered
$i_id = filter_input(INPUT_GET, 'id', FILTER_SANITIZE_SPECIAL_CHARS);
#   Filtered input

if ($i_id == "Rick") {
      echo "Hi<BR>";
      echo "internal UpperR610 is ";
echo checkOnline("http://XXX.XXX.XXX.231");
echo "<BR>";

      echo "internal LowerR610 is ";
echo checkOnline("http://XXX.XXX.XXX.232");
echo "<BR>";

      echo "internal Frontendportal1 is ";
echo checkOnline("http://XXX.XXX.XXX.11");
echo "<BR>";

      echo "internal Frontendportal2 is ";
echo checkOnline("http://XXX.XXX.XXX.10");
echo "<BR>";

   }
else if ($i_id == "UpperR610") {
   
echo checkOnline("http://XXX.XXX.XXX.231");
echo "<BR>";

   }
else if ($i_id == "LowerR610") {
   
echo checkOnline("http://XXX.XXX.XXX.232");
echo "<BR>";

   }
else if ($i_id == "Frontendportal1") {
   
echo checkOnline("http://XXX.XXX.XXX.11");
echo "<BR>";

   }
else if ($i_id == "Frontendportal2") {
   
echo checkOnline("http://XXX.XXX.XXX.10");
echo "<BR>";

   }
else {
   # unauthorized access
   header("Location: index.html");
   die();
   }
?>
</BODY>
</HTML>
