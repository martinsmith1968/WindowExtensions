@ECHO OFF

SETLOCAL

SET APPNAME=WindowExtensions

PUSHD "%~dp0"

DEL "%APPNAME%_*.exe" /S /Q > NUL

CALL InnoSetupCompiler.cmd "%APPNAME%_Setup.iss"

POPD
