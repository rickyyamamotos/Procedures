#!/bin/bash
#SCRIPT NAME: /iplist.sh
#PURPOSE: sort the ip of previous connect users by their IP address along with the date they first logged
#         to view the log go to http://XXX.XXX.XXX.51/sshaudits.php
#CREATED ON: 11/21/2018
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 11/21/2018
#INTRUCTIONS: copy this script onto the root of the backup server with permission 711.
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 05 01 *   *   *    /bin/bash /iplist.sh
#              #  Mn Hr DoM Mon DoW


/usr/bin/tail -n +2 /mnt/shares/drobo/ssh-access-audit.log | /usr/bin/cut -d' ' -f 1,6 > /mnt/shares/drobo/tmp1.txt
/usr/bin/sort -u -k2 -t' ' /mnt/shares/drobo/tmp1.txt > /mnt/shares/drobo/ssh-access-iplist.log
/bin/rm /mnt/shares/drobo/tmp1.txt
