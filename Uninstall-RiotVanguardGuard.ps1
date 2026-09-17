# Uninstall-RiotVanguardGuard.ps1
# Run as Administrator once.

#Requires -RunAsAdministrator
$ErrorActionPreference = 'SilentlyContinue'

$TaskName = 'Riot Vanguard Guard'

Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue

Write-Host 'Riot Vanguard Guard scheduled task removed.'
Write-Host 'Your files and logs in this folder were kept.'
