@echo off
rem Copies everything from the unstable M: drive to C:\! with robocopy.
rem Safe to re-run: files that already match (size + timestamp) are skipped.
rem
rem /E          all subfolders, including empty ones
rem /Z          restartable mode: a large file resumes where it stopped after a disconnect
rem /R:500 /W:30  on an error (drive gone) retry every 30 s, up to ~4 h per file
rem /XJ         do not follow junctions
rem no /MT      single thread = low queue depth, gentlest on the flaky USB bridge
rem /COPY:DAT /DCOPY:DAT  data, attributes and timestamps (no NTFS security, avoids ACL issues)

title Robocopy M:\ to C:\!
robocopy M:\ "C:\!" /E /Z /COPY:DAT /DCOPY:DAT /XJ /R:500 /W:30 ^
  /XD "M:\$RECYCLE.BIN" "M:\System Volume Information" ^
  /NP /NDL /TEE /UNILOG+:"%~dpn0.log"
set RC=%ERRORLEVEL%

rem Copying a drive root can mark the destination folder hidden + system: undo that.
attrib -h -s "C:\!"

echo.
if %RC% LSS 8 (echo Robocopy finished OK, exit code %RC%.) else (echo Robocopy reported FAILURES, exit code %RC%. See "%~dpn0.log")
pause
