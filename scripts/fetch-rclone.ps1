<#
.SYNOPSIS
    Download rclone executable for Windows.
.DESCRIPTION
    Fetches the rclone binary from the official site and places it in signloop-config/bin.
.EXAMPLE
    .\fetch-rclone.ps1
    .\fetch-rclone.ps1 -Version 1.68.2
#>
param (
    [string]$Version = "1.68.2",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$BinDir = Join-Path $RepoRoot "signloop-config\bin"
$RcloneExe = Join-Path $BinDir "rclone.exe"

if ((Test-Path $RcloneExe) -and -not $Force) {
    Write-Host "rclone.exe already exists. Use -Force to re-download." -ForegroundColor Yellow
    exit 0
}

if (-not (Test-Path $BinDir)) {
    New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
}

$Arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "386" }
$ZipName = "rclone-v${Version}-windows-${Arch}.zip"
$Url = "https://downloads.rclone.org/v${Version}/${ZipName}"
$TempZip = Join-Path $env:TEMP $ZipName
$TempExtract = Join-Path $env:TEMP "rclone_extract"

Write-Host "Downloading rclone v${Version}..." -ForegroundColor Cyan
Write-Host "URL: $Url"

try {
    Invoke-WebRequest -Uri $Url -OutFile $TempZip -UseBasicParsing

    if (Test-Path $TempExtract) {
        Remove-Item -Recurse -Force $TempExtract
    }
    Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force

    # rclone extracts to a subdirectory
    $ExtractedExe = Get-ChildItem -Path $TempExtract -Recurse -Filter "rclone.exe" | Select-Object -First 1
    if (-not $ExtractedExe) {
        throw "rclone.exe not found in archive"
    }

    Copy-Item -Path $ExtractedExe.FullName -Destination $RcloneExe -Force
    Write-Host "Installed rclone.exe to $BinDir" -ForegroundColor Green

    # Verify version
    $InstalledVersion = & $RcloneExe --version | Select-Object -First 1
    Write-Host "Installed: $InstalledVersion"
}
finally {
    if (Test-Path $TempZip) { Remove-Item $TempZip -Force }
    if (Test-Path $TempExtract) { Remove-Item -Recurse -Force $TempExtract }
}
