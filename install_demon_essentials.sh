#!/bin/bash
# Demon_Klipper_Essentials_Unified Installation Script
# For Sovol SV08 Max
# Version: 1.0

set -e  # Exit on error

PRINTER_HOST="sovol@sv08.gw.lo"
CONFIG_DIR="/home/sovol/printer_data/config"
BACKUP_DIR="/home/sovol/printer_data/config_backup_before_demon_$(date +%Y%m%d_%H%M%S)"

echo "======================================"
echo "Demon Klipper Essentials Unified"
echo "Installation Script for SV08 Max"
echo "======================================"
echo ""

# Function to run commands on printer via SSH
run_on_printer() {
    ssh "$PRINTER_HOST" "$@"
}

# Function to check if command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo "✅ $1 - SUCCESS"
    else
        echo "❌ $1 - FAILED"
        exit 1
    fi
}

echo "Step 1: Creating backup of current config..."
run_on_printer "mkdir -p $BACKUP_DIR && cp -r $CONFIG_DIR/* $BACKUP_DIR/"
check_status "Backup created at $BACKUP_DIR"

echo ""
echo "Step 2: Running main Demon installer..."
run_on_printer "wget -O - https://raw.githubusercontent.com/3DPrintDemon/Demon_Klipper_Essentials_Unified/refs/heads/main/Other_Files/Demon_Install_Script/Demon_Klipper_Essentials_Installer.sh | bash"
check_status "Main installer completed"

echo ""
echo "Step 3: Running prerequisites installer..."
run_on_printer "sh $CONFIG_DIR/Demon_Klipper_Essentials_Unified/Other_Files/Demon_Install_Script/Demon_Prerequisites_Installer.sh"
check_status "Prerequisites installed"

echo ""
echo "Step 4: Checking if demon_vars.cfg exists..."
if ! run_on_printer "test -f /home/sovol/demon_vars.cfg"; then
    echo "Creating demon_vars.cfg..."
    run_on_printer "touch /home/sovol/demon_vars.cfg"
    check_status "demon_vars.cfg created"
else
    echo "✅ demon_vars.cfg already exists"
fi

echo ""
echo "Step 5: Backing up current printer.cfg..."
run_on_printer "cp $CONFIG_DIR/printer.cfg $CONFIG_DIR/printer.cfg.before_demon"
check_status "printer.cfg backed up"

echo ""
echo "Step 6: Checking for existing START_PRINT and END_PRINT macros..."
if run_on_printer "grep -q '^\[gcode_macro START_PRINT\]' $CONFIG_DIR/Macro.cfg"; then
    echo "⚠️  Found START_PRINT macro in Macro.cfg"
    echo "⚠️  Commenting it out to avoid conflicts..."

    # Comment out START_PRINT macro
    run_on_printer "sed -i 's/^\[gcode_macro START_PRINT\]/#[gcode_macro START_PRINT] # Disabled for Demon Essentials/' $CONFIG_DIR/Macro.cfg"
    run_on_printer "sed -i 's/^\[gcode_macro PRINT_START\]/#[gcode_macro PRINT_START] # Disabled for Demon Essentials/' $CONFIG_DIR/Macro.cfg"
    check_status "Existing macros commented out"
else
    echo "✅ No conflicting START_PRINT macro found"
fi

echo ""
echo "Step 7: Checking required sections in printer.cfg..."

# Check for [save_variables]
if ! run_on_printer "grep -q '^\[save_variables\]' $CONFIG_DIR/printer.cfg"; then
    echo "Adding [save_variables] section..."
    run_on_printer "cat >> $CONFIG_DIR/printer.cfg << 'EOF'

# Demon Essentials - Save Variables
[save_variables]
filename: ~/demon_vars.cfg

EOF"
    check_status "[save_variables] section added"
else
    echo "✅ [save_variables] section already exists"
fi

# Check for [force_move]
if ! run_on_printer "grep -q '^\[force_move\]' $CONFIG_DIR/printer.cfg"; then
    echo "Adding [force_move] section..."
    run_on_printer "cat >> $CONFIG_DIR/printer.cfg << 'EOF'

# Demon Essentials - Force Move
[force_move]
enable_force_move: True

EOF"
    check_status "[force_move] section added"
else
    echo "✅ [force_move] section already exists"
fi

# Check for [idle_timeout] - more complex, may need to replace
if ! run_on_printer "grep -q '_DEMON_IDLE_TIMEOUT' $CONFIG_DIR/printer.cfg"; then
    echo "Updating [idle_timeout] section for Demon Essentials..."

    # Comment out existing idle_timeout if present
    run_on_printer "sed -i 's/^\[idle_timeout\]/#[idle_timeout] # Replaced by Demon Essentials/' $CONFIG_DIR/printer.cfg"

    # Add new idle_timeout
    run_on_printer "cat >> $CONFIG_DIR/printer.cfg << 'EOF'

# Demon Essentials - Idle Timeout
[idle_timeout]
gcode:
    _DEMON_IDLE_TIMEOUT
timeout: 3600

EOF"
    check_status "[idle_timeout] updated for Demon Essentials"
else
    echo "✅ [idle_timeout] already configured for Demon Essentials"
fi

echo ""
echo "Step 8: Adding Demon includes to printer.cfg..."

if ! run_on_printer "grep -q 'Demon_Klipper_Essentials_Unified' $CONFIG_DIR/printer.cfg"; then
    run_on_printer "cat >> $CONFIG_DIR/printer.cfg << 'EOF'

# ==============================================================================
# DEMON KLIPPER ESSENTIALS UNIFIED
# ==============================================================================
[include ./Demon_Klipper_Essentials_Unified/*.cfg]
[include ./Demon_User_Files/*.cfg]

# Demon User Files Updater (Raspberry Pi)
[include ./Demon_Klipper_Essentials_Unified/Other_Files/Demon_User_Files_Updater/Extract_Demon_User_Files_Rpi.cfg]

EOF"
    check_status "Demon includes added to printer.cfg"
else
    echo "✅ Demon includes already present in printer.cfg"
fi

echo ""
echo "Step 9: Restarting Klipper..."
curl -X POST http://sv08.gw.lo/printer/gcode/script -H "Content-Type: application/json" -d '{"script":"FIRMWARE_RESTART"}' >/dev/null 2>&1
check_status "Klipper restart command sent"

echo ""
echo "Waiting 15 seconds for Klipper to restart..."
sleep 15

echo ""
echo "Step 10: Checking Klipper status..."
STATUS=$(curl -s http://sv08.gw.lo/printer/info | python3 -c "import sys, json; print(json.load(sys.stdin)['result']['state'])" 2>/dev/null)
if [ "$STATUS" = "ready" ]; then
    echo "✅ Klipper is ready"
else
    echo "⚠️  Klipper state: $STATUS"
    echo "⚠️  Check for configuration errors"
fi

echo ""
echo "Step 11: Running Demon Diagnostics..."
run_on_printer "sh $CONFIG_DIR/Demon_Klipper_Essentials_Unified/Other_Files/Demon_Diagnostics/Demon_Diagnostics.sh" || true

echo ""
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""
echo "Next Steps:"
echo "1. Review the diagnostics output above"
echo "2. Configure user settings in Demon_User_Files/*.cfg"
echo "3. Set your printer-specific variables"
echo "4. Test with a simple print"
echo ""
echo "Backup Location: $BACKUP_DIR"
echo "Main Config: $CONFIG_DIR/printer.cfg"
echo ""
echo "Documentation: https://github.com/3DPrintDemon/Demon_Klipper_Essentials_Unified"
echo "Discord Support: https://discord.gg/KEbxw22AD4"
echo ""