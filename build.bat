@echo off
setlocal

set "source=build\app\outputs\flutter-apk\app-release.apk"

set "targetDir=C:\Users\wangyi\Downloads"

set "verson=%~1"
set "buildNumber=%~2"


if not exist "%targetDir%" (
    mkdir "%targetDir%"
)

call flutter build apk
explorer C:\Users\wangyi\Downloads

if "%~2"=="" (
    set "newName=%verson%"
) else (
    set "newName=%verson%(%buildNumber%)"
)
copy "%source%" "%targetDir%\we Tools v%newName%.apk" >nul

if errorlevel 1 (
    echo copy failed
    exit /b 1
) else (
    echo successes: "we Tools v%newName%.apk"
)

call flutter build aab
start .\build\app\outputs\bundle\release

endlocal