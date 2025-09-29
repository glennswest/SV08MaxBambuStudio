# Bambu Filament Profiles for Sovol SV08 Max - Windows GUI Installer
# Version 1.0.0
# Double-click to run, or right-click -> Run with PowerShell

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

# Determine script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Read version from VERSION file
$Version = "1.0.0"
$VersionFile = Join-Path $ScriptDir "VERSION"
if (Test-Path $VersionFile) {
    $Version = Get-Content $VersionFile -Raw | ForEach-Object { $_.Trim() }
}

# BambuStudio paths
$BambuSystemDir = Join-Path $env:APPDATA "BambuStudio\system"
$BambuUserDir = Join-Path $env:APPDATA "BambuStudio\user"

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Sovol SV08 Max Profile Installer"
$form.Size = New-Object System.Drawing.Size(500, 400)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false

# Title label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(450, 30)
$titleLabel.Text = "Sovol SV08 Max Profile Installer v$Version"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($titleLabel)

# Description label
$descLabel = New-Object System.Windows.Forms.Label
$descLabel.Location = New-Object System.Drawing.Point(20, 60)
$descLabel.Size = New-Object System.Drawing.Size(450, 80)
$descLabel.Text = "This will install:`n• 44 Bambu Lab filament profiles`n• Sovol sv08 max machine model`n• System vendor configuration"
$descLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.Controls.Add($descLabel)

# Progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 150)
$progressBar.Size = New-Object System.Drawing.Size(450, 25)
$progressBar.Style = "Continuous"
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0
$form.Controls.Add($progressBar)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 180)
$statusLabel.Size = New-Object System.Drawing.Size(450, 60)
$statusLabel.Text = "Ready to install..."
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.Controls.Add($statusLabel)

# Machine config checkbox
$machineCheckbox = New-Object System.Windows.Forms.CheckBox
$machineCheckbox.Location = New-Object System.Drawing.Point(20, 250)
$machineCheckbox.Size = New-Object System.Drawing.Size(450, 30)
$machineCheckbox.Text = "Install machine configuration (start/end G-code, timelapse support)"
$machineCheckbox.Checked = $true
$machineCheckbox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.Controls.Add($machineCheckbox)

# Install button
$installButton = New-Object System.Windows.Forms.Button
$installButton.Location = New-Object System.Drawing.Point(250, 300)
$installButton.Size = New-Object System.Drawing.Size(100, 35)
$installButton.Text = "Install"
$installButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($installButton)

# Cancel button
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(370, 300)
$cancelButton.Size = New-Object System.Drawing.Size(100, 35)
$cancelButton.Text = "Cancel"
$cancelButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

# Update status function
function Update-Status {
    param($message, $progress)
    $statusLabel.Text = $message
    $progressBar.Value = $progress
    $form.Refresh()
    Start-Sleep -Milliseconds 300
}

# Install button click event
$installButton.Add_Click({
    try {
        # Disable controls
        $installButton.Enabled = $false
        $cancelButton.Enabled = $false
        $machineCheckbox.Enabled = $false

        Update-Status "Checking BambuStudio installation..." 10

        # Check if BambuStudio exists
        if (-not (Test-Path (Join-Path $env:APPDATA "BambuStudio"))) {
            [System.Windows.Forms.MessageBox]::Show(
                "BambuStudio directory not found.`n`nPlease install BambuStudio and run it at least once before installing these profiles.",
                "Installation Error",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
            $form.Close()
            return
        }

        Update-Status "Creating directories..." 20

        # Create system directory
        if (-not (Test-Path $BambuSystemDir)) {
            New-Item -ItemType Directory -Path $BambuSystemDir -Force | Out-Null
        }

        # Check for existing installation
        $SovolSystemDir = Join-Path $BambuSystemDir "Sovol"
        $SovolJson = Join-Path $BambuSystemDir "Sovol.json"

        if (Test-Path $SovolSystemDir) {
            $result = [System.Windows.Forms.MessageBox]::Show(
                "Sovol profiles already exist.`n`nWould you like to back them up and continue?",
                "Existing Installation Found",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )

            if ($result -eq [System.Windows.Forms.DialogResult]::No) {
                $form.Close()
                return
            }

            Update-Status "Backing up existing profiles..." 25

            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $BackupDir = "$SovolSystemDir.backup.$timestamp"

            Move-Item -Path $SovolSystemDir -Destination $BackupDir -Force
            if (Test-Path $SovolJson) {
                Move-Item -Path $SovolJson -Destination "$BackupDir.json" -Force
            }
        }

        Update-Status "Installing vendor configuration..." 35
        Copy-Item -Path (Join-Path $ScriptDir "system\Sovol.json") -Destination $BambuSystemDir -Force

        Update-Status "Installing machine model..." 50
        $MachineDir = Join-Path $BambuSystemDir "Sovol\machine"
        New-Item -ItemType Directory -Path $MachineDir -Force | Out-Null
        Copy-Item -Path (Join-Path $ScriptDir "system\Sovol\machine\Sovol sv08 max.json") -Destination $MachineDir -Force

        Update-Status "Installing 44 filament profiles..." 65
        $FilamentDir = Join-Path $BambuSystemDir "Sovol\filament"
        New-Item -ItemType Directory -Path $FilamentDir -Force | Out-Null
        Copy-Item -Path (Join-Path $ScriptDir "system\Sovol\filament\*.json") -Destination $FilamentDir -Force

        $ProfileCount = (Get-ChildItem -Path $FilamentDir -Filter "*.json").Count

        Update-Status "System profiles installed successfully!" 80

        # Install machine configuration if selected
        if ($machineCheckbox.Checked) {
            Update-Status "Installing machine configuration..." 85

            if (Test-Path $BambuUserDir) {
                $UserDirs = Get-ChildItem -Path $BambuUserDir -Directory | Where-Object { $_.Name -match '^\d+$' }

                if ($UserDirs.Count -gt 0) {
                    $UserId = $UserDirs[0].Name
                    $MachineBaseDir = Join-Path $BambuUserDir "$UserId\machine\base"
                    New-Item -ItemType Directory -Path $MachineBaseDir -Force | Out-Null
                    Copy-Item -Path (Join-Path $ScriptDir "Sovol sv08 max 0.4 nozzle.json") -Destination $MachineBaseDir -Force
                }
            }
        }

        Update-Status "Installation complete!" 100

        # Success message
        [System.Windows.Forms.MessageBox]::Show(
            "✅ Installation Complete!`n`nInstalled:`n• $ProfileCount filament profiles`n• Machine model`n• Vendor configuration`n`nNext steps:`n1. Restart BambuStudio`n2. Select 'Sovol sv08 max 0.4 nozzle'`n3. Choose from 44 Bambu filaments`n`nEnjoy your new profiles!",
            "Installation Success",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )

        $form.Close()

    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Installation failed: $($_.Exception.Message)",
            "Installation Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        $form.Close()
    }
})

# Cancel button click event
$cancelButton.Add_Click({
    $form.Close()
})

# Show the form
[void]$form.ShowDialog()
$form.Dispose()