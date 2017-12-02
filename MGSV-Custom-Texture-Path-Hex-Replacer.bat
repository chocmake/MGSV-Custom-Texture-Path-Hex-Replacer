:: ----------------------------------- Batch Script Info -----------------------------------
:: -----------------------------------------------------------------------------------------

:: Name:            MGSV Custom Texture Path Hex Replacer
:: Description:     Simplifies custom FTEX texture path hex replacement in FMDL/FV2 files
:: Requirements:    GzsTool (BobDoleOwndU version), XVI32, included XVIscript file
:: URL:             https://github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer
:: Author:          choc
:: Version:         0.1 (2017-12-02)

:: -----------------------------------------------------------------------------------------

@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: Script version
set version=0.1

:: Command prompt styling (global)
color F0
title MGSV Custom Texture Path Hex Replacer ^(v!version!^)

:: Prompt padding
for /f %%a in ('"prompt $H &echo on &for %%B in (1) do rem"') do set BS=%%a

:: Check for existing program path variables
call :checkpaths
if defined gzstoolpath if defined xvi32path if defined xviscriptpath goto :pathsadded

:: ------------------------------ Program Paths Initial Setup ------------------------------
:: -----------------------------------------------------------------------------------------

:: Command prompt styling
mode con: cols=60 lines=40

echo.
echo.
echo   Initial Setup _________________________________________
echo.
echo.
echo   You'll first need to grab the following programs/files:
echo.
echo   - GzsTool (BobDoleOwndU version) 
echo   - XVI32 hex editor
echo   - XVIscript .XSC file included with this script.
echo.
echo   Then follow the prompts below to store their paths.
echo.
echo.
echo.
echo   Program Paths _________________________________________
echo.
echo.

:: Drag and drop prompts
echo   Drag and drop GzsTool.exe here then press Enter:
echo.
:gzstoolprompt
set /p gzstoolpath=!BS!  
if not defined gzstoolpath goto :gzstoolprompt

echo.
echo.
echo   Drag and drop XVI32.exe here then press Enter:
echo.
:xvi32pathprompt
set /p xvi32path=!BS!  
if not defined xvi32path goto :xvi32pathprompt

echo.
echo.
echo   Drag and drop HexRepl.xsc here then press Enter:
echo.
:xviscriptpathprompt
set /p xviscriptpath=!BS!  
if not defined xviscriptpath goto :xviscriptpathprompt

:: Append the paths to end of this script
set "script=%~f0"
setlocal EnableDelayedExpansion
>>"!script!" echo set gzstoolpath=!gzstoolpath!
>>"!script!" echo set xvi32path=!xvi32path!
>>"!script!" echo set xviscriptpath=!xviscriptpath!
echo.
echo.
pause>nul|set /p =!BS!  Setup complete^^! Press any key to continue  !BS!&& mode con: cols=60 lines=50
endlocal

:: --------------------------------- The Rest of the Script --------------------------------
:: -----------------------------------------------------------------------------------------

:pathsadded
setlocal EnableDelayedExpansion

:: Command prompt styling
mode con: cols=60 lines=48

:top
cls
echo.
echo.
echo   Custom Texture Path Replacement _______________________
echo.
echo.
echo   Add both single FTEX texture files below, with the 
echo   original file in its native path and the modded file
echo   with the desired custom filename or directory path.
echo   Custom paths must be located in the Assets directory.
echo.
echo   Paths are auto formatted for the appropriate hash.
echo.
echo.
echo.
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
        for /f %%i in ('!gzstoolpath! -d -hwe !originalpath!') do set originalpath=%%i
        ) else (
        rem Root directory path formatting
        for %%i in (%originalpath%) do (
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
echo   !originalpathraw!
echo.
call :formathex originalpath originalpathpro
echo   !originalpathpro!
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
echo   !custompathraw!
echo.
call :formathex custompath custompathpro
echo   !custompathpro!
echo.
echo.
echo.
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
    !xvi32path! !filepath! /S=!xviscriptpath! "!originalpathpro!" "!custompathpro!"
    goto :top
    )

:: Target file processed
:filepathprocessed
echo   !filepath!

endlocal

:: Exit
echo.
echo.
echo.
pause>nul|set /p =!BS!  Modification complete^^! Press any key to close  !BS!

:: ------------------------------------ Call Functions -------------------------------------
:: -----------------------------------------------------------------------------------------

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

:: ------------------------------------- Program Paths -------------------------------------
:: -----------------------------------------------------------------------------------------

:checkpaths
