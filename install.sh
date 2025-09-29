#!/bin/bash

# Bambu Filament Profiles for Sovol SV08 Max - macOS Installer
# This script installs the system profiles and optionally the machine configuration

set -e

echo "========================================="
echo "Sovol SV08 Max - BambuStudio Profile Installer"
echo "========================================="
echo ""

# Determine script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# BambuStudio paths
BAMBU_SYSTEM_DIR="$HOME/Library/Application Support/BambuStudio/system"
BAMBU_USER_DIR="$HOME/Library/Application Support/BambuStudio/user"

# Check if BambuStudio directory exists
if [ ! -d "$HOME/Library/Application Support/BambuStudio" ]; then
    echo "❌ Error: BambuStudio directory not found."
    echo "   Please install BambuStudio first and run it at least once."
    exit 1
fi

echo "✓ BambuStudio directory found"
echo ""

# Create system directory if it doesn't exist
mkdir -p "$BAMBU_SYSTEM_DIR"

# Check if Sovol system profiles already exist
if [ -d "$BAMBU_SYSTEM_DIR/Sovol" ]; then
    echo "⚠️  Warning: Sovol system profiles already exist."
    read -p "   Do you want to overwrite them? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    echo "   Backing up existing profiles..."
    BACKUP_DIR="$BAMBU_SYSTEM_DIR/Sovol.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$BAMBU_SYSTEM_DIR/Sovol" "$BACKUP_DIR"
    if [ -f "$BAMBU_SYSTEM_DIR/Sovol.json" ]; then
        mv "$BAMBU_SYSTEM_DIR/Sovol.json" "$BACKUP_DIR.json"
    fi
    echo "   ✓ Backup saved to: $BACKUP_DIR"
    echo ""
fi

# Install system profiles
echo "Installing system profiles..."
echo "  → Copying Sovol.json..."
cp "$SCRIPT_DIR/system/Sovol.json" "$BAMBU_SYSTEM_DIR/"

echo "  → Copying machine model..."
mkdir -p "$BAMBU_SYSTEM_DIR/Sovol/machine"
cp "$SCRIPT_DIR/system/Sovol/machine/Sovol sv08 max.json" "$BAMBU_SYSTEM_DIR/Sovol/machine/"

echo "  → Copying 44 filament profiles..."
mkdir -p "$BAMBU_SYSTEM_DIR/Sovol/filament"
cp "$SCRIPT_DIR/system/Sovol/filament/"*.json "$BAMBU_SYSTEM_DIR/Sovol/filament/"

PROFILE_COUNT=$(ls -1 "$BAMBU_SYSTEM_DIR/Sovol/filament" | wc -l | tr -d ' ')
echo "  ✓ Installed $PROFILE_COUNT filament profiles"
echo ""

# Ask about machine configuration
echo "========================================="
echo "Machine Configuration (Optional)"
echo "========================================="
echo ""
echo "Would you like to install the Sovol SV08 Max machine configuration?"
echo "This includes optimized settings for:"
echo "  • Start/end G-code with Klipper macros"
echo "  • Timelapse support"
echo "  • Direct drive retraction settings"
echo "  • Machine limits and speeds"
echo ""
read -p "Install machine configuration? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Find user directories
    if [ ! -d "$BAMBU_USER_DIR" ]; then
        echo "❌ Error: User directory not found. Please run BambuStudio at least once."
    else
        USER_DIRS=$(find "$BAMBU_USER_DIR" -maxdepth 1 -type d -name "[0-9]*" 2>/dev/null)

        if [ -z "$USER_DIRS" ]; then
            echo "❌ Error: No user profiles found. Please run BambuStudio at least once."
        else
            USER_COUNT=$(echo "$USER_DIRS" | wc -l | tr -d ' ')

            if [ "$USER_COUNT" -eq 1 ]; then
                USER_ID=$(basename "$USER_DIRS")
                MACHINE_DIR="$BAMBU_USER_DIR/$USER_ID/machine/base"
                mkdir -p "$MACHINE_DIR"
                cp "$SCRIPT_DIR/Sovol sv08 max 0.4 nozzle.json" "$MACHINE_DIR/"
                echo "  ✓ Machine configuration installed for user: $USER_ID"
            else
                echo "Multiple user profiles found. Please select one:"
                echo "$USER_DIRS" | nl
                read -p "Enter number (1-$USER_COUNT): " SELECTION
                USER_ID=$(echo "$USER_DIRS" | sed -n "${SELECTION}p" | xargs basename)
                MACHINE_DIR="$BAMBU_USER_DIR/$USER_ID/machine/base"
                mkdir -p "$MACHINE_DIR"
                cp "$SCRIPT_DIR/Sovol sv08 max 0.4 nozzle.json" "$MACHINE_DIR/"
                echo "  ✓ Machine configuration installed for user: $USER_ID"
            fi
        fi
    fi
    echo ""
else
    echo "  ⊘ Skipped machine configuration installation"
    echo ""
fi

# Installation complete
echo "========================================="
echo "✅ Installation Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Restart BambuStudio if it's running"
echo "  2. Select 'Sovol sv08 max 0.4 nozzle' as your printer"
echo "  3. Choose from 44 Bambu filament profiles in the dropdown"
echo ""
echo "Files installed:"
echo "  • System vendor: $BAMBU_SYSTEM_DIR/Sovol.json"
echo "  • Machine model: $BAMBU_SYSTEM_DIR/Sovol/machine/"
echo "  • Filament profiles: $BAMBU_SYSTEM_DIR/Sovol/filament/ ($PROFILE_COUNT files)"
echo ""
echo "For troubleshooting, see README.md"
echo ""