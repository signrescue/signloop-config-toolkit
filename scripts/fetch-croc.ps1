<#
.SYNOPSIS
    Download croc executable for Windows.
.DESCRIPTION
    Fetches the croc binary from GitHub releases and places it in signloop-config/bin.
.EXAMPLE
    .\fetch-croc.ps1
    .\fetch-croc.ps1 -Version 10.3.1
#>
param (
    [string]$Version = "10.3.1",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$BinDir = Join-Path $RepoRoot "signloop-config\bin"
$CrocExe = Join-Path $BinDir "croc.exe"

if ((Test-Path $CrocExe) -and -not $Force) {
    Write-Host "croc.exe already exists. Use -Force to re-download." -ForegroundColor Yellow
    exit 0
}

if (-not (Test-Path $BinDir)) {
    New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
}

$Arch = if ([Environment]::Is64BitOperatingSystem) { "64bit" } else { "32bit" }
$ZipName = "croc_v${Version}_Windows-${Arch}.zip"
$Url = "https://github.com/schollz/croc/releases/download/v${Version}/${ZipName}"
$TempZip = Join-Path $env:TEMP $ZipName
$TempExtract = Join-Path $env:TEMP "croc_extract"

Write-Host "Downloading croc v${Version}..." -ForegroundColor Cyan
Write-Host "URL: $Url"

try {
    Invoke-WebRequest -Uri $Url -OutFile $TempZip -UseBasicParsing

    if (Test-Path $TempExtract) {
        Remove-Item -Recurse -Force $TempExtract
    }
    Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force

    $ExtractedExe = Join-Path $TempExtract "croc.exe"
    if (-not (Test-Path $ExtractedExe)) {
        throw "croc.exe not found in archive"
    }

    Copy-Item -Path $ExtractedExe -Destination $CrocExe -Force
    Write-Host "Installed croc.exe to $BinDir" -ForegroundColor Green

    # Verify version
    $InstalledVersion = & $CrocExe --version
    Write-Host "Installed: $InstalledVersion"
}
finally {
    if (Test-Path $TempZip) { Remove-Item $TempZip -Force }
    if (Test-Path $TempExtract) { Remove-Item -Recurse -Force $TempExtract }
}
