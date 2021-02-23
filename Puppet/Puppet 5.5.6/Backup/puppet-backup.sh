#!/bin/bash
#SCRIPT NAME: /puppet-backup.sh
#PURPOSE: backup puppet configuration to the drobo in the <Location> Office
#CREATED ON: 10/18/2019
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 10/18/2019
#INTRUCTIONS: copy this script onto the root of any puppet server. Then create a crontab job to autoexecute it every week
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\<hostname of puppet server> see subdirectories
#REQUIREMENTS: #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 01 *   *   *    /bin/bash /puppet-backup.sh
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
#              #connect via ssh to XXX.XXX.XXX.243:<PortNumber> at least one to install the ssh key.

#SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK 
#   vpuppet1 defines which days to make a backup of the puppet's configuration
# values 1,2,3,4,5,6,7 for monday through Sunday respectively
#        8 for everyday
#        0 for never
vpuppet1=7


#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin



#EXTRACTING DATA FROM HOST
#vip1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vip1=$(hostname -I | awk '{ print $1 }')
vdate1=$(date '+%Y-%m-%d')
vdow1=$(date +%u)
vwwwroot1="$HOSTNAME"
vfilename1=$vdate1-puppet-$vwwwroot1.tar.gz

# echo "vip1 vdate1 vdow1 vwwwroot1 vfilename1 => $vip1 $vdate1 $vdow1 $vwwwroot1 $vfilename1"

#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
sshpass -p '<Password>' ssh -oStrictHostKeyChecking=no -p <PortNumber> <Username>@XXX.XXX.XXX.243 /bin/mkdir -p /mnt/shares/drobo/$vwwwroot1

#CREATING, COMPACTING AND TRANFERING  A CONFIGURATION FILES
if [ $vpuppet1 -eq $vdow1 -o $vpuppet1 -eq 8 ] ; then
   echo "Started the compression of files..."
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   tar cpPzf /tmp/$vfilename1 /etc/puppetlabs/puppet/ssl /etc/puppetlabs/code/environments/production
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      echo 'tar failed with exit code $vexitcode1'
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=yes -o -m "Error on $vdate1 when compressing database $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/puppet-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Puppet $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
   else
      chmod 777 /tmp/$vfilename1
      echo "Stated transmitting the file to the <Location>'s Office Drobo"
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
      sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
      vexitcode1=$?
      rm -f /tmp/$vfilename1
      if [ $vexitcode1 -ne 0 ] ; then
         echo "sshpass failed with exit code $vexitcode1"
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting database backup from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/puppet-backup.sh sshpass Error: $verrorcode1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Puppet $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up puppet configuration from $vwwwroot1 to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "Puppet Configuration($vip1):Successful backup of puppet configuration was made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Puppet $vwwwroot1 Success: backed up Puppet configuration >> /mnt/shares/drobo/backupserver.log"
      fi
   fi
fi


