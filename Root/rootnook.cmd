@echo off

setlocal enabledelayedexpansion
:: check if its called from external script
if not defined TMPD (
    set PATH=bin;!PATH!
    set TMPD=/data/local/tmp/.nookrooter
    adb start-server >NUL
    for /f %%i in ('adb devices -l ^| find "BNRV700"') do set ANDROID_SERIAL=%%i
) 
setlocal disabledelayedexpansion

set XBINF=su supolicy busybox

if defined ANDROID_SERIAL goto :next
echo ADB not connected?
goto :end

:next

for /f %%i in ('adb shell su -c busybox id -u') do set UID=%%i
if x%UID% == x0 for /f %%l in ('adb shell "test -e /data/data/eu.chainfire.supersu || echo 1"') do set SSU=%%l
echo(
if defined SSU (
    echo Already rooted, but SuperSU not found.
) else (
    if x%UID% == x0 (
        echo Already rooted.
        goto :end
    ) 
)
echo(

adb shell rm -rf %TMPD%
adb push files %TMPD%
adb shell pm install -r %TMPD%/eu.chainfire.supersu.apk
adb shell sh %TMPD%/doroot.sh adbhack >NUL

echo(
echo | set /p tmp=Restarting adbd as root... 
for /f %%i in ('adb wait-for-device shell %TMPD%/busybox id -u') do set UID=%%i
if NOT x%UID% == x0 (
    echo(
    echo Failed to get root privilege, exiting.
    pause
    exit
)

set SUCCESS=1

echo(
adb shell "XBINF='%XBINF%' sh %TMPD%/doroot.sh"

:end
echo %cmdcmdline% | findstr /i /c:"System32\cmd.exe" | findstr /i /c:"%~f0" >NUL && ( 
    if defined SUCCESS echo Rooted.
    pause
) || if defined SUCCESS (
    echo | set /p tmp=Rooted, restarting adbd... 
    adb wait-for-device
    echo(
)

