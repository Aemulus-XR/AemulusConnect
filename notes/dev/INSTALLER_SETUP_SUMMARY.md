# WiX Installer Setup - Summary

## What Was Created

Your project now has a complete WiX installer solution with PowerShell automation:

### ✅ Installer Configuration
- **[src/installer/AemulusConnect.wxs](../../src/installer/AemulusConnect.wxs)** - WiX installer definition
  - Pre-configured for your application
  - UpgradeCode GUID already set: `8b7c49af-4352-4886-a835-dd52f7b44131`
  - Version 2.4.1.0
  - Includes all dependencies and ADB tools

### ✅ PowerShell Build Scripts
- **[tools/build-and-package.ps1](../../tools/build-and-package.ps1)** - Main build automation
  - Builds application and creates MSI
  - Supports clean builds, self-contained, and verbose modes
  - Comprehensive error handling and colored output

- **[tools/verify_prerequisites.ps1](../../tools/verify_prerequisites.ps1)** - Environment checker
  - Validates all requirements are met
  - Checks .NET SDK, WiX Toolset, and project files
  - Detailed mode shows version information

### ✅ Documentation
- **[BUILD.md](BUILD.md)** - Quick reference guide
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Complete build and contribution guide
- **[INSTALLER_SETUP_SUMMARY.md](INSTALLER_SETUP_SUMMARY.md)** - This file

### ✅ Configuration Updates
- **[.gitignore](../../.gitignore)** - Updated to ignore WiX build artifacts and output directory
- Shipping folder structure created for staging files

## What You Need To Do

### One-Time Setup (45-90 minutes)

1. **Install WiX Toolset** (if not already installed):
   ```powershell
   dotnet tool install --global wix
   ```
   ⚠️ **Important**: Close and reopen your terminal after installation!

2. **Install Pandoc** (for documentation conversion):
   - Download from: https://pandoc.org/installing.html
   - Install and restart terminal

3. **Install TeX Live** (for PDF generation - ~7GB, 30-60 min):
   - Download from: https://tug.org/texlive/acquire-netinstall.html
   - Run `install-tl-windows.exe` and choose "Simple install"
   - Restart terminal after installation

4. **Verify Setup**:
   ```powershell
   cd tools
   .\verify_prerequisites.ps1
   ```

5. **Done!** The UpgradeCode GUID has already been set in the .wxs file.

### Build Your First Installer

```powershell
cd tools
.\build-and-package.ps1 -Clean
```

Your installer will be created at: `src\output\AemulusConnect.msi`

## PowerShell Script Features

### build-and-package.ps1

**Parameters:**
- `-Clean` - Remove all previous build artifacts
- `-SkipBuild` - Only rebuild installer (skip app build)
- `-Verbose` - Show detailed output

**Examples:**
```powershell
# Standard build
.\build-and-package.ps1

# Clean build
.\build-and-package.ps1 -Clean

# Quick installer rebuild
.\build-and-package.ps1 -SkipBuild
```

### verify_prerequisites.ps1

**Parameters:**
- `-Detailed` - Show version information and paths

**Examples:**
```powershell
# Basic check
.\verify_prerequisites.ps1

# Detailed information
.\verify_prerequisites.ps1 -Detailed
```

## Installer Features

Your MSI installer will:
- ✅ Check for .NET 8 Desktop Runtime (warn if missing)
- ✅ Install to `C:\Program Files\Aemulus XR\AemulusConnect\`
- ✅ Create Start Menu shortcuts
- ✅ Optionally create Desktop shortcut
- ✅ Include ADB platform tools
- ✅ Support automatic upgrades when version is incremented
- ✅ Clean uninstallation

## Build Type

| Type                    | Command                   | Size     | .NET Required | Best For            |
| ----------------------- | ------------------------- | -------- | ------------- | ------------------- |
| **Framework-Dependent** | `.\build-and-package.ps1` | ~5-10 MB | Yes           | All distributions   |

## Common Workflows

### Daily Development
```powershell
# Make code changes...
cd tools
.\build-and-package.ps1
# Test the MSI in src\output\ folder
```

### Release Build
```powershell
# 1. Update version in src\installer\AemulusConnect.wxs
# 2. Build
cd tools
.\build-and-package.ps1 -Clean

# 3. Test thoroughly
# 4. Optionally code sign the MSI
```

### Quick Installer Update
```powershell
# If you only changed the .wxs file
cd tools
.\build-and-package.ps1 -SkipBuild
```

## Getting Help

All scripts have built-in PowerShell help:

```powershell
Get-Help .\build-and-package.ps1
Get-Help .\build-and-package.ps1 -Detailed
Get-Help .\build-and-package.ps1 -Examples
```

## Troubleshooting

### PowerShell Execution Policy
If you get an execution policy error:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### WiX Not Found
1. Install: `dotnet tool install --global wix`
2. **Close and reopen terminal**
3. Test: `wix --version`

### Build Errors
Run with verbose output:
```powershell
.\build-and-package.ps1 -Clean -Verbose
```

## Version Updates

To create a new version:

1. Edit `src\installer\AemulusConnect.wxs` line 10:
   ```xml
   <?define ProductVersion = "2.4.2.0" ?>
   ```

2. Build:
   ```powershell
   .\build-and-package.ps1 -Clean
   ```

3. The new installer will automatically upgrade existing installations!

## What's Different from Batch Files

The PowerShell scripts provide:
- ✅ Better error handling and reporting
- ✅ Colored, easy-to-read output
- ✅ Named parameters instead of positional arguments
- ✅ Built-in help system
- ✅ Verbose logging mode
- ✅ Cross-platform compatibility (where applicable)
- ✅ More robust file handling

## Next Steps

1. **Verify Prerequisites**: `.\verify_prerequisites.ps1` (from tools/ directory)
2. **Build First Installer**: `.\build-and-package.ps1 -Clean` (from tools/ directory)
3. **Test Installation**: Double-click `src\output\AemulusConnect.msi`
4. **Read Full Docs**: See [BUILD.md](BUILD.md) and [CONTRIBUTING.md](CONTRIBUTING.md)

## File Locations

```
AemulusConnect/
├── notes/dev/
│   ├── BUILD.md                       ← Quick build reference
│   ├── INSTALLER_SETUP_SUMMARY.md     ← This file
│   └── CONTRIBUTING.md                ← Complete build guide
├── src/
│   ├── installer/
│   │   ├── AemulusConnect.wxs         ← WiX installer config
│   │   └── AemulusConnect.wixproj     ← WiX project file
│   ├── Shipping/                      ← Staged files
│   │   ├── bin/                       ← Application binaries
│   │   ├── documentation/             ← Generated docs
│   │   └── installer/                 ← Final MSI
│   └── output/
│       └── AemulusConnect.msi         ← Generated installer
└── tools/
    ├── build-and-package.ps1          ← Main build script
    ├── verify_prerequisites.ps1       ← Environment checker
    └── build/                         ← Build system internals
```

## Support Resources

- **Quick Start**: [BUILD.md](BUILD.md)
- **Full Documentation**: [CONTRIBUTING.md](CONTRIBUTING.md)
- **WiX Docs**: https://wixtoolset.org/docs/

---

**Ready to build?** Just run: `cd tools && .\build-and-package.ps1 -Clean`
