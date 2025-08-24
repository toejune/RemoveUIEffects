@echo off
setlocal
setlocal enabledelayedexpansion

set MSBUILD="C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
set CONFIG=Release

set PROJECTNAME=RemoveUIEffects
set PROJECT=%PROJECTNAME%.sln

if not exist "%~dp0dist\" mkdir "%~dp0dist\"
if not exist "%~dp0dist\BepInEx\" mkdir "%~dp0dist\BepInEx\"
if not exist "%~dp0dist\BepInEx\plugins\" mkdir "%~dp0dist\BepInEx\plugins\"

%MSBUILD% %PROJECT% /t:Build /p:Configuration=%CONFIG%
set RESULT=%ERRORLEVEL%
if %RESULT% neq 0 (
    echo *** Build FAILED with exit code %RESULT% ***
    exit /b %RESULT%
)

where tcli >nul 2>nul
if %ERRORLEVEL%==0 (
    echo Running tcli build...
    tcli build

    set "DISTDIR=%~dp0dist"
    set "VERSIONFILE=%~dp0dist\version.txt"

    if exist "!VERSIONFILE!" (
        set "FILEVER="
        <"!VERSIONFILE!" set /p FILEVER=
    ) else (
        set "FILEVER=1.0.0"
    )

    echo Current version: !FILEVER!

    for /f "tokens=1-3 delims=." %%a in ("!FILEVER!") do (
        set "MAJOR=%%a"
        set "MINOR=%%b"
        set "BUILD=%%c"
    )

    set /a BUILD+=1
    set "NEWVER=!MAJOR!.!MINOR!.!BUILD!"

    echo New version: !NEWVER!
    echo !NEWVER!>"!VERSIONFILE!"

    if exist ".env" (
        for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
            set "%%a=%%b"
        )
    )

    if defined !TCLI_AUTH_TOKEN! (
        echo TCLI auth token found
        tcli publish --package-version !NEWVER! --token !TCLI_AUTH_TOKEN!
    ) else (
        echo WARNING: TCLI auth token not found! Skipping publish...
    )

) else (
    echo tcli not found, skipping...
)

endlocal
pause