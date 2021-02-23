#!/bin/bash
#SCRIPT NAME: /elasticsearch-backup.sh
#PURPOSE: backup elasticsearch data to the drobo in the <Location> Office
#CREATED ON: 01/16/2020
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 1
#INTRUCTIONS: copy this script onto the root of a elasticsearch server. Then create a crontab job to autoexecute it everyday. Then:
#	mkdir /elasticsearch-backup
#	$ chown -R elasticsearch:elasticsearch /elasticsearch-backup/
#	nano /opt/elasticsearch-7.5.0/config/elasticsearch.yml
#		path.repo: ["/elasticsearch-backup"]
# 	restart elasticsearch
#	using kibana, <Site> the repository name "elasticsearch-backup" and point it to /elasticsearch-backup
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\<Site>
#REQUIREMENTS:
#              add to /etc/hosts
#                 XXX.XXX.XXX.168 <Site>1.<Site>
#                    //* replace XXX.XXX.XXX.168 and <Site>1.<Site> with the ip address and the hostname of the elasticsearch server respectively
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 03 *   *   *    /bin/bash /elasticsearch-backup.sh
#              #  Mn Hr DoM Mon DoW
#              yum install sshpass or apt-get install sshpass or (see https://www.tecmint.com/sshpass-non-interactive-ssh-login-shell-script-ssh-password/)
#              get the fullpath for sshpass ($ which sshpass) and replace it in the script.
#              wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz
#              yum install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install libnet-ssleay-perl libio-socket-ssl-perl
#              tar -xvzf sendEmail-v1.56.tar.gz
#              sudo mv sendEmail-v1.56/sendEmail /usr/bin
#              sudo nano /etc/profile.d/addpath.sh
#                 export PATH=$PATH:/usr/local/bin:/usr/local/sbin
#              nano /usr/local/bin/sendEmail
#                 replace: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'SSLv3 TLSv1')) {     with: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'TLSv1')) {
#              #connect via ssh to XXX.XXX.XXX.243:<Port> at least one to install the ssh key.
#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin

vwwwroot1="$HOSTNAME"
#vip1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vip1=$(hostname -I | awk '{ print $1 }')
vdate1=$(date '+%Y-%m-%d')
vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
vfilename1=$vdate1-elasticsearch-backup.tar.gz

#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
sshpass -p '<Password>' ssh -oStrictHostKeyChecking=no -p <PortNumber> <Username>@XXX.XXX.XXX.243 /bin/mkdir -p /mnt/shares/drobo/$vwwwroot1

#CREATING A SNAPSHOT OF ELASTICSEARCH OF ALL INDEXES
cd /
mkdir elasticsearch-backup
chown elasticsearch:elasticsearch elasticsearch-backup
echo CREATNG THE SNAPSHOT
echo "===================="
vline1=$(curl -XPUT "http://$vwwwroot1:9200/_snapshot/elasticsearch-backup/snapshot-$vdate1?wait_for_completion=true")
# OLD: if [ `expr match "$vline1" '.*"successful":10'` \> 0 ] ; then
if [ `expr match "$vline1" '.*"failed":0'` \> 0 ] ; then
   vexitcode1=0
else
   vexitcode1=1
fi
if [ $vexitcode1 -ne 0 ] ; then
   echo "snapshot failed with exit code $vexitcode1"
   sendEmail -vv -o tls=yes -m "Error on $vdate1 when creating elasticsearch snapshot on $vwwwroot1($vip1):elasticsearch-backup/snapshot-$vdate1 -> snapshot failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/elasticsearch-backup.sh snapshot Error: $vexitcode1" >> /var/log/sendEmail.log
   sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Elastic $vwwwroot1 Error:snapshot failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
else
   #COMPATING THE SNAPSHOT
   echo " "
   echo COMPACTING THE SNAPSHOT
   echo "======================="
   cd /elasticsearch-backup
   tar cpPzf /tmp/$vfilename1 /elasticsearch-backup --after-date='1 days ago'
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when compressing /elasticsearch-backup on $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/elasticsearch-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Elastic $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
   else
      echo "STARTING TRANSMISSION OF SNAPSHOT TO THE <Location> OFFICE"
      echo "======================================================="
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
         sendEmail -vv -o tls=yes -m "Successfully backed up all indexes of elasticseach from $vwwwroot1 to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of elasticsearch indexes was made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Mysql $vwwwroot1 Success: backed up elastic >> /mnt/shares/drobo/backupserver.log"
      fi
   fi
fi