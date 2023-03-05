@echo on
setlocal ENABLEDELAYEDEXPANSION
set SEPARATOR=" "
set /A BOOLEAN_TRUE=0
set /A BOOLEAN_FALSE=1 

echo "welcome!"

set param1=test.bat

if 1==1 (
    call :doesFileExist %param1%, dest
    echo !dest!
    exit
)

:doesFileExist
    if exist %~1 (
        set "%~2=%BOOLEAN_TRUE%"
    ) else (
        set "%~2=%BOOLEAN_FALSE%"
    )
EXIT /B 0

