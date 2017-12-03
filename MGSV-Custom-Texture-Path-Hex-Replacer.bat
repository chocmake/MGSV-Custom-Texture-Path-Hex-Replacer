:: ----------------------------------- Batch Script Info -----------------------------------
:: -----------------------------------------------------------------------------------------

:: Name:            MGSV Custom Texture Path Hex Replacer
:: Description:     Simplifies custom FTEX texture path hex replacement in FMDL/FV2 files
:: Requirements:    GzsTool (BobDoleOwndU version), XVI32 hex editor
:: URL:             https://github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer
:: Author:          choc
:: Version:         0.1.1 (2017-12-03)

:: -----------------------------------------------------------------------------------------

@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: Script version
set version=0.1.1

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

:: Check for user settings, existing program path variables
call :checksettings
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
set longstr=!gzstoolpath!&call:newlines 

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
set longstr=!xvi32path!&call:newlines 

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

:: Command prompt styling
if /i "!showhowto:~0,1!"=="1" (
    mode con: cols=60 lines=51
    ) else (
    rem Shorten window height when hiding how to text
    mode con: cols=60 lines=38
    )

:: Input check if script launched with prior input (file dropped on script, etc)
set filepath="%~1"
set "filepath=!filepath:"=!"
if defined filepath (
    rem obtain correct path with ampersands but no spaces
    set "filepath=!cmdcmdline:~0,-1!"
    set "filepath=!filepath:*" =!"
    set "filepath=!filepath:"=!"
    set filepath="!filepath!"
    for /f "delims=" %%a in ("!filepath!") do (
        rem obtain any exclamation marks in filename
        setlocal EnableExtensions DisableDelayedExpansion
        set "filepath=%%~dpa%%~na%%~xa"
        )
    setlocal EnableExtensions EnableDelayedExpansion
    rem Quotes must be added outside here else the problematic characters will be stripped from variable 
    set filepath="!filepath!"
    set filepathhowtocheck=1
    )

:top
cls
echo.
echo.
if /i "!showhowto:~0,1!"=="1" (
    echo   Custom Texture Path Replacement _______________________
    echo.
    echo.
    rem Change how to text depending on whether the target model is input already
    if defined filepathhowtocheck (
        echo   Add both the individual FTEX texture paths below. The
        echo   original FTEX should be in its original path structure
        echo   and the modded FTEX with a custom filename or directory
        echo   ^(or both^). The custom FTEX must be located within an
        echo   Assets directory.
        ) else (
        echo   Add the model file to be tweaked, followed by both the
        echo   individual FTEX texture paths below. The original FTEX
        echo   should be in its original path structure and the modded
        echo   FTEX with a custom filename or directory ^(or both^). The
        echo   custom FTEX must be located within an Assets directory.
        )
    echo.
    echo   Paths are auto formatted for the appropriate hash.
    echo.
    echo.
    echo.
    )

echo   Target Model File _____________________________________
echo.
echo.

:: Target file
if defined filepath goto :filepathprocessed
:filepathprompt
set /p filepath=!BS!  ^> Drag and drop file here:  !BS!
if not defined filepath (
    goto :filepathprompt
    ) else (
    goto :top
    )

:: Target file processed
:filepathprocessed
set longstr=!filepath!&call:newlines
echo.
echo.
echo.

:originalpathheader
echo   Original FTEX Path ____________________________________
echo.
echo.

:: Original FTEX path
if defined originalpath goto :originalpathprocessed
:originalpathprompt
set /p originalpath=!BS!  ^> Drag and drop file here:  !BS!
if not defined originalpath (
    goto :originalpathprompt
    ) else (
    call :formatpath1 originalpath originalpath
    rem Check if the texture file is within Assets or not
    if not x%originalpath:Assets=%==x%originalpath% (
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
set longstr=!originalpathraw!&call:newlines
echo.
call :formathex originalpath originalpathhex
echo   !originalpathhex!
echo.
echo.
echo.
echo   Custom FTEX Path ______________________________________
echo.
echo.

:: Custom FTEX path
if defined custompath goto :custompathprocessed
:custompathprompt
set /p custompath=!BS!  ^> Drag and drop file here:  !BS!
if not defined custompath (
    goto :custompathprompt
    ) else (
    call :formatpath1 custompath custompath
    rem Check if the texture file is within Assets or not
    if not x%custompath:Assets=%==x%custompath% (
        call :formatpath2 custompath custompath
        ) else (
        set custompath=
        goto :top
        )
        set custompathraw=!custompath!
        for /f %%i in ('!gzstoolpath! -d -hwe !custompath!') do set custompath=%%i
        goto :top
    )

:: Custom FTEX path processed
:custompathprocessed
set longstr=!custompathraw!&call:newlines
echo.
call :formathex custompath custompathhex
echo   !custompathhex!

:: Prepare the temp find and replace script, run the hex editor
set scriptfile="!scriptdir!HexRepl-temp.xsc"
set "xviscript=ADR 0!lf!REPLACEALL %%1 BY %%2!lf!EXIT"
echo !xviscript! > !scriptfile!
call :datemodified filepath datemodified1
!xvi32path! !filepath! /S=!scriptfile! "!originalpathhex!" "!custompathhex!"
call :datemodified filepath datemodified2

:: Delete the temp script file
del !scriptfile!

:: Exit
echo.
echo.
echo.
if /i "!datemodified1!"=="!datemodified2!" (
    echo   Modification unsuccessful. Check the FTEX paths. It may
    echo   be the custom hex string already exists in the model
    echo   file or the original hex string does not.
    echo.
    pause>nul|set /p =!BS!  Press any key to close...  !BS!
    ) else (
    pause>nul|set /p =!BS!  Modification successful^^! Press any key to close...  !BS!
    )

:: ------------------------------------ Call Functions -------------------------------------
:: -----------------------------------------------------------------------------------------

:: Break strings longer than visual window margins into new lines
:newlines
    setlocal
    set longstr=!longstr:"=!
    echo   !longstr:~0,55!
    set longstr=!longstr:~55!
    if defined longstr goto newlines
    endlocal
    exit /b 

:: Strip double quotes from input, replace backslashes with forwardslashes
:formatpath1 <input> <output>
    set format=!%~1:"=!
    set %~2=!format:\=/!
    endlocal
    exit /b

:: Crudely truncates path to last occurrence of parent 'Assets' directory, assumes unpacked structure no more than 5 levels deep
:formatpath2 <input> <output>
    set "format=!%~1:*Assets/=!"
    set "format=!format:*Assets/=!"
    set "format=!format:*Assets/=!"
    set "format=!format:*Assets/=!"
    set "format=!format:*Assets/=!"
    set "%~2=/Assets/!format!"
    endlocal
    exit /b

:: Reverses hex byte order, formats in uppercase
:formathex <input> <output>
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

:datemodified <input> <output>
    set "dmin=!%~1!"
    for %%a in (!dmin!) do set "dmout=%%~ta"
    set "%~2=!dmout!"
    endlocal
    exit /b

endlocal

:: ------------------------------ User Settings/Program Paths ------------------------------
:: -----------------------------------------------------------------------------------------

:checksettings
set showhowto=1
exit /b

:checkpaths
