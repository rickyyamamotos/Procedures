#!/bin/bash
#SCRIPT NAME: /dreamfactory-backup.sh
#PURPOSE: backup dreamfactory version >= 2.0 data to the drobo in the <Location> Office
#CREATED ON: 10/08/2018
#CREATED BY: Rick Yamamoto
#REVISED ON: 05/11/2020
#             copy this script onto the root of any dreamfactory server. Then create a crontab job to autoexecute it everyday
#             just backup up the dreamfactory root directory should suffice.
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\ see subdirectories
#REQUIREMENTS: #Set the days variables to define which day of the week to run the backups as shown on "SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK"
#              sudo crontab -e
#                 01 02 *   *   *    /bin/bash /dreamfactory-backup.sh
#              #  Mn Hr DoM Mon DoW
#              yum install sshpass or apt-get install sshpass or (see https://www.tecmint.com/sshpass-non-interactive-ssh-login-shell-script-ssh-password/)
#              get the fullpath for sshpass ($ which sshpass) and replace it in the script.
#              wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz
#              yum install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)'
#              tar -xvzf sendEmail-v1.56.tar.gz
#              sudo mv sendEmail-v1.56/sendEmail /usr/local/bin
#              sudo nano /etc/profile.d/addpath.sh
#                 export PATH=$PATH:/usr/local/bin:/usr/local/sbin
#              nano /usr/local/bin/sendEmail
#                 replace: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'SSLv3 TLSv1')) {     with: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'TLSv1')) {
#              #connect via ssh to XXX.XXX.XXX.243:<Port> at least one to install the ssh key.
#THERE ARE OUR DREAMFACTORY SERVERS:
#	<Site>
#	<Site>
#	<Site>
#	<Site>.<Domain>
#	<Site>
#	<Site> (mahara, not dreamfactory)
#SET EXECUTION TIME AT 5AM, because MySQL files changes

#DATA REQUIREMENTS
#SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK
#   vfulldataroot: performas a full directory backup, except log files
#   vdiffdataroot: performas a directory backup of files changed in the last 24 hours
# values 1,2,3,4,5,6,7 for monday through Sunday respectively
#        8 for everyday
#        0 for never
vfulldataroot=7
vdiffdataroot=8

#DETERMINING THE DREAMFACTORY ROOT DIRECTORY
vdreamroot=$(echo $(find / -name "ctlscript.sh"))
vdreamroot=${vdreamroot%'ctlscript.sh'*}
vdreamroot=${vdreamroot::-1}
echo "Dreamfactory root directory: "$vdreamroot

#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin

#EXTRACTING DATA FROM HOST
vip1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vdate1=$(date '+%Y-%m-%d')
vdow1=$(date +%u)
vwwwroot1="$HOSTNAME"
echo "$vip1 $vdate1 $vdow1 $vwwwroot1"


#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
sshpass -p '<Password>' ssh -oStrictHostKeyChecking=no -p <PortNumber> <Username>@XXX.XXX.XXX.243 /bin/mkdir -p /mnt/shares/drobo/$vwwwroot1

#COMPATING AND TRANSMITTING THR WEEKLY DATAROOT DIRECTORY
#SET VALUE OF vfulldataroot ON THE TOP OF THIS SCRIPT
if [ $vfulldataroot -eq $vdow1 -o $vfulldataroot -eq 8 ] ; then
   echo "Started compressing the dataroot directory"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   vfilename1=$vdate1-dreamfactory-full-dataroot-backup.tar.gz
   tar --exclude="$vdreamroot/mysql/tmp" --exclude="$vdreamroot/apache2/logs" --exclude="$vdreamroot/apps/dreamfactory/htdocs/log" --exclude="mongodb/tmp/mongodb-27017.sock" --exclude="mongodb/data/db/diagnostic.data" -cpzf /tmp/$vfilename1 $vdreamroot
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when compressing the full dataroot directory ($vdreamroot) on $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/dreamfactory-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Full-Dataroot $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
   else
      chmod 777 /tmp/$vfilename1
      echo "Stated transmitting the files to the <Location>s Office Drobo"
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
      sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
      vexitcode1=$?
      rm -f /tmp/$vfilename1
      if [ $vexitcode1 -ne 0 ] ; then
         echo "sshpass failed with exit code $vexitcode1"
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting the full dataroot directory($vdreamroot) from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/dreamfactory-backup.sh sshpass Error: $verrorcdoe1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Full-Dataroot $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up $vwwwroot1($vip1) full dataroot directory  to:\n   <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n Date: $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of $vdreamroot dataroot directory made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Full-Dataroot $vwwwroot1 Success: backed up dataroot >> /mnt/shares/drobo/backupserver.log"
# If a full backup was done, a diff backup s not needed, exiting
         exit
      fi
   fi
fi


#COMPATING AND TRANSMITTING THR DAILY DATAROOT DIRECTORY
#SET VALUE OF vdiffdataroot ON THE TOP OF THIS SCRIPT
if [ $vdiffdataroot -eq $vdow1 -o $vdiffdataroot -eq 8 ] ; then
   echo "Started compressing the dataroot directory"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   vfilename1=$vdate1-dreamfactory-diff-dataroot-backup.tar.gz
   find $vdreamroot/* -mtime -1 -print | grep -v ".log" | grep -v "mysql/tmp" | grep -v ".sock" | grep -v "diagnostic.data" | xargs tar cpvf /tmp/$vfilename1
#   tar --exclude="$vdreamroot/mysql/tmp" --exclude="$vdreamroot/apache2/logs/" --exclude="mongodb/tmp/mongodb-27017.sock" --exclude="mongodb/data/db/diagnostic.data" -cpzf /tmp/$vfilename1 $vdreamroot
   vexitcode1=$?
   if [ $vexitcode1 -eq 123 ] ; then
      echo "Not new files to backup that were created on the last 24 hours, exiting normally without errors"
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=yes -m "Successfully backed up $vwwwroot1($vip1) diff dataroot directory  to:\n   <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n Not new files to backup\n Date: $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of$vdreamroot dataroot directory made on $vdate1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Diff-Dataroot $vwwwroot1 Success: Not new files to backup on  dataroot >> /mnt/shares/drobo/backupserver.log"
      exit
   fi
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when compressing the diff dataroot directory ($vdreamroot) on $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/dreamfactory-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Diff-Dataroot $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
   else
      chmod 777 /tmp/$vfilename1
      echo "Stated transmitting the files to the <Location>s Office Drobo"
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
      sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
      vexitcode1=$?
      rm -f /tmp/$vfilename1
      if [ $vexitcode1 -ne 0 ] ; then
         echo "sshpass failed with exit code $vexitcode1"
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting the diff dataroot directory($vdreamroot) from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/dreamfactory-backup.sh sshpass Error: $verrorcdoe1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Diff-Dataroot $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up $vwwwroot1($vip1) diff dataroot directory  to:\n   <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n Date: $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of$vdreamroot dataroot directory made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Diff-Dataroot $vwwwroot1 Success: backed up dataroot >> /mnt/shares/drobo/backupserver.log"
      fi
   fi
fi
