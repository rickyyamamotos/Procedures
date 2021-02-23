#!/bin/bash
#SCRIPT NAME: /deletelog.sh
#PURPOSE: deletes canvaslms log to avoid them to fill the disk
#CREATED ON: 08/04/2020
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 08/04/2020
#REQUIREMENTS:
#              #Set the days variables to define which day of the week to run the backups
#              sudo crontab -e
#                 01 06 *   *   1    /bin/bash /deletelog.sh
#              #  Mn Hr DoM Mon DoW

cd /opt/bitnami/apps/canvaslms/log/
rm canvaslms.log -f
rm production.log -f
touch canvaslms.log
touch production.log
chown daemon:daemon canvaslms.log
chown daemon:daemon production.log

cd /opt/bitnami/apps/canvaslms/htdocs/log
rm delayed_job.log -f
rm production.log -f
touch delayed_job.log
touch production.log
chown daemon:daemon delayed_job.log
chown daemon:daemon production.log
