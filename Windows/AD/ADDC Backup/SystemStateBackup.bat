rem @echo off
rem backups are stored on //<Site>/$Y/WindowsImageBackup
SETLOCAL
SETLOCAL EnableExtensions
SETLOCAL EnableDelayedExpansion

set vwwwroot1=<Site>
set servername1=%computername%
set vdate1=%date:~10,4%-%date:~4,2%-%date:~7,2%
set vtime1=%time: =0%
set vtime1=%vtime1:~0,8%

rem C:\Windows\System32\wbadmin.exe start systemstatebackup -quiet -backuptarget:Y:
C:\Windows\System32\wbadmin.exe start systemstatebackup -backuptarget:Y:  >> c:\temp\wbadmin.log


IF NOT %ERRORLEVEL%==0 (
   echo "Windows Backup failed to create a System State Backup for <Site> - AD with error code: %ERRORLEVEL%" 

set vtime3=!time!
echo !vtime3!


   echo eval "/bin/echo %vdate1% %vtime1% %date:~10,4%-%date:~4,2%-%date:~7,2% !vtime3! EDT WindowsBackup %vwwwroot1% Error:wbadmin failed with exit code %ERRORLEVEL% >> /mnt/shares/drobo/backupserver.log" > c:\temp\ssh.cmd
   putty -P <PortNumber> <Username>@XXX.XXX.XXX.243 -pw <Password> -m c:\temp\ssh.cmd
   del /Q c:\temp\ssh.cmd
   sendEmail -vv -o tls=yes -m "Error on %date% when backing up System State from %vwwwroot1%. wbadmin failed with error code %ERRORLEVEL%" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "(%vwwwroot1%):c:\SystemStateBackup.bat Error: wbadmin error %ERRORLEVEL%" >> c:\temp\sendEmail.log
) ELSE (
   echo "Backup of sites successfully"
   echo "Rick1: Backup of sites successfully" >> c:\temp\wbadmin.log

set vtime3=!time!
echo !vtime3!

   echo eval "/bin/echo %vdate1% %vtime1% %date:~10,4%-%date:~4,2%-%date:~7,2% !vtime3! EDT StateBackup %vwwwroot1% Success: Backed up <Site> >> /mnt/shares/drobo/backupserver.log" > c:\temp\ssh.cmd
   putty -P <PortNumber> <Username>@XXX.XXX.XXX.243 -pw <Password> -m c:\temp\ssh.cmd
   del /Q c:\temp\ssh.cmd
   sendEmail -vv -o tls=yes -m "Successfully backed up System State from %vwwwroot1% to <Location>\<Site>:Y:\WindowsImageBackup\%vwwwroot1%\SystemStateBackup\ .\nY: is a mounted iSCI volume of XXX.XXX.XXX.40 in <Site> drive\n $vdate1\n See <Location>Office\\XXX.XXX.XXX.87\backup\restore-procedure.txt for instructions to restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "(%vwwwroot1%):Successful backup of System State Backup was made on %vdate1%" >> c:\temp\sendEmail.log
   rem Deleting old backups, keeping only the last 2 ones because they are huge (20+ Gb)


   C:\Windows\System32\wbadmin.exe delete systemstatebackup -quiet -keepVersions:5

)

echo "Rick2: Backup of sites successfully" >> c:\temp\wbadmin.log
exit
