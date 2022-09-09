:: ----------------------------------- Batch Script Info -----------------------------------
:: -----------------------------------------------------------------------------------------

:: Name:            MGSV Custom Texture Path Hex Replacer
:: Description:     Simplifies custom FTEX texture path hex replacement in FMDL/FV2 files
:: Requirements:    GzsTool (BobDoleOwndU version) or QuickHash, XVI32 (hex editor)
:: URL:             https://github.com/chocmake/MGSV-Custom-Texture-Path-Hex-Replacer
:: Author:          choc
:: Version:         0.3 (2022-09-07)

:: -----------------------------------------------------------------------------------------

@echo off

:: --------------------------------------- Settings ----------------------------------------
:: -----------------------------------------------------------------------------------------

:: If enabled will ask for and use QuickHash instead of BobDoleOwndU's version of GzsTool
:: for the hashing function.
set usequickhash=no

:: If enabled will offer a prompt to clear the FTEX paths and start again with the same
:: target file, after a successful modification. Useful for allowing more texture paths to
:: be edited during a single script session.
set promptaftersuccess=no

:: Script window color scheme
:: Valid values: light, dark
set colorscheme=light

:: ---------------------------------------- Script -----------------------------------------
:: -----------------------------------------------------------------------------------------

setlocal enableextensions enabledelayedexpansion

call :initformat
call :scriptargs
if /i not "!usequickhash:~0,1!"=="n" (
    call :setupcheck QuickHash XVI32
    ) else (
    call :setupcheck GzsTool XVI32
    )

:inputs
if not "[%~1]"=="[]" (
    call :cmdheightmanual "!cmdheight!"
    call :input
    call :cmdheight "input"
    )
:inputprompts
call :cmdheightmanual "!cmdheight!"

call :inputprompt input
call :inputprompt ftexorig
call :hex ftexorig
set "finalinputprompt=1"
call :inputprompt ftexcustom
call :hex ftexcustom
call :hexscript

exit

:: ----------------------------------------- Calls -----------------------------------------
:: -----------------------------------------------------------------------------------------

:choice
    setlocal disabledelayedexpansion
    set "n=0" & set "c=" & set "e=" & set "map=%~1"
    if not defined map endlocal & exit /b 0
    for /f "eol=1 delims=" %%i in ('xcopy /lwq "%~f0" :\') do set "c=%%i"
    set "c=%c:~-1%"
    if defined c (
        for /f delims^=^ eol^= %%i in ('cmd /von /u /c "echo !map!"^|find /v ""^|findstr .') do (
            set /a "n += 1" & set "e=%%i"
            setlocal enabledelayedexpansion
            if /i "!e!"=="!c!" (
                echo !c!
                for /f %%j in ("!n!") do endlocal & endlocal & exit /b %%j
                )
            endlocal
            )
        ) else (
        rem Action if Enter pressed
        endlocal & exit /b 0
        )
    endlocal & goto :choice
    exit /b

:cmdheight
    set "inheightall="
    for /f "delims=" %%p in ("!%~1!") do (
        setlocal disabledelayedexpansion
        set "p=%%p"
        setlocal enabledelayedexpansion
        set "p=!p:"=!"
        call :len p pheight
        call :linescalc pheight
        set /a "inheightall=!inheightall!+!pheight!+1"
        for %%h in (!inheightall!) do endlocal & endlocal & set "inheightall=%%h"
        )
    if "%~1"=="input" (
        set "cmdheightextra=3"
        ) else (
        rem Adjust extra margin depending on whether during setup
        if not defined input (
            set "cmdheightextra=0"
            ) else (
            rem Avoid adding margin prior to echo'ing final text
            if not defined finalinputprompt (
                set "cmdheightextra=5"
                ) else (
                    set "cmdheightextra=0"
                )
            )
        )
    set /a "cmdheight=!cmdheight!+!inheightall!+!cmdheightextra!"
    exit /b

:cmdheightmanual
    mode con lines=%~1
    exit /b

:datemodified
    for %%f in (!%~1!) do (
        rem Input path has trailing backslash trimmed for compatibility with forfiles
        for /f "usebackq tokens=1,* delims=|" %%d in (
            `forfiles /p "!indr[1]!!inpa[1]:~0,-1!" /m "!inna[1]!!inex[1]!" /c "cmd /c echo @fdate @ftime"`
            ) do (
            set "d=%%d"
            )
        )
    set "%~2=!d!"
    exit /b

:detectemptyinput
    if "!%~1!"=="""" set "%~1="
    if "!%~1: =!"=="" set "%~1="
    if "!%~1!"==" =" set "%~1="
    exit /b

:echoprompt
    if not "%~2"=="noheading" call :heading "!%~1prompttext!"
    set "l=!%~1!" & call :newlines
    exit /b

:error
    set "error=1"
    if "%~1"=="reset" (
        set "error="
        set "%~2="
    ) else (
        set "%~1=1"
    )
    exit /b

:escape
    set "s=!%~1:"=!"
    setlocal disabledelayedexpansion
    set "s=%s:!=###esc-excl###%"
    set "s=%s:^=###esc-caret###%"
    setlocal enabledelayedexpansion
    for %%a in ("!s!") do endlocal & endlocal & set "%~1=%%a"
    exit /b

:unescape
    set "s=!%~1:"=!"
    rem Checks if string contains exclamation point to later adjust number of carets for unescaping
    set "doublecaret=" & if not "!s!"=="!s:###esc-excl###=!" set "doublecaret=1"
    setlocal disabledelayedexpansion
    set "s=%s:###esc-excl###=^!%"
    if defined doublecaret (set "s=%s:###esc-caret###=^^%") else (set "s=%s:###esc-caret###=^%")
    setlocal enabledelayedexpansion
    for %%a in ("!s!") do endlocal & endlocal & set "%~1=%%a"
    exit /b

:heading
    set "h=%~1"
    rem Determine length of heading string for trimming underline variable
    call :len h trim
    set /a "trim=!cmdpadtextwidth! - (!trim! + 2)" & rem Addition is number of spaces after text
    set "l=!h!  !hl:~0,%trim%!" & echo. & call :newlines
    set "h=" & set "trim="
    exit /b

:hex
    if not defined %~1hex (
        rem Check if pre-hashed filename already defined
        if defined %~1hexpre (
            set "hex=!%~1hexpre!"
            ) else (
                rem Generate hash
                if /i not "!usequickhash:~0,1!"=="n" (
                    for /f %%h in ('!QuickHash! !%~1! -p64e') do set "hex=%%h"
                    ) else (
                    for /f %%h in ('!GzsTool! -d -hwe !%~1!') do set "hex=%%h"
                    )
            )
        rem Reverse byte order
        set "count=0" & set "ha=0" & set "hb=0"
        rem Loop through each eight bytes
        for /l %%i in (1,1,8) do (
            set /a "count+=1"
            if !count! equ 1 (
                set /a "ha+=2"
                for /f "tokens=1 delims=" %%a in ("!ha!") do set "h=!h! !hex:~-%%a!"
                ) else (
                set /a "ha+=2" & set /a "hb+=2"
                for /f "tokens=1-2 delims= " %%a in ("!ha! !hb!") do set "h=!h! !hex:~-%%a,-%%b!"
                )
            )
        set "hex=!h!" & set "h="
        rem Format to uppercase
        set "u=" & for /f "skip=2 delims=" %%a in ('tree "\!hex!"') do if not defined u set "u=%%~a"
        set "%~1hex=!u:~4!"
        )
    call :echoprompt %~1hex noheading
    exit /b

:hexscript
    if not defined complete (
        set "tempdir=!temp:"=!" & rem Strip any initial quotes in case Windows username contains spaces
        set "xviscript="!tempdir!\HexRepl-temp.xsc""
        rem Generate script
        echo ADR 0!lf!REPLACEALL %%1 BY %%2!lf!EXIT > !xviscript!
        call :datemodified input datemodified1
        !XVI32! !input! /S=!xviscript! "!ftexorighex!" "!ftexcustomhex!"
        call :datemodified input datemodified2
        rem Delete the temp script
        del !xviscript!
        set "complete=1"
        if /i "!datemodified1!"=="!datemodified2!" (
            call :error "errorcomplete"
            set "errorcompletemsg=Modification unsuccessful. Possibly the 'Original FTEX Path' entered may not exist in the target file, or the texture path has already been changed."
            call :len errorcompletemsg errorcompletemsgheight
            call :linescalc errorcompletemsgheight
            set /a "errorcompletemsgheight+=1" & rem Extra new line for choice prompt
            set "errorcompletemsgheight=+!errorcompletemsgheight!"
            ) else (
            if /i not "!promptaftersuccess:~0,1!"=="n" (
                set /a "cmdheight+=2"
                )
            )
        rem Compensate for :cmdheight regular prompt additional margin and add height of lines
        set /a "cmdheight=!cmdheight!-(!cmdheightextra!-2)!errorcompletemsgheight!"
        goto :inputprompts
        )
    echo.
    if defined error (
        if defined errorcomplete (
            call :error "reset" "errorcomplete" & set "errorcompletemsgheight="
            set "l=!erp! !errorcompletemsg!" & call :newlines
            call :resetprompt
            )
        ) else (
        set "excl=Modification successful^!"
        if /i not "!promptaftersuccess:~0,1!"=="n" (
            set "l=!excl!" & call :newlines
            call :resetprompt
            ) else (
            set "excl=!excl! Press any key to close..."
            call :prompt "excl" "pause"
            )
        )
    exit /b

:resetprompt
    set "choices=yn"
    call :prompt "Start again with same file? (Yes or Enter / No):"
    call :choice !choices!
    if !errorlevel! leq 1 (
        call :initformat & call :cmdheight "input" & goto :inputprompts
        ) else (
            exit
        )
    exit /b

:initformat
    if /i "!colorscheme:~0,1!"=="l" (
        color F0
        ) else (
        color 0F
        )
    set "version=0.3" & rem Script version
    for /f %%a in ('"prompt $H &echo on &for %%b in (1) do rem"') do set bs=%%a
    set "cmdpadtextwidth=60" & set "cmdpadwidth=3" & set /a "cmdwidth=!cmdpadtextwidth!+(!cmdpadwidth!*2)" & set "cmdheight=8"
    set "ws=                         " & set "ws=!ws!!ws!!ws!!ws!" & set "cmdpad=!ws:~-%cmdpadwidth%!"
    set "hl=תתתתתתתתתתתתתתתתתתתתתתתתת" & set "hl=!hl!!hl!!hl!!hl!" & rem Header line
    mode con: cols=!cmdwidth! lines=!cmdheight! & title MGSV Custom Texture Path Hex Replacer ^(v!version!^)
    set "inputprompttext=Target File"
    set "ftexorigprompttext=Original FTEX Path"
    set "ftexcustomprompttext=Custom FTEX Path"
    set "whitelist=fmdl, fv2"
    set "erp=(^!)" & rem Error message prefix
    rem Reset relevant variables apart from input file
    set "reset=ftexorig!lf!ftexcustom!lf!finalinputprompt!lf!complete"
    for /f "delims=" %%a in ("!reset!") do (
        set "%%a=" & set "%%ahex="
        )
    set lf=^


    exit /b

:input
    set "count=0"
    set args="!args:"=!"
    for /f "tokens=1 delims=:" %%d in (!args!) do (
        for %%l in ("!lf!") do (
            set args=!args:%%d:\=%%l%%d:\!
            )
        )
    set "args=!args: "="!"
    set "args=!args:~2!"

    for %%f in (!args!) do (
        setlocal disabledelayedexpansion
        set "infull=%%f"
        setlocal enabledelayedexpansion
        call :escape infull
        for /f "delims=" %%e in ("!infull!") do (
            endlocal & endlocal
            set "infull=%%e"
            call :unescape infull & set "infull=!infull:"=!"
            )
        rem Determine whether file or directory
        set isfile=1&pushd "!infull!" 2>nul&&(popd&set isfile=)||(if not exist "!infull!" set isfile=)
        if defined isfile (
            set "isfile="
            setlocal disabledelayedexpansion
            for %%x in (%%f) do set "inex=%%~xx"
            setlocal enabledelayedexpansion
            call :skippable inex skippable
            if defined skippable (
                endlocal & endlocal
                ) else (
                endlocal & endlocal
                set /a "count+=1"
                call :escape infull
                for %%c in (!count!) do (
                    set "infull[%%c]=!infull!"
                    call :unescape infull[%%c]
                    )
                )
            )
        )

    for /l %%i in (1,1,!count!) do (
        set "infull=!infull[%%i]!"
        call :escape infull & set "infull=!infull:"=!"
        for %%p in ("!infull!") do (
            set "indr[%%i]=%%~dp"
            set "inpa[%%i]=%%~pp"
            set "inna[%%i]=%%~np"
            set "inex[%%i]=%%~xp"
            )
        call :unescape inpa[%%i] & set "inpa[%%i]=!inpa[%%i]:"=!"
        call :unescape inna[%%i] & set "inna[%%i]=!inna[%%i]:"=!"
        call :unescape inex[%%i] & set "inex[%%i]=!inex[%%i]:"=!"
        for %%s in (!infull[%%i]!) do if %%~zs equ 0 set "zerobytes[%%i]=1"
        set "infull="
        )

    if !count! equ 0 (
        set "count="
        call :error "errorinvalidmodel" & set "input=" & goto :inputprompts
        ) else (
        rem Make the first file the exclusive input (if more than one input entered)
        set "input=!infull[1]!"
        )
    exit /b

:inputprompt
    if not defined %~1 (
        call :heading "!%~1prompttext!"

        if defined error (
            if defined errorinvalidmodel (
                call :error "reset" "errorinvalidmodel"
                set "l=!erp! Path either isn't a .fmdl/.fv2 file or doesn't exist." & call :newlines
            )
            if defined errorinvalidtexture (
                call :error "reset" "errorinvalidtexture"
                set "l=!erp! Path doesn't contain a .ftex." & call :newlines
            )
            if defined errortexturepath (
                call :error "reset" "errortexturepath"
                set "l=!erp! Path inside 'Assets' contains invalid characters (eg: spaces, brackets). Please check and rename." & call :newlines
            )
            if defined errortexturepathalt (
                call :error "reset" "errortexturepathalt"
                set "l=!erp! Path not usable as FTEX is neither contained in an 'Assets' directory nor has a valid existing hashed filename." & call :newlines
            )
            if defined errornoassetsdir (
                call :error "reset" "errornoassetsdir"
                set "l=!erp! Path doesn't contain an 'Assets' directory." & call :newlines
            )
        )

        call :prompt "Drag and drop file here then press Enter:" "%~1"
        call :detectemptyinput "%~1"
        if defined %~1 (
            call :trimspace "%~1"
            call :wrapquotes "%~1"
            if "%~1"=="input" (
                rem Check if valid by sending it through input function (exist/whitelist check)
                set args="!%1!"
                call :input
                if not defined inex[1] set "%~1=" & goto :inputprompts
                ) else (
                    rem Check if FTEX by simpler extension comparison
                    set "%~1=!%~1:"=!"
                    if not "!%1:~-4!"=="ftex" (
                        set "%~1=" & call :error "errorinvalidtexture" & goto :inputprompts
                    ) else (
                        set "t=!%~1:\=/!"
                        set "t=!t:"=!"
                        rem Check for presence of `/Assets/` directory
                        if "!t:/Assets/=!"=="!t!" (
                            if "%~1"=="ftexcustom" (
                                set "%~1=" & set "t=" & call :error "errornoassetsdir" & goto :inputprompts
                            )
                            if "%~1"=="ftexorig" (
                                call :escape t & rem Escape to catch special characters
                                set "t=!t:"=!" & rem Strip double quotes again for consistency between pasted/dragged paths
                                if not "!t:/=!"=="!t!" (
                                    call :trimslash & rem Trim path (requires being a call)
                                )
                                set "to=!t!" & rem Backup original variable for later echo
                                set "t=!t:.ftex=!" & rem Strip extension for length check
                                call :len t tlen
                                if not "!tlen!"=="13" (
                                    if not "!tlen!"=="12" (
                                        if not "!tlen!"=="11" (
                                            set "%~1=" & set "t=" & call :error "errortexturepathalt" & goto :inputprompts
                                        )
                                    )
                                )
                                if !tlen! leq 13 (
                                    if !tlen! geq 11 (
                                        rem Check for presence of invalid characters in remaining path
                                        call :invalidpathcheck "t" "hashed"
                                        if defined invalid (
                                            set "%~1=" & set "t=" & call :error "errortexturepathalt" & goto :inputprompts
                                        ) else (
                                            rem Likely valid pre-hashed FTEX
                                            rem Rename heading to indicate detection
                                            set "%~1prompttext=!%~1prompttext! (Hashed Filename Assumed)"
                                            rem Add appropriate byte depending on hash
                                            if !tlen! leq 12 (
                                                if !tlen! equ 11 set "t=0!t!"
                                                set "t=68!t!"
                                                ) else (
                                                    if "!t:~0,1!"=="1" set "t=69!t:~1!"
                                                    if "!t:~0,1!"=="2" set "t=6A!t:~1!"
                                                    if "!t:~0,1!"=="3" set "t=6B!t:~1!"
                                                )
                                            set "t=15!t!"
                                            set "%~1=!to!" & set "%~1hexpre=!t!" & set "t=" & set "to="
                                        )
                                    )
                                ) 
                            )    
                        ) else (
                            call :escape t
                            call :trimassets
                            set "%~1=!t!" & set "t="
                            call :invalidpathcheck "%~1"
                            if defined invalid (
                                set "%~1=" & call :error "errortexturepath" & goto :inputprompts
                            )
                        )
                    )
                )
            call :cmdheight "%~1" & goto :inputprompts
            ) else (
            goto :inputprompts
            )
        ) else (
        call :echoprompt "%~1"
        )
    exit /b

:invalidpathcheck
    set "%~1=!%~1:"=!"
    set "invalid="
    if "%~2"=="hashed" (
        set "validchars=0123456789abcdefghijkjlmnopqrstuvwxyz"
        rem Check for lack of numbers
        cmd /c "echo !%~1! ^| findstr /r [0-9]"
        if !errorlevel! equ 1 set "invalid=1"
    ) else (
        set "validchars=0123456789abcdefghijkjlmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_/"
    )
    for /f "delims=%validchars%" %%a in ("!%~1:.ftex=!") do (
        set "invalid=1"
        )
    exit /b

:len
    set "s=!%~1!#"
    set "len=0"
    for %%p in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%p,1!" neq "" ( 
            set /a "len+=%%p"
            set "s=!s:~%%p!"
            )
        )
    set "s=" & set "%~2=!len!"
    exit /b

:linescalc
    set "l=!%~1!"
    set /a "l=!l!*100"
    set /a "l=!l!/!cmdpadtextwidth!"
    set /a "mod=!l! %% 100"
    if !l! lss 100 set "l=100"
    if !mod! gtr 0 (
        if !l! gtr 100 (
            set /a "add=100-!l:~-1!"
            set /a "l=!l!+!add!" & set "add="
            )
        )
    set /a "l=!l!/100" & set "%~1=!l!" & set "mod=" & set "l="
    exit /b

:newlines
    set l=!l:"=!
    call :len l llen
    set "lineswidth=!cmdpadtextwidth!"
    :newlinessub
    if !llen! gtr !lineswidth! (
        for %%w in (!lineswidth!) do (
            echo !cmdpad!!l:~0,%%w!
            set l=!l:~%%w!
            )
        if defined l goto :newlinessub
        )
    if !llen! leq !lineswidth! (
        echo !cmdpad!!l!
        )
    set "l=" & set "llen="
    echo. & rem Add new line spacer
    exit /b

:prompt
    set "t=%~2" & set "p=!bs!!cmdpad!>"
    rem To properly carry exclamation marks across call with prompt the string needs to be in existing variable.
    if "%~1"=="excl" (
        set "m=!%~1!" & set "excl="
    ) else (
        set "m=%~1"
    )
    if defined t (
        if "!t!"=="pause" (
            pause >nul|set /p "=!p! !m!  !bs!" & exit
        )
        if "!t!"=="pausecont" (
            pause >nul|set /p "=!p! !m!  !bs!" & exit /b
        )
        if "!t!"=="timeout" (
            timeout 1 >nul|set /p "=!p! !m!  !bs!" & exit
        )
        rem If none of the above assume regular prompt and second argument as input variable
        if "%~1"=="" set "m=!bs!" & rem For textless prompts. Backspace variable removes extra space.
        set /p "%~2=!p! !m!  !bs!" & exit /b
    ) else (
        <nul set /p "=!p! !m!  !bs!" & exit /b
    )
    exit /b

:scriptargs
    for %%f in ("!cmdcmdline!") do (
        setlocal disabledelayedexpansion
        set scr="%~f0"
        set scrdir="%~dp0"
        setlocal enabledelayedexpansion
        call :len scr scrlen
        call :len scrdir scrdirlen
        set "scrall=!scrlen! !scrdirlen!"
        for /f "tokens=1,2 delims= " %%a in ("!scrall!") do endlocal & endlocal & set "scrlen=%%a" & set "scrdirlen=%%b"
        )
    set "cmdcmdline=!cmdcmdline:~32!" & call set scr=%%cmdcmdline:~0,!scrlen!%%
    call set scrdir=%%cmdcmdline:~0,!scrdirlen!%%
    set "scrdir=!scrdir:~1,-1!"
    set "args=!cmdcmdline:~%scrlen%,-1!" & set "args=!args:* =!"
    exit /b

:setupcheck
    set "count=0"
    for %%b in (%*) do (
        set /a "count+=1"
        set "binaries=!binaries! %%b"
        set "binaries[!count!]=%%b"
        )
    if !count! gtr 1 set "plural=s"
    if not defined p set /a "cmdheight+=7" & rem Define minimum initial window height
    call :programpaths
    call :setupcheckcalc !binaries!
    if !p! geq 1 (
        call :cmdheightmanual "!cmdheight!"
        if !p2! gtr 1 if !p1! gtr 1 (
            call :heading "Initial Setup"
            set "l=You'll first need to grab the latest of the following:" & call :newlines
            rem Window height calc assumes one line per program description
            if /i not "!usequickhash:~0,1!"=="n" (
                set "l=ת QuickHash" & call :newlines
                ) else (
                set "l=ת GzsTool (BobDoleOwndU version)" & call :newlines
                )
            set "l=!ת XVI32 (hex editor)" & call :newlines
            set "l=Then follow the prompt!plural! below to set the program path!plural!." & call :newlines
            call :heading "Program Path!plural!"
            )
        if not !p1! gtr 1 if !p2! geq 1 (
            if !p2! gtr 1 set "pluralmissing=s"
            call :heading "Setup Update"
            set "l=Looks like the following program!pluralmissing! moved location:" & call :newlines
            for /f "delims=" %%b in ("!binariesmissing!") do (
                set "l=!ת %%b" & call :newlines
                )
            set "l=Follow the prompt!pluralmissing! below to update the path!pluralmissing!." & call :newlines
            call :heading "Program Path!pluralmissing!"
            )

        call :setupcheckpromptloop !binaries!

        set "excl=Setup complete^! Press any key to continue..."
        echo. & set "setupcomplete=1" & call :prompt "excl" "pausecont"
        ) else (
            call :initformat
        )
    set "p="
    if defined setupcomplete call :initformat & call :programpaths & goto :inputs & rem Break out of the setup
    exit /b

:setupcheckcalc
    set "p1=0" & set "p2=0"
    for %%b in (%*) do (
        if not defined %%b (
            set /a "p1+=1"
            if not defined p set /a "cmdheight+=2"
            )
        if not exist !%%b! (
            set /a "p2+=1"
            for /l %%i in (1,1,!count!) do (
                if "%%b"=="!binaries[%%i]!" (
                    set "binariesmissing=!binariesmissing!!lf!%%b"
                    if defined %%b set /a "cmdheight+=2"
                    )
                )
            )
        )
    set /a "p=!p1!+!p2!"
    exit /b

:setupcheckpromptloop
    for %%b in (%*) do (
        if not exist !%%b! (
            call :setupcheckprompt %%b %%bpath
            )
        )
    rem Write the program path to the script itself
    for %%b in (%*) do (
        if not exist !%%b! (
            >>!scr! echo set %%b=!%%bpath!
            )
        )
    exit /b

:setupcheckprompt
    if not defined %~2 (

        if defined error (
            if defined errorpath (
                call :error "reset" "errorpath"
                set "l=!erp! Program path entered doesn't exist. Please try again." & call :newlines
            )
            if defined errorversion (
                call :error "reset" "errorversion"
                set "l=!erp! BobDoleOwndU's version required. Please try again." & call :newlines
            )
        )
        
        call :prompt "Drag and drop %~1.exe here then press Enter:" "%~2"
        call :detectemptyinput "%~2"
        if defined %~2 (
            call :trimspace "%~2"
            set "exename=%~1.exe"
            rem Compare entered path to binary name (assumes no special characters in name)
            set "t=!%2:\=/!" & call :trimslash
            if /i not "!t!"=="!exename!" (
                set "%~2=" & set "exename=" & call :error "errorpath" & call :setupcheck
                )
            call :wrapquotes "%~2"
            if not exist "!%~2!" set "%~2=" & call :error "errorpath" & call :setupcheck

            rem Check if program is Bob's version by comparing to known output
            if "%~1"=="GzsTool" (
                for /f "usebackq tokens=1 delims= " %%a in (`!%~2! -d -hwe '/Assets/tpp/custom/test.ftex'`) do (
                    if not "%%a"=="6172ababdd4e3" (
                        set "%~2=" & call :error "errorversion" & call :setupcheck
                    )
                )
            )
            call :cmdheight "%~1path" & call :setupcheck
            ) else (
            call :setupcheck
            )
    ) else (
        call :echoprompt "%~2" noheading
    )
    exit /b

:skippable
    set "x=!%~1:"=!"
    call :escape whitelist & set "whitelist=!whitelist:"=!"
    rem Commands not joined on single line to avoid issues:
    call :escape x
    set "x=!x:"=!"
    set "x=!x:.=!"
    if "!whitelist:%x%=!"=="!whitelist!" set "%~2=1"
    exit /b

:trimassets
    rem Trim from last occurrence of `/Assets/`
    set "t=!t:"=!" & rem String mustn't contain double quotes for this function to work
    set "t=%t:/Assets/=" & set "trim=%"
    set "t=/Assets/!trim!" & set "trim="
    exit /b

:trimslash
    rem Trim from last occurrence of `/` (filename only)
    set "t=!t:"=!"
    set "t=%t:/=" & set "trim=%"
    set "t=!trim!" & set "trim="
    exit /b

:trimspace
    rem Remove leading/trailing whitespace
    call :escape %~1
    set "t1=!%~1:"=! "
    set "t=%t1: =" & (if "!t!" neq "" set "t2=!t2! !t!") & set "t=%" & set "t2=!t2:~1!"
    set "%~1=!t2!"
    call :unescape %~1
    set "t=" & set "t1=" & set "t2="
    exit /b

:wrapquotes
    set "%~1="!%~1!""
    set "%~1=!%~1:""="!"
    exit /b

endlocal

:: ------------------------------------ Program Paths --------------------------------------
:: -----------------------------------------------------------------------------------------

:programpaths
