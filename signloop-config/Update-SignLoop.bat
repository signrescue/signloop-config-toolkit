@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "tools\Update-SignLoop.ps1"
