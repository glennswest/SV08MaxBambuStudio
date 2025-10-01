# Bambu Filament Profiles for Sovol SV08 Max

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![BambuStudio](https://img.shields.io/badge/BambuStudio-1.9.0.14+-green.svg)
![Profiles](https://img.shields.io/badge/profiles-44-orange.svg)

This repository contains converted Bambu Lab filament profiles for use with the Sovol SV08 Max printer in BambuStudio.

**Current Version:** 1.0.0 | [Changelog](CHANGELOG.md)

## Overview

BambuStudio includes comprehensive filament profiles for Bambu Lab printers (P1S, X1C, etc.) but not for third-party printers like the Sovol SV08 Max. This project converts all 44 Bambu filament profiles to work as system presets for the Sovol SV08 Max.

## File Structure

```
├── Install Sovol Profiles.app.command  # macOS GUI installer (double-click)
├── Install Sovol Profiles.bat          # Windows GUI installer (double-click)
├── Install-SovolProfiles.ps1           # Windows PowerShell GUI script
├── install.sh                          # macOS command-line installer
├── install.ps1                         # Windows command-line installer
├── install_demon_essentials.sh         # Demon Klipper Essentials installer
├── README.md                           # This file
├── CLAUDE.md                           # Development process documentation
├── Sovol sv08 max 0.4 nozzle.json     # User machine configuration
├── test_start_end_macros.gcode        # Test G-code for macro verification
├── factory_sv08_backup/                # Factory configuration backup
│   ├── README.md                       # Backup documentation
│   ├── config/                         # Klipper configuration files
│   ├── database/                       # Moonraker database
│   └── [system information files]
└── system/
    ├── Sovol.json                      # Vendor configuration file
    └── Sovol/
        ├── machine/
        │   └── Sovol sv08 max.json    # Machine model definition
        └── filament/
            └── [44 filament profiles]  # All Bambu filament profiles
```

## Included Filament Profiles

**PLA Variants (14):** Basic, Aero, Dynamic, Galaxy, Glow, Lite, Marble, Matte, Metal, Silk, Silk+, Sparkle, Tough, Tough+, Translucent, Wood, PLA-CF

**PETG Variants (5):** Basic, HF, Translucent, PETG-CF, PET-CF

**ABS Variants (2):** ABS, ABS-GF

**ASA Variants (3):** ASA, ASA-Aero, ASA-CF

**Engineering Materials (9):** PA-CF, PA6-CF, PA6-GF, PAHT-CF, PC, PC FR, PPA-CF

**Flexible (5):** TPU 85A, TPU 90A, TPU 95A, TPU 95A HF, TPU for AMS

**Support Materials (5):** Support For PLA, Support G, Support W, Support for ABS, PVA

## Conversion Process

### 1. Understanding BambuStudio's System Profile Structure

BambuStudio uses a vendor system with the following components:

- **Vendor JSON** (`Sovol.json`): Registry file listing all machine models, processes, and filaments
- **Machine Model**: Defines printer specifications and default materials
- **Filament Profiles**: Complete material settings without inheritance

### 2. Key Differences from Bambu Printers

The Sovol SV08 Max requires different settings than Bambu printers:

- **Extruder Type**: Direct drive (vs Bambu's direct drive with different mechanics)
- **Retraction**: 0.8-1.0mm (vs Bambu's settings)
- **Bed Size**: 500x500x500mm
- **No AMS Support**: Single extruder configuration

### 3. Conversion Steps

#### Step 1: Create Base User Profiles

1. Started with Bambu P1S 0.4mm nozzle profiles as the base
2. Created user profiles for each filament type with full settings
3. Adjusted settings for direct drive extruder:
   - Reduced retraction distance
   - Modified retraction speed
   - Updated compatible printer field

#### Step 2: Resolve Inheritance Chains

Bambu profiles use deep inheritance:
```
Bambu PC @BBL P1S.json
  → inherits: Bambu PC @BBL X1C.json
    → inherits: Bambu PC @base.json
      → inherits: fdm_filament_pc
```

System profiles cannot use `inherits` from other vendors, so we:
1. Merged all inherited settings from parent templates
2. Flattened into complete standalone profiles
3. Removed all `inherits` fields

#### Step 3: Create System Vendor Structure

1. Created `Sovol.json` vendor configuration matching BBL.json structure:
   ```json
   {
       "name": "Sovol",
       "version": "01.00.00.01",
       "machine_model_list": [...],
       "process_list": [],
       "filament_list": [...]
   }
   ```

2. Created machine model definition with:
   - Printer specifications
   - Default materials list
   - Compatible nozzle sizes

3. Set all profiles to `"from": "system"` instead of `"from": "User"`

#### Step 4: Fix Profile Naming

- Maintained Bambu naming convention: `Bambu [Material] @Sovol sv08 max 0.4 nozzle`
- Used space before `@` symbol to match BambuStudio parser expectations
- Updated all `compatible_printers` fields to reference Sovol printer

### 4. Critical Settings Modified

Each profile was modified with:

```json
{
    "from": "system",
    "compatible_printers": ["Sovol sv08 max 0.4 nozzle"],
    "filament_retraction_length": ["0.8"],
    "filament_retraction_speed": ["30"],
    "filament_extruder_variant": ["Direct Drive Standard"]
}
```

Temperature settings, flow ratios, and material-specific parameters were preserved from Bambu profiles.

## Machine Configuration

The repository includes `Sovol sv08 max 0.4 nozzle.json` - a complete user machine configuration for the Sovol SV08 Max. This file contains:

- Printer dimensions (500x500x500mm build volume)
- Machine limits (acceleration, speed, jerk)
- **Optimized start G-code**: Calls `START_PRINT` macro with temperature parameters (parallel heating)
- **Optimized end G-code**: Calls `END_PRINT` macro (10mm retraction, back corner positioning)
- **Layer change G-code**: Displays layer number and time estimate on printer screen
- Timelapse support with `TIMELAPSE_TAKE_FRAME`
- Direct drive extruder settings
- Retraction settings optimized for SV08 Max

This configuration works with the enhanced Klipper macros that include parallel heating, proper temperature management, and bed leveling.

## Print Process Profiles

The repository includes two optimized print process profiles based on Bambu P1P settings:

**0.16mm Optimal @Sovol SV08**:
- Layer height: 0.16mm
- High-speed printing: 200mm/s outer walls, 300mm/s inner walls
- Optimized for quality and detail
- 5 top layers, 4 bottom layers
- 15% infill density

**0.20mm Standard @Sovol SV08**:
- Layer height: 0.20mm
- Same high-speed settings as 0.16mm profile
- Balanced quality and speed
- Standard layer height for most prints

Both profiles include:
- Accelerations: 10000mm/s² default, 5000mm/s² outer walls
- Travel speed: 400mm/s
- Line widths optimized for 0.4mm nozzle
- Compatible with all Sovol SV08 Max filament profiles

### Installing the Machine Configuration

Copy to:
```
~/Library/Application Support/BambuStudio/user/[user_id]/machine/base/
```

Or create a new printer profile in BambuStudio and import this JSON file.

## Installation

### Quick Install (Recommended)

**macOS:**
1. Double-click `Install Sovol Profiles.app.command`
2. Follow the on-screen prompts
3. Restart BambuStudio

**Windows:**
1. Double-click `Install Sovol Profiles.bat`
2. Follow the GUI installer
3. Restart BambuStudio

The installers will:
- Check for existing installations and offer to back them up
- Install all 44 filament profiles
- Install the machine model
- Optionally install the machine configuration
- Show progress during installation

### Manual Installation

If you prefer to install manually:

1. Copy the entire `system/` directory to:

   **macOS:**
   ```
   ~/Library/Application Support/BambuStudio/system/
   ```

   **Windows:**
   ```
   %APPDATA%\BambuStudio\system\
   ```

2. The final structure should be:
   ```
   BambuStudio/system/
   ├── Sovol.json
   ├── Sovol/
   │   ├── machine/
   │   │   └── Sovol sv08 max.json
   │   └── filament/
   │       └── [44 .json files]
   └── BBL/
       └── [existing Bambu files]
   ```

3. (Optional) Copy `Sovol sv08 max 0.4 nozzle.json` to:

   **macOS:**
   ```
   ~/Library/Application Support/BambuStudio/user/[user_id]/machine/base/
   ```

   **Windows:**
   ```
   %APPDATA%\BambuStudio\user\[user_id]\machine\base\
   ```

4. Restart BambuStudio

5. The Sovol vendor and all 44 filament profiles should now appear in the printer/filament selection dropdowns

## Verification

After installation:

1. Open BambuStudio
2. Select "Sovol sv08 max 0.4 nozzle" as your printer
3. Check filament dropdown - you should see all 44 Bambu filament profiles with "@Sovol sv08 max 0.4 nozzle" suffix
4. Profiles should load without errors

## Troubleshooting

### Profiles Not Appearing

- Ensure `Sovol.json` is in the correct location
- Verify `machine_model_list` includes the Sovol sv08 max entry
- Check that all filament files exist in the paths specified in `Sovol.json`

### Profile Loading Errors

- Confirm no `inherits` fields remain in filament profiles
- Verify all profiles have `"from": "system"`
- Check that `compatible_printers` field matches machine name exactly

### Missing Settings

- Profiles should be 300+ lines with complete settings
- If a profile seems incomplete, re-copy from this repository

## Technical Notes

- All profiles use BambuStudio version `1.9.0.14` format
- Profiles are tested with BambuStudio 01.09.00.14 and later
- No changes to Bambu's original material specifications (temps, flow ratios, etc.)
- Only printer-specific settings (retraction, compatibility) were modified

## Klipper Configuration

### Factory Backup

The `factory_sv08_backup/` directory contains a complete backup of the printer's configuration after successful eddy current probe calibration on September 30, 2025. This includes:

- **Configuration files** (19 files): printer.cfg, Macro.cfg, timelapse.cfg, and more
- **Database**: Moonraker database with bed meshes and job history
- **System information**: Klipper version, network configuration, running services
- **Calibration data**: Complete eddy current probe calibration (LDC1612)
  - Drive current: 15
  - Probe accuracy: 0.0014mm standard deviation
  - 60x60 bed mesh (3600 points)

See `factory_sv08_backup/README.md` for full documentation and restoration instructions.

### Demon Klipper Essentials

**Status**: ⚠️ **Not Recommended** - Reverted to factory configuration

**Installation Script**: `install_demon_essentials.sh` (available but not recommended)

This repository includes an automated installer for [Demon Klipper Essentials Unified](https://github.com/3DPrintDemon/Demon_Klipper_Essentials_Unified). However, **installation is not recommended** due to compatibility issues with the SV08 Max's factory buffer stepper system.

**Issues Encountered:**
- CAN bus errors from buffer_mcu controller
- Version mismatch errors with PLR (Power Loss Recovery) system
- Filament sensor and bed fan integration conflicts
- Multiple print failures despite configuration attempts

**Recommendation**: Use the factory configuration with enhanced START_PRINT/END_PRINT macros (see Custom Macros section above). The factory macros provide reliable operation with the SV08 Max hardware.

**For Advanced Users**: If you wish to attempt Demon Essentials installation:
1. Create a full backup first
2. Be prepared to revert to factory configuration
3. Research SV08 Max-specific buffer stepper integration
4. Expect significant debugging and configuration work

The factory configuration has been enhanced with:
- Temperature-aware filament retraction (10mm)
- Nozzle wipe after heating to prevent oozing
- Proper integration with BambuStudio slicer

### Custom Macros

The printer configuration includes enhanced START_PRINT and END_PRINT macros optimized for speed and reliability:

**START_PRINT** (Parallel Heating Strategy):
- Accepts `EXTRUDER` and `BED` temperature parameters from slicer
- **Parallel heating**: Starts bed and nozzle heating simultaneously (saves 3-5 minutes)
  - Phase 1: Start bed + preheat nozzle to 150°C (non-blocking)
  - Phase 2: Clean nozzle at 150°C while bed continues heating
  - Phase 3: Wait for bed, perform calibration with hot bed
  - Phase 4: Final nozzle heat (quick, already at 150°C)
- Performs quad gantry leveling and bed mesh calibration with heated bed
- **Wipes nozzle** after final heating to remove accumulated ooze
- Performs filament feed and clog check
- Draws purge line before print
- Total startup time: ~5-7 minutes (vs 8-12 minutes serial heating)

**END_PRINT**:
- Retracts filament while hot (**10mm total** - improved for easier filament changes)
  - Fast 5mm retract + 5mm with Z lift
  - Always retracts if extruder is hot (no conditional logic)
- Turns off heaters and fans **after** retraction (ensures clean retraction)
- Lifts Z by 10mm (reduced from 30mm for easier print removal)
- Homes X and Y axes
- Moves to back right corner (X500 Y500) for safety
- Resets speeds and clears pause state

**WIPE_NOZZLE**: Quick nozzle wipe macro (no heating) used after M109 to remove ooze

**PRINT_START**: Alias for START_PRINT (BambuStudio compatibility)

### Layer Tracking and Progress Display

The machine configuration includes automatic layer tracking and time estimates:

**On Printer Display**:
```
Layer 45/120 - ETA: 1h 23m
```

Updates every layer with:
- Current layer number
- Total layer count
- Estimated time remaining from slicer

**In Mainsail/Fluidd**:
- Progress percentage
- Layer information
- Real-time statistics via `SET_PRINT_STATS_INFO`

### Eddy Current Probe

The SV08 Max uses an LDC1612 eddy current probe for Z-homing and bed meshing:

- **Custom Klipper branch**: `klipper-eddy_contact_probe`
- **Probe offsets**: X=-19.8mm, Y=-0.75mm, Z=3.50mm
- **Calibrated settings** preserved in SAVE_CONFIG
- **Best practices**: Calibrate with heated bed (70°C) for accurate results

## Future Enhancements

Potential additions:
- Additional nozzle sizes (0.2mm, 0.6mm, 0.8mm)
- Print process profiles optimized for SV08 Max
- Custom bed models and textures
- Additional third-party filament profiles
- Advanced Demon Essentials configuration templates

## License

These profiles are derived from Bambu Lab's open configuration files and modified for Sovol SV08 Max compatibility. Use at your own risk. Always verify settings before printing.

## Contributing

To add new profiles or improve existing ones:

1. Test thoroughly on actual hardware
2. Document any changes to material settings
3. Maintain compatibility with BambuStudio's profile format
4. Update this README with changes

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and release notes.

### Release Summary

- **v1.0.0** (2024-09-29) - Initial release
  - 44 Bambu filament profiles
  - System vendor configuration
  - Machine model definition
  - GUI and CLI installers for macOS and Windows
  - Complete documentation

## Credits

- Original Bambu Lab profiles: Bambu Lab
- Sovol SV08 Max conversion: Community effort
- BambuStudio: Bambu Lab