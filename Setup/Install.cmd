@ECHO OFF

SETLOCAL

PUSHD "%~dp0"

CALL CreateStartupShortcut.cmd ..\WindowMenu.exe

POPD
