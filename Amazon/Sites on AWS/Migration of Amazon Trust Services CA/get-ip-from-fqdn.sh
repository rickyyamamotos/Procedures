#!/bin/bash
#SCRIPT NAME: /get-ip-from-fqdn.sh
#PURPOSE: get the IP address from a list of fqdn
#CREATED ON: 02/08/2021
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 02/08/2021
#REQUIREMENTS
#		1) copy a file containing the list of fqdn in nagios4:/tmp/address.txt, one fqdn per line
#		2) execute this script
#		3) result will be on nagios4:/tmp/ip-address.txt. A file containing fqdn, ip-address

vfqdn1=""
vipaddress1=""
vfilename1="/tmp/address.txt"
vfilename2="/tmp/ip-address.txt"


rm $vfilename2 -f


while read -r vline1
do
   vipaddress1=$(getent hosts $vline1 | awk '{ print $1 }')
   echo "$vline1," "$vipaddress1" >> $vfilename2
done < $vfilename1
	