@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "tools\Walk-SignLoopConfig.ps1"
