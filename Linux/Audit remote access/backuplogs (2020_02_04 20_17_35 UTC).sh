#!/bin/bash
#SCRIPT NAME: /backuplogs.sh
#PURPOSE: backup logs from /mnt/shares/drobo/*.log to /mnt/shares/drobo/backupserver/date*.log
#CREATED ON: 11/21/2018
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 11/21/2018
#INTRUCTIONS: copy this script onto the root of the backupserver server. Then create a crontab job to autoexecute it everyday
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\ see subdirectories
#REQUIREMENTS: DATABASE ENGINE MUST BE MYSQL
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 01 *   *   *    /bin/bash /backup-logs.sh
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


#Declaring Variables
vwwwroot1="backupserver"


#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin

#EXTRACTING DATA FROM HOST
vip1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vdate1=$(date "+%Y-%m-%d")
vtime1=$(TZ=US/Eastern date '+%H:%M:%S')

#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
/bin/mkdir -p /mnt/shares/drobo/$vwwwroot1


#COMPATING AND COPYING LOG FILES
echo "Started compressing the log files"
vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
vfilename1=$vdate1-logs-backup.tar.gz
tar cpPzf /mnt/shares/drobo/$vwwwroot1/$vfilename1 /mnt/shares/drobo/*.log
vexitcode1=$?
if [ $vexitcode1 -ne 0 ] ; then
   echo "tar failed with exit code $vexitcode1"
   rm -f /tmp/$vfilename1
   sendEmail -vv -o tls=yes -m "Error on $vdate1 when compressing /mnt/shares/drobo/*.log on $vwwwroot1($vip1):/mnt/shares/drobo/$vwwwroot1/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/backup-logs.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
   /bin/echo $vdate1 $vtime1 $(date "+%Y-%m-%d") $(TZ=US/Eastern date '+%H:%M:%S') EDT BackuLogs $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log
else
   echo "Backup finished without errors"
   sendEmail -vv -o tls=yes -m "Successfully backed up $vwwwroot1($vip1) /mnt/shares/drobo/*.log to:\n   <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n Date: $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of $vwwwroot1 /mnt/shares/drobo/*.log made on $vdate1" >> /var/log/sendEmail.log
   /bin/echo $vdate1 $vtime1 $(date "+%Y-%m-%d") $(TZ=US/Eastern date '+%H:%M:%S') EDT BackupLogs $vwwwroot1 Success: Backed up backuplogs >> /mnt/shares/drobo/backupserver.log
fi
