#!/bin/bash
#SCRIPT NAME: /github-push.sh
#PURPOSE: check if changes are not committed, then push them to github
#CREATED ON: 10/30/2018
#CREATED BY: Rick Yamamoto
#VERSION: 1 of 10/30/2018
#INTRUCTIONS: - copy this script onto the root of server with github. Then create a crontab job to autoexecute it everyday
#              		sudo crontab -e
#                 	01 03 *   *   *    /bin/bash /github-push.sh
#              		#  Mn Hr DoM Mon DoW
#             - replace the value of the vdir1 variable with the directory where the .git is installed (place where git init was made)
#             - We will use a ssh key to authenticate our server with the github.com
#               1) Determine if any existing key exists
#                  $ sudo su
#                  $ ls -al ~/.ssh
#                      //* if id_rsa and id_rsa.pub dont exist, then we will create new ssh keys. ~/.ssh equals /root/.ssh
#               2) Create new ssh keys
#                  $ sudo su
#                  $ ssh-keygen -t rsa
#                       //* accept the default for all questions
#               3) copy the public key
#                  $ sudo su
#                  $ nano ~/.ssh/id_rsa.pub
#                      //* copy the content into the clipboard
#               4) log into the github.com using a <Username> account
#               5) go to "Account" icon -> Settings -> SSH and GPG keys -> "New SSH key" -> name the key using the $HOSTNAME of this server, and paste the clipboard into the key box -> "Add SSH key"
#               6) Ensure that the remote origin is using SSH instead of HTTP
#                  $ cd $vdir1
#                      //* replace $vdir1 with the path of the directory where the .git is installed (place where git init was made)
#                      //* I.E. cd /var/www/html
#                  $ git remote rm origin
#                  $ git remote add origin git+ssh://git@github.com/<Site>/$HOSTNAME.git
#                      //* replace $HOSTNAME with the hostname of this server
#                      //* I.E. git remote add origin git+ssh://git@github.com/<Site>/<Site>.<Domain>.git


#VARIABLES DECLARATION:
vdir1="/var/www/html"


#STARTING SCRIPT
[[ ":$PATH:" != *":/usr/local/git/bin:"* ]] && PATH="/usr/local/git/bin:${PATH}"
cd $vdir1
var1=$(git status | grep "nothing to commit" -o)
if [[ $var1 == "nothing to commit" ]] ; then 
   echo "Nothing to commit or push"
else
   git add *
   vmessage1=$HOSTNAME'-Auto-Push made on:'$(date "+%Y-%m-%d")
   git commit -m "$vmessage1"
   git push origin master
   echo "Changes pushed to https://github.com/<Site>/"$HOSTNAME".git"
fi