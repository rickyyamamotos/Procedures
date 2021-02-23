#!/bin/bash
#SCRIPT NAME: /audit-ssh-access.sh
#PURPOSE: save a log of success ssh connections to servers
#         to view the log go to http://XXX.XXX.XXX.51/sshaudits.php
#CREATED ON: 11/20/2018
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 11/20/2018
#REF: https://askubuntu.com/questions/179889/how-do-i-set-up-an-email-alert-when-a-ssh-login-is-successful
#INTRUCTIONS: copy this script onto the root of any wordpress server with permission 711. Then, append the following 1 line into /etc/pam.d/sshd
#        session optional pam_exec.so seteuid /audit-ssh-access.sh
#            # optional: it will allow user to log even is this script fails
#            # required: it will not allow user to log even is this script fails
# and ensure the PAM is enable in /etc/ssh/sshd_config:        UsePam yes


#LOG FILE: <Location>:\XXX.XXX.XXX.87\backup\ssh-access-audit.log
#REQUIREMENTS:
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

#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin

#PAM_TYPE="Test"
#PAM_RHOST="XXX.XXX.XXX.254"
#PAM_USER="rick1"

#EXTRACTING DATA FROM HOST
vip1=`hostname -I`
vip1=`echo $vip1 | sed 's/\ /-/g'`
wwwroot1=`hostname`
vdateip1=""

if [ "$PAM_TYPE" != "close_session" ]; then
   venv1=$(echo `env` | tr '\n' ' , ')
   vvar1=$(grep $PAM_RHOST /mnt/shares/drobo/ssh-access-iplist.log)
   vdateip1=${vvar1:0:`expr index "$vvar1" " "`}
   if [ ${#vdateip1} -eq 0 ]; then
      vdateip1=$(date '+%Y-%m-%d')
# We do want to log when a new source IP is logged via SSH, using any username
      /bin/echo $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT $wwwroot1 $vip1 $PAM_RHOST $PAM_USER $vdateip1 @$venv1@ >> /mnt/shares/drobo/ssh-access-audit.log
   fi

# We dont want to log every ssh session including backups sessions
#   /bin/echo $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT $wwwroot1 $vip1 $PAM_RHOST $PAM_USER $vdateip1 @$venv1@ >> /mnt/shares/drobo/ssh-access-audit.log

# We dont want to filter out ssh session from <Username>
#   if [$PAM_USER != "<Username>"]; then
#      /bin/echo $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT $wwwroot1 $vip1 $PAM_RHOST $PAM_USER $vdateip1 @$venv1@ >> /mnt/shares/drobo/ssh-access-audit.log
#   fi

# We dont want notificatios via email messages
    # sendEmail -vv -o tls=yes -m "User $PAM_USER connected to $wwwroot1 ($vip1) via SSH from $PAM_RHOST on $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT \n$venv1" -f <Email> -t <Email> -cc

fi




