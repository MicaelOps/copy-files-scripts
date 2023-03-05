@echo on
set SEPARATOR=" "
set /A BOOLEAN_TRUE=0
set /A BOOLEAN_FALSE=1

:: To allow the code to run with variable data retrieved from runtime
setlocal ENABLEDELAYEDEXPANSION 


:: empty line
echo: 
echo Welcome to this amazing program!
echo To quit at any moment press Ctrl + c
echo:

:: Checks if the first argument does not exist
if "%~1" == "" (

    call :askFolders %source%, dest
    call :checkOverwrite !dest!, returnvalue
    call :copyContents !source!, !dest!, !returnvalue!

    
) else (

    if "%~2" == "" (

        call :readListFile %~1
        
    ) else (

        echo Too many arguments!
    )
)


:exit
    EXIT /B 0

    
:: Checks if file exists and it is a file
:: Expected parameters 
:: %~1 = path to file
:: %~2 = return value
:doesFileExist
    if exist %~1 (
        set %~2=%BOOLEAN_TRUE%
    ) else (
        set %~2=%BOOLEAN_FALSE%
    )
EXIT /B 0


:: Checks if Folder exists and it is a folder
:: Expected parameters 
:: %~1 = path to folder
:: %~2 = return variable
:doesFolderExist
    if exist %~1\ (
        set %~2=%BOOLEAN_TRUE%
    ) else (
        set %~2=%BOOLEAN_FALSE%
    )
EXIT /B 0

:: Checks if the destination folder exists and asks the user if he wants to overwite
:: Expected Paramters
:: %~1 parameter = Destination folder
:: %~2 parameter = return value
:checkOverwrite 
     
    CALL :doesFolderExist %~1, returnvalue

    if %returnvalue% == %BOOLEAN_TRUE% (
        echo "Destination folder exists!"
        set /p OVERWRITE_STR="Do you wish to overwrite existing contents? (y/n) "
        
        if "%OVERWRITE_STR%"== "y" (
            echo "Overwritting..."
            set %~2=%BOOLEAN_TRUE%
        ) else (
            if "%OVERWRITE_STR%" == "n" (
                set %~2=%BOOLEAN_FALSE%
            ) else (
                echo Invalid option!
                call :checkOverwrite %~1, %~2
            )
        )
    ) else (
        set %~2=%BOOLEAN_FALSE%
    )
EXIT /B 0


:: Asks the user while persisting for correct values
:: to input source and destination folders location
:askFolders

    set /p SRC="Please input the source folder "
    call :doesFolderExist %SRC%, returnvalue

    if %returnvalue% == %BOOLEAN_FALSE% (
            echo The folder does not exist
            goto askFolders
    )
    set %~1=%SRC%
    set /p DEST="Please input the destination folder "
    set %~2=%DEST%

 
EXIT /B 0


:readListFile

    call: doesFileExist %~1, returnvalue

    if %returnvalue% == %BOOLEAN_TRUE% (

            call :readListFile %~1, source, dest

        ) else (

            echo List file does not exist!
        )
    )
EXIT /B 0
:: Copies all contents of one folder to another
:: Expected paramters :
:: $1 = source folder
:: $2 = destination folder
:: $3 = overrite (BOOLEAN_TRUE or BOOLEAN_FALSE)
:copyContents
   
    echo "All files have been written."
EXIT /B 0