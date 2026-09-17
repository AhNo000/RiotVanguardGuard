# Install-RiotVanguardGuard.ps1
# Run as Administrator once. This version runs in-place.

#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

$TaskName = 'Riot Vanguard Guard'
$ScriptPath = Join-Path $PSScriptRoot 'RiotVanguardGuard.ps1'

if (-not (Test-Path $ScriptPath)) {
    throw "Cannot find $ScriptPath"
}

$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$action = New-ScheduledTaskAction `
    -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`""

$trigger = New-ScheduledTaskTrigger -AtLogOn -User $currentUser

$principal = New-ScheduledTaskPrincipal `
    -UserId $currentUser `
    -LogonType Interactive `
    -RunLevel Highest

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Description 'Watches Riot process launches and ensures the vgc service is Automatic and Running.' `
    -Force | Out-Null

Start-ScheduledTask -TaskName $TaskName

Write-Host ''
Write-Host 'Installed: Riot Vanguard Guard'
Write-Host "Task: $TaskName"
Write-Host "Script: $ScriptPath"
Write-Host "Log: $(Join-Path $PSScriptRoot 'guard.log')"
Write-Host ''
Write-Host 'IMPORTANT: Do not move or rename this folder after installation.'
