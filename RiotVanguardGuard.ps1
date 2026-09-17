# RiotVanguardGuard.ps1
# Watches for Riot Client / Riot game process launches.
# Log file is stored beside this script.

$ErrorActionPreference = 'Continue'

$BaseDir = $PSScriptRoot
$LogPath = Join-Path $BaseDir 'guard.log'

function Rotate-Log {
    try {
        if (Test-Path $LogPath) {
            $item = Get-Item $LogPath -ErrorAction Stop
            if ($item.Length -gt 2MB) {
                $old = Join-Path $BaseDir 'guard.old.log'
                Remove-Item $old -Force -ErrorAction SilentlyContinue
                Move-Item $LogPath $old -Force
            }
        }
    } catch {}
}

function Write-Log {
    param([string]$Message)
    Rotate-Log
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -LiteralPath $LogPath -Value $line -Encoding UTF8
}

$KnownRiotProcesses = @(
    'RiotClientServices.exe',
    'RiotClientUx.exe',
    'RiotClientUxRender.exe',
    'LeagueClient.exe',
    'LeagueClientUx.exe',
    'LeagueClientUxRender.exe',
    'League of Legends.exe',
    'VALORANT.exe',
    'VALORANT-Win64-Shipping.exe',
    'LoR.exe',
    '2XKO.exe'
)

function Test-IsRiotProcess {
    param(
        [uint32]$ProcessId,
        [string]$ProcessName
    )

    if ($KnownRiotProcesses -contains $ProcessName) {
        return $true
    }

    try {
        $p = Get-CimInstance Win32_Process -Filter "ProcessId = $ProcessId" -ErrorAction Stop
        if ($p.ExecutablePath -and $p.ExecutablePath -match '\\Riot Games\\') {
            return $true
        }
    } catch {}

    return $false
}

function Ensure-Vgc {
    param([string]$Reason)

    try {
        $svcInfo = Get-CimInstance Win32_Service -Filter "Name='vgc'" -ErrorAction Stop
    } catch {
        Write-Log "ERROR: vgc service not found. Trigger=$Reason"
        return
    }

    $beforeMode = $svcInfo.StartMode
    $beforeState = $svcInfo.State

    if ($svcInfo.StartMode -ne 'Auto') {
        try {
            & sc.exe config vgc start= auto | Out-Null
            Write-Log "Changed vgc startup type: $beforeMode -> Auto. Trigger=$Reason"
        } catch {
            Write-Log "ERROR: failed to set vgc startup type to Automatic. $($_.Exception.Message)"
        }
    }

    try {
        $svc = Get-Service -Name vgc -ErrorAction Stop
        if ($svc.Status -ne 'Running') {
            Start-Service -Name vgc -ErrorAction Stop
            $svc.WaitForStatus('Running', [TimeSpan]::FromSeconds(10))
            Write-Log "Started vgc service. PreviousState=$beforeState Trigger=$Reason"
        }
    } catch {
        Write-Log "ERROR: failed to start vgc. Trigger=$Reason Error=$($_.Exception.Message)"
        return
    }

    try {
        $after = Get-CimInstance Win32_Service -Filter "Name='vgc'" -ErrorAction Stop
        Write-Log "vgc check complete: StartMode=$($after.StartMode), State=$($after.State), Trigger=$Reason"
    } catch {}
}

function Check-ExistingRiotProcess {
    try {
        foreach ($p in Get-CimInstance Win32_Process -ErrorAction Stop) {
            if (Test-IsRiotProcess -ProcessId ([uint32]$p.ProcessId) -ProcessName ([string]$p.Name)) {
                Ensure-Vgc "existing process: $($p.Name) PID=$($p.ProcessId)"
                return
            }
        }
    } catch {
        Write-Log "ERROR while checking existing processes: $($_.Exception.Message)"
    }
}

Write-Log 'Watcher started.'
Check-ExistingRiotProcess

$query = 'SELECT * FROM Win32_ProcessStartTrace'
$watcher = New-Object System.Management.ManagementEventWatcher $query

try {
    $watcher.Start()
    while ($true) {
        $event = $watcher.WaitForNextEvent()
        $name = [string]$event.ProcessName
        $pidValue = [uint32]$event.ProcessID

        if (Test-IsRiotProcess -ProcessId $pidValue -ProcessName $name) {
            Ensure-Vgc "process start: $name PID=$pidValue"
        }
    }
}
catch {
    Write-Log "WATCHER ERROR: $($_.Exception.Message)"
    throw
}
finally {
    try { $watcher.Stop() } catch {}
    try { $watcher.Dispose() } catch {}
    Write-Log 'Watcher stopped.'
}
