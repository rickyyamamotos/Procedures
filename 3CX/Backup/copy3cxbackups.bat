@echo off
cls
echo copying 3cx backups to \\<Site>\backupserver\3CX
echo please wait...
xcopy c:\backups\*.* \\<Site>\backupserver\3CX /d
cls

