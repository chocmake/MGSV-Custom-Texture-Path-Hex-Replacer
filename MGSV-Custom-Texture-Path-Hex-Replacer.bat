:: ----------------------------------- Batch Script Info -----------------------------------
:: -----------------------------------------------------------------------------------------

:: Name:            MGSV Custom Texture Path Hex Replacer
:: Description:     Simplifies custom FTEX texture path hex replacement in FMDL/FV2 files
:: Requirements:    GzsTool (BobDoleOwndU version), XVI32 hex editor
:: URL:             https://github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer
:: Author:          choc
:: Version:         0.2 (2018-05-15)

:: -----------------------------------------------------------------------------------------

@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: Script version
set version=0.2

:: Command prompt styling (global)
color F0
title MGSV Custom Texture Path Hex Replacer ^(v!version!^)

:: Prompt padding
for /f %%a in ('"prompt $H &echo on &for %%B in (1) do rem"') do set BS=%%a

:: New line character variable (two new lines required below)
set lf=^


:: Set temp directory for self-generated script files
if exist "%temp%" (
    set "scriptdir=%temp%\"
    ) else (
    set "scriptdir=%~dp0"
    )

:: Check for existing program path variables
call :checkpaths
if defined gzstoolpath if defined xvi32path goto :pathsadded

:: ------------------------------ Program Paths Initial Setup ------------------------------
:: -----------------------------------------------------------------------------------------

:: Command prompt styling
mode con: cols=60 lines=30

:topinitial
echo.
echo.
echo   Initial Setup _________________________________________
echo.
echo.
echo   You'll first need to grab the following programs:
echo.
echo   - GzsTool (BobDoleOwndU version)
echo   - XVI32 hex editor
echo.
echo   Then follow the prompts below to store their paths.
echo.
echo.
echo.
echo   Program Paths _________________________________________
echo.
echo.

:: Drag and drop prompts
if defined gzstoolpath goto :gzstoolpathprocessed
echo   Drag and drop GzsTool.exe here then press Enter:
echo.
:gzstoolprompt
set /p gzstoolpath=!BS!  
if not defined gzstoolpath (
    goto :gzstoolprompt
    ) else (
    cls
    goto :topinitial
    )
:gzstoolpathprocessed
set longstr=!gzstoolpath! & call :newlines 

if defined xvi32path goto :xvi32pathprocessed
echo.
echo.
echo   Drag and drop XVI32.exe here then press Enter:
echo.
:xvi32pathprompt
set /p xvi32path=!BS!  
if not defined xvi32path (
    goto :xvi32pathprompt
    ) else (
    cls
    goto :topinitial
    )
:xvi32pathprocessed
echo.
echo.
set longstr=!xvi32path! & call :newlines 

:: Append the paths to end of this script
set "script=%~f0"
setlocal EnableDelayedExpansion
>>"!script!" echo set gzstoolpath=!gzstoolpath!
>>"!script!" echo set xvi32path=!xvi32path!
echo.
echo.
pause>nul|set /p =!BS!  Setup complete^^! Press any key to continue...  !BS!&& mode con: cols=60 lines=50
endlocal

:: --------------------------------- The Rest of the Script --------------------------------
:: -----------------------------------------------------------------------------------------

:pathsadded
setlocal EnableExtensions EnableDelayedExpansion
mode con: cols=60 lines=38

:: Check if script launched with prior input (file dropped on script, etc)
set inputfile="%~1"
set "inputfile=!inputfile:"=!"
if defined inputfile (
    rem Obtain correct path with ampersands but no spaces
    set "inputfile=!cmdcmdline:~0,-1!"
    goto :inputfileparse
    )

:: Escape the input path (has issues as a function call so used goto instead)
:inputfileparse
if defined inputfile (
    set "inputfile=!inputfile:*" =!"
    set "inputfile=!inputfile:"=!"
    set inputfile="!inputfile!"
    for /f "delims=" %%a in ("!inputfile!") do (
            rem Obtain any exclamation marks in path
            setlocal EnableExtensions DisableDelayedExpansion
            set "inputfile=%%~dpa%%~na%%~xa"
            set "inputfilepath=%%~dpa"
            set "inputfilename=%%~na%%~xa"
            )
    setlocal EnableExtensions EnableDelayedExpansion
    rem Quotes must be added outside here else the problematic characters will be stripped from variable 
    set inputfile="!inputfile!"
    rem Trim trailing backslash for forfiles function and pre-wrap in double quotes
    set inputfilepath="!inputfilepath:~0,-1!"
    )

:top
cls
echo.
echo.
echo   Target Model File _____________________________________
echo.
echo.

:: Check filetype
:inputfiletypecheck
set "errormsg=Error: opened file was not an .fmdl or .fv2, please re-select the correct file and try again."
if defined inputfile (
    set "filetype=!inputfile:"=!"
    if /i not "!filetype:~-4!"=="fmdl" (
        if /i not "!filetype:~-3!"=="fv2" (
            rem Error message displayed when wrong filetype was entered in prompt
            set inputfile=
            set filetype=
            set longstr=!errormsg! & call :newlines
            echo.
            )
        )
    ) else (
    if not defined inputfile (
        if defined resetprompt (
            set resetprompt=
            set longstr=!errormsg! & call :newlines
            echo.
            )
        )
    )

:: Target file
if defined inputfile goto :inputfileprocessed
:inputfileprompt
rem Setting an initial variable value like this prevents empty prompt values from crashing script
set "inputfile=foobar"
set /p inputfile=!BS!  ^> Drag and drop file here then press Enter:  !BS!
if not defined inputfile (
    goto :top
    ) else (
    goto :inputfileparse
    set "filetype=!inputfile:"=!" && if /i not "!filetype:~-4!"=="fmdl" && if /i not "!filetype:~-3!"=="fv2" && set resetprompt=1 goto :top
    set filetype=
    goto :top
    )

:: Target file processed
:inputfileprocessed
set longstr=!inputfile! & call :newlines
echo.
echo.
echo.

:originalpathheader
echo   Original FTEX Path ____________________________________
echo.
echo.

:: Error message displayed when wrong filetype was entered in prompt
if not defined originalpath call :errormsg

:: Original FTEX path
if defined originalpath goto :originalpathprocessed
:originalpathprompt
set "originalpath=foobar"
set /p originalpath=!BS!  ^> Drag and drop file here then press Enter:  !BS!
if not defined originalpath (
    goto :top
    ) else (
    call :formatpath1 originalpath originalpath
    rem Check filetype
    if /i not "!originalpath:~-4!"=="ftex" (
        set originalpath=
        set resetprompt=1
        goto :top
        )
    rem Check if the texture file is within Assets or not
    if not %originalpath:Assets=%==%originalpath% (
        call :formatpath2 originalpath originalpath
        set originalpathraw=!originalpath!
        echo !originalpath!
        for /f %%i in ('!gzstoolpath! -d -hwe !originalpath!') do set originalpath=%%i
        ) else (
        rem Root directory path formatting
        for %%i in (!originalpath!) do (
            set originalpath=%%~ni
            set originalpathraw=/%%~ni%%~xi
            )
        if "!originalpath:~12,1!"=="" (
            set originalpath=68!originalpath!
            ) else (
            if /i "!originalpath:~0,1!"=="1" set originalpath=69!originalpath:~1!
            if /i "!originalpath:~0,1!"=="2" set originalpath=6A!originalpath:~1!
            if /i "!originalpath:~0,1!"=="3" set originalpath=6B!originalpath:~1!
            )
        set originalpath=15!originalpath!
        )
        goto :top
    )

:: Original FTEX path processed
:originalpathprocessed
set longstr=!originalpathraw! & call :newlines
echo.
call :formathex originalpath originalpathhex
echo   !originalpathhex!
echo.
echo.
echo.
echo   Custom FTEX Path ______________________________________
echo.
echo.

:: Error message displayed when wrong filetype was entered in prompt
if not defined custompath call :errormsg

:: Custom FTEX path
if defined custompath goto :custompathprocessed
:custompathprompt
set "custompath=foobar"
set /p custompath=!BS!  ^> Drag and drop file here then press Enter:  !BS!
if not defined custompath (
    goto :top
    ) else (
    call :formatpath1 custompath custompath
    rem Check filetype
    if /i not "!custompath:~-4!"=="ftex" (
        set custompath=
        set resetprompt=1
        goto :top
        )
    rem Check if the texture file is within Assets or not
    if not %custompath:Assets=%==%custompath% (
        call :formatpath2 custompath custompath
        ) else (
        set custompath=
        set assetserror=1
        goto :top
        )
        set custompathraw=!custompath!
        for /f %%i in ('!gzstoolpath! -d -hwe !custompath!') do set custompath=%%i
        goto :top
    )

:: Custom FTEX path processed
:custompathprocessed
set longstr=!custompathraw! & call :newlines
echo.
call :formathex custompath custompathhex
echo   !custompathhex!

:: Prepare the temp find and replace script, run the hex editor
set scriptfile="!scriptdir!HexRepl-temp.xsc"
set "xviscript=ADR 0!lf!REPLACEALL %%1 BY %%2!lf!EXIT"
echo !xviscript! > !scriptfile!
call :datemodified inputfile datemodified1
!xvi32path! !inputfile! /S=!scriptfile! "!originalpathhex!" "!custompathhex!"
call :datemodified inputfile datemodified2

:: Delete the temp script file
del !scriptfile!

:: Modification result
echo.
echo.
echo.
if /i "!datemodified1!"=="!datemodified2!" (
    set "modunsuccessful=Modification unsuccessful. Possibly the 'Original FTEX Path' entered may not exist in the target file, or the texture path has already been changed."
    set longstr=!modunsuccessful! & call :newlines
    echo.
    choice /m "!BS!  Try again? (Yes/No)  !BS!" /n /c yn
    if errorlevel 2 exit /b
    if errorlevel 1 (
        set originalpath=
        set custompath=
        goto :top
        )
    ) else (
    pause>nul|set /p =!BS!  Modification successful^^! Press any key to close...  !BS!
    )

:: --------------------------------------- Functions ---------------------------------------
:: -----------------------------------------------------------------------------------------

:: Error message for incorrect texture filetype
:errormsg
    if defined resetprompt (
        set resetprompt=
        set "errormsg=Error: file entered was not a .ftex, please select the correct texture and try again."
        set longstr=!errormsg! & call :newlines
        echo.
        )
    if defined assetserror (
        set assetserror=
        set "errormsg=Error: texture entered was not contained within an Assets directory, please place custom texture within an Assets directory and try again."
        set longstr=!errormsg! & call :newlines
        echo.
        )
    endlocal
    exit /b

:: Visually format strings longer than window width into new lines with padding
:newlines
    setlocal
    set longstr=!longstr:"=!
    echo   !longstr:~0,55!
    set longstr=!longstr:~55!
    if defined longstr goto newlines
    endlocal
    exit /b 

:: Strip double quotes from texture path, replace backslashes with forwardslashes
:formatpath1
    set format=!%~1:"=!
    set %~2=!format:\=/!
    endlocal
    exit /b

:: Truncate texture path to last occurrence of parent 'Assets' directory (assumes max 5 levels deep)
:formatpath2
    set "format=!%~1:*Assets/=!"
    set "format=!format:*Assets/=!"
    set "format=!format:*Assets/=!"
    set "format=!format:*Assets/=!"
    set "format=!format:*Assets/=!"
    set "%~2=/Assets/!format!"
    endlocal
    exit /b

:: Reverse hex byte order, format in uppercase
:formathex
    set "hex=!%~1!"
    set hex1=!hex:~-2!
    set hex2=!hex:~-4,-2!
    set hex3=!hex:~-6,-4!
    set hex4=!hex:~-8,-6!
    set hex5=!hex:~-10,-8!
    set hex6=!hex:~-12,-10!
    set hex7=!hex:~-14,-12!
    set hex8=!hex:~-16,-14!
    set hex=!hex1! !hex2! !hex3! !hex4! !hex5! !hex6! !hex7! !hex8!
    rem Make it uppercase 
    set upper=
    set "upperstr=!hex!"
    for /f "skip=2 delims=" %%I in ('tree "\%upperstr%"') do if not defined upper set "upper=%%~I"
    set "%~2=%upper:~3%"
    endlocal
    exit /b

:: Check the target file timestamp
:datemodified
    for %%f in ("%~1") do (
        for /f "tokens=1,* delims=|" %%k in (
            'forfiles /p !inputfilepath! /m !inputfilename! /c "cmd /c echo @fdate @ftime"'
            ) do (
            set modified=%%k
            )
        )
    set "%~2=!modified!"
    endlocal
    exit /b

endlocal

:: ------------------------------------ Program Paths --------------------------------------
:: -----------------------------------------------------------------------------------------

:checkpaths
