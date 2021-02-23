#!/bin/bash
#SCRIPT NAME: /mongodb-backup.sh
#PURPOSE: backup all mongodb databases data to the drobo in the <Location> Office
#CREATED ON: 03/06/2020
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 03/06/2020
#INTRUCTIONS: copy this script onto the root of any mongodb server. Then create a crontab job to autoexecute it everyday
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\ see subdirectories
#REQUIREMENTS: DATABASE ENGINE MUST BE MONGODB
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 03 *   *   *    /bin/bash /mongodb-backup.sh
#              #  Mn Hr DoM Mon DoW
#              yum install sshpass or apt-get install sshpass or (see https://www.tecmint.com/sshpass-non-interactive-ssh-login-shell-script-ssh-password/)
#              get the fullpath for sshpass ($ which sshpass) and replace it in the script.
#              wget wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz
#              yum install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apr-get install libnet-ssleay-perl libio-socket-ssl-perl
#              tar -xvzf sendEmail-v1.56.tar.gz
#              sudo mv sendEmail-v1.56/sendEmail /usr/local/bin
#              sudo nano /etc/profile.d/addpath.sh
#                 export PATH=$PATH:/usr/local/bin:/usr/local/sbin
#              nano /usr/local/bin/sendEmail
#                 replace: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'SSLv3 TLSv1')) {     with: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'TLSv1')) {
#              #connect via ssh to XXX.XXX.XXX.243:<PortNumber> at least one to install the ssh key.

#SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK
# vdmongodb defines which days to make a backup of the wordpress's MongoDB database
#        8 for everyday
#        0 for never
vdmongodb=8

#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin

#REQUIRED DATA
vhost="XXX.XXX.XXX.167"
vport=27017
vusername="rick"
vpassword="<Password>"
vdir="/tmp/dump"
#vdbname="<DBName>"

#EXTRACTING DATA FROM HOST
#vip1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $7}')
vip1=$(hostname -I | awk '{ print $1 }')
vdate1=$(date '+%Y-%m-%d')
vdow1=$(date +%u)
vwwwroot1="$HOSTNAME"
# echo "vhost, vport, vusername, vpassword, vdir, vip1, vdate1, vdow1, vwwwroot1: $vhost, $vport, $vusername, $vpassword, $vdir, $vip1, $vdate1, $vdow1, $vwwwroot1"

#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
sshpass -p '<Password>' ssh -oStrictHostKeyChecking=no -p <PortNumber> <Username>@XXX.XXX.XXX.243 /bin/mkdir -p /mnt/shares/drobo/$vwwwroot1

rm $vdir -rf
if [ $vdmongodb -eq $vdow1 -o $vdmongodb -eq 8 ] ; then
   echo "Started the creation the database dump..."
#  /usr/bin/mongodump --host="XXX.XXX.XXX.167" --port=27017 --username "rick" --password "<Password>" --authenticationDatabase "<Username>" --db <DBName> --out /tmp/dump
   /usr/bin/mongodump --host="$vhost" --port=$vport --username $vusername --password $vpassword --authenticationDatabase "<Username>" --out $vdir
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      rm $vdir -rf
      echo 'mongodump failed with exit code $vexitcode1'
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when making a dump backup of all MongoDB databases on $vwwwroot1($vip1) -> mongodump failed with exit code $verrorcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/mongodb-backup.sh mongodbdump Error:$vexiterror1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT MongoDB $vwwwroot1 Error:mongodump failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
   else
      vfilename1=$vdate1-mongodb-$vdbname1-backup.tar.gz
      echo "Started compressing the database dump"
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
      tar cpPzf /tmp/$vfilename1 $vdir
      vexitcode1=$?
      rm $vdir -rf
      if [ $vexitcode1 -ne 0 ] ; then
         rm -f /tmp/$vfilename1
         echo 'tar failed with exit code $vexitcode1'
         sendEmail -vv -o tls=yes -o -m "Error on $vdate1 when compressing MongoDB database $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/mongodb-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT MongoDB $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         chmod 777 /tmp/$vfilename1
         echo "Stated transmitting the file to the <Location>'s Office Drobo"
         vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
         sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
         vexitcode1=$?
         rm -f /tmp/$vfilename1
         if [ $vexitcode1 -ne 0 ] ; then
            echo "sshpass failed with exit code $vexitcode1"
            sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting MongoDB database backup from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/mongodb-backup.sh sshpass Error: $verrorcode1" >> /var/log/sendEmail.log
            sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT MongoDB $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log" 
         else
            echo "Backup finished without errors"
            sendEmail -vv -o tls=yes -m "Successfully backed up $vdbname1 MongoDB database from $vwwwroot1 to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$wwwroot1($vip1):Successful backup of All MongoDB databases was made on $vdate1" >> /var/log/sendEmail.log
            sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT MongoDB $vwwwroot1 Success: backed up MongoDB Database >> /mnt/shares/drobo/backupserver.log"
         fi
      fi
   fi
fi
