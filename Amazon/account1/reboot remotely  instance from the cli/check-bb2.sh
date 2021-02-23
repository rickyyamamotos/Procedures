#!/bin/bash
#SCRIPT NAME: /check-<Site>.sh
#PURPOSE: check if <Site>.<Domain> crashes and reboot the instance
#CREATED ON: 08/05/2020
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 08/05/2020
#INTRUCTIONS: copy this script onto the root of the nagios server. Then create a crontab job to autoexecute it every 2 minutes
#REQUIREMENTS:
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 */3 * *   *   *    /bin/bash /wordpress-backup.sh
#              #  Mn Hr DoM Mon DoW
#              install the AWS CLI version 2 from
#              yum update -y
#              python --version
#                 //* AWS CLI requires either Python 2.6.5+ or Python 3.3+ to be installed on the system
#              cd /tmp
#              curl -O https://bootstrap.pypa.io/get-pip.py
#              python get-pip.py
#              yum install awscli
#              pip install awscli
#              pip install awscli --upgrade
#              aws -> iams -> policies -> create policy -> JSON -> paste the following
#                       {
#                           "Version": "2012-10-17",
#                           "Statement": [
#                               {
#                                   "Effect": "Allow",
#                                   "Action": "*",
#                                   "Resource": "*"
#                               }
#                           ]
#                       }
#              review polcy -> name: reboot-ec2-instance -> create policy
#              aws -> iams -> users -> add user -> name: rick , check "Programmatic access" -> next permissions -> check "reboot-ec2-instance" -> tag -> review -> create user
#                       //* get access key id, secret access key
#              aws -> ec2 -> i-<ID> -> tag -> add/edit tag -> create tag -> key: Owner , value=rick
#                       //* get zone
#              aws configure
#                       Access key ID:  <Key>
#                       Secret access key:      <key>
#                       Availability zone:      us-west-2



vdate1=$(date '+%Y-%m-%d')
vip1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
vwwwroot1="<Site>.<Domain>"
vtime1=$(TZ=US/Eastern date '+%H:%M:%S')" EDT"

read -d. seconds1 < /proc/uptime
if (( $seconds1 > 2*60 )) ; then
   echo "this server has been up and running for $seconds1 seconds"
   vexitcode1=$(curl -k https://<Site>.<Domain>/ | grep "502 Bad Gateway")

   if [ ${#vexitcode1} -gt 0 ]; then
      sendEmail -vv -o tls=yes -m "This is a notification. No actions needed. \n   check-<Site>.sh on nagios found that $vwwwroot1 creashed and it will autoamtically rebooted on $vdate1 @ $vtime1 to fix a java crash. \n The $vwwwroot1 server will automatically be back online in 1 minute. \n\nRick Yamamoto" -f <Username>@<Site> -t <Email> -cc <Email> -s <SMTPServer>:2525 -xu <Email> -xp <Password> -u "($vip1):/check-<Site>.sh Error:Java crashed, server rebooted to fix a java crasj" >> /var/log/sendEmail.log
      echo "system rebooted on $vdate1 @ $vtime1, because bb.<Domain> is down" >> /var/log/restart-bb.log
      aws ec2 reboot-instances --instance-ids i-<ID>
   else
      bbstatus1="Up and runing"
      echo "Blackboard Status is: $bbstatus1"
      echo "$vdate1 $vtime1 Blackboard Status is: $bbstatus1"  >> /var/log/restart-bb.log
   fi
else
   echo "Srver just restart $seconds1 ago. Ignoring Status until server is up more than 2 minutes"
fi
