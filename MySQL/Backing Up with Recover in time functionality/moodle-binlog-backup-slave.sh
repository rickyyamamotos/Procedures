#!/bin/bash
#SCRIPT NAME: /moodle-binlog-backup-slave.sh
#PURPOSE: backup binlogs older than 7 days to the drobo in the <Location> Office
#CREATED ON: 11/13/2018
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 11/13/2018
#<==================> ATTENTION: THIS SCRIPT WAS DESIGNED FOR <Site>.<Domain> ONLY === Remove it if clonned ==========================>
#<======== Due to the complexity of the <Domain> master/slave infrastructure. This script will not adapt if this server is cloned =========>
#INTRUCTIONS: copy this script onto the root of <Site>.<Domain>.  Then create a crontab job to autoexecute it everyday
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\<Domain>\YYYY-MM=DD-binlog-<Domain>-backup.tar.gz
#REQUIREMENTS: #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 09 *   *   1    /bin/bash /moodle-binlog-backup-slave.sh
#              #  Mn Hr DoM Mon DoW
#              yum install sshpass or apt-get install sshpass or (see https://www.tecmint.com/sshpass-non-interactive-ssh-login-shell-script-ssh-password/)
#              get the fullpath for sshpass ($ which sshpass) and replace it in the script.
#              wget wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz
#              yum install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)'
#              tar -xvzf sendEmail-v1.56.tar.gz
#              sudo mv sendEmail-v1.56/sendEmail /usr/local/bin
#              sudo nano /etc/profile.d/addpath.sh
#                 export PATH=$PATH:/usr/local/bin:/usr/local/sbin
#              nano /usr/local/bin/sendEmail
#                 replace: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'SSLv3 TLSv1')) {     with: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'TLSv1')) {
#              #connect via ssh to XXX.XXX.XXX.243:<Port> at least one to install the ssh key.

#THE FOLLOWING ARE SOME STATIC VARIABLES THAT NEEDS TO BE MANUALLY ENTERED
vwwwroot1="<Domain>"
<Username>="root"
vdbpass1="<Password>"


#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin


#EXTRACTING DATA FROM HOST
vip1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vdate1=$(date '+%Y-%m-%d')
vdow1=$(date +%u)


#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
sshpass -p '<Password>' ssh -oStrictHostKeyChecking=no -p <PortNumber> <Username>@XXX.XXX.XXX.243 /bin/mkdir -p /mnt/shares/drobo/$vwwwroot1


#COMPACTING AND TRANFERING BINFILE OLDER THAN 7 days
vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
vfilename1=$vdate1-binlog-$vwwwroot1-backup.tar.gz
echo "Started compressing the binlog files"
find /var/log/mysql/* -type f -mtime +3 > /tmp/binloglist.txt
#   compress binlog files older than 3 days
echo "/var/log/mysql/mysql-bin.index" >> /tmp/binloglist.txt
tar cvPzf /tmp/$vfilename1 -T /tmp/binloglist.txt
vexitcode1=$?
rm -f /tmp/binloglist.txt
if [ $vexitcode1 -ne 0 ] ; then
   rm -f /tmp/$vfilename1
   echo 'tar failed with exit code $vexitcode1'
   sendEmail -vv -o tls=yes -o -m "Error on $vdate1 when compressing binlog $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/moodle-binlog-backup-slave.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
   sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Binlog $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
else
   chmod 777 /tmp/$vfilename1
   echo "Stated transmitting the file to the <Location>'s Office Drobo"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
   vexitcode1=$?
   rm -f /tmp/$vfilename1
   if [ $vexitcode1 -ne 0 ] ; then
      echo "sshpass failed with exit code $vexitcode1"
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting binlog backup from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/moodle-binlog-backup-slave.sh sshpass Error: $verrorcode1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Binlog $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
   else
      sshpass -p $vdbpass1 mysql -u$<Username> -p -Ae"PURGE BINARY LOGS BEFORE DATE(NOW() - INTERVAL 7 DAY) + INTERVAL 0 SECOND;"
      vexitcode1=$?
      if [ $vexitcode1 -ne 0 ] ; then
         echo "sshpass failed with exit code $vexitcode1"
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when deleting old binlog files from $vwwwroot1($vip1):/var/log/mysql/ \n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/moodle-binlog-backup-slave.sh deleting old binlog files Error: $verrorcode1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Binlog $vwwwroot1 Error: failed to delete old binlog files, sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
#        delete binlog files older than 3 days
         find /var/log/mysql/* -type f -mtime +3 -exec rm {} \;
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up binlog older than from $vwwwroot1 to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vdbname1($vip1):Successful backup of binlog older than 7 days was made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Binlog $vwwwroot1 Success: backed up binlog files >> /mnt/shares/drobo/backupserver.log"
      fi
   