html>
<body>
<?php
//* made by Rick Yamamoto on 11/20/2018 *//

$day1=date("d");
$month1=date("m");
$year1=date("Y");
$day2=$day1;
$month2=$month1;
$year2=$year1;

$vyear1 = "";
$vmonth1 = "";
$vday1 = "";
$vyear2 = "";
$vmonth2 = "";
$vday2 = "";
$vtime1 = "";
$vline1 = "";
$vwwwroot1 = "";
$vip1 = "";
$vip2 = "";
$vip3 = "";
$v<Username> = "";
$vdateorig1 ="";
$venv1 = "";
$vproto1 = "";
$vserverip3 = "";
$vuserip3 = "";
$vusername3 = "";


if (isset($_POST['todo'])) {
   $todo=$_POST['todo'];
   if ($todo=="submit") {
      $month1=$_POST['month1'];
      $day1=$_POST['day1'];
      $year1=$_POST['year1'];
      $month2=$_POST['month2'];
      $day2=$_POST['day2'];
      $year2=$_POST['year2'];
      $vserverip3=$_POST['vserverip3'];
      $vuserip3=$_POST['vuserip3'];
      $vusername3=$_POST['vusername3'];
      $vip3=$_POST['vip3'];
   }
}
?>

<table>
<tr>
   <td>
       <img src="/images/<Site>Logo-e1521063871620.png" HEIGHT="73" WIDTH="150">
   </td>
   <td>
      <font size="5"><Organization> - IT department </font>
   </td>
</tr>
</table>

Click <A HREF="./index.php"> here </A> to go to the Backups audit page <BR>

<H1>
   Displays of times when the remote users accessed servers via SSH or SFTP
</H1>
<H3>
  Use this table to audit the users that accessed the servers via SSH or SFTP<BR><BR>
<H3>

FILTERS:
<table border="3">
<tr>
<td>
Select the date range  and click on submit to refresh the table
<form method=post name=f1 action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]);?>">
<input type=hidden name=todo value=submit>
<table border="0" cellspacing="0" >
<tr>
<td align=left >
   FROM:
</td>
<td  align=left >
   &nbsp;&nbsp;Month
   <select name=month1> Select Month</option>
   <option value='01' <?php if($month1 == "01"){echo("Selected");}?>>January</option>
   <option value='02' <?php if($month1 == "02"){echo("Selected");}?>>February</option>
   <option value='03' <?php if($month1 == "03"){echo("Selected");}?>>March</option>
   <option value='04' <?php if($month1 == "04"){echo("Selected");}?>>April</option>
   <option value='05' <?php if($month1 == "05"){echo("Selected");}?>>May</option>
   <option value='06' <?php if($month1 == "06"){echo("Selected");}?>>June</option>
   <option value='07' <?php if($month1 == "07"){echo("Selected");}?>>July</option>
   <option value='08' <?php if($month1 == "08"){echo("Selected");}?>>August</option>
   <option value='09' <?php if($month1 == "09"){echo("Selected");}?>>September</option>
   <option value='10' <?php if($month1 == "10"){echo("Selected");}?>>October</option>
   <option value='11' <?php if($month1 == "11"){echo("Selected");}?>>November</option>
   <option value='12' <?php if($month1 == "12"){echo("Selected");}?>>December</option>
   </select>
</td>
<td align=left>
   &nbsp;&nbsp;Day
   <select name=day1>
   <option value='01' <?php if($day1 == "01"){echo("Selected");}?>>01</option>
   <option value='02' <?php if($day1 == "02"){echo("Selected");}?>>02</option>
   <option value='03' <?php if($day1 == "03"){echo("Selected");}?>>03</option>
   <option value='04' <?php if($day1 == "04"){echo("Selected");}?>>04</option>
   <option value='05' <?php if($day1 == "05"){echo("Selected");}?>>05</option>
   <option value='06' <?php if($day1 == "06"){echo("Selected");}?>>06</option>
   <option value='07' <?php if($day1 == "07"){echo("Selected");}?>>07</option>
   <option value='08' <?php if($day1 == "08"){echo("Selected");}?>>08</option>
   <option value='09' <?php if($day1 == "09"){echo("Selected");}?>>09</option>
   <option value='10' <?php if($day1 == "10"){echo("Selected");}?>>10</option>
   <option value='11' <?php if($day1 == "11"){echo("Selected");}?>>11</option>
   <option value='12' <?php if($day1 == "12"){echo("Selected");}?>>12</option>
   <option value='13' <?php if($day1 == "13"){echo("Selected");}?>>13</option>
   <option value='14' <?php if($day1 == "14"){echo("Selected");}?>>14</option>
   <option value='15' <?php if($day1 == "15"){echo("Selected");}?>>15</option>
   <option value='16' <?php if($day1 == "16"){echo("Selected");}?>>16</option>
   <option value='17' <?php if($day1 == "17"){echo("Selected");}?>>17</option>
   <option value='18' <?php if($day1 == "18"){echo("Selected");}?>>18</option>
   <option value='19' <?php if($day1 == "19"){echo("Selected");}?>>19</option>
   <option value='20' <?php if($day1 == "20"){echo("Selected");}?>>20</option>
   <option value='21' <?php if($day1 == "21"){echo("Selected");}?>>21</option>
   <option value='22' <?php if($day1 == "22"){echo("Selected");}?>>22</option>
   <option value='23' <?php if($day1 == "23"){echo("Selected");}?>>23</option>
   <option value='24' <?php if($day1 == "24"){echo("Selected");}?>>24</option>
   <option value='25' <?php if($day1 == "25"){echo("Selected");}?>>25</option>
   <option value='26' <?php if($day1 == "26"){echo("Selected");}?>>26</option>
   <option value='27' <?php if($day1 == "27"){echo("Selected");}?>>27</option>
   <option value='28' <?php if($day1 == "28"){echo("Selected");}?>>28</option>
   <option value='29' <?php if($day1 == "29"){echo("Selected");}?>>29</option>
   <option value='30' <?php if($day1 == "30"){echo("Selected");}?>>30</option>
   <option value='31' <?php if($day1 == "31"){echo("Selected");}?>>31</option>
   </select>
</td>
<td align=left >
    &nbsp;&nbsp;Year(yyyy)<input type=text name=year1 size=4 value=<?=$year1?>>
</td>
</tr>

<tr>
<td align=left >
   TO:
</td>
<td align=left >
   &nbsp;&nbsp;Month
   <select name=month2> Select Month</option>
   <option value='01' <?php if($month2 == "01"){echo("Selected");}?>>January</option>
   <option value='02' <?php if($month2 == "02"){echo("Selected");}?>>February</option>
   <option value='03' <?php if($month2 == "03"){echo("Selected");}?>>March</option>
   <option value='04' <?php if($month2 == "04"){echo("Selected");}?>>April</option>
   <option value='05' <?php if($month2 == "05"){echo("Selected");}?>>May</option>
   <option value='06' <?php if($month2 == "06"){echo("Selected");}?>>June</option>
   <option value='07' <?php if($month2 == "07"){echo("Selected");}?>>July</option>
   <option value='08' <?php if($month2 == "08"){echo("Selected");}?>>August</option>
   <option value='09' <?php if($month2 == "09"){echo("Selected");}?>>September</option>
   <option value='10' <?php if($month2 == "10"){echo("Selected");}?>>October</option>
   <option value='11' <?php if($month2 == "11"){echo("Selected");}?>>November</option>
   <option value='12' <?php if($month2 == "12"){echo("Selected");}?>>December</option>
   </select>
</td>
<td align=left>
   &nbsp;&nbsp;Day
   <select name=day2>
   <option value='01' <?php if($day2 == "01"){echo("Selected");}?>>01</option>
   <option value='02' <?php if($day2 == "02"){echo("Selected");}?>>02</option>
   <option value='03' <?php if($day2 == "03"){echo("Selected");}?>>03</option>
   <option value='04' <?php if($day2 == "04"){echo("Selected");}?>>04</option>
   <option value='05' <?php if($day2 == "05"){echo("Selected");}?>>05</option>
   <option value='06' <?php if($day2 == "06"){echo("Selected");}?>>06</option>
   <option value='07' <?php if($day2 == "07"){echo("Selected");}?>>07</option>
   <option value='08' <?php if($day2 == "08"){echo("Selected");}?>>08</option>
   <option value='09' <?php if($day2 == "09"){echo("Selected");}?>>09</option>
   <option value='10' <?php if($day2 == "10"){echo("Selected");}?>>10</option>
   <option value='11' <?php if($day2 == "11"){echo("Selected");}?>>11</option>
   <option value='12' <?php if($day2 == "12"){echo("Selected");}?>>12</option>
   <option value='13' <?php if($day2 == "13"){echo("Selected");}?>>13</option>
   <option value='14' <?php if($day2 == "14"){echo("Selected");}?>>14</option>
   <option value='15' <?php if($day2 == "15"){echo("Selected");}?>>15</option>
   <option value='16' <?php if($day2 == "16"){echo("Selected");}?>>16</option>
   <option value='17' <?php if($day2 == "17"){echo("Selected");}?>>17</option>
   <option value='18' <?php if($day2 == "18"){echo("Selected");}?>>18</option>
   <option value='19' <?php if($day2 == "19"){echo("Selected");}?>>19</option>
   <option value='20' <?php if($day2 == "20"){echo("Selected");}?>>20</option>
   <option value='21' <?php if($day2 == "21"){echo("Selected");}?>>21</option>
   <option value='22' <?php if($day2 == "22"){echo("Selected");}?>>22</option>
   <option value='23' <?php if($day2 == "23"){echo("Selected");}?>>23</option>
   <option value='24' <?php if($day2 == "24"){echo("Selected");}?>>24</option>
   <option value='25' <?php if($day2 == "25"){echo("Selected");}?>>25</option>
   <option value='26' <?php if($day2 == "26"){echo("Selected");}?>>26</option>
   <option value='27' <?php if($day2 == "27"){echo("Selected");}?>>27</option>
   <option value='28' <?php if($day2 == "28"){echo("Selected");}?>>28</option>
   <option value='29' <?php if($day2 == "29"){echo("Selected");}?>>29</option>
   <option value='30' <?php if($day2 == "30"){echo("Selected");}?>>30</option>
   <option value='31' <?php if($day2 == "31"){echo("Selected");}?>>31</option>
   </select>
</td>
<td align=left>
   &nbsp;&nbsp;Year(yyyy)<input type=text name=year2 size=4 value=<?=$year2?>>
</td>
</tr>
</table>
</td>
<td>
Optionally enter IP of Server:
<BR>
(I.E. 127.0.0.1)
<BR>
<input type=text name=vserverip3 size=15 value=<?php echo $vserverip3; ?> >
</td>
<td>
Optionally enter IP of Remote User:
<BR>
(I.E. 127.0.0.1)
<BR>
<input type=text name=vuserip3 size=15 value=<?php echo $vuserip3; ?> >
</td>
<td>
Optionally enter Username:
<BR>
(I.E. <Username>)
<BR>
<input type=text name=vusername3 size=16 value=<?php echo $vusername3; ?> >
</td>

<!-- This part is not needed
<td>
Optionally select a source IP (IP of the remote user):
<BR>
Leave it blank for all IP addresses
<BR>
<select name="vip3">
<option value=""></option>
   <?php
#      $vfilename1="/mnt/shares/drobo/ssh-access-iplist.log";
#      $f = fopen($vfilename1, 'r') or exit("Unable to open file!");
#      while(!feof($f))
#         {
#         $vline1 =  fgets($f);
#         $vline1=  substr($vline1,strpos($vline1," ")+1);
#         echo '<option value="' . $vline1 . '">' . $vline1. '</option>' . "\n";
#         }
   ?>
</select>
</td>
-->

</tr>
<tr>
<td colspan=4 align=right>
   <input type=submit value=Submit>
</td>
</tr>
</table>
</form>

<!--FILTER VARIABLES: vserverip3, vuserip3, vusername3-->
<BR>
RESULTS:
<?php
   if ($year1*365+$month1*31+$day1 > $year2*365+$month2*31+$day2) {
      echo ("Error: incorrect range of dates <BR>");
      }
   else {
      $vmessage1 = "Creating report for log From: $year1/$month1/$day1 To: $year2/$month2/$day2";
      if (strlen($vserverip3) > 1) {
          $vmessage1=$vmessage1." and for Server with IP=".$vserverip3;
      }
      if (strlen($vuserip3) > 1) {
          $vmessage1=$vmessage1." and for remote User with IP=".$vuserip3;
      }
      if (strlen($vusername3) > 1) {
          $vmessage1=$vmessage1." and for user with username=".$vusername3;
      }
      echo $vmessage1."<BR>";
      $vfilename1="/mnt/shares/drobo/ssh-access-audit.log";
      $f = fopen($vfilename1, 'r') or exit("Unable to open file!");
      echo "<table border='1'><tr><td width='7%'>Time when the Server was accessed:</td><td width='15%'>Name of the Server accessed (SSH target):</td><td width='7%'>IP of the server (SSH target):</td><td width='7%'>IP of the remote user$
      while(!feof($f))
         {
         $vline1 =  fgets($f);
         if (strlen($vline1) > 1) {
            $vyear1 = substr($vline1,0,4);
            $vmonth1 = substr($vline1,5,2);
            $vday1 = substr($vline1,8,2);
            $vtime1 = substr($vline1,11,8);
            $vline1 = substr($vline1,24);
            $vwwwroot1 = substr($vline1,0,strpos($vline1," "));
            $vline1 = substr($vline1,strpos($vline1," ")+1);
            $vip1 = substr($vline1,0,strpos($vline1," "));
            $vline1 = substr($vline1,strpos($vline1," ")+1);
            $vip2 = substr($vline1,0,strpos($vline1," "));
            $vline1 = substr($vline1,strpos($vline1," ")+1);
            $v<Username> = substr($vline1,0,strpos($vline1," "));
            $vline1=  substr($vline1,strpos($vline1," ")+1);
            $vdateorig1 = substr($vline1,0,strpos($vline1," "));
            $venv1 = substr($vline1,strpos($vline1," ")+1);
            $vline1 = substr($venv1,strpos($venv1,"PAM_SERVICE")+12);
            $vproto1 = substr($vline1,0,strpos($vline1," "));
            if ((($vyear1*365+$vmonth1*31+$vday1 >= $year1*365+$month1*31+$day1) && ($vyear1*365+$vmonth1*31+$vday1 <= $year2*365+$month2*31+$day2)) || (($vyear2*365+$vmonth2*31+$vday2 >= $year1*365+$month1*31+$day1) && ($vyear2*365+$vm$
#echo "strlen(vserverip3)=".strlen($vserverip3)."<BR>";
#echo "strlen(vuserip3)=".strlen($vuserip3)."<BR>";
#echo "strlen(vusername3)=".strlen($vusername3)."<BR>";
#echo "vuserip3=".$vuserip3."<BR>";
               if ((strlen($vserverip3) == 0) || ($vip1 == $vserverip3)) {
                  if ((strlen($vuserip3) == 0) || ($vip2 == $vuserip3)) {
                     if ((strlen($vusername3) == 0) || ($v<Username> == $vusername3)) {
                        if((strlen($vip3) == 0) || ($vip2 == $vip3)) {
                           $vflag1="";
                           if ($vdateorig1 == $vyear1."-".$vmonth1."-".$vday1) {
                              $vflag1='bgcolor="#FF0000"';
                           }
                           echo "<tr ".$vflag1."><td>".$vyear1."/".$vmonth1."/".$vday1."@".$vtime1."</td>";
                           echo "<td>".$vwwwroot1."</td>";
                           echo "<td>".$vip1."</td>";
#                           echo "<td><a href=http://www.infosniper.net/index.php?ip_address=".$vip2."&k=&lang=1 target=_blank />".$vip2."</td>";
                           echo "<td><a href=https://gsuite.tools/ip-location?host=".$vip2." target=_blank />".$vip2."</td>";
#                           echo "<td><a href=https://gsuite.tools/ip-location?host=".$vip2." target=`popup` onclick=`window.open('https://gsuite.tools/ip-location?host='.$vip2,'popup','width=600,height=600'); return false;`>".$vip2."</$
                           echo "<td>".$v<Username>."</td>";
                           echo "<td>".$vproto1."</td>";
                           echo "<td>(".$vip2.") first logged on ".$vdateorig1."</td>";
                           echo "<td>".$venv1."</td>";
                        }
                     }
                  }
               }
            }
         }
      }
      echo "</table>";
      fclose($f);
   }

?>

<BR><BR>
<table border='1'><tr><td colspan=2><center>Legend</center></td></tr>
   <tr><td>Color</td><td>Meaning</td><tr>
   <tr><td bgcolor="#FF0000">&nbsp;</td><td>Warning, the source IP never logged before</td></tr>
   <tr><td>&nbsp;</td><td>The source IP already logged before, as indicated in the "IP Fist Login on" column</td></tr>
</table>

<div align="right">
   <font size="1" color="Silver">
      Developed by Rick Yamamoto<BR>
      Last Revision: 11/29/2018<BR>
   </font>
</div>


