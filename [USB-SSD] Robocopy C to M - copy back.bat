@echo off
rem Copies C:\!\AI Tools back to the freshly formatted M: drive (Strata stays on C:\AI Tools).
rem Safe to re-run: files that already match (size + timestamp) are skipped.
rem Same settings as _copy-from-M.bat: restartable, retry every 30 s for ~4 h per file, single thread,
rem links skipped (Unsloth's transformers-cache link is recreated on M: afterwards).

title Robocopy C:\!\AI Tools to M:\AI Tools
robocopy "C:\!\AI Tools" "M:\AI Tools" /E /Z /COPY:DAT /DCOPY:DAT /XJ /R:500 /W:30 ^
  /NP /NDL /TEE /UNILOG+:"%~dpn0.log"
set RC=%ERRORLEVEL%

echo.
if %RC% LSS 8 (echo Robocopy finished OK, exit code %RC%.) else (echo Robocopy reported FAILURES, exit code %RC%. See "%~dpn0.log")
pause
