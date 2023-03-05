:: Author Micael Cossa
@echo on

set /A BOOLEAN_TRUE=0
set /A BOOLEAN_FALSE=1

:: Print welcome messages
echo: 
echo Welcome to this amazing program!
echo To quit at any moment press Ctrl + c
echo:

:: Checks if the first argument does not exist
:: If it does exist, proceeds to check if there is no second argument
if "%~1" == "" (

    :: Asks the user to input source and destination folder to perform a copy
    call :askFolders source, dest
    
    :: To allow the code to run with variable data retrieved from runtime
    setlocal ENABLEDELAYEDEXPANSION 

    :: Executes the copy of folders
    call :copyContents !source!, !dest!, !returnvalue!

    endlocal

) else ( if "%~2" == "" ( call :readListFile %~1 ) else ( echo Too many arguments! ) )

:: Closes the program
EXIT /B 0

    
:: Checks if file exists and it is a file
:: Expected parameters 
:: %~1 = path to file
:: %~2 = return value
:doesFileExist
    if exist %~1 ( set %~2=%BOOLEAN_TRUE% ) else ( set %~2=%BOOLEAN_FALSE% )
EXIT /B 0


:: Checks if Folder exists and it is a folder
:: Expected parameters 
:: %~1 = path to folder
:: %~2 = return variable
:doesFolderExist
    if exist %~1\ ( set %~2=%BOOLEAN_TRUE% ) else ( set %~2=%BOOLEAN_FALSE% )
EXIT /B 0


:: Asks the user while persisting for correct values
:: to input source and destination folders location
:askFolders

    :: Asks the user to input source folder
    set /p SRC="Please input the source folder "

    :: Checks if source folder exist
    call :doesFolderExist %SRC%, returnvalue

    :: If does not exist repeats the function
    if %returnvalue% EQU %BOOLEAN_FALSE% (
            echo The folder does not exist
            goto askFolders
    )

    set %~1=%SRC%

    :: Asks the destination folder
    set /p DEST="Please input the destination folder "
    set %~2=%DEST%

EXIT /B 0

:: Reads list file and copies the sources to the destination folders
:: Expected format in every line: '<source> <destination>'
:: Expected Parameter:
:: %~1 = path to list file
:readListFile

    :: Check if list file exists
    call :doesFileExist %~1, returnvalue

    if %returnvalue% EQU %BOOLEAN_TRUE% (

        :: To allow the code to run with variable data retrieved from runtime inside the for loop
        setlocal ENABLEDELAYEDEXPANSION

        :: This enable to track the loop iterations
        set /A counter = 0

        :: Reads line by line the file in the first parameter
        :: Separates using space character and gets the first and second results after split
        for /F "tokens=1,2 delims= " %%A in (%~1) do (
            
            :: Checks if the source and destination are not the same or not empty
            if not "%%A%%B" == "%%B%%A" (              

                set /A counter = 1
                
                :: Checks if source folder exists
                call :doesFolderExist %%A, returnvalue
                
                :: Get the updated value from doesFolderExist returnvalue
                set /A updatedreturn = !returnvalue!
                
                if !updatedreturn! EQU %BOOLEAN_TRUE% (

                    echo Copying %%A...
                    call :copyContents %%A %%B

                ) else ( echo Source %%A does not exist )
                
            ) else ( echo Invalid file line detected )
        )

        :: the for loop did not have a single successful iteration
        if !counter! EQU 0 echo If you are seeing this message it means File was empty or corrupted
        
        endlocal

    ) else ( echo List file does not exist! )

EXIT /B 0

:: Copies all contents of one folder to another using xcopy
:: /F = Displays full source and destination file names while copying.
:: /E = Copies directories and subdirectories, including empty ones.
:: /I = If the destination does not exist and copies more than one file, it assumes that the destination must be a directory.
:: xcopy has built in function to ask for overwrite.
:: Expected paramters :
:: %~1 = source folder
:: %~2 = destination folder
:copyContents
    xcopy %~1 %~2 /F /E /I
EXIT /B 0