# Sovol SV08 Max - Factory Configuration Backup

**Backup Date:** September 30, 2025
**Printer:** Sovol SV08 Max
**Hostname:** sv08.gw.lo
**IP Address:** 192.168.1.106 (static)

## Backup Contents

This directory contains a complete backup of the Sovol SV08 Max printer configuration after successful eddy current probe calibration.

### Configuration Files (19 files)

**Location:** `config/`

- `printer.cfg` - Main Klipper configuration (48KB)
- `Macro.cfg` - Custom G-code macros including START_PRINT, END_PRINT
- `timelapse.cfg` - Timelapse configuration
- `buffer_stepper.cfg` - Buffer stepper and gcode_button configuration
- `moonraker.conf` - Moonraker API server configuration
- `saved_variables.cfg` - Persistent variables
- Plus 13 additional configuration files

### Database

**Location:** `database/`

- `moonraker-sql.db` - Moonraker database containing bed meshes, statistics, and job history

### System Information

**Location:** Root directory

- `klipper_version.txt` - Klipper git commit and branch information
- `printer_info.json` - Complete printer state from Moonraker API
- `network_interfaces.txt` - Network interface configuration
- `running_services.txt` - Active systemd services
- `network_config.txt` - NetworkManager connection settings (if accessible)

## Klipper Configuration

**Version:** Custom branch `klipper-eddy_contact_probe`
**Commit:** f80d36c6e "1"
**Remote:** https://github.com/Klipper3d/klipper.git

**Note:** This is a custom branch with eddy current probe support. The printer uses an LDC1612-based eddy current probe for Z-homing and bed meshing.

## Recent Calibrations Performed

### Eddy Current Probe Calibration (Completed September 30, 2025)

1. **LDC1612 Drive Current Calibration**
   - Result: `reg_drive_current = 15`
   - Saved in printer.cfg

2. **Probe Frequency Calibration**
   - Full calibration table from 0.05mm to 3.5mm
   - 124 calibration points
   - Saved in printer.cfg as `#*# [probe_eddy_current eddy]`

3. **Probe Accuracy Test Results**
   - Maximum: 3.531871mm
   - Minimum: 3.527124mm
   - Range: 0.004747mm
   - Standard deviation: 0.001351mm
   - **Result: Excellent repeatability**

4. **Z Offset Calibration**
   - Calibrated using PROBE_CALIBRATE command
   - Configured for 70°C bed temperature

### Bed Mesh

- **Resolution:** 60x60 points (3600 measurements)
- **Area:** 13mm to 476mm (X), 15mm to 490mm (Y)
- **Algorithm:** Bicubic interpolation
- **Status:** Successfully completed after probe calibration

## Network Configuration

- **Static IP:** 192.168.1.106/24
- **Gateway:** 192.168.1.1
- **DNS:** 192.168.1.51
- **DHCP:** Disabled (dhcpcd masked)
- **Method:** NetworkManager

## Printer Specifications

- **Model:** Sovol SV08 Max
- **Build Volume:** 500mm x 500mm x 500mm
- **Extruder:** Direct Drive
- **Probe:** LDC1612 Eddy Current Probe
  - X Offset: -19.8mm
  - Y Offset: -0.75mm
  - Z Offset: 3.50mm
- **Firmware:** Klipper (custom eddy probe branch)

## Key Macros

### START_PRINT
- Accepts EXTRUDER and BED temperature parameters
- Heats bed and nozzle
- Performs G28 homing
- Runs bed mesh calibration
- Cleans nozzle
- Draws purge line

### END_PRINT
- Retracts filament while hot (4mm total)
- Turns off heaters
- Lifts Z by 30mm
- Homes X and Y axes
- Moves to back right corner (X500 Y500)
- Safe position away from user reach

## Machine Limits

- **Max Acceleration X/Y:** 20,000 mm/s²
- **Max Acceleration Z:** 500 mm/s²
- **Max Speed X/Y:** 500 mm/s
- **Max Speed Z:** 12 mm/s
- **Max Speed E:** 25 mm/s

## Important Notes

1. **Eddy Probe Temperature Sensitivity**
   - Probe calibration performed at 70°C bed temperature
   - Best results when bed is heated during mesh calibration
   - Lower temperatures (below 60°C) may cause probe trigger failures

2. **Custom Klipper Branch**
   - Using `klipper-eddy_contact_probe` branch for probe support
   - Do not update to mainline Klipper without verifying eddy probe compatibility
   - Check if features have been merged to official Klipper before updating

3. **Network Configuration**
   - dhcpcd is masked to prevent conflicts with NetworkManager
   - Static IP prevents DHCP lease changes

4. **Timelapse**
   - Enabled with parking
   - TIMELAPSE_TAKE_FRAME called in before_layer_change_gcode

## Restoration Instructions

To restore this configuration to a fresh Klipper installation:

1. **Install Klipper on custom branch:**
   ```bash
   cd ~/klipper
   git fetch
   git checkout klipper-eddy_contact_probe
   ```

2. **Restore configuration files:**
   ```bash
   rsync -av config/ ~/printer_data/config/
   ```

3. **Restore database (optional):**
   ```bash
   rsync -av database/ ~/printer_data/database/
   ```

4. **Restart services:**
   ```bash
   sudo systemctl restart klipper
   sudo systemctl restart moonraker
   ```

5. **Verify eddy probe calibration:**
   ```bash
   G28
   G1 X250 Y250 Z10
   PROBE_ACCURACY
   ```
   - Should show std dev < 0.002mm

6. **Test bed mesh:**
   ```bash
   BED_MESH_CALIBRATE
   ```

## Files NOT Included in Backup

- Log files (too large and constantly changing)
- G-code files (print jobs)
- Thumbnails and cached images
- Python virtual environments
- Compiled MCU firmware

## Backup Verification

Total files backed up:
- Config files: 19
- Database files: 1
- System info files: 5

Total backup size: ~250KB (excluding logs)

## Support

For issues related to this backup or restoration:
- Check printer_info.json for current printer state at backup time
- Review klipper_version.txt for exact firmware version
- Consult Klipper documentation: https://www.klipper3d.org/

---

**Backup Created By:** Claude AI
**Purpose:** Factory configuration preservation after eddy probe calibration
**Repository:** /Volumes/minihome/gwest/projects/BambuSV08Max