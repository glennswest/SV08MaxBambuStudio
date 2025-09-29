# Changelog

All notable changes to the Sovol SV08 Max BambuStudio profiles will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-09-29

### Added
- Initial release of Bambu Lab filament profiles for Sovol SV08 Max
- 44 complete filament profiles converted from Bambu P1S/X1C profiles
  - 14 PLA variants (Basic, Aero, Dynamic, Galaxy, Glow, Lite, Marble, Matte, Metal, Silk, Silk+, Sparkle, Tough, Tough+, Translucent, Wood, PLA-CF)
  - 5 PETG variants (Basic, HF, Translucent, PETG-CF, PET-CF)
  - 2 ABS variants (ABS, ABS-GF)
  - 3 ASA variants (ASA, ASA-Aero, ASA-CF)
  - 9 Engineering materials (PA-CF, PA6-CF, PA6-GF, PAHT-CF, PC, PC FR, PPA-CF)
  - 5 Flexible materials (TPU 85A, TPU 90A, TPU 95A, TPU 95A HF, TPU for AMS)
  - 5 Support materials (Support For PLA, Support G, Support W, Support for ABS, PVA)
- System vendor configuration (Sovol.json)
- Machine model definition (Sovol sv08 max.json)
- User machine configuration with optimized settings
  - Klipper-compatible start/end G-code
  - PRINT_START macro integration
  - Timelapse support with TIMELAPSE_TAKE_FRAME
  - Direct drive extruder settings (0.8mm retraction)
  - Optimized acceleration and speed limits
- GUI installers for easy deployment
  - macOS installer with native dialogs and progress notifications
  - Windows installer with GUI progress bar
  - Automatic backup of existing installations
  - Optional machine configuration installation
- Command-line installers for advanced users
  - Bash script for macOS/Linux
  - PowerShell script for Windows
- Comprehensive documentation
  - README.md with installation and usage instructions
  - CLAUDE.md documenting the complete development process
  - Detailed conversion process explanation

### Technical Details
- All profiles fully resolve inheritance chains (300+ lines per profile)
- No external dependencies - standalone system vendor
- Compatible with BambuStudio 1.9.0.14+
- Proper `compatible_printers` field for Sovol sv08 max
- Retraction settings optimized for direct drive (0.8-1.0mm)
- Temperature settings preserved from original Bambu profiles
- Flow ratios and material-specific parameters maintained

### Files
- 46 system profile files (1 vendor + 1 machine model + 44 filaments)
- 1 user machine configuration file
- 2 documentation files (README.md, CLAUDE.md)
- 5 installer files (2 GUI + 2 CLI + 1 Windows launcher)
- 2 project metadata files (VERSION, CHANGELOG.md)

### Known Issues
- None at initial release

### Future Enhancements
- Additional nozzle sizes (0.2mm, 0.6mm, 0.8mm)
- Print process profiles optimized for SV08 Max
- Custom bed models and textures
- Additional third-party filament brands
- Automated update script for new BambuStudio versions

---

## Version History

- **1.0.0** (2024-09-29) - Initial release with 44 Bambu filament profiles