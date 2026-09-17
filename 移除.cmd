@echo off
setlocal
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0Uninstall-RiotVanguardGuard.ps1""'"

echo.
echo ----------------------------------------
echo Uninstaller finished.
echo Files and logs were NOT deleted.
echo ----------------------------------------
echo.
pause
