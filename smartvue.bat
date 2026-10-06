@echo off
setlocal

REM ============================================================
REM ARGUMENT
REM %1 = Server / IP
REM %2 = SMB Username
REM %3 = SMB Password
REM ============================================================

set "SERVER=%~1"
set "SMBUSER=%~2"
set "SMBPASS=%~3"

set "SMARTVUDIR=C:\Program Files (x86)\Survalent\SmartVU"
set "APPNAME=SmartVU2.exe"

set "LOGDIR=C:\Users\Public\SmartVULogs"
set "LOG=%LOGDIR%\SmartVU_SMB_Login.log"

if not exist "%LOGDIR%" mkdir "%LOGDIR%"

echo ============================================================ > "%LOG%"
echo SmartVU SMB Launcher >> "%LOG%"
echo Date   : %date% %time% >> "%LOG%"
echo User   : %USERDOMAIN%\%USERNAME% >> "%LOG%"
echo Server : %SERVER% >> "%LOG%"
echo App    : %APPNAME% >> "%LOG%"
echo ============================================================ >> "%LOG%"

echo. >> "%LOG%"
echo [1] SMB LOGIN >> "%LOG%"

net use \\%SERVER%\IPC$ "%SMBPASS%" /user:"%SMBUSER%" /persistent:no >> "%LOG%" 2>&1

set "RC=%ERRORLEVEL%"
echo SMB ErrorLevel=%RC% >> "%LOG%"

if not "%RC%"=="0" (
    echo SMB LOGIN FAILED >> "%LOG%"
    exit /b %RC%
)

echo SMB LOGIN OK >> "%LOG%"

echo. >> "%LOG%"
echo [2] CHANGE DIRECTORY >> "%LOG%"

cd /d "%SMARTVUDIR%" >> "%LOG%" 2>&1

set "RC=%ERRORLEVEL%"
echo CD ErrorLevel=%RC% >> "%LOG%"
echo CurrentDir=%CD% >> "%LOG%"

if not "%RC%"=="0" exit /b %RC%

echo. >> "%LOG%"
echo [3] CHECK APPLICATION >> "%LOG%"

dir "%APPNAME%" >> "%LOG%" 2>&1

set "RC=%ERRORLEVEL%"
echo App Check ErrorLevel=%RC% >> "%LOG%"

if not "%RC%"=="0" exit /b %RC%

echo. >> "%LOG%"
echo [4] START SMARTVU >> "%LOG%"
echo StartTime=%date% %time% >> "%LOG%"

start "" /wait "%APPNAME%"

set "RC=%ERRORLEVEL%"

echo. >> "%LOG%"
echo SmartVU ExitCode=%RC% >> "%LOG%"
echo EndTime=%date% %time% >> "%LOG%"

endlocal
exit /b %RC%
