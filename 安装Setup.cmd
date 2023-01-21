@ECHO Installing Certificate
"%CD%\BIN\elevate" -w certutil -f -p "P@ss0wrd" -importpfx -v trustedpublisher "%CD%\BIN\signed.pfx"

@echo off
IF EXIST "c:\windows\sysnative\pnputil.exe" (
:Innosetup
    pushd "%CD%"
    CD /D "%~dp0"
ECHO ***** Innosetup ****
::***************************************************************************
for /f "delims=" %%i in ('dir .\Source\*.INF /s/b') do (
start /w %windir%\sysnative\pnputil.exe -i -a "%%~fi"
if /i not "%errorlevel%"=="0" goto :NG
)
goto :end
) else ( goto :manually)
:manually
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
ECHO ***** manually ****
::***************************************************************************
for /f "delims=" %%i in ('dir .\Source\*.INF /s/b') do (
start /w pnputil.exe -i -a "%%~fi"
if /i not "%errorlevel%"=="0" goto :NG
)
goto :end

:NG
echo Install Fail....
exit /b1

:end

