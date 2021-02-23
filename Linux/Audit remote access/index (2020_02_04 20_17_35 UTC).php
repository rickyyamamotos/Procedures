<html>
<body>
<?php
//* made by Rick Yamamoto on 04/03/2018 *//

$day1=date("d");
$month1=date("m");
$year1=date("Y");
$day2=$day1;
$month2=$month1;
$year2=$year1;

function timedifference1 ($dayv1, $timev1, $dayv2, $timev2) {
   $vtimediff1=0;
   if (intval($dayv1) < intval($dayv2)) {
      $vtimediff1 = 24*60*(intval($dayv2) - intval($dayv1));
      }
   $vtimediff1 = $vtimediff1 +  intval(substr($timev2,0,2)) * 60 + intval(substr($timev2,3,2)) - (intval(substr($timev1,0,2)) * 60 + intval(substr($timev1,3,2)));
   return $vtimediff1+1;
   }

if (isset($_POST['todo'])) {
   $todo=$_POST['todo'];
   if ($todo=="submit") {
      $month1=$_POST['month1'];
      $day1=$_POST['day1'];
      $year1=$_POST['year1'];
      $month2=$_POST['month2'];
      $day2=$_POST['day2'];
      $year2=$_POST['year2'];
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



<H1>
   Display of times when the backup of servers used the drobo
</H1>
<H3>
  Use this table to manage the times of the backups. Set the adequate times on the server's crontabs to avoid congestions on the Drobo (XXX.XXX.XXX.99)<BR><BR>
<H3>

Select the date range  and click on submit to refresh the table
<form method=post name=f1 action=''><input type=hidden name=todo value=submit>
<table border="0" cellspacing="0" >
<tr>
<td align=left >
   FROM:
</td>
<td  align=left >
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
   Date
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
   Year(yyyy)<input type=text name=year1 size=4 value=<?=$year1?>>
</td>
</tr>

<tr>
<td align=left >
   TO:
</td>
<td align=left >
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
   Date
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
<td align=left >
   Year(yyyy)<input type=text name=year2 size=4 value=<?=$year2?>>
   <input type=submit value=Submit>
</td>
</tr>
</table>
</form>


<?php
   if ($year1*365+$month1*31+$day1 > $year2*365+$month2*31+$day2) {
      echo ("Error: incorrect range of dates <BR>");
      }
   else {
      echo "Creating report for log From: $year1/$month1/$day1 To: $year2/$month2/$day2 <BR>";
      $vfilename1="/mnt/shares/drobo/backupserver.log";
      $f = fopen($vfilename1, 'r') or exit("Unable to open file!");
      echo "<table border='1'><tr><td>Time taken to<BR>transfer file<BR>to Drobo</td><td>Time when<BR> the trasnfer<BR> began</td><td>Time when<BR> the transfer<BR>finished</td><td>Service:</td><td>Server Name:</td><td>Status</td></tr>";
      while(!feof($f))
         {
         $vline1 =  fgets($f);
         if (strlen($vline1) > 1) {
            $vyear1 = substr($vline1,0,4);
            $vmonth1 = substr($vline1,5,2);
            $vday1 = substr($vline1,8,2);
            $vtime1 = substr($vline1,11,8);
            $vyear2 = substr($vline1,20,4);
            $vmonth2 = substr($vline1,25,2);
            $vday2 = substr($vline1,28,2);
            $vtime2 = substr($vline1,31,8);
            $vline1 = substr($vline1,44);
            $vservice1 = substr($vline1,0,strpos($vline1," "));
            $vline1 = substr($vline1,strpos($vline1," ")+1);
            $vserver1 = substr($vline1,0,strpos($vline1," "));
            if ((($vyear1*365+$vmonth1*31+$vday1 >= $year1*365+$month1*31+$day1) && ($vyear1*365+$vmonth1*31+$vday1 <= $year2*365+$month2*31+$day2)) || (($vyear2*365+$vmonth2*31+$vday2 >= $year1*365+$month1*31+$day1) && ($vyear2*365+$vmonth2*31+$vday2 <= $year2*365+$month2*31+$day2))) {
               $vflag1="";
               if (strpos($vline1,"Error") > 0) {
                  $vflag1='bgcolor="#FF0000"';
                  }
               echo "<tr ".$vflag1."><td>".timedifference1 ($vday1, $vtime1, $vday2, $vtime2)." minutes</td><td>".$vyear1."/".$vmonth1."/".$vday1."@".$vtime1."</td>";
               echo "<td>".$vyear2."/".$vmonth2."/".$vday2."@".$vtime2."</td>";
               echo "<td>".$vservice1."</td>";
               echo "<td>".$vserver1."</td>";
               if (strpos($vline1,"Error") > 0) {
                  echo "<td>Error on Backup</td></tr>";
                  }
               else {
                  echo "<td>OK</td></tr>";
                  }
               }
            }
         }
      fclose($f);
      }

?>


