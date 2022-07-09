@Echo OFF
SetLocal EnableDelayedExpansion



Rem //  7-Zip Executable Path
Set imageMagick="C:\tools\ImageMagick-x64\bin\magick.exe"



Rem // START: NewLine Variable Hack
Set newLine=^


Rem // END: NewLine Variable Hack !! DO NOT DELETE 2 EMPTY LINES ABOVE !!



Rem //  Set ErrorLog Variables
Set errorCount=0
Set separator=--------------------------------------------------------
Set errorLog=!newLine!!separator!!newLine!!newLine!
Set errorPrefix=ERROR @:
Set successMessage=All Files Were Successfully Converted



Rem //  Loop Through Each Argument
SetLocal DisableDelayedExpansion
for %%x in (%*) do (

    Rem //  Use Current Argument To set File, Folder Paths
    SetLocal DisableDelayedExpansion
    Set filePath="%%~x"
    Set directoryFiles="%%~x\*"
    SetLocal EnableDelayedExpansion

    Rem //  Source Is A Folder
    if exist !directoryFiles! (
            Set sourcePath=!directoryFiles!
    )

    Rem //  Source Is A File
    if not exist !directoryFiles! (
            Set sourcePath=!filePath!
    )

    Rem //  Print Separator To Divide Output
    echo !newLine!!separator!!newLine!

    Rem //  Make output directory
    if not exist OUTPUT (
            mkdir OUTPUT
            echo OUTPUT Directory created
            echo !newLine!!separator!!newLine!
    )
    
    Rem //  Convert files
    echo Converting: !filePath!
    !imageMagick! mogrify -format JPEG -path OUTPUT *.webp !sourcePath!

    Rem //  Log Errors
    if ErrorLevel 1 (
        Set /A errorCount=errorCount+1
        Set errorLog=!errorLog!!newLine!!errorPrefix!!sourcePath!
    )
)



Rem //  Print ErrorLog
if !errorCount!==0 (
    Set errorLog=!errorLog!!newLine!!successMessage!
)
Echo !errorLog!!newLine!!newLine!!newLine!



Rem //  Keep Window Open To View ErrorLog
pause