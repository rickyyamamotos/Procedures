#!/bin/bash
#SCRIPT NAME: backupallsonicwall.sh
#PURPOSE: backups the configurations from all the sonicwall to the drobo in the <Location> Office (\\<Site>\backupserver\sonicwall)
#CREATED ON: 10/07/2020
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 10/07/2020
#INTRUCTIONS: copy this script onto the root of backup-server (XXX.XXX.XXX.51). Then create a crontab job to autoexecute it everyweek
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.20\backupserver\sonicwall
#REQUIREMENTS: 
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 08 15 *   *   1    /bin/bash /backupallsonicwall.sh
#              #  Mn Hr DoM Mon DoW
#              yum install expect or apt-get install expect
#              wget wget http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v1.56.tar.gz
#              yum install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install 'perl(Net::SSLeay)' 'perl(IO::Socket::SSL)' or apt-get install libnet-ssleay-perl libio-socket-ssl-perl
#              tar -xvzf sendEmail-v1.56.tar.gz
#              sudo mv sendEmail-v1.56/sendEmail /usr/local/bin
#              sudo nano /etc/profile.d/addpath.sh
#                 export PATH=$PATH:/usr/local/bin:/usr/local/sbin
#              nano /usr/local/bin/sendEmail
#                 replace: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'SSLv3 TLSv1')) {     with: if (! IO::Socket::SSL->start_SSL($SERVER, SSL_version => 'TLSv1')) {
#              #connect via ssh to XXX.XXX.XXX.243:<Port> at least one to install the ssh key.
#              create the sonicwall user, see "C:\Users\rick.yamamoto\Desktop\Training\hardware\Sonicwall\sonicwall Automatic backups\create sonicwall user on backup-server.txt"
#              set the firewalls, see "C:\Users\rick.yamamoto\Desktop\Training\hardware\Sonicwall\sonicwall Automatic backups\sonciwall automatic backups.txt"
#              Add a route to XXX.XXX.XXX.0/24 to the backup-server(XXX.XXX.XXX.51), since its gateway is XXX.XXX.XXX.1
#                 nano /etc/network/interfaces
#                    up route add -net XXX.XXX.XXX.0/24 gw XXX.XXX.XXX.2 dev ens160
#                 service networking restart
#                 ping XXX.XXX.XXX.1

#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin


#Declaring Variables
vdate1=""
vtime1=""
vequipment1=""
vcommand1=""
vftpserver1=""
vsonicwallip1=""

#EXTRACTING DATA FROM HOST
vdate1=$(date '+%Y-%m-%d')


#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
mkdir -p /mnt/shares/drobo/sonicwall


#PROCESSING THE Office Main (NSA 3500 SonicOS Enhanced 5.9.1.13-5o) XXX.XXX.XXX.1
vsonicwallip1="XXX.XXX.XXX.1"
vfilename1="a$vdate1-sw-main-nsa3500"
vequipment1="Office Main (NSA 3500 SonicOS Enhanced 5.9.1.13-5o)(IP:$vsonicwallip1)"
vftpserver1="XXX.XXX.XXX.51"
vcommand1="export current-config sonicos ftp ftp://sonicwall:<Password>@$vftpserver1/$vfilename1.exp"
vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
echo "*"
echo "*"
echo "*"
echo "************* PROCESSING $vequipment1 *************"
/usr/bin/expect << EOF
    spawn ssh -p 22 -oStrictHostKeyChecking=no <Username>@$vsonicwallip1
    expect "Password:"
    send "<Password>\r"
    expect -re ">"
    send "$vcommand1\r"
    expect -re ">"
    send "exit\n"
EOF
vexitcode1=$?
if [ $vexitcode1 -ne 0 ] ; then
   echo "creation of configuration backup file failed with exit code $vexitcode1"
   rm -f /home/sonicwall/ftp/$vfilename1.exp
   sendEmail -vv -o tls=yes -m "Error on $vdate1 when creating a configuration file of $vequipment1 -> creation of $vftpserver1:/home/sonicwall/ftp/$vfilename1.exp failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "XXX.XXX.XXX.51:/backupallsonicwall.sh creation of $vfilename1.exp failed, Error:$vexitcode1" >> /var/log/sendEmail.log
   /bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Sonicwall $vsonicwallip1 Error:$vfilename1.exp failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log
else
   echo "Started compressing the configuration file"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   tar cpPzf /mnt/shares/drobo/sonicwall/$vfilename1.tar.gz /home/sonicwall/ftp/$vfilename1.exp
   vexitcode1=$?
   rm -f /home/sonciwall/ftp/$vfilename1.exp
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /mnt/shares/drobo/sonicwall/$vfilename1.tar.gz
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when comnpacting the configuration backup of $vequipment1 -> tar of $vftpserver1:/mnt/shares/drobo/sonicwall/$vfilename1.tar.gz failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "XXX.XXX.XXX.51:/backupallsonicwall.sh tar of $vfilename1.tar.gz failed, Error:$vexitcode1" >> /var/log/sendEmail.log
      /bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Sonicwall $vsonicwallip1 Error:tar of $vfilename1.tar.gz failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log
   else
      echo "Backup finished without errors"
      sendEmail -vv -o tls=yes -m "Successfully backed up the configuration backup of $vequipment1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "XXX.XXX.XXX.51:/backupallsonicwall.sh Successfully backed up $vfilename1.exp on $vdate1" >> /var/log/sendEmail.log
      /bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Sonicwall $vsonicwallip1 Success: backed up of $vfilename1.tar.gz >> /mnt/shares/drobo/backupserver.log
   fi
fi


#PROCESSING THE Office Backup (TZ 210 SonicOS Enhanced 5.8.0.2-37o) XXX.XXX.XXX.2
vsonicwallip1="XXX.XXX.XXX.2"
#another sonicwall bug, filename cant begin with a number
vfilename1="a$vdate1-sw-back-tz210"
vequipment1="Office Backup (TZ 210 SonicOS Enhanced 5.8.0.2-37o)(XXX.XXX.XXX.2)"
vftpserver1="XXX.XXX.XXX.51"
#vcommand1="export preferences ftp $vftpserver1 sonicwall <Password>  $vfilename1.exp"
vcommand1="export current-config sonicos ftp ftp://sonicwall:<Password>@$vftpserver1/$vfilename1.exp"
vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
echo "*"
echo "*"
echo "*"
echo "************* PROCESSING $vequipment1 *************"
/usr/bin/expect << EOF
    spawn ssh -p 22 -o StrictHostKeyChecking=no -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-dss <Username>@$vsonicwallip1
#    expect "User:"
#    send "<Username>\r"
    expect "Password:"
    send "<Password>\r"
    expect -re ">"
    send "$vcommand1\r"
    expect -re ">"
    send "exit\n"
EOF
vexitcode1=$?
if [ $vexitcode1 -ne 0 ] ; then
   echo "creation of configuration backup file failed with exit code $vexitcode1"
   rm -f /home/sonicwall/ftp/$vfilename1.exp
   sendEmail -vv -o tls=yes -m "Error on $vdate1 when creating a configuration file of $vequipment1 -> creation of $vftpserver1:/home/sonicwall/ftp/$vfilename1.exp failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "XXX.XXX.XXX.51:/backupallsonicwall.sh creation of $vfilename1.exp failed, Error:$vexitcode1" >> /var/log/sendEmail.log
   /bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Sonicwall $vsonicwallip1 Error:$vfilename1.exp failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log
else
   echo "Started compressing the configuration file"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   tar cpPzf /mnt/shares/drobo/sonicwall/$vfilename1.tar.gz /home/sonicwall/ftp/$vfilename1.exp
   vexitcode1=$?
   rm -f /home/sonciwall/ftp/$vfilename1.exp
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /mnt/shares/drobo/sonicwall/$vfilename1.tar.gz
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when comnpacting the configuration backup of $vequipment1 -> tar of $vftpserver1:/mnt/shares/drobo/sonicwall/$vfilename1.tar.gz failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "XXX.XXX.XXX.51:/backupallsonicwall.sh tar of $vfilename1.tar.gz failed, Error:$vexitcode1" >> /var/log/sendEmail.log
      /bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Sonicwall $vsonicwallip1 Error:tar of $vfilename1.tar.gz failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log
   else
      echo "Backup finished without errors"
      sendEmail -vv -o tls=yes -m "Successfully backed up the configuration backup of $vequipment1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "XXX.XXX.XXX.51:/backupallsonicwall.sh Successfully backed up $vfilename1.exp on $vdate1" >> /var/log/sendEmail.log
      /bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Sonicwall $vsonicwallip1 Success: backed up of $vfilename1.tar.gz >> /mnt/shares/drobo/backupserver.log
   fi
fi



#PROCESSING THE <Datacenter> (NSA 3600 SonicOS Enhanced 6.1.1.9-30n) XXX.XXX.XXX.1
vsonicwallip1="XXX.XXX.XXX.1"
vfilename1="a$vdate1-sw-<Datacenter>-nsa3600"
vequipment1="<Datacenter> (NSA 3600 SonicOS Enhanced 6.1.1.9-30n)(XXX.XXX.XXX.1)"
vftpserver1="XXX.XXX.XXX.243"
#vcommand1="export current-config sonicos ftp ftp://sonicwall:<Password>@$vftpserver1/$vfilename1.exp"
vcommand1="export current-config exp ftp ftp://sonicwall:<Password>@XXX.XXX.XXX.243/$vfilename1.exp"
vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
echo "*"
echo "*"
echo "*"
echo "************* PROCESSING $vequipment1 *************"
/usr/bin/expect << EOF
    spawn ssh -p 22 -o StrictHostKeyChecking=no -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-dss <Username>@$vsonicwallip1
    expect "Password:"
    send "<Password>\r"
    expect -re ">"
    send "$vcommand1\r"
    expect -re ">"
    send "exit\n"
EOF
vexitcode1=$?
if [ $vexitcode1 -ne 0 ] ; then
   echo "creation of configuration backup file failed with exit code $vexitcode1"
   rm -f /home/sonicwall/ftp/$vfilename1.exp
   sendEmail -vv -o tls=yes -m "Error on $vdate1 when creating a configuration file of $vequipment1 -> creation of $vftpserver1:/home/sonicwall/ftp/$vfilename1.exp failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "XXX.XXX.XXX.51:/backupallsonicwall.sh creation of $vfilename1.exp failed, Error:$vexitcode1" >> /var/log/sendEmail.log
   /bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Sonicwall $vsonicwallip1 Error:$vfilename1.exp failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log
else
   echo "Started compressing the configuration file"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   tar cpPzf /mnt/shares/drobo/sonicwall/$vfilename1.tar.gz /home/sonicwall/ftp/$vfilename1.exp
   vexitcode1=$?
   rm -f /home/sonciwall/ftp/$vfilename1.exp
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /mnt/shares/drobo/sonicwall/$vfilename1.tar.gz
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when comnpacting the configuration backup of $vequipment1 -> tar of $vftpserver1:/mnt/shares/drobo/sonicwall/$vfilename1.tar.gz failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "XXX.XXX.XXX.51:/backupallsonicwall.sh tar of $vfilename1.tar.gz failed, Error:$vexitcode1" >> /var/log/sendEmail.log
      /bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Sonicwall $vsonicwallip1 Error:tar of $vfilename1.tar.gz failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log
   else
      echo "Backup finished without errors"
      sendEmail -vv -o tls=yes -m "Successfully backed up the configuration backup of $vequipment1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "XXX.XXX.XXX.51:/backupallsonicwall.sh Successfully backed up $vfilename1.exp on $vdate1" >> /var/log/sendEmail.log
      /bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Sonicwall $vsonicwallip1 Success: backed up of $vfilename1.tar.gz >> /mnt/shares/drobo/backupserver.log
   fi
fi


#PROCESSING THE <Datacenter> (NSA 4600 SonicOS Enhanced 6.2.7.1-23n) XXX.XXX.XXX.4
vsonicwallip1="XXX.XXX.XXX.4"
vfilename1="a$vdate1-sw-<Datacenter>-nsa4600"
vequipment1="<Datacenter> (NSA 4600 SonicOS Enhanced 6.2.7.1-23n)(XXX.XXX.XXX.4)"
vftpserver1="XXX.XXX.XXX.243"
vcommand1="export current-config exp ftp ftp://sonicwall:<Password>@XXX.XXX.XXX.243/$vfilename1.exp"
vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
echo "*"
echo "*"
echo "*"
echo "************* PROCESSING $vequipment1 *************"
/usr/bin/expect << EOF
    spawn ssh -p 22 -oStrictHostKeyChecking=no <Username>@$vsonicwallip1
    expect "Password:"
    send "<Password>\r"
    expect -re ">"
    send "$vcommand1\r"
    expect -re ">"
    send "exit\n"
EOF
vexitcode1=$?
if [ $vexitcode1 -ne 0 ] ; then
   echo "creation of configuration backup file failed with exit code $vexitcode1"
   rm -f /home/sonicwall/ftp/$vfilename1.exp
   sendEmail -vv -o tls=yes -m "Error on $vdate1 when creating a configuration file of $vequipment1 -> creation of $vftpserver1:/home/sonicwall/ftp/$vfilename1.exp failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "XXX.XXX.XXX.51:/backupallsonicwall.sh creation of $vfilename1.exp failed, Error:$vexitcode1" >> /var/log/sendEmail.log
   /bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Sonicwall $vsonicwallip1 Error:$vfilename1.exp failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log
else
   echo "Started compressing the configuration file"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   tar cpPzf /mnt/shares/drobo/sonicwall/$vfilename1.tar.gz /home/sonicwall/ftp/$vfilename1.exp
   vexitcode1=$?
   rm -f /home/sonciwall/ftp/$vfilename1.exp
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /mnt/shares/drobo/sonicwall/$vfilename1.tar.gz
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when comnpacting the configuration backup of $vequipment1 -> tar of $vftpserver1:/mnt/shares/drobo/sonicwall/$vfilename1.tar.gz failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "XXX.XXX.XXX.51:/backupallsonicwall.sh tar of $vfilename1.tar.gz failed, Error:$vexitcode1" >> /var/log/sendEmail.log
      /bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Sonicwall $vsonicwallip1 Error:tar of $vfilename1.tar.gz failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log
   else
      echo "Backup finished without errors"
      sendEmail -vv -o tls=yes -m "Successfully backed up the configuration backup of $vequipment1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "XXX.XXX.XXX.51:/backupallsonicwall.sh Successfully backed up $vfilename1.exp on $vdate1" >> /var/log/sendEmail.log
      /bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Sonicwall $vsonicwallip1 Success: backed up of $vfilename1.tar.gz >> /mnt/shares/drobo/backupserver.log
   fi
fi

