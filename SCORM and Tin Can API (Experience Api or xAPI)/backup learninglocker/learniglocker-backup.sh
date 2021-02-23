#!/bin/bash
#SCRIPT NAME: /learniglocker-backup.sh
#PURPOSE: backup learning locker data to the drobo in the <Location> Office
#CREATED ON: 01/04/2021
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 01/04/2021
#INTRUCTIONS: copy this script onto the root of any learninglocker server. Then create a crontab job to autoexecute it everyday
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\ see subdirectories
#REQUIREMENTS: DATABASE ENGINE MUST BE MONGODB
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 03 *   *   *    /bin/bash /learniglocker-backup.sh
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
# check the mongodb version with: $ mongodb --version
#    <Site> is mongodb version 4.0.6
# To restore, upload the BSON's gzip backup file into the target server, then execute as root: $ mongorestore --verbose --host localhost --port 27017 --objcheck --gzip --archive <Site>-2021-01-04


#SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK 
#   vdmongodb defines which days to make a backup of the learninglocker's mongodb database
#   vddataroot defines which days to make a backup of the learninglocker's data directory
# values 1,2,3,4,5,6,7 for monday through Sunday respectively
#        8 for everyday
#        0 for never
vdmongodb=8
vddataroot=3


#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin


#Declaring Variables
vdbhost1="localhost"
vdataroot1=$(readlink /usr/local/learninglocker/current)


#EXTRACTING DATA FROM HOST

vipaddress1=$(hostname -I | awk '{ print $1 }')
vdate1=$(date '+%Y-%m-%d')
vdow1=$(date +%u)
vwwwroot1="$HOSTNAME"
echo "vdataroot1 vwwwroot1 vdbhost1: $vdataroot1 $vwwwroot1 $vdbhost1"
echo "vipaddress1 vdate1 vdow1: $vipaddress1 $vdate1 $vdow1"


#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
sshpass -p '<Password>' ssh -oStrictHostKeyChecking=no -p <PortNumber> <Username>@XXX.XXX.XXX.243 /bin/mkdir -p /mnt/shares/drobo/$vwwwroot1


#CREATING, COMPACTING AND TRANFERING  A DATABASE DUMP
#THIS SCRIPT ONLY WORKS FOR MONGODB. OTHER DATABASES ENGINES NOT SUPPORTED
if [ $vdmongodb -eq $vdow1 -o $vdmongodb -eq 8 ] ; then
   echo "Started the creation the database dump..."
   vfilename1="$vwwwroot1-$vdate1-MongoDB.gzip"
   mongodump --host=localhost --port=27017 --gzip --archive=/tmp/$vfilename1
      # --oplog cant be used because the server does not have oplog start
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      rm /tmp/$vfilename1 -rf
      echo 'mongodump failed with exit code $vexitcode1'
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when making a dump backup of all MongoDB databases on $vwwwroot1($vipaddress1) -> mongodump failed with exit code $verrorcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vipaddress1):/learniglocker-backup.sh mongodbdump Error:$vexiterror1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT MongoDB $vwwwroot1 Error:mongodump failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
   else
      # dump is already gziped
      chmod 777 /tmp/$vfilename1
      echo "Stated transmitting the file to the <Location>'s Office Drobo"
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
      sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
      vexitcode1=$?
      rm -f /tmp/$vfilename1
      if [ $vexitcode1 -ne 0 ] ; then
         echo "sshpass failed with exit code $vexitcode1"
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting MongoDB database backup from $vwwwroot1($vipaddress1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vipaddress1):/learniglocker-backup.sh sshpass Error: $verrorcode1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT MongoDB $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log" 
      else
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up $vdbname1 MongoDB database from $vwwwroot1 to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$wwwroot1($vipaddress1):Successful backup of All MongoDB databases was made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT MongoDB $vwwwroot1 Success: backed up MongoDB Database >> /mnt/shares/drobo/backupserver.log"
      fi
   fi
fi


#COMPATING AND TRANSMITTING THR DATAROOT DIRECTORY
#SET VALUE OF vddataroot ON THE TOP OF THIS SCRIPT
if [ $vddataroot -eq $vdow1 -o $vddataroot -eq 8 ] ; then
   echo "Started compressing the dataroot directory"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   vfilename1="$vwwwroot1-$vdate1-dataroot.tar.gz"
#   tar cpPzf /tmp/$vfilename1 --after-date='7 days ago' $vdataroot1
   tar cpPzf /tmp/$vfilename1 $vdataroot1
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when compressing the dataroot directory ($vdataroot1) on $vwwwroot1($vipaddress1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vipaddress1):/learniglocker-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
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
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting the dataroot directory($vdataroot1) from $vwwwroot1($vipaddress1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vipaddress1):/learniglocker-backup.sh sshpass Error: $verrorcdoe1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Dataroot $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up $vwwwroot1($vipaddress1) dataroot directory  to:\n   <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n Date: $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vipaddress1):Successful backup of $vdataroot1 dataroot directory made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Dataroot $vwwwroot1 Success: backed up dataroot >> /mnt/shares/drobo/backupserver.log"
      fi
   fi
fi






