rem Script to email a notification when anybody log into the local windows computer
rem download and extract http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v156.zip into C:\sendEmail-v156
rem save this script as C:\sendEmail-v156\LogUserAccessWindows.bat
rem log into the local windows computer -> task Scheduler -> Create task -> triggers -> "on workstation unlock"
rem                                     -> Actions -> New -> Browse -> C:\sendEmail-v156\LogUserAccessWindows.bat

set vemail1=<Email>
echo recipient's email is %vemail1%

for /f "s=2 delims=[]" %%f in ('ping -4 -n 1 %COMPUTERNAME% ^|find /i "pinging"') do set vip1=%%f
echo local computer ip is %vip1%

for /f "s=*" %%i in ('t<Password> /g') do set vtimezone1=%%i
echo local timezone is %vtimezone1%


C:\sendEmail-v156\sendEmail -f <Email> -t %vemail1% -u "Access to %COMPUTERNAME%(%vip1%)" -m "%USERNAME% logged on %COMPUTERNAME%(%vip1%) on %DATE% %TIME% %vtimezone1%" -s smtp.gmail.com:587 -xu <Email> -xp <Password> -vvv -o tls=yes
