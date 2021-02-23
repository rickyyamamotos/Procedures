#!/bin/bash
#SCRIPT NAME: /wordpress-backup.sh
#PURPOSE: backup wordpress data to the drobo in the <Location> Office
#CREATED ON: 03/30/2018
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 03/30/2018
#INTRUCTIONS: copy this script onto the root of any wordpress server. Then create a crontab job to autoexecute it everyday
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\ see subdirectories
#REQUIREMENTS: DATABASE ENGINE MUST BE MYSQL
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 03 *   *   *    /bin/bash /wordpress-backup.sh
#              #  Mn Hr DoM Mon DoW
#              yum install sshpass or apt-get install sshpass or (see https://www.tecmint.com/sshpass-non-interactive-ssh-login-shell-script-ssh-password/)
#              get the fullpath for sshpass ($ which sshpass) and replace it in the script.
#              wget wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz
#              yum install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install libnet-ssleay-perl libio-socket-ssl-perl
#              tar -xvzf sendEmail-v1.56.tar.gz
#              sudo mv sendEmail-v1.56/sendEmail /usr/local/bin
#              sudo nano /etc/profile.d/addpath.sh
#                 export PATH=$PATH:/usr/local/bin:/usr/local/sbin
#              nano /usr/local/bin/sendEmail
#                 replace: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'SSLv3 TLSv1')) {     with: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'TLSv1')) {
#              #connect via ssh to XXX.XXX.XXX.243:<Port> at least one to install the ssh key.

#SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK 
#   vdmysql defines which days to make a backup of the wordpress's mysql database
#   vdhtmlroot defines which days to make a backup of the wordpress's html directory
# values 1,2,3,4,5,6,7 for monday through Sunday respectively
#        8 for everyday
#        0 for never
vdmysql1=8
vdhtmlroot=3


#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin


#Declaring Variables
vdbhost1=""
vdbname1=""
<Username>=""
<Username>=""
vdbpass1=""
vtabpre1=""
vtabopt1=""


#EXTRACTING DATA FROM HOST
#vip1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vip1=$(hostname -I | awk '{ print $1 }')
vdate1=$(date '+%Y-%m-%d')
vdow1=$(date +%u)
#echo $vip1 $vdate1 $vdow1


#FIND THE LOCATION OF wpconfig.php
#IT COULD BE /var/www/wp-config.php or /var/www/html/wp-config.php
if [ -f /var/www/wp-config.php ] ; then
   vfilename1="/var/www/wp-config.php"
else
   if [ -f /var/www/html/wp-config.php ] ; then
      vfilename1="/var/www/html/wp-config.php"
   else
      echo "Error: can not find the wordpress configuration file: wp-config.php"
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when backing up wordpress data from $vip1 -> wp-config.php was not found" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "($vip1):/wordpress-backup.sh Error: wp-config.php  was ntot found1" >> /var/log/sendEmail.log
      exit 1
   fi
fi
#echo "File location: $vfilename1"


#EXTRACTING DATA FROM WORDPRESS CONFIGURATION
while read -r line
do
   vline1="$line"
   if [ `expr match "$vline1" "define("` == "7" ] ;  then
      if [ `expr match "$vline1" ".*DB_HOST"` \> 0 ] ; then
         vline1=${vline1:`expr index "$vline1" ","`}
         vline1=${vline1:`expr index "$vline1" "'"`}
         vline1=${vline1::`expr index "$vline1" "'"` - 1}
         vdbhost1=$vline1
      fi
      if [ `expr match "$vline1" ".*DB_NAME"` \> 0 ] ; then
         vline1=${vline1:`expr index "$vline1" ","`}
         vline1=${vline1:`expr index "$vline1" "'"`}
         vline1=${vline1::`expr index "$vline1" "'"` - 1}
         vdbname1=$vline1
      fi
      if [ `expr match "$vline1" ".*DB_USER"` \> 0 ] ; then
         vline1=${vline1:`expr index "$vline1" ","`}
         vline1=${vline1:`expr index "$vline1" "'"`}
         vline1=${vline1::`expr index "$vline1" "'"` - 1}
         <Username>=$vline1
      fi
      if [ `expr match "$vline1" ".*DB_PASSWORD"` \> 0 ] ; then
         vline1=${vline1:`expr index "$vline1" ","`}
         vline1=${vline1:`expr index "$vline1" "'"`}
         vline1=${vline1::`expr index "$vline1" "'"` - 1}
         vdbpass1=$vline1
      fi
    else
       if [ `expr match "$vline1" ".*table_prefix"` = "13" ] ; then
         vline1=${vline1:`expr index "$vline1" ","`}
         vline1=${vline1:`expr index "$vline1" "'"`}
         vline1=${vline1::`expr index "$vline1" "'"` - 1}
         vtabpre1=$vline1
      fi
   fi
done < "$vfilename1"
#GETTING URL FROM WORDPRESS DATABASE
vtabopt1=$vtabpre1"options"
vwwwroot1=$(sshpass -p $vdbpass1 mysql --silent --disable-column-names -u$<Username> -p --database="$vdbname1" --execute="select option_value from $vtabopt1 where option_name = 'siteurl';")
vwwwroot1="$(echo $vwwwroot1 | awk -F/ '{ print $3}')"
#echo "$vdbtype1 $vdbhost1 $vdbname1 $<Username> $vdbpass1 $vwwwroot1 $vtabpre1 $vtabopt1"


#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
sshpass -p '<Password>' ssh -oStrictHostKeyChecking=no -p <PortNumber> <Username>@XXX.XXX.XXX.243 /bin/mkdir -p /mnt/shares/drobo/$vwwwroot1


#CREATING, COMPACTING AND TRANFERING  A DATABASE DUMP
#THIS SCRIPT ONLY WORKS FOR MYSQL. OTHER DATABASES ENGINES NOT SUPPORTED
if [ $vdmysql1 -eq $vdow1 -o $vdmysql1 -eq 8 ] ; then
   echo "Started the creatiopn the database dump..."
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   mysqldump --max_allowed_packet=1024M --single-transaction=TRUE --quick -h $vdbhost1 -u $<Username> -p$vdbpass1 -C -Q -e --create-options $vdbname1 > /tmp/$vdbname1-backup.sql
		# For MyIsam -> always lock your tables. It is recommended to migrate tables to InnoDB to avoid locking of tables while running mysqldump
		# For InnoDB -> use --single-transaction
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      echo 'mysqldump failed with exit code $vexitcode1'
      rm -f /tmp/$vdbname1-backup.sql
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when making a dump backup of database: $vdbname1 on $vwwwroot1($vip1) -> mysqldump failed with exit code $verrorcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/wordpress-backup.sh mysqldump Error:$vexiterror1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Mysql $vwwwroot1 Error:mysqldump failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
   else
      echo "Started compressing the database dump"
      vfilename1=$vdate1-mysql-$vdbname1-backup.tar.gz
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S') 
      tar cpPzf /tmp/$vfilename1 /tmp/$vdbname1-backup.sql
      vexitcode1=$?
      rm -f /tmp/$vdbname1-backup.sql
      if [ $vexitcode1 -ne 0 ] ; then
         echo 'tar failed with exit code $vexitcode1'
         rm -f /tmp/$vfilename1
         sendEmail -vv -o tls=yes -o -m "Error on $vdate1 when compressing database $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/wordpress-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Mysql $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         echo "Stated transmitting the file to the <Location>'s Office Drobo"
         chmod 777 /tmp/$vfilename1
         vtime1=$(TZ=US/Eastern date '+%H:%M:%S') 
         sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
         vexitcode1=$?
         rm -f /tmp/$vfilename1
         if [ $vexitcode1 -ne 0 ] ; then
            echo "sshpass failed with exit code $vexitcode1"
            sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting database backup from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/wordpress-backup.sh sshpass Error: $verrorcode1" >> /var/log/sendEmail.log
            sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Mysql $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
         else
            echo "Backup finished without errors"
            sendEmail -vv -o tls=yes -m "Successfully backed up $vdbname1 database from $vwwwroot1 to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of $vdbname1 database was made on $vdate1" >> /var/log/sendEmail.log
            sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Mysql $vwwwroot1 Success: backed up Mysql Database >> /mnt/shares/drobo/backupserver.log"
         fi
      fi
   fi
fi


#COMPATING AND TRANSMITTING THR HTMLROOT DIRECTORY
#SET VALUE OF vdhtmlroot ON THE TOP OF THIS SCRIPT
if [ $vdhtmlroot -eq $vdow1 -o $vdhtmlroot -eq 8 ] ; then
   echo "Started compressing the html root directory"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   vfilename1=$vdate1-htmlroot-backup.tar.gz
#   tar -cpzf /tmp/$vfilename1 /var/www/html --exclude='/var/www/html/wp-content/updraft' --exclude='/var/www/html/wp-content/uploads'
   tar cpPzf /tmp/$vfilename1 --exclude='/var/www/html/wp-content/updraft' --exclude='/var/www/html/wp-content/debug.log' --exclude='/var/www/html/wp-content/uploads/wc-logs/*' --exclude='/var/www/html/wp-content/uploads/eb-logs/*' /var/www/html
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when compressing /var/www/html on $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/wordpress-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Htmlroot $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
   else
      echo "Stated transmitting the files to the <Location>s Office Drobo"
      chmod 777 /tmp/$vfilename1
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S') 
      sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
      vexitcode1=$?
      rm -f /tmp/$vfilename1
      if [ $vexitcode1 -ne 0 ] ; then
         echo "sshpass failed with exit code $vexitcode1"
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting the /var/www/html directory backup from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/wordpress-backup.sh sshpass Error: $vexitcode1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Htmlroot $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up $vwwwroot1($vip1) /var/www/html directory  to:\n   <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n Date: $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of $vwwwroot1 /var/www/html directory made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Htmlroot $vwwwroot1 Success: Backed up htmlroot >> /mnt/shares/drobo/backupserver.log"
      fi
   fi
fi
