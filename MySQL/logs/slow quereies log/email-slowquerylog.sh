#!/bin/bash
#SCRIPT NAME: /email-slowquerylog.sh
#PURPOSE: every 4 hours, this copies current /var/log/mysql/mysql-slow.log as //var/log/mysql/mysql-slow-$TIMESTAMPT.log, and zaps it. Then emails it to recipients
#CREATED ON: 02/03/2021
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 02/03/2021
#INTRUCTIONS: copy this script onto the root of any mysql server runing "SLOW QUERIES" log. Then create a crontab job to autoexecute it everyday
#REQUIREMENTS: #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 0 */4 *   *   *    /bin/bash /email-slowquerylog.sh
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


#REQUIREMENTS
vlogpath1="/var/log/mysql"
vlogname1="mysql-slow.log"
vmainrecipient1="<Email>"
votherrecipients1="<Email> <Email> <Email> <Email>"
vsubject1="mysql slow queries log for "
vbody1="Attached is the file containing the log for the last 4 hours. Filename is "


#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin


#EXTRACTING DATA FROM HOST
vwwwroot1="$HOSTNAME"
#vipaddress1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vipaddress1=$(hostname -I | awk '{ print $1 }')
vdate1=$(date '+%Y-%m-%d')
vtime1=$(date '+%H')


#COPYING THE SLOW-QUERIES-LOG FILE AND CLEANING IT
vfilename1="$vwwwroot1-mysql-slow-$vdate1-$vtime1.log"
vbody1="$vbody1$vfilename1. \n Current Time/Date = $vdate1 and $vtime1 hours"
vsubject1="$vsubject1 $vwwwroot1"

#echo "vlogpath1, vlogname1, vmainrecipient1 = $vlogpath1, $vlogname1, $vmainrecipient1"
#echo "votherrecipients1 = $votherrecipients1"
#echo "vwwwroot1, vipaddress1, vdate1, vtime1 = $vwwwroot1, $vipaddress1, $vdate1, $vtime1"
#echo "vfilename1 = $vfilename1"
#echo "vsubject1 = $vsubject1"
#echo "vbody1 = $vbody1"


cp $vlogpath1/$vlogname1 $vlogpath1/$vfilename1
tar cpPzf $vlogpath1/$vfilename1.tar.gz  $vlogpath1/$vfilename1
rm $vlogpath1/$vfilename1 -f
truncate -s 0 $vlogpath1/$vlogname1
sendEmail -vv -o tls=yes -m $vbody1 -f <Email> -t $vmainrecipient1  -cc $votherrecipients1 -s smtp.gmail.com:587 -xu <Site>.server@gma$

exit
