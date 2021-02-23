#!/bin/bash
#SCRIPT NAME: /passenger-backup.sh
#PURPOSE: backup passenger-rails app data to the drobo in the <Location> Office. MySQL ONLY
#CREATED ON: 07/10/2019
#CREATED BY: Rick Yamamoto
#INTRUCTIONS: copy this script onto the root of any rails server. Then create a crontab job to autoexecute it everyday
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\ see subdirectories
#REQUIREMENTS: #Set the days variables to define which day of the week to run the backups as shown on "SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK"
#              #Ensure that $HOSTNAME equals the url's domain. i.e. <Site>
#              sudo crontab -e
#                 01 02 *   *   *    /bin/bash /passenger-backup.sh
#              #  Mn Hr DoM Mon DoW
#              yum install sshpass or apt-get install sshpass or (see https://www.tecmint.com/sshpass-non-interactive-ssh-login-shell-script-ssh-password/)
#              get the fullpath for sshpass ($ which sshpass) and replace it in the script.
#              wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz
#              yum install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install libnet-ssleay-perl libio-socket-ssl-perl
#              tar -xvzf sendEmail-v1.56.tar.gz
#              sudo mv sendEmail-v1.56/sendEmail /usr/local/bin
#              sudo nano /etc/profile.d/addpath.sh
#                 export PATH=$PATH:/usr/local/bin:/usr/local/sbin
#              nano /usr/local/bin/sendEmail
#                 replace: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'SSLv3 TLSv1')) {     with: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'TLSv1')) {
#              #connect via ssh to XXX.XXX.XXX.243:<Port> at least one to install the ssh key.


#DATA REQUIREMENTS
#SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK
#   vdmysql defines which days to make a backup of the rail's MySQL database
#   vddataroot  defines which days to make a backup of the rails' dataroot directory
# values 1,2,3,4,5,6,7 for monday through Sunday respectively
#        8 for everyday
#        0 for never
vdmysql1=0
vddataroot=8


#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin:/usr/sbin


#GETTING THE APP'S ROOT DIRECTORY
vrailsroot=$(passenger-status | grep "App root:")
vrailsroot=${vrailsroot:12}


#GETTING THE APP'S ENVIRONMENT
railsenv1=$(passenger-status | grep "):")
railsenv1=${railsenv1:`expr index "$railsenv1" "\("`}
railsenv1=${railsenv1:0:`expr index "$railsenv1" "\)" - 1`}


#EXTRACTING DATA FROM HOST
#vip1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vip1=$(hostname -I | awk '{ print $1 }')
vdate1=$(date '+%Y-%m-%d')
vdow1=$(date +%u)
vwwwroot1="$HOSTNAME"


#EXTRACTING DATA FROM RAILS CONFIGURATION
if [ $railsenv1="development" ] ; then
   railsenv2="production:"
   railsenv3="test:"
else
   if [ $railsenv1="production" ] ; then
      railsenv2="development:"
      railsenv3="test:"
   else
      if [ $railsenv1="test" ] ; then
         railsenv2="production:"
         railsenv3="development:"
      else
         echo "Error"
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when determining the rails environment, it is neither production, development or test. Check file: $vfilename1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/passenger-backup.sh cant determine rails environment" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Error determining the rails environment, it is neither production, development or test. Check file: $vfilename1 >> /mnt/shares/drobo/backupserver.log"
         exit
      fi
   fi
fi


vfilename1="$vrailsroot/config/database.yml"
vdbtype1=""
vdbhost1="127.0.0.1"
vdbname1=""
<Username>=""
vdbpass1=""
vflag=0
while read -r line
do
   vline1="$line"
#   echo "$vline1"
   if [ `expr match "$vline1" "$railsenv1"` \> 0 ]  ; then
#      echo "1   vflag=1"
      vflag=1
   fi
   if [ `expr match "$vline1" "#"` -eq 0 ] && [ `expr match "$vline1" "adapter:"` \> 0 ] && [ $vflag = 1 ] && [ "${#vdbtype1}" -eq 0 ]; then
      vline1=${vline1:`expr index "$vline1" " "`}
      vdbtype1=$vline1
   fi
   if [ `expr match "$vline1" "#"` -eq 0 ] && [ `expr match "$vline1" "host:"` \> 0 ] && [ $vflag = 1 ] && [ "${#vdbhost1}" -eq 0 ]; then
      vline1=${vline1:`expr index "$vline1" " "`}
      vdbhost1=$vline1
   fi
   if [ `expr match "$vline1" "#"` -eq 0 ] && [ `expr match "$vline1" "database:"` \> 0 ] && [ $vflag = 1 ] && [ "${#vdbname1}" -eq 0 ]; then
      vline1=${vline1:`expr index "$vline1" " "`}
      vdbname1=$vline1
   fi
   if [ `expr match "$vline1" "#"` -eq 0 ] && [ `expr match "$vline1" "username:"` \> 0 ] && [ $vflag = 1 ] && [ "${#<Username>}" -eq 0 ]; then
      vline1=${vline1:`expr index "$vline1" " "`}
      <Username>=$vline1
   fi
   if [ `expr match "$vline1" "#"` -eq 0 ] && [ `expr match "$vline1" "password:"` \> 0 ] && [ $vflag = 1 ] && [ "${#vdpass1}" -eq 0 ]; then
      vline1=${vline1:`expr index "$vline1" " "`}
      vdbpass1=$vline1
   fi
   if [ `expr match "$vline1" "$railsenv2"` \> 0 ] || [ `expr match "$vline1" "$railsenv3"` \> 0 ] ; then
#      echo "2   vflag=0"
      vflag=0
   fi
#echo "3   vflag=$vflag"
done < "$vfilename1"



echo "vdbtype1 vdbhost1 $vdbname1 <Username> vdbpass1:  $vdbtype1 $vdbhost1 $vdbname1 $<Username> $vdbpass1"
echo "database config file: $vfilename1"
echo "vip1 vdate1 vdow1 vwwwroot1: $vip1 $vdate1 $vdow1 $vwwwroot1"
echo "vrailsroot=$vrailsroot"
echo "railsenv1=$railsenv1"
#echo "railsenv2=$railsenv2"
#echo "railsenv3=$railsenv3"


#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
sshpass -p '<Password>' ssh -oStrictHostKeyChecking=no -p <PortNumber> <Username>@XXX.XXX.XXX.243 /bin/mkdir -p /mnt/shares/drobo/$vwwwroot1


#CREATING, COMPACTING AND TRANFERING  A DATABASE DUMP FOR MYSQL ONLY
if [ $vdmysql1 -eq $vdow1 -o $vdmysql1 -eq 8 ] ; then
   echo "Started the creation the database dump..."
   if [ `expr match "$vdbtype1" "mysql"` \> 0 ] ; then
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
      mysqldump --single-transaction=TRUE --quick -h $vdbhost1 -u $<Username> -p$vdbpass1 -C -Q -e --create-options $vdbname1 > /tmp/$vdbname1-backup.sql
		# For MyIsam -> always lock your tables. It is recommended to migrate tables to InnoDB to avoid locking of tables while running mysqldump
		# For InnoDB -> use --single-transaction
      vexitcode1=$?
      if [ $vexitcode1 -ne 0 ] ; then
         rm -f /tmp/$vdbname1-backup.sql
         echo 'MySQL dump failed with exit code $vexitcode1'
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when making a dump backup of database: $vdbname1 on $vwwwroot1($vip1) -> Mysql Dump  failed with exit code $verrorcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/rails-backup.sh Mysql Dump Error:$vexiterror1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Mysql $vwwwroot1 Error:Mysql Ddump failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         vfilename1=$vdate1-mysql-$vdbname1-backup.tar.gz
         echo "Started compressing the database dump"
         vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
         tar cpPzf /tmp/$vfilename1 /tmp/$vdbname1-backup.sql
         vexitcode1=$?
         rm -f /tmp/$vdbname1-backup.sql
         if [ $vexitcode1 -ne 0 ] ; then
            rm -f /tmp/$vfilename1
            echo 'tar failed with exit code $vexitcode1'
            sendEmail -vv -o tls=yes -o -m "Error on $vdate1 when compressing database $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/rails-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
            sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Mysql $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
        else
           chmod 777 /tmp/$vfilename1
           echo "Stated transmitting the file to the <Location>'s Office Drobo"
           vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
           sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
           vexitcode1=$?
           rm -f /tmp/$vfilename1
           if [ $vexitcode1 -ne 0 ] ; then
              echo "sshpass failed with exit code $vexitcode1"
              sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting database backup from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/rails-backup.sh sshpass Error: $verrorcode1" >> /var/log/sendEmail.log
              sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT MySQL $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
           else
              echo "Backup finished without errors"
              sendEmail -vv -o tls=yes -m "Successfully backed up $vdbname1 database from $vwwwroot1 to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of $vdbname1 database was made on $vdate1" >> /var/log/sendEmail.log
              sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT MySQL $vwwwroot1 Success: backed up MySQL Database >> /mnt/shares/drobo/backupserver.log"
           fi
        fi
      fi
   else
         echo "Error: RAILS databases is not MySQL"
   fi
fi


#COMPATING AND TRANSMITTING THR DATAROOT DIRECTORY
#DEVELOPERS LIKE TO STORE BACKUPS FILES IN THE /DATAROOT DIRECTORY. THEREFORE, PLEASE  MOVE ALL BACKUPS FILES INSIDE /DATAROOT TO /DATAROOT/BACKUPS
if [ $vddataroot -eq $vdow1 -o $vddataroot -eq 8 ] ; then
   echo "Started compressing the dataroot directory"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   vfilename1=$vdate1-dataroot-backup.tar.gz
   tar cpPzf /tmp/$vfilename1 --exclude="$vrailsroot/backups" --exclude="$vrailsroot/tmp" --exclude="$vrailsroot/trashdir" --exclude="$vrailsroot/test" --exclude="$vrailsroot/log"  --exclude="$vrailsroot/*.lock"  $vrailsroot/*
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when compressing the dataroot directory ($vrailsroot) on $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/mahara-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Dataroot $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
   else
      chmod 777 /tmp/$vfilename1
      echo "Stated transmitting the files to the <Location>s Office Drobo"
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
      sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
      vexitcode1=$?
      rm -f /tmp/$vfilename1
      if [ $vexitcode1 -ne 0 ] ; then
         echo "sshpass failed with exit code $vexitcode1"
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting the dataroot directory($vrailsroot) from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/mahara-backup.sh sshpass Error: $verrorcdoe1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Dataroot $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up $vwwwroot1($vip1) dataroot directory  to:\n   <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n Date: $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of $vrailsroot dataroot directory made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Dataroot $vwwwroot1 Success: backed up dataroot >> /mnt/shares/drobo/backupserver.log"
      fi
   fi
fi




