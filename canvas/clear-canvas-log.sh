#!/bin/bash
#SCRIPT NAME: /lear-canvas-log.sh
#PURPOSE: keep last 50000 lines of entries on the canvas/rails log files
#CREATED ON: 11/07/2019
#CREATED BY: Rick Yamamoto
#INTRUCTIONS: You need to manually change below the vrailsroot value with the path of the Rails's Application Root
#             It is assumed that the enviroment is production
#             copy this script onto the root of any rails server. Then create a crontab job to autoexecute it everyday
#REQUIREMENTS: #Set the days variables to define which day of the week to run the backups as shown on "SET THE FOLLOWING VARIALBLES TO DEFINE WHICH DAY OF THE WEEK"
#              sudo crontab -e
#                 01 02 *   *   *    /bin/bash /clear-canvas-log.sh
#              #  Mn Hr DoM Mon DoW


#THE FOLLOWING INFORMATION NEEDS TO BE CHANGED TO SPECIFY THE RAILS APPLICATION ROOT
vrailsroot="/var/canvas"

#STARTING...
PATH=$PATH:/usr/local/bin:/usr/bin

tail -n 50000 $vrailsroot/log/production.log > $vrailsroot/log/production.log.bak
rm $vrailsroot/log/production.log
mv $vrailsroot/log/production.log.bak $vrailsroot/log/production.log
tail -n 50000 $vrailsroot/log/delayed_job.log > $vrailsroot/log/delayed_job.log.bak
rm $vrailsroot/log/delayed_job.log
mv $vrailsroot/log/delayed_job.log.bak $vrailsroot/log/delayed_job.log
tail -n 50000 $vrailsroot/log/development.log > $vrailsroot/log/development.log.bak
rm $vrailsroot/log/development.log
mv $vrailsroot/log/development.log.bak $vrailsroot/log/development.log