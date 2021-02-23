#!/bin/bash
#SCRIPT NAME: /apache-backup.sh
#PURPOSE: backup wordpress data to the drobo in the <Location> Office
#CREATED ON: 10/08/2018
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 10/08/2018
#INTRUCTIONS: copy this script onto the root of any apache server. Then create a crontab job to autoexecute it everyday
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\ see subdirectories
#REQUIREMENTS: DATABASE ENGINE MUST BE MYSQL
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 03 *   *   *    /bin/bash /apache-backup.sh
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

#SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK
#   vdmysql defines which days to make a backup of the wordpress's mysql database
#   vdhtmlroot defines which days to make a backup of the wordpress's html directory
# values 1,2,3,4,5,6,7 for monday through Sunday respectively
#        8 for everyday
#        0 for never
vdhtmlroot=8


#REQUIRE PARAMETERS
vdirectory1="/var/www/html/<Site>"

#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin


#EXTRACTING DATA FROM HOST
#vipaddress1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vipaddress1=$(hostname -I | awk '{ print $1 }')
vdate1=$(date '+%Y-%m-%d')
vdow1=$(date +%u)
vwwwroot1=$(hostname)
echo "vipaddress1, vwwwroot1, vdate1, vdow1,:  $vipaddress1, $vwwwroot1, $vdate1, $vdow1,"

#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
sshpass -p '<Password>' ssh -oStrictHostKeyChecking=no -p <PortNumber> <Username>@XXX.XXX.XXX.243 /bin/mkdir -p /mnt/shares/drobo/$vwwwroot1


#COMPATING AND TRANSMITTING THR HTMLROOT DIRECTORY
#SET VALUE OF vdhtmlroot ON THE TOP OF THIS SCRIPT
if [ $vdhtmlroot -eq $vdow1 -o $vdhtmlroot -eq 8 ] ; then
   echo "Started compressing the html root directory"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   vfilename1=$vdate1-htmlroot-backup.tar.gz
   tar -cpzf /tmp/$vfilename1 $vdirectory1
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=no -m "Error on $vdate1 when compressing $vdirectory1 on $vwwwroot1($vipaddress1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f connect4educa$
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Htmlroot $vwwwroot1 Error:tar$
   else
      echo "Stated transmitting the files to the <Location>s Office Drobo"
      chmod 777 /tmp/$vfilename1
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
      sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
      vexitcode1=$?
      rm -f /tmp/$vfilename1
      if [ $vexitcode1 -ne 0 ] ; then
         echo "sshpass failed with exit code $vexitcode1"
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting the $vdirectory1 directory backup from $vwwwroot1[$vipaddress1] to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwww$
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Htmlroot $vwwwroot1 Error:$
      else
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up $vwwwroot1[$vipaddress1] $vdirectory1 directory  to:\n   <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n $
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Htmlroot $vwwwroot1 Succes$
      fi
   fi
fi


