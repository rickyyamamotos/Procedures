#!/bin/bash
#SCRIPT NAME: /copycert.sh
#PURPOSE: copies the ssl certs from <Site>-nginx(frontend) to this server
#         run this on the <Site>-nginx server
#CREATED ON: 06/23/2020
#CREATED BY: Rick Yamamoto
#REQUIREMENTS: 
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 03 *   *   1    /bin/bash /copycert.sh
#              #  Mn Hr DoM Mon DoW
#              yum install sshpass or apt-get install sshpass or (see https://www.tecmint.com/sshpass-non-interactive-ssh-login-shell-script-ssh-password/)
#              get the fullpath for sshpass ($ which sshpass) and replace it in the script.

cd /tmp
rm *.pem
cd /etc/letsencrypt/live/<Site>/
cp -Lr cert.pem /tmp/cert.pem
cp -Lr chain.pem /tmp/chain.pem
cp -Lr fullchain.pem /tmp/fullchain.pem
sshpass -p '<Password>' scp -oStrictHostKeyChecking=no -P <PortNumber> -p /tmp/*.pem <Username>@XXX.XXX.XXX.153:/etc/apache2/certs/
cd /tmp
rm *.pem

