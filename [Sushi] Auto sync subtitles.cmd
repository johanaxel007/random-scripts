@echo off

set /p "srcdir=Source directory: "
set /p "srcvid=Source video: "
set /p "srcscript=Source script: "

set /p "destdir=Destination directory: "
set /p "destvid=Destination video: "

@echo on
.\sushi.exe --src "%srcdir%\%srcvid%" --dst "%destdir%\%destvid%" --script "%srcdir%\%srcscript%"