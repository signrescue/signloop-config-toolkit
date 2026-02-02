# SignLoop Configuration Wizard

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Show-Header {
    param([string]$Title, [string]$Subtitle = "")
    Clear-Host
    Write-Host ""
    Write-Host "SignLoop Configuration Wizard" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    Write-Host ""
    if ($Title) {
        Write-Host "$Title" -ForegroundColor White
        if ($Subtitle) {
            Write-Host "$Subtitle" -ForegroundColor DarkGray
        }
        Write-Host ""
    }
}

function Show-Welcome {
    Show-Header
    Write-Host "Step 1: Cloud Settings"
    Write-Host "Step 2: SignLoop Specs"
    Write-Host "Step 3: Push Config"
    Write-Host ""
    Write-Host "Press any key to begin..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Invoke-Step1 {
    Show-Header "Step 1 of 3: Cloud Settings" "Configure your cloud connection"

    # Source the cloud script if it has functions, or just show stub message
    $cloudScript = Join-Path $scriptDir "Edit-SignLoopCloud.ps1"
    if (Test-Path $cloudScript) {
        # For now, just indicate this is a stub
        Write-Host "[Stub] Cloud settings would be configured here." -ForegroundColor DarkYellow
        Write-Host ""
    }

    Write-Host "Press any key to continue..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return $true
}

function Invoke-Step2 {
    Show-Header "Step 2 of 3: SignLoop Specs" "Define your SignLoop specifications"

    $specsScript = Join-Path $scriptDir "Edit-SignLoopSpecs.ps1"
    if (Test-Path $specsScript) {
        Write-Host "[Stub] SignLoop specs would be configured here." -ForegroundColor DarkYellow
        Write-Host ""
    }

    Write-Host "Press any key to continue..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    return $true
}

function Invoke-Step3 {
    $pushScript = Join-Path $scriptDir "Push-SignLoopConfig.ps1"
    $timeoutSeconds = 60

    Show-Header "Step 3 of 3: Push Config" "Deploy your configuration"

    Write-Host "Push configuration to remote appliance? [Y/n]: " -NoNewline -ForegroundColor Yellow
    $confirm = Read-Host

    if ($confirm -eq 'n' -or $confirm -eq 'N') {
        Write-Host ""
        Write-Host "Skipping push step." -ForegroundColor DarkYellow
        Start-Sleep -Seconds 1
        return $true
    }

    do {
        Show-Header "Step 3 of 3: Push Config" "Deploy your configuration"

        Write-Host "Enter the transfer code provided by the appliance."
        Write-Host "Code must be at least 8 characters. Timeout: ${timeoutSeconds}s" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "Code: " -NoNewline -ForegroundColor Yellow
        $code = Read-Host

        if ([string]::IsNullOrWhiteSpace($code)) {
            Write-Host ""
            Write-Host "No code entered. Skipping push step." -ForegroundColor DarkYellow
            Start-Sleep -Seconds 1
            return $true
        }

        if ($code.Length -lt 8) {
            Write-Host ""
            Write-Host "Code too short. Must be at least 8 characters." -ForegroundColor Red
            Write-Host "Press any key to try again..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            continue
        }

        Write-Host ""
        & $pushScript -Code $code -TimeoutSeconds $timeoutSeconds
        $exitCode = $LASTEXITCODE

        if ($exitCode -eq 0) {
            Write-Host ""
            Write-Host "Transfer initiated." -ForegroundColor Green
            Write-Host "(Remote appliance will not confirm receipt by design)" -ForegroundColor DarkGray
            Write-Host ""
            Write-Host "Press any key to continue..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            return $true
        } else {
            Write-Host ""
            Write-Host "Transfer failed (exit code: $exitCode)" -ForegroundColor Red
            Write-Host ""
            Write-Host "[R] Retry  [S] Skip  [Q] Quit: " -NoNewline -ForegroundColor Yellow
            $choice = Read-Host

            switch ($choice.ToLower()) {
                'r' { continue }
                's' { return $true }
                'q' { return $false }
                default { continue }
            }
        }
    } while ($true)
}

function Show-Complete {
    Show-Header "Setup Complete!"
    Write-Host "All steps have been completed." -ForegroundColor Green
    Write-Host ""
}

# Main wizard loop
do {
    Show-Welcome

    $success = Invoke-Step1
    if (-not $success) { break }

    $success = Invoke-Step2
    if (-not $success) { break }

    $success = Invoke-Step3
    if (-not $success) { break }

    Show-Complete

    Write-Host "Run again? [y/N]: " -NoNewline -ForegroundColor Yellow
    $again = Read-Host

} while ($again -eq 'y' -or $again -eq 'Y')
