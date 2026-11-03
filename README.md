## Online tools
- [7zip cli command generator](https://axelstudios.github.io/7z/#!/)

## [USB-SSD] tools (M: drive rescue, 2026-10-31)
Made while rescuing the unstable `M:` drive (Intenso TX100 in a VIA VL716 USB enclosure, UAS resets). Each script
writes its log next to itself (`<script name>.log`). Paths and IDs inside are for that drive: adjust them first.
- **Robocopy M to C [ADMIN].bat**: copy a flaky drive's root to `C:\!` - restartable (`/Z`), retries every 30 s for
  ~4 h per file (survives disconnects), single thread (gentlest on a weak USB bridge), skips junctions/symlinks. Re-run
  to resume: matching files are skipped.
- **Robocopy C to M.bat**: the same, for copying `C:\!\AI Tools` back to `M:\AI Tools`.
- **Watchdog [ADMIN].ps1**: run next to a robocopy. Every 5 s it checks that the drive is really usable (storage disk
  + mounted volume, not just listed by PnP), tries a software reconnect on a drop-out (rescan, remove failed
  "Unknown USB device" entries), says NEEDS REPLUG when the bridge firmware hangs (only a power cycle helps then),
  puts the volume back on its letter, and logs progress. `-CopyLog <robocopy log>` adds the summary at the end.
  Edit `$Bridge` (the enclosure's USB instance ID) and the `Intenso TX100` name for another drive.
- **Stress test [ADMIN].ps1**: writes N x 1 GiB unique files to a drive (default 400 to `M:\_stress`), dismounts the
  volume to drop the cache, reads every file back and compares SHA-256, then deletes them. Waits and retries on a
  drop-out. Watch the System log (UASPStor 129, disk 51/153) alongside it.
- **Verify HF model cache against Hub SHA-256.py**: `python -I "<script>" "<HF_HOME>\hub"` - hashes every LFS file in
  a Hugging Face cache (snapshots as real files) and compares it with the SHA-256 the Hub lists for that exact revision.
- **Fresco Logic FL1100 driver backup\\**: the official Fresco driver (3.8.35514.0), removed so the card uses
  Microsoft's driver (the Fresco one did not detect USB storage). Restore as admin:
  `pnputil /add-driver "<this folder>\*.inf" /install`