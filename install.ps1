# Bambu Filament Profiles for Sovol SV08 Max - Windows Installer (PowerShell)
# This script installs the system profiles and optionally the machine configuration

param(
    [switch]$SkipMachineConfig = $false
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Sovol SV08 Max - BambuStudio Profile Installer" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Determine script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# BambuStudio paths
$BambuSystemDir = Join-Path $env:APPDATA "BambuStudio\system"
$BambuUserDir = Join-Path $env:APPDATA "BambuStudio\user"

# Check if BambuStudio directory exists
if (-not (Test-Path (Join-Path $env:APPDATA "BambuStudio"))) {
    Write-Host "❌ Error: BambuStudio directory not found." -ForegroundColor Red
    Write-Host "   Please install BambuStudio first and run it at least once." -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ BambuStudio directory found" -ForegroundColor Green
Write-Host ""

# Create system directory if it doesn't exist
if (-not (Test-Path $BambuSystemDir)) {
    New-Item -ItemType Directory -Path $BambuSystemDir -Force | Out-Null
}

# Check if Sovol system profiles already exist
$SovolSystemDir = Join-Path $BambuSystemDir "Sovol"
$SovolJson = Join-Path $BambuSystemDir "Sovol.json"

if (Test-Path $SovolSystemDir) {
    Write-Host "⚠️  Warning: Sovol system profiles already exist." -ForegroundColor Yellow
    $reply = Read-Host "   Do you want to overwrite them? (y/N)"

    if ($reply -ne 'y' -and $reply -ne 'Y') {
        Write-Host "Installation cancelled." -ForegroundColor Yellow
        exit 0
    }

    Write-Host "   Backing up existing profiles..." -ForegroundColor Yellow
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $BackupDir = "$SovolSystemDir.backup.$timestamp"

    Move-Item -Path $SovolSystemDir -Destination $BackupDir -Force

    if (Test-Path $SovolJson) {
        Move-Item -Path $SovolJson -Destination "$BackupDir.json" -Force
    }

    Write-Host "   ✓ Backup saved to: $BackupDir" -ForegroundColor Green
    Write-Host ""
}

# Install system profiles
Write-Host "Installing system profiles..." -ForegroundColor Cyan

Write-Host "  → Copying Sovol.json..."
Copy-Item -Path (Join-Path $ScriptDir "system\Sovol.json") -Destination $BambuSystemDir -Force

Write-Host "  → Copying machine model..."
$MachineDir = Join-Path $BambuSystemDir "Sovol\machine"
New-Item -ItemType Directory -Path $MachineDir -Force | Out-Null
Copy-Item -Path (Join-Path $ScriptDir "system\Sovol\machine\Sovol sv08 max.json") -Destination $MachineDir -Force

Write-Host "  → Copying 44 filament profiles..."
$FilamentDir = Join-Path $BambuSystemDir "Sovol\filament"
New-Item -ItemType Directory -Path $FilamentDir -Force | Out-Null
Copy-Item -Path (Join-Path $ScriptDir "system\Sovol\filament\*.json") -Destination $FilamentDir -Force

$ProfileCount = (Get-ChildItem -Path $FilamentDir -Filter "*.json").Count
Write-Host "  ✓ Installed $ProfileCount filament profiles" -ForegroundColor Green
Write-Host ""

# Ask about machine configuration
if (-not $SkipMachineConfig) {
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "Machine Configuration (Optional)" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Would you like to install the Sovol SV08 Max machine configuration?"
    Write-Host "This includes optimized settings for:"
    Write-Host "  • Start/end G-code with Klipper macros"
    Write-Host "  • Timelapse support"
    Write-Host "  • Direct drive retraction settings"
    Write-Host "  • Machine limits and speeds"
    Write-Host ""

    $reply = Read-Host "Install machine configuration? (y/N)"

    if ($reply -eq 'y' -or $reply -eq 'Y') {
        if (-not (Test-Path $BambuUserDir)) {
            Write-Host "❌ Error: User directory not found. Please run BambuStudio at least once." -ForegroundColor Red
        } else {
            $UserDirs = Get-ChildItem -Path $BambuUserDir -Directory | Where-Object { $_.Name -match '^\d+$' }

            if ($UserDirs.Count -eq 0) {
                Write-Host "❌ Error: No user profiles found. Please run BambuStudio at least once." -ForegroundColor Red
            } elseif ($UserDirs.Count -eq 1) {
                $UserId = $UserDirs[0].Name
                $MachineBaseDir = Join-Path $BambuUserDir "$UserId\machine\base"
                New-Item -ItemType Directory -Path $MachineBaseDir -Force | Out-Null
                Copy-Item -Path (Join-Path $ScriptDir "Sovol sv08 max 0.4 nozzle.json") -Destination $MachineBaseDir -Force
                Write-Host "  ✓ Machine configuration installed for user: $UserId" -ForegroundColor Green
            } else {
                Write-Host "Multiple user profiles found. Please select one:"
                for ($i = 0; $i -lt $UserDirs.Count; $i++) {
                    Write-Host "  $($i + 1). $($UserDirs[$i].Name)"
                }

                $selection = Read-Host "Enter number (1-$($UserDirs.Count))"
                $selectedIndex = [int]$selection - 1

                if ($selectedIndex -ge 0 -and $selectedIndex -lt $UserDirs.Count) {
                    $UserId = $UserDirs[$selectedIndex].Name
                    $MachineBaseDir = Join-Path $BambuUserDir "$UserId\machine\base"
                    New-Item -ItemType Directory -Path $MachineBaseDir -Force | Out-Null
                    Copy-Item -Path (Join-Path $ScriptDir "Sovol sv08 max 0.4 nozzle.json") -Destination $MachineBaseDir -Force
                    Write-Host "  ✓ Machine configuration installed for user: $UserId" -ForegroundColor Green
                } else {
                    Write-Host "  ❌ Invalid selection" -ForegroundColor Red
                }
            }
        }
        Write-Host ""
    } else {
        Write-Host "  ⊘ Skipped machine configuration installation" -ForegroundColor Yellow
        Write-Host ""
    }
}

# Installation complete
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✅ Installation Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Restart BambuStudio if it's running"
Write-Host "  2. Select 'Sovol sv08 max 0.4 nozzle' as your printer"
Write-Host "  3. Choose from 44 Bambu filament profiles in the dropdown"
Write-Host ""
Write-Host "Files installed:"
Write-Host "  • System vendor: $BambuSystemDir\Sovol.json"
Write-Host "  • Machine model: $BambuSystemDir\Sovol\machine\"
Write-Host "  • Filament profiles: $BambuSystemDir\Sovol\filament\ ($ProfileCount files)"
Write-Host ""
Write-Host "For troubleshooting, see README.md"
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")