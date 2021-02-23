#!/bin/bash
#SCRIPT NAME: /moodle-backup.sh
#PURPOSE: backup moodle data to the drobo in the <Location> Office
#CREATED ON: 03/28/2018
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 03/28/2018
#INTRUCTIONS: copy this script onto the root of any moodle server. Then create a crontab job to autoexecute it everyday
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\ see subdirectories
#REQUIREMENTS: #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 03 *   *   *    /bin/bash /moodle-backup.sh
#              #  Mn Hr DoM Mon DoW
#              yum install sshpass or apt-get install sshpass or (see https://www.tecmint.com/sshpass-non-interactive-ssh-login-shell-script-ssh-password/)
#              get the fullpath for sshpass ($ which sshpass) and replace it in the script.
#              wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz
#              yum install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apr-get install libnet-ssleay-perl libio-socket-ssl-perl
#              tar -xvzf sendEmail-v1.56.tar.gz
#              sudo mv sendEmail-v1.56/sendEmail /usr/local/bin
#              sudo nano /etc/profile.d/addpath.sh
#                 export PATH=$PATH:/usr/local/bin:/usr/local/sbin
#              nano /usr/local/bin/sendEmail
#                 replace: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'SSLv3 TLSv1')) {     with: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'TLSv1')) {
#              #connect via ssh to XXX.XXX.XXX.243:<Port> at least one to install the ssh key.

#SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK 
#   vdmysql defines which days to make a backup of the moodle's mysql database
#   vddataroot  defines which days to make a backup of the moodle's dataroot directory
#   vdhtmlroot defines which days to make a backup of the moodle's html directory
# values 1,2,3,4,5,6,7 for monday through Sunday respectively
#        8 for everyday
#        0 for never
vdmysql1=8
vddataroot=0
vdhtmlroot=0


#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin

#EXTRACTING DATA FROM MOODLE CONFIGURATION
vfilename1="/var/www/html/config.php"
while read -r line
do
   vline1="$line"
   if [ `expr index "$vline1" $CFG-\>` -eq 5 ] ;  then
      if [ `expr match "$vline1" ".*dbtype"` \> 0 ] ; then
         vline1=${vline1:`expr index "$vline1" "'"`}
         vline1=${vline1::`expr index "$vline1" "'"` - 1}
         vdbtype1=$vline1
      fi
      if [ `expr match "$vline1" ".*dbhost"` \> 0 ] ; then
         vline1=${vline1:`expr index "$vline1" "'"`}
         vline1=${vline1::`expr index "$vline1" "'"` - 1}
         vdbhost1=$vline1
      fi
      if [ `expr match "$vline1" ".*dbname"` \> 0 ] ; then
         vline1=${vline1:`expr index "$vline1" "'"`}
         vline1=${vline1::`expr index "$vline1" "'"` - 1}
         vdbname1=$vline1
      fi
      if [ `expr match "$vline1" ".*dbuser"` \> 0 ] ; then
         vline1=${vline1:`expr index "$vline1" "'"`}
         vline1=${vline1::`expr index "$vline1" "'"` - 1}
         <Username>=$vline1
      fi
      if [ `expr match "$vline1" ".*dbpass"` \> 0 ] ; then
         vline1=${vline1:`expr index "$vline1" "'"`}
         vline1=${vline1::`expr index "$vline1" "'"` - 1}
         vdbpass1=$vline1
      fi
      if [ `expr match "$vline1" ".*dataroot"` \> 0 ] ; then
         vline1=${vline1:`expr index "$vline1" "'"`}
         vline1=${vline1::`expr index "$vline1" "'"` - 1}
         vdataroot1=$vline1
      fi
      if [ `expr match "$vline1" ".*wwwroot"` \> 0 ] ; then
         vline1=${vline1:`expr index "$vline1" "'"`}
         vline1=${vline1::`expr index "$vline1" "'"` - 1}
         vline1="$(echo $vline1 | awk -F/ '{ print $3}')"
         vwwwroot1=$vline1
      fi
   fi
done < "$vfilename1"
# echo "$vdbtype1 $vdbhost1 $vdbname1 $<Username> $vdbpass1 $vwwwroot1 $vdataroot1"


#EXTRACTING DATA FROM HOST
#vip1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vaddress1=$(hostname -I | awk '{ print $1 }')
vdate1=$(date '+%Y-%m-%d')
vdow1=$(date +%u)


#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
sshpass -p '<Password>' ssh -oStrictHostKeyChecking=no -p <PortNumber> <Username>@XXX.XXX.XXX.243 /bin/mkdir -p /mnt/shares/drobo/$vwwwroot1


#CREATING, COMPACTING AND TRANFERING  A DATABASE DUMP
if [ $vdmysql1 -eq $vdow1 -o $vdmysql1 -eq 8 ] ; then
   echo "Started the creation the database dump..."
   if [ `expr match "$vdbtype1" "mysqli"` \> 0 ] ; then
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
      mysqldump --max_allowed_packet=1024M --single-transaction=TRUE --quick -h $vdbhost1 -u $<Username> -p$vdbpass1 -C -Q -e --create-options $vdbname1 > /tmp/$vdbname1-backup.sql
		# For MyIsam -> always lock your tables. It is recommended to migrate tables to InnoDB to avoid locking of tables while running mysqldump
		# For InnoDB -> use --single-transaction
      vexitcode1=$?
      if [ $vexitcode1 -ne 0 ] ; then
         rm -f /tmp/$vdbname1-backup.sql
         echo 'mysqldump failed with exit code $vexitcode1'
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when making a dump backup of database: $vdbname1 on $vwwwroot1($vip1) -> mysqldump failed with exit code $verrorcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/moodle-backup.sh mysqldump Error:$vexiterror1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Mysql $vwwwroot1 Error:mysqldump failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
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
            sendEmail -vv -o tls=yes -o -m "Error on $vdate1 when compressing database $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/moodle-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
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
              sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting database backup from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/moodle-backup.sh sshpass Error: $verrorcode1" >> /var/log/sendEmail.log
              sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Mysql $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
           else
              echo "Backup finished without errors"
              sendEmail -vv -o tls=yes -m "Successfully backed up $vdbname1 database from $vwwwroot1 to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of $vdbname1 database was made on $vdate1" >> /var/log/sendEmail.log
              sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Mysql $vwwwroot1 Success: backed up Mysql Database >> /mnt/shares/drobo/backupserver.log"
           fi
        fi
      fi
   else
         echo "Error: moodle databases is not MySQL"
   fi
fi


#COMPATING AND TRANSMITTING THR DATAROOT DIRECTORY
#SET VALUE OF vddataroot ON THE TOP OF THIS SCRIPT
#DEVELOPERS LIKE TO STORE BACKUPS FILES IN THE /DATAROOT DIRECTORY, MOVE ALL BACKUPS FILES INSIDE /DATAROOT TO /DATAROOT/BACKUPS
if [ $vddataroot -eq $vdow1 -o $vddataroot -eq 8 ] ; then
   echo "Started compressing the dataroot directory"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   vfilename1=$vdate1-dataroot-backup.tar.gz
   tar cpPzf /tmp/$vfilename1 --exclude="$vdataroot1/backups" --exclude="$vdataroot1/temp" --exclude="$vdataroot1/trashdir" --after-date='7 days ago' $vdataroot1
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when compressing the dataroot directory ($vdataroot1) on $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/moodle-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
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
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting the dataroot directory($vdataroot1) from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/moodle-backup.sh sshpass Error: $verrorcdoe1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Dataroot $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up $vwwwroot1($vip1) dataroot directory  to:\n   <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n Date: $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of $vdataroot1 dataroot directory made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Dataroot $vwwwroot1 Success: backed up dataroot >> /mnt/shares/drobo/backupserver.log"
      fi
   fi
fi


#COMPATING AND TRANSMITTING THR HTMLROOT DIRECTORY
#SET VALUE OF vdhtmlroot ON THE TOP OF THIS SCRIPT
#IT IS TOO DIFFICULT TO GET THE DOCUMENTROOT FROM THE SERVER
#IT IS ALSO RISKY BECAUSE MULTIPLE DOCUMENTROOT MAY EXIST
#THEREFORE, IT IS ASSUMED THAT /var/www/html IS THE DOCUMENTROOT (vhtmlroot1)
if [ $vdhtmlroot -eq $vdow1 -o $vdhtmlroot -eq 8 ] ; then
   echo "Started compressing the html root directory"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   vfilename1=$vdate1-htmlroot-backup.tar.gz
   tar cpPzf /tmp/$vfilename1 /var/www/html
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when compressing /var/www/html on $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/moodle-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Hmtlroot $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
   else
      chmod 777 /tmp/$vfilename1
      echo "Stated transmitting the files to the <Location>s Office Drobo"
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
      sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
      vexitcode1=$?
      rm -f /tmp/$vfilename1
      if [ $vexitcode1 -ne 0 ] ; then
         echo "sshpass failed with exit code $vexitcode1"
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting the /var/www/html directory backup from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/moodle-backup.sh sshpass Error: $vexitcode1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Hmtlroot $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up $vwwwroot1($vip1$) /var/www/html directory  to:\n   <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n Date: $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of $vwwwroot1 /var/www/html directory made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Hmtlroot $vwwwroot1 Success: Backed up htmlroot >> /mnt/shares/drobo/backupserver.log"
      fi
   fi
fi


