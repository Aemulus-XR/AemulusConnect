# WiX Installer Setup - Summary

## What Was Created

Your project now has a complete WiX installer solution with PowerShell automation:

### ✅ Installer Configuration
- **[installer/AemulusConnect.wxs](installer/AemulusConnect.wxs)** - WiX installer definition
  - Pre-configured for your application
  - UpgradeCode GUID already set: `8b7c49af-4352-4886-a835-dd52f7b44131`
  - Version 1.0.0.0
  - Includes all dependencies and ADB tools

### ✅ PowerShell Build Scripts
- **[tools/build_and_package.ps1](tools/build_and_package.ps1)** - Main build automation
  - Builds application and creates MSI
  - Supports clean builds, self-contained, and verbose modes
  - Comprehensive error handling and colored output

- **[tools/verify_prerequisites.ps1](tools/verify_prerequisites.ps1)** - Environment checker
  - Validates all requirements are met
  - Checks .NET SDK, WiX Toolset, and project files
  - Detailed mode shows version information

### ✅ Documentation
- **[BUILD.md](BUILD.md)** - Quick reference guide
- **[installer/README.md](installer/README.md)** - Complete installer documentation
- **[installer/SETUP_GUIDE.md](installer/SETUP_GUIDE.md)** - Step-by-step setup walkthrough
- **[tools/README.md](tools/README.md)** - Build automation reference

### ✅ Configuration Updates
- **[.gitignore](.gitignore)** - Updated to ignore WiX build artifacts and output directory
- **[src/Properties/PublishProfiles/](src/Properties/PublishProfiles/)** - Build profiles created

## What You Need To Do

### One-Time Setup (15 minutes)

1. **Install WiX Toolset** (if not already installed):
   ```powershell
   dotnet tool install --global wix
   ```
   ⚠️ **Important**: Close and reopen your terminal after installation!

2. **Verify Setup**:
   ```powershell
   cd tools
   .\verify_prerequisites.ps1
   ```

3. **Done!** The UpgradeCode GUID has already been set in the .wxs file.

### Build Your First Installer

```powershell
cd tools
.\build_and_package.ps1 -Clean
```

Your installer will be created at: `output\AemulusConnect.msi`

## PowerShell Script Features

### build_and_package.ps1

**Parameters:**
- `-Clean` - Remove all previous build artifacts
- `-SelfContained` - Include .NET runtime in installer
- `-SkipBuild` - Only rebuild installer (skip app build)
- `-Verbose` - Show detailed output

**Examples:**
```powershell
# Standard build
.\build_and_package.ps1

# Clean build
.\build_and_package.ps1 -Clean

# Self-contained (no .NET required on target)
.\build_and_package.ps1 -Clean -SelfContained

# Quick installer rebuild
.\build_and_package.ps1 -SkipBuild
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

## Build Types Comparison

| Type                    | Command                                  | Size     | .NET Required | Best For                |
| ----------------------- | ---------------------------------------- | -------- | ------------- | ----------------------- |
| **Framework-Dependent** | `.\build_and_package.ps1`                | ~5-10 MB | Yes           | Enterprise, dev testing |
| **Self-Contained**      | `.\build_and_package.ps1 -SelfContained` | ~100+ MB | No            | Public distribution     |

## Common Workflows

### Daily Development
```powershell
# Make code changes...
cd tools
.\build_and_package.ps1
# Test the MSI in output/ folder
```

### Release Build
```powershell
# 1. Update version in installer\AemulusConnect.wxs
# 2. Build
cd tools
.\build_and_package.ps1 -Clean

# 3. Test thoroughly
# 4. Optionally code sign the MSI
```

### Quick Installer Update
```powershell
# If you only changed the .wxs file
cd tools
.\build_and_package.ps1 -SkipBuild
```

## Getting Help

All scripts have built-in PowerShell help:

```powershell
Get-Help .\build_and_package.ps1
Get-Help .\build_and_package.ps1 -Detailed
Get-Help .\build_and_package.ps1 -Examples
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
.\build_and_package.ps1 -Clean -Verbose
```

## Version Updates

To create a new version:

1. Edit `installer\AemulusConnect.wxs` line 9:
   ```xml
   <?define ProductVersion = "1.0.1.0" ?>
   ```

2. Build:
   ```powershell
   .\build_and_package.ps1 -Clean
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

1. **Verify Prerequisites**: `.\verify_prerequisites.ps1`
2. **Build First Installer**: `.\build_and_package.ps1 -Clean`
3. **Test Installation**: Double-click `output\AemulusConnect.msi`
4. **Read Full Docs**: See [installer/README.md](installer/README.md)

## File Locations

```
AemulusConnect/
├── BUILD.md                           ← Quick build reference
├── INSTALLER_SETUP_SUMMARY.md         ← This file
├── installer/
│   ├── AemulusConnect.wxs         ← WiX installer config
│   ├── README.md                      ← Full installer docs
│   └── SETUP_GUIDE.md                 ← Setup walkthrough
├── tools/
│   ├── build_and_package.ps1          ← Main build script
│   ├── verify_prerequisites.ps1       ← Environment checker
│   └── README.md                      ← Tools reference
└── output/
    └── AemulusConnect.msi         ← Generated installer
```

## Support Resources

- **Quick Start**: [BUILD.md](BUILD.md)
- **Detailed Setup**: [installer/SETUP_GUIDE.md](installer/SETUP_GUIDE.md)
- **Full Documentation**: [installer/README.md](installer/README.md)
- **Tools Reference**: [tools/README.md](tools/README.md)
- **WiX Docs**: https://wixtoolset.org/docs/

---

**Ready to build?** Just run: `cd tools && .\build_and_package.ps1 -Clean`
