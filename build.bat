@echo off
setlocal

:: Build script for getsignloop
:: Usage: build.bat [install|clean|help]

if "%1"=="" goto install
if /i "%1"=="install" goto install
if /i "%1"=="clean" goto clean
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
echo === Clean complete ===
goto end

:help
echo Usage: build.bat [command]
echo.
echo Commands:
echo   install   Download rclone and croc to signloop-config/bin/ (default)
echo   clean     Remove binaries from signloop-config/bin/
echo   help      Show this help message
echo.
goto end

:end
endlocal
