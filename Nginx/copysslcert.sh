#!/bin/bash
#SCRIPT NAME: /copysslcert.sh
#PURPOSE: copy the ssl certficates stored in the nginx reverse proxy server to a local storage
#CREATED ON: 11/28/2018
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 11/28/2018
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 01 *   *   *    /bin/bash /copysslcert.sh
#              #  Mn Hr DoM Mon DoW


vwwwroot1=`hostname`

vvar1=$(sshpass -p '<Password>' ssh -oStrictHostKeyChecking=no -p <PortNumber> <Username>@XXX.XXX.XXX.42 /bin/grep ssl_certificate /etc/nginx/sites-available/$vwwwroot1)

vvar2=${vvar1:`expr match "$vvar1" '.*ssl_certificate '`}
vvar2=${vvar2:0:`expr index "$vvar2" ';'`-1}
vvar2="${vvar2//[[:space:]]/}"

vvar3=${vvar1:`expr match "$vvar1" '.*ssl_certificate_key'`}
vvar3=${vvar3:0:`expr index "$vvar3" ';'`-1};
vvar3="${vvar3//[[:space:]]/}"

vvar4=${vvar3:0:`expr match "$vvar3" '.*privkey.pem'`-11}
vvar4=$vvar4"chain.pem"

echo "vwwwroot1: $vwwwroot1"
echo "vvar1: $vvar1"
echo "vvar2: $vvar2"
echo "vvar3: $vvar3"
echo "vvar4: $vvar4"

vvar1=`cat /etc/*-release | grep Ubuntu`
if [ ${#vvar1} -gt 0 ]; then
   echo "Ununtu"
   vvar1=$(grep -Rv "#" /etc/apache2/sites-enabled | grep "SSLCertificateFile")
   vvar5=${vvar1:`expr match "$vvar1" '.*SSLCertificateFile '`}
   echo "location of Public: $vvar5"
   vvar1=$(grep -Rv "#" /etc/apache2/sites-enabled | grep "SSLCertificateKeyFile")
   vvar6=${vvar1:`expr match "$vvar1" '.*SSLCertificateKeyFile '`}
   echo "location of Key: $vvar6"
   vvar1=$(grep -Rv "#" /etc/apache2/sites-enabled | grep "SSLCertificateChainFile")
   vvar7=${vvar1:`expr match "$vvar1" '.*SSLCertificateChainFile '`}
   echo "location of Key: $vvar6"

   sshpass -p '<Password>' scp -P <PortNumber> <Username>@XXX.XXX.XXX.42:$vvar2 $vvar5
   sshpass -p '<Password>' scp -P <PortNumber> <Username>@XXX.XXX.XXX.42:$vvar3 $vvar5
   sshpass -p '<Password>' scp -P <PortNumber> <Username>@XXX.XXX.XXX.42:$vvar4 $vvar7
   service apache2 restart
else
   vvar1=`cat /etc/*-release | grep CentOS`
   if [ ${#vvar1} -gt 0 ]; then
      echo "CentOS"
   else
      echo "Unknown OS"
   fi
fi
