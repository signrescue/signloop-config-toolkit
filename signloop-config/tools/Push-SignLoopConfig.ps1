<#
.SYNOPSIS
    Push SignLoop configuration files via croc with a specified code.
.DESCRIPTION
    Sends the signloop-config directory or specific config files to a remote recipient using croc.
.EXAMPLE
    Push-SignLoopConfig.ps1 my-secret-code
    Push-SignLoopConfig.ps1 -Code my-code -All
#>
param (
    [Parameter(Position = 0)]
    [string]$Code,

    [switch]$All,

    [switch]$Help,

    [switch]$ShowPath,

    [int]$TimeoutSeconds = 120,

    [int]$MinCodeLength = 8
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigRoot = Split-Path -Parent $ScriptDir

function Show-Usage {
    Write-Host "Usage: Push-SignLoopConfig.ps1 <code> [options]"
    Write-Host ""
    Write-Host "Arguments:"
    Write-Host "  code            Transfer code (min $MinCodeLength chars)"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -All             Send entire signloop-config folder (default: config only)"
    Write-Host "  -ShowPath        Show full path being sent"
    Write-Host "  -TimeoutSeconds  Transfer timeout (default: 120)"
    Write-Host "  -MinCodeLength   Minimum code length (default: 8)"
    Write-Host "  -Help            Show this help"
}

if ($Help -or $args -contains "-?" -or $args -contains "/?") {
    Show-Usage
    exit 0
}

$CrocPath = Join-Path $ConfigRoot "bin\croc.exe"
$RequiredVersion = "10.3.1"

if (-not (Test-Path $CrocPath)) {
    Write-Host "Error: Croc not found at $CrocPath" -ForegroundColor Red
    exit 1
}

$versionInfo = & $CrocPath --version
if ($versionInfo -notmatch $RequiredVersion) {
    Write-Host "Error: Version mismatch. Required: $RequiredVersion. Found: $versionInfo" -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrWhiteSpace($Code)) {
    Show-Usage
    exit 1
}

if ($Code.Length -lt $MinCodeLength) {
    Write-Host "Error: Code too short. Minimum $MinCodeLength characters." -ForegroundColor Red
    exit 1
}

if ($All) {
    $SendPath = $ConfigRoot
} else {
    $SendPath = Join-Path $ConfigRoot "config"
}

if (-not (Test-Path $SendPath)) {
    Write-Host "Error: Path not found: $SendPath" -ForegroundColor Red
    exit 1
}

if ($ShowPath) {
    Write-Host "Sending: $SendPath" -ForegroundColor Cyan
} else {
    Write-Host "Sending configuration..." -ForegroundColor Cyan
}

$Arguments = "--yes --quiet send --code $Code `"$SendPath`""
$TimeoutMs = $TimeoutSeconds * 1000

try {
    $process = Start-Process -FilePath $CrocPath -ArgumentList $Arguments -PassThru -NoNewWindow
    if (-not $process.WaitForExit($TimeoutMs)) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        Write-Host "Error: Timeout after $TimeoutSeconds seconds." -ForegroundColor Red
        exit 1
    }
    if ($process.ExitCode -eq 0) {
        Write-Host "Config pushed successfully." -ForegroundColor Green
    }
    exit $process.ExitCode
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
