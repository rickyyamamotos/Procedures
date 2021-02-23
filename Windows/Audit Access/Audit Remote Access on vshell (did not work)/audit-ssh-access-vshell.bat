echo off
cls
rem script to log ssh access to windows servers that have vshell service
rem requires putty to be installed
rem save this script as c:\audit-ssh-access-vshell.bat on the server with Vshell 
rem In this server, log into VshellCP.exe -> Triggers -> Select "Login" -> "Edit" -> check "Enable Trigger" -> command = "c:\audit-ssh-access-vshell.bat" -> paramenter = %I %U %D -> Click Ok -> Checl "Login" -> Click "Apply"
rem vshell parameters passed to this script
rem    %D Date of Occurrence
rem    %I IP address of user
rem    %T Time of Occurrence
rem    %U User

set PAM_RHOST=%1
set PAM_USER=%2
set venv1=%3
set venv1=%venv1% vshell logon
echo PAM_RHOST=%PAM_RHOST%
echo PAM_USER=%PAM_USER%
echo venv1=%venv1%

set wwwroot1=%COMPUTERNAME%
echo wwwroot1=%wwwroot1%

for /f "s=2 delims=[]" %%f in ('ping -4 -n 1 %wwwroot1% ^|find /i "pinging"') do set vip1=%%f
echo vip1=%vip1%

set vdateip1=""

FOR /F "s=* USEBACKQ" %%g IN (`plink -ssh -P <PortNumber> -pw <Password> -batch <Username>@XXX.XXX.XXX.243 "grep %%PAM_RHOST%% /mnt/shares/drobo/ssh-access-iplist.log"`) do (SET "vvar1=%%g")
	rem FOR /F "s=* USEBACKQ" %%g IN (`plink -ssh -P <PortNumber> -pw <Password> -batch <Username>@XXX.XXX.XXX.243 "grep XXX.XXX.XXX.19 /mnt/shares/drobo/ssh-access-iplist.log"`) do (SET "vvar1=%%g")
set vdateip1= %vvar1:~0,10%
echo vdateip1=%vdateip1%

echo plink -ssh -P <PortNumber> -pw <Password> -batch <Username>@XXX.XXX.XXX.243 "/bin/echo $(date '+%%Y-%%m-%%d') $(TZ=US/Eastern date '+%%H:%%M:%%S') EDT %wwwroot1% %vip1% %PAM_RHOST% %PAM_USER% %vdateip1% @%venv1%@ >> /mnt/shares/drobo/ssh-access-audit.log"
