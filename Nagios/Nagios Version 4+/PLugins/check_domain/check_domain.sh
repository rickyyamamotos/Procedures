#!/bin/sh
#SCRIPT NAME: /check_domain.sh
#PURPOSE: Check the expiration date of a domain, and alarm if the domain is due in less than a month
#CREATED ON: 02/03/2021
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 02/03/2021
#INTRUCTIONS: copy this script onto the /usr/lib64/nagios/plugins of the nagios server
#REQUIREMENTS:     yum install whois or apt-get install whois

#DECLARING VARIABLES
vexpdate1=""
vdate1=$(date --date '-1 month' '+%Y-%m-%d')             # using last month date to create an alert a month before domain expiration


#STARTING
if [ $# -lt 1 ]; then                                    # Verifiying that 1 parameter for the domain is provided
  echo 1>&2 "Not enough arguments. Please use $0 DomainName"
  exit 2
elif [ $# -gt 1 ]; then
  echo 1>&2 "Too many arguments.  Please use $0 DomainName"
  exit 2
fi
vexpdate1=$(whois $1 | grep "Registry Expiry Date:")     # Getting the domain's expiration date from whois
vexpdate1=${vexpdate1:`expr index "$vexpdate1" "D"`+5}
vexpdate1=${vexpdate1::`expr index "$vexpdate1" "T"`-1}
vdate1=$(date -d $vdate1 +"%Y%m%d")
vexpdate2=$(date -d $vexpdate1 +"%Y%m%d")
vday1s=$(echo $(( ($(date -d $vexpdate2 +%s) - $(date -d $vdate1 +%s)) / 86400 )))


if [ $vdate1 -ge $vexpdate2 ]; then
   echo "CRITICAL - domain $1 will expired in [$vday1s days]"
   exit "3"
else
   echo "OK: domain $1 will not expired until $vexpdate1 (YYYY/MN/DD) [$vday1s days left]"
   exit "0"
fi

#echo "vexpdate1 < vdate1 = $vexpdate1 < $vdate1"
