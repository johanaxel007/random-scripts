@Echo OFF
set /p "timeInSeconds=Enter time in seconds: "
timeout %timeInSeconds% && shutdown /h