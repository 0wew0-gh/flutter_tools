@echo off
setlocal

set "source=build\app\outputs\flutter-apk\app-release.apk"

@REM set "targetDir=C:\Users\wangyi\Downloads"
set "shareDir=D:\share\weTools"

set "verson=%~1"
set "buildNumber=%~2"


@REM if not exist "%targetDir%" (
@REM     mkdir "%targetDir%"
@REM )

if not exist "%shareDir%" (
    mkdir "%shareDir%"
)

call flutter build apk

if "%~2"=="" (
    set "newName=%verson%"
) else (
    set "newName=%verson%(%buildNumber%)"
)
copy "%source%" "%shareDir%\we Tools v%newName%.apk" >nul

if errorlevel 1 (
    echo copy failed
    exit /b 1
) else (
    echo successes: "we Tools v%newName%.apk"
)

call flutter build aab
copy ".\build\app\outputs\bundle\release\app-release.aab" "%shareDir%\app-release.aab" >nul
@REM 打开文件夹
explorer "%shareDir%"
@REM 打开命令行
@REM start "%shareDir%"


@REM 打开aab文件夹 
@REM start .\build\app\outputs\bundle\release

endlocal