@echo off
title Windows Maintenance and Repair Tool
color 0B

:: Ensure Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please right-click and "Run as Administrator".
    echo.
    pause
    exit /b
)

:MENU
cls
echo ========================================================
echo          ORIGINAL WINDOWS MAINTENANCE MENU
echo ========================================================
echo.
echo  [1] Core System Repair and Cleanup (DISM + SFC + Component Cleanup)
echo  [2] Deep Component Cleanup [EVERY 6 MONTHS] (/ResetBase)
echo  [3] Flush DNS Cache
echo  [4] System Reports (Driver List to Desktop + Perfmon Report)
echo  [5] Network Winsock Reset (Use ONLY if having network bugs)
echo  [6] Exit
echo.
echo ========================================================
set /p choice="Select an option (1-6): "

if "%choice%"=="1" goto COREREPAIR
if "%choice%"=="2" goto RESETBASE
if "%choice%"=="3" goto FLUSHDNS
if "%choice%"=="4" goto REPORTS
if "%choice%"=="5" goto WINSOCK
if "%choice%"=="6" goto END

echo Invalid selection, try again.
timeout /t 2 >nul
goto MENU

:COREREPAIR
cls
echo [1/3] Repairing Component Store...
dism /Online /Cleanup-Image /RestoreHealth
echo.
echo [2/3] Scanning and Repairing System Files...
sfc /scannow
echo.
echo [3/3] Cleaning Component Store...
dism /Online /Cleanup-Image /StartComponentCleanup
echo.
echo Core Repair and Maintenance Complete!
pause
goto MENU

:RESETBASE
cls
echo WARNING: This process resets the base of updated components.
echo After running this, you WILL NOT be able to uninstall current updates.
echo.
set /p confirm="Are you sure you want to proceed? (Y/N): "
if /i "%confirm%" neq "Y" goto MENU

echo.
echo Cleaning Component Store and Resetting Base...
dism /Online /Cleanup-Image /StartComponentCleanup /ResetBase
echo.
echo Deep Cleanup Complete!
pause
goto MENU

:FLUSHDNS
cls
echo Flushing DNS Resolver Cache...
ipconfig /flushdns
echo.
pause
goto MENU

:REPORTS
cls
echo [1/2] Saving Driver List to Desktop (driver_list.txt)...
driverquery /v /fo list > "%userprofile%\Desktop\driver_list.txt"
echo Driver list saved to Desktop!
echo.
echo [2/2] Generating Performance Report (Takes 60 seconds)...
perfmon /report
echo.
echo Check the Performance Monitor window that opens and the text file on your desktop.
pause
goto MENU

:WINSOCK
cls
echo WARNING: Resetting Winsock will restore network settings to default.
echo A COMPUTER RESTART IS REQUIRED AFTER RUNNING THIS.
echo.
set /p confirm="Do you want to reset Winsock now? (Y/N): "
if /i "%confirm%" neq "Y" goto MENU

echo.
echo Resetting Winsock Catalog...
netsh winsock reset
echo.
echo Reset complete. Please restart your computer when possible.
pause
goto MENU

:END
exit