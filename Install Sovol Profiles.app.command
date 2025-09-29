#!/bin/bash

# Bambu Filament Profiles for Sovol SV08 Max - macOS GUI Installer
# Version 1.0.0
# This creates a double-clickable installer with progress dialogs

# Determine script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Read version from VERSION file
VERSION=$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || echo "1.0.0")

# BambuStudio paths
BAMBU_SYSTEM_DIR="$HOME/Library/Application Support/BambuStudio/system"
BAMBU_USER_DIR="$HOME/Library/Application Support/BambuStudio/user"

# Function to show native macOS dialog
show_dialog() {
    osascript <<EOF
tell application "System Events"
    activate
    display dialog "$1" buttons {"OK"} default button 1 with icon note with title "Sovol SV08 Max Installer"
end tell
EOF
}

# Function to show error dialog
show_error() {
    osascript <<EOF
tell application "System Events"
    activate
    display dialog "$1" buttons {"OK"} default button 1 with icon stop with title "Installation Error"
end tell
EOF
}

# Function to show progress notification
show_notification() {
    osascript -e "display notification \"$1\" with title \"Sovol SV08 Max Installer\" sound name \"Glass\""
}

# Function to ask yes/no question
ask_question() {
    result=$(osascript <<EOF
tell application "System Events"
    activate
    display dialog "$1" buttons {"No", "Yes"} default button 2 with icon note with title "Sovol SV08 Max Installer"
    button returned of result
end tell
EOF
)
    echo "$result"
}

# Welcome message
welcome=$(osascript <<EOF
tell application "System Events"
    activate
    display dialog "Welcome to the Sovol SV08 Max Profile Installer!
Version $VERSION

This will install:
• 44 Bambu Lab filament profiles
• Sovol sv08 max machine model
• System vendor configuration

Click Continue to proceed." buttons {"Cancel", "Continue"} default button 2 with icon note with title "Sovol SV08 Max Installer"
    button returned of result
end tell
EOF
)

if [ "$welcome" != "Continue" ]; then
    exit 0
fi

# Check if BambuStudio exists
if [ ! -d "$HOME/Library/Application Support/BambuStudio" ]; then
    show_error "BambuStudio directory not found.

Please install BambuStudio and run it at least once before installing these profiles."
    exit 1
fi

show_notification "Installing system profiles..."

# Create system directory
mkdir -p "$BAMBU_SYSTEM_DIR"

# Check for existing installation
if [ -d "$BAMBU_SYSTEM_DIR/Sovol" ]; then
    backup=$(ask_question "Sovol profiles already exist.

Would you like to back them up and continue?")

    if [ "$backup" = "Yes" ]; then
        BACKUP_DIR="$BAMBU_SYSTEM_DIR/Sovol.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$BAMBU_SYSTEM_DIR/Sovol" "$BACKUP_DIR"
        if [ -f "$BAMBU_SYSTEM_DIR/Sovol.json" ]; then
            mv "$BAMBU_SYSTEM_DIR/Sovol.json" "$BACKUP_DIR.json"
        fi
        show_notification "Backup created"
    else
        exit 0
    fi
fi

# Install system profiles
show_notification "Copying vendor configuration..."
cp "$SCRIPT_DIR/system/Sovol.json" "$BAMBU_SYSTEM_DIR/" 2>/dev/null || {
    show_error "Failed to copy Sovol.json. Make sure all files are present."
    exit 1
}

show_notification "Installing machine model..."
mkdir -p "$BAMBU_SYSTEM_DIR/Sovol/machine"
cp "$SCRIPT_DIR/system/Sovol/machine/Sovol sv08 max.json" "$BAMBU_SYSTEM_DIR/Sovol/machine/" 2>/dev/null || {
    show_error "Failed to copy machine model."
    exit 1
}

show_notification "Installing filament profiles..."
mkdir -p "$BAMBU_SYSTEM_DIR/Sovol/filament"
cp "$SCRIPT_DIR/system/Sovol/filament/"*.json "$BAMBU_SYSTEM_DIR/Sovol/filament/" 2>/dev/null || {
    show_error "Failed to copy filament profiles."
    exit 1
}

PROFILE_COUNT=$(ls -1 "$BAMBU_SYSTEM_DIR/Sovol/filament" | wc -l | tr -d ' ')

# Ask about machine configuration
machine_config=$(ask_question "System profiles installed successfully! ($PROFILE_COUNT filament profiles)

Would you also like to install the machine configuration?

This includes:
• Optimized start/end G-code
• Timelapse support
• Direct drive settings")

if [ "$machine_config" = "Yes" ]; then
    if [ ! -d "$BAMBU_USER_DIR" ]; then
        show_error "User directory not found. Please run BambuStudio at least once."
    else
        USER_DIRS=$(find "$BAMBU_USER_DIR" -maxdepth 1 -type d -name "[0-9]*" 2>/dev/null)

        if [ -z "$USER_DIRS" ]; then
            show_error "No user profiles found. Please run BambuStudio at least once."
        else
            USER_COUNT=$(echo "$USER_DIRS" | wc -l | tr -d ' ')

            if [ "$USER_COUNT" -eq 1 ]; then
                USER_ID=$(basename "$USER_DIRS")
                MACHINE_DIR="$BAMBU_USER_DIR/$USER_ID/machine/base"
                mkdir -p "$MACHINE_DIR"
                cp "$SCRIPT_DIR/Sovol sv08 max 0.4 nozzle.json" "$MACHINE_DIR/"
                show_notification "Machine configuration installed"
            else
                # Multiple users - just install to first one
                USER_ID=$(echo "$USER_DIRS" | head -1 | xargs basename)
                MACHINE_DIR="$BAMBU_USER_DIR/$USER_ID/machine/base"
                mkdir -p "$MACHINE_DIR"
                cp "$SCRIPT_DIR/Sovol sv08 max 0.4 nozzle.json" "$MACHINE_DIR/"
                show_notification "Machine configuration installed to first user profile"
            fi
        fi
    fi
fi

# Success dialog
osascript <<EOF
tell application "System Events"
    activate
    display dialog "✅ Installation Complete!

Installed:
• $PROFILE_COUNT filament profiles
• Machine model
• Vendor configuration

Next steps:
1. Restart BambuStudio
2. Select 'Sovol sv08 max 0.4 nozzle'
3. Choose from 44 Bambu filaments

Enjoy your new profiles!" buttons {"Done"} default button 1 with icon note with title "Installation Success"
end tell
EOF

show_notification "Installation complete!"