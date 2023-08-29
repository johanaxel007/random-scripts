@Echo OFF
set /p "processid=Enter PID: "

taskkill /F /T /PID %processid%

pause