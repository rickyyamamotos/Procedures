vvar1=$(cat /etc/*-release | grep Ubuntu)
if [ ${#vvar1} -gt 0 ]; then
   sudo echo "puppet-agent install" | dpkg --set-selections
   sudo echo "puppet5-release install" | dpkg --set-selections
   dpkg --get-selections | grep puppet
fi
vvar1=$(cat /etc/*-release | grep CentOS)
if [ ${#vvar1} -gt 0 ]; then
   vvar2=$(yum versionlock list puppet-agent | grep puppet-agent)
   sudo yum versionlock delete $vvar2
   yum versionlock list
fi


