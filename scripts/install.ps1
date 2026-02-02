<#
.SYNOPSIS
    Install signloop-config toolkit.
.DESCRIPTION
    Downloads the latest release and extracts to a chosen location.
    Optionally creates a Desktop shortcut.
#>

$ErrorActionPreference = "Stop"

$RepoOwner = "signrescue"
$RepoName = "signloop-config-toolkit"
$DefaultInstallPath = "C:\signloop-config"

function Get-LatestReleaseUrl {
    $apiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest"
    $release = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
    $asset = $release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1
    if (-not $asset) {
        throw "No zip asset found in latest release"
    }
    return $asset.browser_download_url
}

function New-DesktopShortcut {
    param([string]$TargetPath)
    $shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "SignLoop Config.lnk"
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $TargetPath
    $Shortcut.Save()
    Write-Host "Created shortcut: $shortcutPath" -ForegroundColor Green
}

# Header
Write-Host ""
Write-Host "SignLoop Config Toolkit Installer" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Determine install location
$currentDir = (Get-Location).Path
Write-Host "Install location:"
Write-Host "  [1] Current directory: $currentDir"
Write-Host "  [2] Default: $DefaultInstallPath"
Write-Host ""
Write-Host "Choice [1/2]: " -NoNewline -ForegroundColor Yellow
$choice = Read-Host

if ($choice -eq "2") {
    $installPath = $DefaultInstallPath
} else {
    $installPath = $currentDir
}

# Confirm
Write-Host ""
Write-Host "Will install to: $installPath" -ForegroundColor White
Write-Host ""

# Download
Write-Host "Fetching latest release..." -ForegroundColor Cyan
$downloadUrl = Get-LatestReleaseUrl
$tempZip = Join-Path $env:TEMP "signloop-config.zip"

Write-Host "Downloading..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing

# Extract
Write-Host "Extracting..." -ForegroundColor Cyan
if (-not (Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
}
Expand-Archive -Path $tempZip -DestinationPath $installPath -Force

# Cleanup
Remove-Item $tempZip -Force

Write-Host ""
Write-Host "Installed to: $installPath" -ForegroundColor Green
Write-Host ""

# Shortcut prompt
Write-Host "Create Desktop shortcut? [y/N]: " -NoNewline -ForegroundColor Yellow
$shortcutChoice = Read-Host

if ($shortcutChoice -eq "y" -or $shortcutChoice -eq "Y") {
    New-DesktopShortcut -TargetPath $installPath
    Write-Host "Tip: You can pin this shortcut to Taskbar or Start Menu, or move it anywhere." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Done. Run welcome.bat to get started." -ForegroundColor Green
Write-Host ""
