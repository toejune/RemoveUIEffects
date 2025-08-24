@echo off
setlocal
setlocal enabledelayedexpansion

set MSBUILD="C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
set CONFIG=Release

set PROJECTNAME=RemoveUIEffects
set PROJECT=%PROJECTNAME%.sln
set CSPROJ=%PROJECTNAME%.csproj
set TMPFILE=%CSPROJ%.tmp
set REPLACED=0

if not exist "%~dp0dist\" mkdir "%~dp0dist\"
if not exist "%~dp0dist\BepInEx\" mkdir "%~dp0dist\BepInEx\"
if not exist "%~dp0dist\BepInEx\plugins\" mkdir "%~dp0dist\BepInEx\plugins\"

:UPDATE_VERSION
(for /f "usebackq delims=" %%L in ("%CSPROJ%") do (
    set "LINE=%%L"

    if !REPLACED! == 0 (
        call set "CHECK=!LINE:<Version>=!%"
        if not "!CHECK!"=="!LINE!" (
            set "FILEVER=!LINE:    <Version>=!"
            set "FILEVER=!FILEVER:</Version>=!"
            
            for /f "tokens=1-3 delims=." %%a in ("!FILEVER!") do (
                set "MAJOR=%%a"
                set "MINOR=%%b"
                set "BUILD=%%c"
            )

            set /a BUILD+=1
            set "NEWVER=!MAJOR!.!MINOR!.!BUILD!"

            set "LINE=    <Version>!NEWVER!</Version>"
            set "REPLACED=1"
        )
    )

    echo(!LINE!
)) > "%TMPFILE%"

:MOVE_FILE
move /y "%TMPFILE%" "%CSPROJ%" >nul

:MS_BUILD
%MSBUILD% %PROJECT% /t:Build /p:Configuration=%CONFIG%
set RESULT=%ERRORLEVEL%
if %RESULT% neq 0 (
    echo *** Build FAILED with exit code %RESULT% ***
    exit /b %RESULT%
)

:TCLI
where tcli >nul 2>nul
if %ERRORLEVEL%==0 (
    echo Running tcli build...
    tcli build --package-version !NEWVER!

    if exist ".env" (
        for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
            set "%%a=%%b"
        )
    )

    echo New version: !NEWVER!
    echo Are you sure you want to publish?
    pause

    echo WOULD PUBLISH HERE
    @REM if defined !TCLI_AUTH_TOKEN! (
    @REM     echo TCLI auth token found
    @REM     tcli publish --package-version !NEWVER! --token !TCLI_AUTH_TOKEN!
    @REM ) else (
    @REM     echo WARNING: TCLI auth token not found! Skipping publish...
    @REM )

) else (
    echo tcli not found, skipping...
)

endlocal
pause