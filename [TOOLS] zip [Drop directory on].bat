@Echo OFF
@SETLOCAL enableextensions enabledelayedexpansion



Rem //  7-Zip Executable Path
Set sevenZip="C:\Program Files\7-Zip\7z.exe"



Rem // START: NewLine Variable Hack
Set newLine=^


Rem // END: NewLine Variable Hack !! DO NOT DELETE 2 EMPTY LINES ABOVE !!



Rem //  Set ErrorLog Variables
Set errorCount=0
Set separator=--------------------------------------------------------
Set errorLog=!newLine!!newLine!!separator!!newLine!!newLine!
Set errorPrefix=ERROR @:
Set successMessage=All Files Were Successfully Archived



Rem //  Loop Through Each Argument
SETLOCAL DisableDelayedExpansion
for %%x in (%*) do (

    Rem //  Use Current Argument To set File, Folder, & Archive Paths
    SETLOCAL DisableDelayedExpansion
    Set filePath="%%~x"
    Set directoryFiles="%%~x\*"
    Set archivePath="%%~x.zip"
    SETLOCAL EnableDelayedExpansion

    Rem //  Source Is A Folder
    if exist !directoryFiles! (
            Set sourcePath=!directoryFiles!
    )

    Rem //  Source Is A File
    if not exist !directoryFiles! (
            Set sourcePath=!filePath!
    )

    Rem //  Print Separator To Divide 7-Zip Output
    echo !newLine!!newLine!!separator!!newLine!!newLine!

    Rem //  Add Files To Zip Archive
    !sevenZip! A -TZIP -mx0 !archivePath! !sourcePath!

    Rem //  Log Errors
    if ErrorLevel 1 (
        Set /A errorCount=errorCount+1
        Set errorLog=!errorLog!!newLine!!errorPrefix!!sourcePath!
    )
	ENDLOCAL
)
@ENDLOCAL



Rem //  Print ErrorLog
if !errorCount!==0 (
    Set errorLog=!errorLog!!newLine!!successMessage!
)
Echo !errorLog!!newLine!!newLine!!newLine!



Rem //  Keep Window Open To View ErrorLog
pause