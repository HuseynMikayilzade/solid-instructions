@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\init-solidworks-workspace.ps1" %*
exit /b %ERRORLEVEL%
