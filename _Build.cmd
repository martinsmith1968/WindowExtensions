@ECHO OFF

SETLOCAL EnableDelayedExpansion

PUSHD "%~dp0"

SET APPNAME=WindowExtensions
SET APPFILENAME=%APPNAME%.ahk
SET EXEFILENAME=%APPNAME%.exe
SET ICONFILENAME=Icons\windows.ico

CALL :ExtractVariable AppDescription "%APPFILENAME%"
CALL :ExtractVariable AppVersion "%APPFILENAME%"

REM GREP -i "^AppVersion" "%APPFILENAME%" | SED -e "s/:=/=/g" -e "s/ //g" -e "s/[a-z]/\U&/g" -e "s/^/@SET /g" -e "s/\""//g" > Version.cmd
REM CALL Version.cmd

SET ZIPFILENAME=%APPNAME%.%APPVERSION%.zip

CALL BuildAHK.cmd -b "%~n0" -a "%APPNAME%" -d "%APPDESCRIPTION%" -f "%APPFILENAME%" -e "%EXEFILENAME%" -i "%ICONFILENAME%" -v "%APPVERSION%" %1 -w 0

IF EXIST "%ZIPFILENAME%" DEL /Q "%ZIPFILENAME%"

ECHO.Building: %ZIPFILENAME%...
ZIP -v "%ZIPFILENAME%" "%APPNAME%.exe" "%APPNAME%.icl"

POPD

GOTO :EOF

:ExtractVariable
IF "%~1" == "" GOTO :EOF
IF "%~2" == "" GOTO :EOF

CALL BUILDUNIQUETEMPFILENAME.CMD "%~n0"

GREP -i "^%~1" "%~2" | SED -e "s/:=/=/g" -e "s/ //g" -e "s/[a-z]/\U&/g" -e "s/^/@SET /g" -e "s/\""//g" > "%UNIQUETEMPFILENAME%.cmd"
CALL "%UNIQUETEMPFILENAME%.cmd"

GOTO :EOF
