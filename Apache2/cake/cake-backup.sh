#!/bin/bash
#SCRIPT NAME: /cake-backup.sh
#PURPOSE: backup cake data to the drobo in the <Location> Office
#CREATED ON: 10/05/2018
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 10/05/2018
#INTRUCTIONS: copy this script onto the root of any wordpress server. Then create a crontab job to autoexecute it everyday
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\ see subdirectories
#REQUIREMENTS:
#Since cake is used only in few servers, i will not create an automatic backup script
#if you copy this script to another server, YOU WILL NEED TO MANUALLY CHANGE THE VALUES of this script
#1) see /etc/apache2/sites-enabled/default-ssl to find the wwwroot directory
#2) Look into the wwwroot directory/app/Config/database.php to determine the database and credentials
#        public $default = array(
#                'datasource' => 'Database/Mysql',
#                'persistent' => false,
#                'host' => 'localhost',
#                'login' => '<Username>',
#                'password' => '<Password>',
#                'database' => '<DBName>',
#                'prefix' => '',
#                //'encoding' => 'utf8',
#        );
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 03 *   *   *    /bin/bash /wordpress-backup.sh
#              #  Mn Hr DoM Mon DoW
#              wget wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz
#              yum install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)'
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
PATH=$PATH:/usr/local/bin:/usr/bin:/usr/local/bin/sshpass


#Declaring Variables
vdbhost1=""
vdbname1=""
<Username>=""
vdbpass1=""
vtabpre1=""
vtabopt1=""
vwwwroot1=""
vvhdire1=""


#EXTRACTING DATA FROM HOST
#vip1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vip1=$(hostname -I | awk '{ print $1 }')
vdate1=$(date '+%Y-%m-%d')
vdow1=$(date +%u)
echo $vip1 $vdate1 $vdow1


#MANUALLY SETTING VALUES TO VARIABLES.
vdbtype1="Database/Mysql"
vwwwroot1="<Site>"
vvhdire1="/var/www/vhosts/<Directory>"
vdbhost1="localhost"
vdbname1="<Username>"
<Username>="DBName"
vdbpass1="<Password>"
vtabpre1=""
vtabopt1=""

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
   tar cpPzf /tmp/$vfilename1 $vvhdire1
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when compressing $vvhdire1 on $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/wordpress-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
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
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting the $vvhdire1 directory backup from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/wordpress-backup.sh sshpass Error: $vexitcode1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Htmlroot $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up $vwwwroot1($vip1) $vvhdire1 directory  to:\n   <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n Date: $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of $vwwwroot1 $vvhdire1 directory made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Htmlroot $vwwwroot1 Success: Backed up htmlroot >> /mnt/shares/drobo/backupserver.log"
      fi
   fi
fi

