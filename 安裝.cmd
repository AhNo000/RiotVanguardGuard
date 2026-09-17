@echo off
setlocal
cd /d "%~dp0"

echo Riot Vanguard Guard installer
echo.
echo This version keeps guard.log in THIS folder.
echo Do not move or rename this folder after installation.
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0Install-RiotVanguardGuard.ps1""'"

echo.
echo ----------------------------------------
echo Installer finished.
echo guard.log will appear in this folder after the watcher starts.
echo ----------------------------------------
echo.
pause
