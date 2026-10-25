@echo off
setlocal enabledelayedexpansion

set "LIST_FILE=mods.txt"

if not exist "%LIST_FILE%" (
    echo Error: %LIST_FILE% not found!
    pause
    exit /b 1
)

for /f "usebackq tokens=* delims=" %%A in ("%LIST_FILE%") do (
    set "URL=%%A"
    
    if not "!URL!"=="" if not "!URL:~0,1!"=="#" (
        
        for /f "delims=?" %%U in ("!URL!") do (
            for %%F in ("%%U") do set "FILENAME=%%~nxF"
        )

        rem Decode %%2B to +
        set "FILENAME=!FILENAME:%%2B=+!"

        echo Downloading: !FILENAME!
        curl -L -s --show-error -o "!FILENAME!" "!URL!"
    )
)

pause
