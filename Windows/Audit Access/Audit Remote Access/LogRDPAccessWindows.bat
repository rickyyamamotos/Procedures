echo off
cls
rem Script to email a notification when anybody log into the local windows computer
rem download and extract http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v156.zip into C:\sendEmail-v156
rem donwload and install putty from https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.71-installer.msi
rem save this script as C:\sendEmail-v156\LogRDPAccessWindows.bat
rem log into the server, run gpedit -> computer configuration -> Administrative templates -> System -> Logon -> Run these programs at user logon -> enable
	Add: C:\sendEmail-v156\LogRDPAccessWindows.bat
rem connect at least 1 time to XXX.XXX.XXX.243:<PortNumber> using putty to save the ssh key
rem t<Password>.exe is not available in some windows 2008 or earlier


set vemail1=<Email>
rem echo recipient's email is %vemail1%


set wwwroot1=%COMPUTERNAME%
set PAM_USER=%USERNAME%

for /F "s=2 delims=[]" %%q in ('ping -4 -n 1 %wwwroot1% ^|find /i "pinging"') do set vip1=%%q
rem echo RDP server ip is %vip1%

for /f "s=*" %%i in ('t<Password> /g') do set vtimezone1=%%i
rem echo local timezone is %vtimezone1%

set vremotepc=%CLIENTNAME%
for /F "s=2 delims=[]" %%q in ('ping -4 -n 1 %vremotepc% ^|find /i "pinging"') do set PAM_RHOST=%%q
rem echo remote client is %CLIENTNAME% with IP %PAM_RHOST%


FOR /F "s=* USEBACKQ" %%g IN (`plink -ssh -P <PortNumber> -pw <Password> -batch <Username>@XXX.XXX.XXX.243 "grep %%PAM_RHOST%% /mnt/shares/drobo/ssh-access-iplist.log"`) do (SET "vvar1=%%g")
	rem FOR /F "s=* USEBACKQ" %%g IN (`plink -ssh -P <PortNumber> -pw <Password> -batch <Username>@XXX.XXX.XXX.243 "grep XXX.XXX.XXX.19 /mnt/shares/drobo/ssh-access-iplist.log"`) do (SET "vvar1=%%g")
set vdateip1= %vvar1:~0,10%
rem echo vvar1=%vvar1%
rem echo vdateip1=%vdateip1%

set venv1=@XDG_SESSION_ID=XXX PAM_SERVICE=RDPs PAM_RHOST=%PAM_RHOST% PAM_USER=%PAM_USER% PAM_TTY=RDPs 

plink -ssh -P <PortNumber> -pw <Password> -batch <Username>@XXX.XXX.XXX.243 "/bin/echo $(date '+%%Y-%%m-%%d') $(TZ=US/Eastern date '+%%H:%%M:%%S') EDT %wwwroot1% %vip1% %PAM_RHOST% %PAM_USER% %vdateip1% @%venv1%@ >> /mnt/shares/drobo/ssh-access-audit.log"
rem if errorlevel 1 (
rem    C:\sendEmail-v156\sendEmail -f <Email> -t %vemail1% -u "Access to %COMPUTERNAME%(%vip1%)" -m "%USERNAME% logged on %COMPUTERNAME%(%vip1%) on %DATE% %TIME% %vtimezone1%" -s smtp.gmail.com:587 -xu <Email> -xp <Password> -vvv -o tls=yes
rem )


