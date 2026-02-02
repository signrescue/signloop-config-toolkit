@echo off
setlocal

:: Build script for getsignloop
:: Usage: build.bat [install|clean|release|help]

if "%1"=="" goto install
if /i "%1"=="install" goto install
if /i "%1"=="clean" goto clean
if /i "%1"=="release" goto release
if /i "%1"=="help" goto help
if /i "%1"=="-h" goto help
if /i "%1"=="/?" goto help

echo Unknown command: %1
goto help

:install
echo === Installing portable binaries ===
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\fetch-rclone.ps1"
if errorlevel 1 (
    echo ERROR: Failed to fetch rclone
    exit /b 1
)
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\fetch-croc.ps1"
if errorlevel 1 (
    echo ERROR: Failed to fetch croc
    exit /b 1
)
echo.
echo === Build complete ===
goto end

:clean
echo === Cleaning binaries ===
if exist "%~dp0signloop-config\bin\rclone.exe" (
    del "%~dp0signloop-config\bin\rclone.exe"
    echo Removed rclone.exe
)
if exist "%~dp0signloop-config\bin\croc.exe" (
    del "%~dp0signloop-config\bin\croc.exe"
    echo Removed croc.exe
)
if exist "%~dp0signloop-config\VERSION" (
    del "%~dp0signloop-config\VERSION"
    echo Removed VERSION
)
echo === Clean complete ===
goto end

:release
echo === Creating release package ===
echo.

:: Read version from VERSION file
set /p VERSION=<"%~dp0VERSION"
if "%VERSION%"=="" (
    echo ERROR: VERSION file is empty or missing
    exit /b 1
)
echo Version: %VERSION%
echo.

:: Run install first
call :install_binaries
if errorlevel 1 exit /b 1

:: Copy VERSION into signloop-config
echo Stamping version...
copy /y "%~dp0VERSION" "%~dp0signloop-config\VERSION" >nul
echo.

:: Create zip
set "ZIPNAME=signloop-config-%VERSION%.zip"
echo Creating %ZIPNAME%...
powershell -Command "Compress-Archive -Path '%~dp0signloop-config' -DestinationPath '%~dp0%ZIPNAME%' -Force"
if errorlevel 1 (
    echo ERROR: Failed to create zip
    exit /b 1
)
echo.
echo === Release package created: %ZIPNAME% ===
goto end

:install_binaries
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\fetch-rclone.ps1"
if errorlevel 1 (
    echo ERROR: Failed to fetch rclone
    exit /b 1
)
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\fetch-croc.ps1"
if errorlevel 1 (
    echo ERROR: Failed to fetch croc
    exit /b 1
)
exit /b 0

:help
echo Usage: build.bat [command]
echo.
echo Commands:
echo   install   Download rclone and croc to signloop-config/bin/ (default)
echo   clean     Remove binaries from signloop-config/bin/
echo   release   Build and package signloop-config-VERSION.zip
echo   help      Show this help message
echo.
goto end

:end
endlocal
