set /p "password=Enter password: "

@FOR /R %%a IN (*.zip,*.7z,*.rar,*.tar,*.gz,*.part1.exe) DO @(
    @if [%1] EQU [/y] (
        @"C:\Program Files\7-Zip\7z.exe" x "%%a" -o"%%~dpna" -aoa -p%password%
    ) else if [%1] EQU [/yd] (
        @"C:\Program Files\7-Zip\7z.exe" x "%%a" -o"%%~dpna" -aoa -p%password%
        @if errorlevel 1 (
            @echo There was an error so I won't delete
        ) else (
            REM You can also prompt with del /p
            @del "%%a"
        )
    ) else (
        @echo "C:\Program Files\7-Zip\7z.exe" x "%%a" -o"%%~dpna" -aoa
    )
)

@echo USAGE: Use /y to actually do the extraction. Use /yd to extract then delete the zip file.