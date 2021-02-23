@echo off
cls
ECHO "SOME FILE IN C:\IIS\ ARE ENCRYPTED AND ONLY THE <Username> CAN READ THOSE FILES. YOU NEED TO RUN THIS SCRIPT AS THE <Username> USER

echo "Requirements: wwwroot, servername, dbname, dbuser, dbpassword, vdiis, vdmssql"
set vwwwroot1=<Site>
set servername1=%computername%
set dbname1=xxx
set username1=xxx
set Password<Password>
set vipaddress1=""
for /f "s=14" %%a in ('ipconfig ^| findstr IPv4') do set vipaddress1=%%a
echo "Set vdmssql & vdiis with a number from 1 to 8, 1 for monday, 8 for everyday
set vdmssql=0
set vdiis=2

echo "Other Requirements:
echo "Windows Server 2008R2 SP1+ and .Net 2.0 SP1+ for msdeploy to work"
echo "* Connect at least 1 time using PSCP to <Username>@XXX.XXX.XXX.243 to save the ssh key locally
echo "* IIS 6+ on the source and target servers" Comment/Uncomment the "Backing UP Directories, this may take some minutes" section for IIS 6 or 7+
echo "* SQL if used by the IIS App"
echo "* Installing Web Deploy  on the source and target servers from http://www.iis.net/downloads/microsoft/web-deploy"
echo "* Install putty. It includes PSCP. https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.70-installer.msi"
echo "* Name of database, Name of the Source and Target Servers, credentials to SQL"
echo "* Download and unizp sendEmail.exe from http://caspian.dotconf.net/menu/Software/SendEmail/sendEmail-v156.zip, copy it to c:\windows\system32"
echo "* Determine is IIS is using MSSQL. server -> IIS Manager -> Server Name -> Connection Strings -> Edit  OR server -> IIS Manager -> Server Name -> Sites -> SiteName -> Connection Strings -> Edit"
echo ""

set vdate1=%date:~10,4%-%date:~4,2%-%date:~7,2%
	rem date in the format YYYY-MM-DD
set vtime1=%time: =0%
set vtime2=%time: =0%
set vtime1=%vtime1:~0,8%
set vtime2=%vtime2:~0,8%

set DayOfWeek=%DATE:~0,3%
IF %DayOfWeek% == Mon set DayOfWeek=1
IF %DayOfWeek% == Tue set DayOfWeek=2
IF %DayOfWeek% == Wed set DayOfWeek=3
IF %DayOfWeek% == Thu set DayOfWeek=4
IF %DayOfWeek% == Fri set DayOfWeek=5
IF %DayOfWeek% == Sat set DayOfWeek=6
IF %DayOfWeek% == Sun set DayOfWeek=7
echo "today is the %DayOfWeek% day of the week"

echo "Creating a directory on the drobo storage"
mkdir c:\temp\
mkdir c:\%vwwwroot1%\
PSCP -P <PortNumber> -batch -r -pw <Password> c:\%vwwwroot1%\ <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/%vwwwroot1%/

set vtrue=0
IF %vdiis%==%DayOfWeek% set vtrue=1
IF %vdiis%==8 set vtrue=1
IF %vtrue%==1 (
   echo "Backing UP Directories, this may take some minutes"
   rem FOR IIS6 "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync  -source:metakey=lm/w3svc/1 -dest:package=c:\temp\%vdate1%-sites-%vwwwroot1%.zip,encryptpassword=<Password> > c:\temp\WebDeployPackage.log
   rem FOR IIS7+ "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync -source:webServer,computerName=%servername1% -dest:package=c:\temp\%vdate1%-sites-%vwwwroot1%.zip,encryptpassword=<Password> > c:\temp\WebDeployPackage.log
   "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync -source:webServer,computerName=%servername1% -dest:package=c:\temp\%vdate1%-sites-%vwwwroot1%.zip,encryptpassword=<Password> > c:\temp\WebDeployPackage.log
   IF NOT %ERRORLEVEL%==0 (
      echo "msdeploy failed with error code %ERRORLEVEL%. Sites backup not performed"
      set vtime2=%time: =0%
      set vtime2=%vtime2:~0,8%
      echo eval "/bin/echo %vdate1% %vtime1% %date:~10,4%-%date:~4,2%-%date:~7,2% %vtime2% EDT IIS %vwwwroot1% Error:msdeploy failed with exit code %ERRORLEVEL% >> /mnt/shares/drobo/backupserver.log" > c:\temp\ssh.cmd
      putty -P <PortNumber> <Username>@XXX.XXX.XXX.243 -pw <Password> -m c:\temp\ssh.cmd
      del /Q c:\temp\ssh.cmd
      sendEmail -vv -o tls=yes -m "Error on %date% when backing up IIS sites data from %vwwwroot1%. Msdeploy failed with error code %ERRORLEVEL%" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "%vwwwroot1% (%vipaddress1%):c:\backupiisApp.bat Error: msdeploy error %ERRORLEVEL%" >> c:\temp\sendEmail.log
   ) ELSE (
      echo ""
      echo "Transmitting Directories to Drobo"
      PSCP -P <PortNumber> -batch -pw <Password> c:\temp\%vdate1%-sites-%vwwwroot1%.zip <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/%vwwwroot1%/ > c:\temp\pscp.log
      IF NOT %ERRORLEVEL%==0 (
         echo "Transmission of backup to the office drobo failed with error code %ERRORLEVEL%. Backup deleted"
         set vtime2=%time: =0%
         set vtime2=%vtime2:~0,8%
         echo eval "/bin/echo %vdate1% %vtime1% %date:~10,4%-%date:~4,2%-%date:~7,2% %vtime2% EDT IIS %vwwwroot1% Error:pscp failed with exit code %ERRORLEVEL% >> /mnt/shares/drobo/backupserver.log" > c:\temp\ssh.cmd
         putty -P <PortNumber> <Username>@XXX.XXX.XXX.243 -pw <Password> -m c:\temp\ssh.cmd
         del /Q c:\temp\ssh.cmd
         sendEmail -vv -o tls=yes -m "Error on %date% when transmitting IIS sites data backup file from %vwwwroot1% to the office drobo. PSCP failed with error code %ERRORLEVEL%" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "%vwwwroot1% (%vipaddress1%):c:\backupiisApp.bat Error: PSCP error %ERRORLEVEL%" >> c:\temp\sendEmail.log
      ) ELSE (
         echo "Backup of sites successfully"
         set vtime2=%time: =0%
         set vtime2=%vtime2:~0,8%
         echo eval "/bin/echo %vdate1% %vtime1% %date:~10,4%-%date:~4,2%-%date:~7,2% %vtime2% EDT IIS %vwwwroot1% Success: Backed up IIS >> /mnt/shares/drobo/backupserver.log" > c:\temp\ssh.cmd
         putty -P <PortNumber> <Username>@XXX.XXX.XXX.243 -pw <Password> -m c:\temp\ssh.cmd
         del /Q c:\temp\ssh.cmd
         sendEmail -vv -o tls=yes -m "Successfully backed up IIS sites of %vwwwroot1% to <Location>\\XXX.XXX.XXX.87\backup\%vwwwroot1%\%vdate1%-sites-%vwwwroot1%.zip.\n $vvdate1\n See <Location>Office\\XXX.XXX.XXX.87\backup\restore-procedure.txt for instructions to restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "%vwwwroot1% (%vipaddress1%):Successful backup of IIS sites was made on %vdate1%" >> c:\temp\sendEmail.log
      )
   )
   del /Q c:\temp\%vdate1%-sites-%vwwwroot1%.zip
)


set vtrue=0
IF %vdmssql%==%DayOfWeek% set vtrue=1
IF %vdmssql%==8 set vtrue=1
IF %vtrue%==1 (
   echo "Backing UP SQL Database, this may take some minutes"
   "C:\Program Files\IIS\Microsoft Web Deploy V3\msdeploy.exe" -verb:sync -source:dbFullSql="data source=%servername1%;Initial Catalog=%dbname1%;User ID=%username1%;Password=%<Password>%;User Instance=False;" -dest:package="c:\temp\%vdate1%-sql-%vwwwroot1%.zip" > c:\temp\WebDeployPackage.log
      rem replace data source's value with source server name
      rem replace Initial Catalog's value with database name, look inside php files for "connection" the IIS directory
      rem replace user and password
   IF NOT %ERRORLEVEL%==0 (
      echo "msdeploy failed with error code %ERRORLEVEL%. Database backup not performed"
      set vtime2=%time: =0%
      set vtime2=%vtime2:~0,8%
      echo eval "/bin/echo %vdate1% %vtime1% %date:~10,4%-%date:~4,2%-%date:~7,2% %vtime2% EDT SQL %vwwwroot1% Error:msdeploy failed with exit code %ERRORLEVEL% >> /mnt/shares/drobo/backupserver.log" > c:\temp\ssh.cmd
      putty -P <PortNumber> <Username>@XXX.XXX.XXX.243 -pw <Password> -m c:\temp\ssh.cmd
      del /Q c:\temp\ssh.cmd
      sendEmail -vv -o tls=yes -m "Error on %date% when backing up IIS database data from %vwwwroot1%. Msdeploy failed with error code %ERRORLEVEL%" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "%vwwwroot1% (%vipaddress1%):c:\backupiisApp.bat Error: msdeploy error %ERRORLEVEL%" >> c:\temp\sendEmail.log
   ) ELSE (
      echo ""
      echo "Transmitting Directories to Drobo"
      PSCP -P <PortNumber> -batch -pw <Password> c:\temp\%vdate1%-sql-%vwwwroot1%.zip <Username>@XXX.XXX.XXX.243:/mnt/shares/drobo/%vwwwroot1%/ > c:\temp\pscp.log
      IF NOT %ERRORLEVEL%==0 (
         echo "Transmission of backup to the office drobo failed with error code %ERRORLEVEL%. Backup deleted"
         set vtime2=%time: =0%
         set vtime2=%vtime2:~0,8%
         echo eval "/bin/echo %vdate1% %vtime1% %date:~10,4%-%date:~4,2%-%date:~7,2% %vtime2% EDT SQL %vwwwroot1% Error:pscp failed with exit code %ERRORLEVEL% >> /mnt/shares/drobo/backupserver.log" > c:\temp\ssh.cmd
         putty -P <PortNumber> <Username>@XXX.XXX.XXX.243 -pw <Password> -m c:\temp\ssh.cmd
         del /Q c:\temp\ssh.cmd
         sendEmail -vv -o tls=yes -m "Error on %date% when transmitting IIS database data backup file from %vwwwroot1% to the office drobo. PSCP failed with error code %ERRORLEVEL%" -f <Email> -t <Email> -cc <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "%vwwwroot1% (%vipaddress1%):c:\backupiisApp.bat Error: PSCP error %ERRORLEVEL%" >> c:\temp\sendEmail.log
      ) ELSE (
         echo "Backup of sites successfully"
         set vtime2=%time: =0%
         set vtime2=%vtime2:~0,8%
         echo eval "/bin/echo %vdate1% %vtime1% %date:~10,4%-%date:~4,2%-%date:~7,2% %vtime2% EDT SQL %vwwwroot1% Success: Backed up SQL >> /mnt/shares/drobo/backupserver.log" > c:\temp\ssh.cmd
         putty -P <PortNumber> <Username>@XXX.XXX.XXX.243 -pw <Password> -m c:\temp\ssh.cmd
         del /Q c:\temp\ssh.cmd
         sendEmail -vv -o tls=yes -m "Successfully backed up IIS database of %vwwwroot1% to <Location>\\XXX.XXX.XXX.87\backup\%vwwwroot1%\%vdate1%-sql-%vwwwroot1%.zip.\n $vvdate1\n See <Location>Office\\XXX.XXX.XXX.87\backup\restore-procedure.txt for instructions on restore the backup" -f <Email> -t <Email> -s smtp.gmail.com:587 -xu <Email> -xp <Password> -u "%vwwwroot1% (%vipaddress1%):Successful backup of IIS sites was made on %vdate1%" >> c:\temp\sendEmail.log
      )
   )
   del /Q c:\temp\%vdate1%-sql-%vwwwroot1%.zip
)


