# Watchdog for the M: -> C:\! robocopy run (run elevated, in its own window).
# - "Healthy" means: the Intenso shows up as a storage disk AND volume M: is mounted.
#   (The PnP device list alone is not enough: when the USB bridge firmware hangs, PnP still
#   shows the disk as OK while the storage stack has lost it.)
# - On a drop-out it tries software recovery with time limits on every step:
#   rescan -> remove failed "Unknown USB device" entries + rescan -> restart USB bridge.
#   A hung bridge usually refuses the restart; then it reports NEEDS REPLUG.
# - Detects a stalled copy (robocopy reads nothing for $StallSec while M: looks healthy).
# - Puts the volume back on M: if it returns under another letter.
# - Logs to <this script>.log and exits when robocopy is gone.

param([string]$CopyLog = '')   # optional: robocopy log whose summary goes into the DONE line
$Log       = $PSCommandPath -replace '\.ps1$', '.log'
$Bridge    = 'USB\VID_2109&PID_0716\MSFT302025091910000612'   # VIA VL716 USB-SATA bridge of the Intenso
$StallSec  = 240
$ProgressEveryMin = 15

function Say($msg) {
    $line = '{0:yyyy-MM-dd HH:mm:ss} {1}' -f (Get-Date), $msg
    Add-Content -LiteralPath $Log -Value $line
    Write-Host $line
}
# Run a scriptblock in a separate process-backed job with a time limit; returns $null on timeout.
function Timed([scriptblock]$sb, [int]$sec, $arg) {
    $j = Start-Job -ScriptBlock $sb -ArgumentList $arg
    if (Wait-Job $j -Timeout $sec) { $r = Receive-Job $j; Remove-Job $j -Force; return $r }
    Stop-Job $j -EA SilentlyContinue; Remove-Job $j -Force -EA SilentlyContinue; return $null
}
# Returns 'ok', 'letter:<X>' (mounted elsewhere), 'nodisk', or 'timeout'.
function State {
    $r = Timed {
        $d = Get-Disk -EA SilentlyContinue | Where-Object FriendlyName -like 'Intenso TX100*'
        if (-not $d) { return 'nodisk' }
        $v = Get-Volume -EA SilentlyContinue | Where-Object FileSystemLabel -like 'Intenso*' | Select-Object -First 1
        if (-not $v -or -not $v.DriveLetter) { return 'nodisk' }
        if ($v.DriveLetter -ne 'M') { return "letter:$($v.DriveLetter)" }
        'ok'
    } 25
    if ($null -eq $r) { 'timeout' } else { "$r" }
}
function RoboRead {
    $p = Get-Process robocopy -EA SilentlyContinue | Select-Object -First 1
    if ($p) { (Get-CimInstance Win32_Process -Filter "ProcessId=$($p.Id)" -EA SilentlyContinue).ReadTransferCount } else { $null }
}
function WaitOk($sec) { $end = (Get-Date).AddSeconds($sec); while ((Get-Date) -lt $end) { $s = State; if ($s -ne 'nodisk' -and $s -ne 'timeout') { return $s }; Start-Sleep 3 }; return $null }
function FixLetter($s) {
    if ($s -like 'letter:*') {
        $r = Timed { $p = Get-Disk | Where-Object FriendlyName -like 'Intenso TX100*' | Get-Partition | Where-Object Type -eq 'Basic' | Select-Object -First 1
                     try { $p | Set-Partition -NewDriveLetter M -EA Stop; 'moved' } catch { $_.Exception.Message } } 30
        Say "LETTER volume came back as $($s.Substring(7)): -> move to M: result: $r"
    }
}
function Reconnect {
    Say 'RECOVER step 1: rescan devices'
    Timed { pnputil /scan-devices | Out-Null; 'done' } 30 | Out-Null
    $s = WaitOk 20; if ($s) { return @('rescan', $s) }

    $failed = Get-PnpDevice -PresentOnly -EA SilentlyContinue | Where-Object InstanceId -like 'USB\VID_0000*'
    foreach ($f in $failed) {
        Say "RECOVER step 2: removing failed device '$($f.FriendlyName)'"
        Timed { param($id) pnputil /remove-device "$id" | Out-Null; 'done' } 30 $f.InstanceId | Out-Null
    }
    Timed { pnputil /scan-devices | Out-Null; 'done' } 30 | Out-Null
    $s = WaitOk 25; if ($s) { return @('remove failed device + rescan', $s) }

    # No bridge / root hub restart: when the bridge firmware hangs it stalls the whole USB
    # controller, a restart request just blocks, and only a power cycle (replug) helps.
    return $null
}

Say 'WATCH started (v2)'
$lastRead = RoboRead; $lastChange = Get-Date; $lastProgress = Get-Date; $fails = 0

while ($true) {
    $read = RoboRead
    if ($null -eq $read) {
        $sum = if ($CopyLog) { Select-String -LiteralPath $CopyLog -Pattern '^\s*(Dirs|Files|Bytes)\s*:' -EA SilentlyContinue | Select-Object -Last 3 | ForEach-Object { $_.Line.Trim() } }
        Say ('DONE robocopy has exited. ' + ($sum -join ' | '))
        break
    }

    $s = State
    if ($s -ne 'ok') {
        if ($s -like 'letter:*') { FixLetter $s; Start-Sleep 5; continue }
        Say "DROPPED M: is not usable (state: $s)"
        $back = WaitOk 15
        if ($back) { Say 'RECONNECTED on its own'; FixLetter $back; $fails = 0 }
        else {
            $res = Reconnect
            if ($res) { Say "RECONNECTED via $($res[0])"; FixLetter $res[1]; $fails = 0 }
            else {
                $fails++; Say "NEEDS REPLUG software reconnect failed (attempt $fails): unplug and replug the drive"
                $back = WaitOk 600   # wait up to 10 min for a manual replug
                if ($back) { Say 'RECONNECTED after replug'; FixLetter $back; $fails = 0 }
            }
        }
        $lastChange = Get-Date; $lastRead = RoboRead
        continue
    }

    if ($read -ne $lastRead) { $lastRead = $read; $lastChange = Get-Date }
    elseif (((Get-Date) - $lastChange).TotalSeconds -gt $StallSec) {
        Say "STALL robocopy read nothing for $StallSec s while M: looks mounted"
        $lastChange = Get-Date
    }

    if (((Get-Date) - $lastProgress).TotalMinutes -ge $ProgressEveryMin) {
        Say ('PROGRESS robocopy has read {0:N1} GB in total' -f ($read / 1GB)); $lastProgress = Get-Date
    }
    Start-Sleep 5
}
