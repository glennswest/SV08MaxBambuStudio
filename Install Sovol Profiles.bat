@echo off
REM Bambu Filament Profiles for Sovol SV08 Max - Windows Installer Launcher
REM Double-click this file to run the installer

echo Starting Sovol SV08 Max Profile Installer...
echo.

REM Run PowerShell script with bypass execution policy
powershell.exe -ExecutionPolicy Bypass -File "%~dp0Install-SovolProfiles.ps1"

REM Keep window open only if there was an error
if errorlevel 1 (
    echo.
    echo Installation failed. Press any key to exit...
    pause >nul
)