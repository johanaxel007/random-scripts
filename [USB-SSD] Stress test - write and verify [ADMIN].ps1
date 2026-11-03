# Write + verify stress test for the freshly formatted M: drive (run elevated, pwsh 7).
#   Phase 1: writes $Files x 1 GiB test files to M:\_stress\ (every 64 MiB chunk unique: random block + stamp),
#            recording each file's SHA-256 while writing.
#   Phase 2: dismounts M: (drops Windows' cache, so reads really come from the drive), reads every file back
#            and compares the hash.
# Survives drop-outs: on an I/O error it logs, waits for M: to come back and redoes that file.
# Log: <this script>.log (one line per event; progress every 10 files).
param([int]$Files = 400, [string]$Dir = 'M:\_stress', [string]$Log = ($PSCommandPath -replace '\.ps1$', '.log'))

$ErrorActionPreference = 'Stop'
$Chunk = 64MB; $PerFile = 1GB / $Chunk
function Say($m) { $l = '{0:yyyy-MM-dd HH:mm:ss} {1}' -f (Get-Date), $m; Add-Content -LiteralPath $Log -Value $l; Write-Host $l }
function WaitDrive {
    Say 'WAIT M: not usable, waiting for it to come back (replug if it froze)'
    $t0 = Get-Date
    while (-not (Test-Path 'M:\')) { Start-Sleep 5; if (((Get-Date) - $t0).TotalMinutes -gt 60) { Say 'ABORT M: gone for 60 min'; exit 2 } }
    Say "BACK M: usable again after $([int]((Get-Date) - $t0).TotalSeconds) s"
}

$block = [byte[]]::new($Chunk); [Security.Cryptography.RandomNumberGenerator]::Fill($block)
function Fill([int]$i, [int]$j) { [BitConverter]::GetBytes([long]$i).CopyTo($block, 0); [BitConverter]::GetBytes([long]$j).CopyTo($block, 8) }

New-Item -ItemType Directory -Force $Dir | Out-Null
$expected = @{}
Say "START write phase: $Files x 1 GiB to $Dir"
$sw = [Diagnostics.Stopwatch]::StartNew(); $done = 0
for ($i = 0; $i -lt $Files; $i++) {
    $path = Join-Path $Dir ('t{0:D4}.bin' -f $i)
    while ($true) {
        try {
            $h = [Security.Cryptography.IncrementalHash]::CreateHash('SHA256')
            $fs = [IO.FileStream]::new($path, 'Create', 'Write', 'None', 1MB, [IO.FileOptions]::WriteThrough)
            try { for ($j = 0; $j -lt $PerFile; $j++) { Fill $i $j; $fs.Write($block, 0, $Chunk); $h.AppendData($block) } }
            finally { $fs.Dispose() }
            $expected[$path] = [Convert]::ToHexString($h.GetHashAndReset()); break
        } catch { Say "IOERROR writing $path : $($_.Exception.Message)"; WaitDrive }
    }
    $done++
    if ($done % 10 -eq 0) { Say ('WRITE {0}/{1} files, avg {2:N0} MB/s' -f $done, $Files, ($done * 1024 / $sw.Elapsed.TotalSeconds)) }
}
$expected.GetEnumerator() | ForEach-Object { "$($_.Key) $($_.Value)" } | Set-Content -LiteralPath ($Log -replace '\.log$', '.hashes')
Say ('DONE write phase in {0:N0} min, avg {1:N0} MB/s' -f $sw.Elapsed.TotalMinutes, ($Files * 1024 / $sw.Elapsed.TotalSeconds))

Say 'DISMOUNT M: to drop the read cache'
fsutil volume dismount M: | Out-Null
Start-Sleep 5

Say 'START verify phase'
$sw.Restart(); $bad = 0; $n = 0
foreach ($path in ($expected.Keys | Sort-Object)) {
    while ($true) {
        try {
            $fs = [IO.FileStream]::new($path, 'Open', 'Read', 'Read', 4MB, [IO.FileOptions]::SequentialScan)
            try { $got = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($fs)) } finally { $fs.Dispose() }
            break
        } catch { Say "IOERROR reading $path : $($_.Exception.Message)"; WaitDrive }
    }
    if ($got -ne $expected[$path]) { $bad++; Say "MISMATCH $path" }
    $n++
    if ($n % 10 -eq 0) { Say ('VERIFY {0}/{1} files, {2} bad, avg {3:N0} MB/s' -f $n, $Files, $bad, ($n * 1024 / $sw.Elapsed.TotalSeconds)) }
}
Say ('DONE verify phase in {0:N0} min: {1} of {2} files bad' -f $sw.Elapsed.TotalMinutes, $bad, $Files)
Say 'CLEANUP deleting test files'
Remove-Item -LiteralPath $Dir -Recurse -Force
Say 'FINISHED'
