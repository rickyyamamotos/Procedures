#!/bin/bash
#SCRIPT NAME: /rails-backup.sh
#PURPOSE: backup rails data to the drobo in the <Location> Office
#CREATED ON: 06/29/2018
#CREATED BY: Rick Yamamoto
#INTRUCTIONS: You need to manually change below the vrailsroot value with the path of the Rails's Application Root
#             It is assumed that the enviroment is production
#             copy this script onto the root of any rails server. Then create a crontab job to autoexecute it everyday
#DATA REPOSITORY LOCATION: <Location>:\XXX.XXX.XXX.87\backup\ see subdirectories
#REQUIREMENTS: #Set the days variables to define which day of the week to run the backups as shown on "SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK"
#              sudo crontab -e
#                 01 02 *   *   *    /bin/bash /rails-backup.sh
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
#              Postgresql error, user does not have access to table
#                 su postgres 
#                 psql
#                 ALTER USER "my_user" WITH option;

#DATA REQUIREMENTS
#SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK
#   vdmysql defines which days to make a backup of the rail's postgresql database
#   vddataroot  defines which days to make a backup of the rails' dataroot directory
# values 1,2,3,4,5,6,7 for monday through Sunday respectively
#        8 for everyday
#        0 for never
vdmysql1=8
vddataroot=1


#THE FOLLOWING INFORMATION NEEDS TO BE CHANGED TO SPECIFY THE RAILS APPLICATION ROOT
vrailsroot="/var/www/<Directory>/current"


#WE NEED TO USE A POSTGRES USER THAT IS ROOT, vdbuser="postgres" will be used instead the one on the database.yml
#Ensure that $HOSTNAME equals the url's domain. i.e. <Site>


#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin


#EXTRACTING DATA FROM RAILS CONFIGURATION
vfilename1="$vrailsroot/config/database.yml"
#Assuming that the enviroment used is production
vdbtype1=""
vdbhost1=""
vdbname1=""
<Username>=""
vdbpass1=""
vflag=0
while read -r line
do
   vline1="$line"
#   echo "$vline1"
   if [ "$vline1" == "production:" ]; then
      vflag=1
   fi
   if [ `expr match "$vline1" "#"` -eq 0 ] && [ `expr match "$vline1" "adapter:"` \> 0 ] && [ $vflag == 1 ] && [ "${#vdbtype1}" -eq 0 ]; then
      vline1=${vline1:`expr index "$vline1" " "`}
      vdbtype1=$vline1
   fi
   if [ `expr match "$vline1" "#"` -eq 0 ] && [ `expr match "$vline1" "host:"` \> 0 ] && [ $vflag == 1 ] && [ "${#vdbhost1}" -eq 0 ]; then
      vline1=${vline1:`expr index "$vline1" " "`}
      vdbhost1=$vline1
   fi
   if [ `expr match "$vline1" "#"` -eq 0 ] && [ `expr match "$vline1" "database:"` \> 0 ] && [ $vflag == 1 ] && [ "${#vdbname1}" -eq 0 ]; then
      vline1=${vline1:`expr index "$vline1" " "`}
      vdbname1=$vline1
   fi
   if [ `expr match "$vline1" "#"` -eq 0 ] && [ `expr match "$vline1" "username:"` \> 0 ] && [ $vflag == 1 ] && [ "${#<Username>}" -eq 0 ]; then
      vline1=${vline1:`expr index "$vline1" " "`}
      <Username>=$vline1
   fi
   if [ `expr match "$vline1" "#"` -eq 0 ] && [ `expr match "$vline1" "password:"` \> 0 ] && [ $vflag == 1 ] && [ "${#vdpass1}" -eq 0 ]; then
      vline1=${vline1:`expr index "$vline1" " "`}
      vdbpass1=$vline1
   fi
done < "$vfilename1"
#<Username>="postgres"
echo "$vdbtype1 $vdbhost1 $vdbname1 $<Username> $vdbpass1"

#EXTRACTING DATA FROM HOST
#vip1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vip1=$(hostname -I | awk '{ print $1 }')
vdate1=$(date '+%Y-%m-%d')
vdow1=$(date +%u)
vwwwroot1="$HOSTNAME"
echo "$vip1 $vdate1 $vdow1 $vwwwroot1"


#VERIFYING THAT DIRECTORY EXIST ON DROBO AND CREATE IF IT DOES NOT
sshpass -p '<Password>' ssh -oStrictHostKeyChecking=no -p <PortNumber> <Username>@XXX.XXX.XXX.243 /bin/mkdir -p /mnt/shares/drobo/$vwwwroot1


#CREATING, COMPACTING AND TRANFERING  A DATABASE DUMP
if [ $vdmysql1 -eq $vdow1 -o $vdmysql1 -eq 8 ] ; then
   echo "Started the creation the database dump..."
   if [ `expr match "$vdbtype1" "postgresql"` \> 0 ] ; then
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
#      sshpass su postgres -c "sshpass -p '$vdbpass1' /usr/bin/pg_dump --file=/tmp/$vdbname1-backup.pg_dump -Fc -v -b -o -O -x --host=$vdbhost1 --username=$<Username> --password $vdbname1" 
      sshpass -p $vdbpass1 /usr/bin/pg_dump --file=/tmp/$vdbname1-backup.pg_dump -Fc -v -b -o -O -x --host=$vdbhost1 -U $<Username> --password $vdbname1
      vexitcode1=$?
      if [ $vexitcode1 -ne 0 ] ; then
         rm -f /tmp/$vdbname1-backup.pg_dump
         echo 'PostgreSQL dump failed with exit code $vexitcode1'
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when making a dump backup of database: $vdbname1 on $vwwwroot1($vip1) -> PostgreSQL Dump  failed with exit code $verrorcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/rails-backup.sh PostgreSQL Dump Error:$vexiterror1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT PostgreSQL $vwwwroot1 Error:PostgreSQL Ddump failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         vfilename1=$vdate1-postgresql-$vdbname1-backup.tar.gz
         echo "Started compressing the database dump"
         vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
         tar cpPzf /tmp/$vfilename1 /tmp/$vdbname1-backup.pg_dump
         vexitcode1=$?
         rm -f /tmp/$vdbname1-backup.pg_dump
         if [ $vexitcode1 -ne 0 ] ; then
            rm -f /tmp/$vfilename1
            echo 'tar failed with exit code $vexitcode1'
            sendEmail -vv -o tls=yes -o -m "Error on $vdate1 when compressing database $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/rails-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
            sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT PostgreSQL $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
        else
           chmod 777 /tmp/$vfilename1
           echo "Stated transmitting the file to the <Location>'s Office Drobo"
           vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
           sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
           vexitcode1=$?
           rm -f /tmp/$vfilename1
           if [ $vexitcode1 -ne 0 ] ; then
              echo "sshpass failed with exit code $vexitcode1"
              sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting database backup from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/rails-backup.sh sshpass Error: $verrorcode1" >> /var/log/sendEmail.log
              sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT PostgreSQL $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
           else
              echo "Backup finished without errors"
              sendEmail -vv -o tls=yes -m "Successfully backed up $vdbname1 database from $vwwwroot1 to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of $vdbname1 database was made on $vdate1" >> /var/log/sendEmail.log
              sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT PostgreSQL $vwwwroot1 Success: backed up PostgreSQL Database >> /mnt/shares/drobo/backupserver.log"
           fi
        fi
      fi
   else
         echo "Error: RAILS databases is not PostgreSQL"
   fi
fi


#COMPATING AND TRANSMITTING THR DATAROOT DIRECTORY
#SET VALUE OF vddataroot ON THE TOP OF THIS SCRIPT
#DEVELOPERS LIKE TO STORE BACKUPS FILES IN THE /DATAROOT DIRECTORY. THEREFORE, PLEASE  MOVE ALL BACKUPS FILES INSIDE /DATAROOT TO /DATAROOT/BACKUPS
if [ $vddataroot -eq $vdow1 -o $vddataroot -eq 8 ] ; then
   echo "Started compressing the dataroot directory"
   vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
   vfilename1=$vdate1-dataroot-backup.tar.gz
   tar cpPzf /tmp/$vfilename1 --exclude="$vrailsroot/backups" --exclude="$vrailsroot/tmp" --exclude="$vrailsroot/trashdir --exclude="$vrailsroot/test" $vrailsroot/*
   vexitcode1=$?
   if [ $vexitcode1 -ne 0 ] ; then
      echo "tar failed with exit code $vexitcode1"
      rm -f /tmp/$vfilename1
      sendEmail -vv -o tls=yes -m "Error on $vdate1 when compressing the dataroot directory ($vrailsroot) on $vwwwroot1($vip1):/tmp/$vfilename1-> tar failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/mahara-backup.sh tar Error: $vexitcode1" >> /var/log/sendEmail.log
      sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Dataroot $vwwwroot1 Error:tar failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
   else
      chmod 777 /tmp/$vfilename1
      echo "Stated transmitting the files to the <Location>s Office Drobo"
      vtime1=$(TZ=US/Eastern date '+%H:%M:%S')
      sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/$vfilename1 <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/$vwwwroot1/
      vexitcode1=$?
      rm -f /tmp/$vfilename1
      if [ $vexitcode1 -ne 0 ] ; then
         echo "sshpass failed with exit code $vexitcode1"
         sendEmail -vv -o tls=yes -m "Error on $vdate1 when transmitting the dataroot directory($vrailsroot) from $vwwwroot1($vip1) to <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n -> sshpass failed with exit code $vexitcode1" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):/mahara-backup.sh sshpass Error: $verrorcdoe1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Dataroot $vwwwroot1 Error:sshpass failed with exit code $vexitcode1 >> /mnt/shares/drobo/backupserver.log"
      else
         echo "Backup finished without errors"
         sendEmail -vv -o tls=yes -m "Successfully backed up $vwwwroot1($vip1) dataroot directory  to:\n   <Location>\\\\XXX.XXX.XXX.87\\backup\\$vwwwroot1\\$vfilename1.\n Date: $vdate1\n See <Location>Office\\\\XXX.XXX.XXX.87\\backup\\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "$vwwwroot1($vip1):Successful backup of $vrailsroot dataroot directory made on $vdate1" >> /var/log/sendEmail.log
         sshpass -p '<Password>' ssh -p <PortNumber> <Username>@XXX.XXX.XXX.243 "/bin/echo $vdate1 $vtime1 $(date '+%Y-%m-%d') $(TZ=US/Eastern date '+%H:%M:%S') EDT Dataroot $vwwwroot1 Success: backed up dataroot >> /mnt/shares/drobo/backupserver.log"
      fi
   fi
fi



