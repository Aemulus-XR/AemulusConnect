# Build and Packaging Tools

This directory contains automation scripts for building and packaging the AemulusConnect Application.

## Table of Contents

- [Available Scripts](#available-scripts)
  - [1. verify_prerequisites.ps1](#1-verify_prerequisitesps1)
  - [2. build_and_package.ps1](#2-build_and_packageps1)
  - [3. harvest_runtime.ps1](#3-harvest_runtimeps1)
  - [4. test_detection.ps1](#4-test_detectionps1)
  - [5. check_encoding.ps1](#5-check_encodingps1)
- [Quick Start](#quick-start)
  - [First Time Setup](#first-time-setup)
  - [Regular Development Workflow](#regular-development-workflow)
- [Build Output Structure](#build-output-structure)
- [Common Scenarios](#common-scenarios)
  - [Scenario 1: Daily Development Build](#scenario-1-daily-development-build)
  - [Scenario 2: Clean Release Build](#scenario-2-clean-release-build)
  - [Scenario 3: Self-Contained Distribution](#scenario-3-self-contained-distribution)
  - [Scenario 4: Quick Installer Rebuild](#scenario-4-quick-installer-rebuild)
  - [Scenario 5: Pre-Release Checklist](#scenario-5-pre-release-checklist)
- [PowerShell Features](#powershell-features)
  - [Getting Help](#getting-help)
- [Troubleshooting](#troubleshooting)
- [Advanced Usage](#advanced-usage)
  - [Custom Build Configuration](#custom-build-configuration)
  - [WiX with Custom Parameters](#wix-with-custom-parameters)
  - [Silent Installation Testing](#silent-installation-testing)
- [Environment Variables (Optional)](#environment-variables-optional)
- [CI/CD Integration](#cicd-integration)
  - [GitHub Actions Example](#github-actions-example)
  - [Azure DevOps Example](#azure-devops-example)
- [Additional Resources](#additional-resources)
- [Support](#support)

## Available Scripts

### 1. verify_prerequisites.ps1

PowerShell script that checks if all required tools and configurations are in place before building.

**Usage:**
```powershell
.\verify_prerequisites.ps1

# With detailed information
.\verify_prerequisites.ps1 -Detailed
```

**What it checks:**
- .NET SDK installation and version
- WiX Toolset installation and version
- Project file existence
- WiX configuration file existence
- UpgradeCode GUID customization
- Previous build output (optional)

**When to use:**
- First time setup
- After installing new development tools
- Troubleshooting build issues

### 2. build_and_package.ps1

PowerShell script that builds the application and creates the MSI installer with comprehensive error handling.

**Basic Usage:**
```powershell
.\build_and_package.ps1
```

**With Options:**
```powershell
# Clean build (removes previous build artifacts first)
.\build_and_package.ps1 -Clean

# Self-contained build (includes .NET runtime in installer)
.\build_and_package.ps1 -SelfContained

# Both options
.\build_and_package.ps1 -Clean -SelfContained

# Skip build, only create installer (assumes build is up to date)
.\build_and_package.ps1 -SkipBuild

# Verbose output for debugging
.\build_and_package.ps1 -Verbose
```

**What it does:**
1. Verifies prerequisites (.NET SDK, WiX Toolset)
2. Optionally cleans previous builds
3. Restores NuGet packages
4. Builds the application in Release configuration
5. Creates the MSI installer using WiX
6. Opens the output folder

**Output:**
- Location: `src\Shipping\output\AemulusConnect-Installer.msi`
- Build logs: Console output
- Build artifacts: `src\bin\Release\`

### 3. harvest_runtime.ps1

PowerShell script that uses WiX Heat to automatically generate a WiX fragment containing all .NET runtime DLLs for self-contained deployments.

**Usage:**
```powershell
.\harvest_runtime.ps1 -BuildOutputPath "..\src\bin\Release\net8.0-windows10.0.26100.0\win-x64"
```

**What it does:**
- Uses WiX Heat tool to harvest all files from the build output directory
- Generates a RuntimeFiles.wxs fragment file
- Creates component groups for easy inclusion in the main installer

**When to use:**
- Creating self-contained installers that include the .NET runtime
- Automating the process of adding ~400+ runtime DLLs to the installer
- Updating the installer when runtime files change

**Output:**
- Location: `src\installer\RuntimeFiles.wxs`
- Next step: Add `<ComponentGroupRef Id='RuntimeFiles'/>` to your main .wxs file

### 4. test_detection.ps1

PowerShell script that tests the .NET Desktop Runtime detection logic used by the installer.

**Usage:**
```powershell
.\test_detection.ps1
```

**What it does:**
- Checks if the .NET Desktop Runtime directory exists
- Lists all installed .NET Desktop Runtime versions (64-bit and 32-bit)
- Simulates the WiX DirectorySearch logic
- Reports whether the installer will detect the runtime

**When to use:**
- Troubleshooting installer runtime detection issues
- Verifying .NET installation on a target machine
- Testing before deploying to users

**Output:**
- Console report showing detected .NET versions
- Prediction of installer behavior

### 5. check_encoding.ps1

PowerShell script that verifies the encoding and syntax of PowerShell scripts.

**Usage:**
```powershell
.\check_encoding.ps1
```

**What it does:**
- Checks file encoding (UTF-8 with/without BOM, UTF-16)
- Validates PowerShell syntax
- Reports file size and line count
- Ensures scripts are properly formatted

**When to use:**
- Troubleshooting script execution issues
- Verifying scripts after editing in different editors
- Ensuring cross-platform compatibility

**Output:**
- Console report showing encoding, syntax validation, and file statistics

## Quick Start

### First Time Setup

1. **Verify prerequisites:**
   ```powershell
   cd tools
   .\verify_prerequisites.ps1
   ```

2. **Install any missing tools** as indicated by the verification script

3. **Generate UpgradeCode GUID** (if not done yet):
   ```powershell
   [guid]::NewGuid()
   ```
   Update `src\installer\AemulusConnect.wxs` line 11 with the generated GUID

4. **Build the installer:**
   ```powershell
   .\build_and_package.ps1
   ```

### Regular Development Workflow

```powershell
# Make code changes...

# Build and package
cd tools
.\build_and_package.ps1 -Clean

# Test the installer
cd ..\src\output
# Double-click AemulusConnect.msi to test
```

## Build Output Structure

```
AemulusConnect/
├── src/
│   ├── bin/
│   │   └── Release/
│   │       └── net8.0-windows10.0.26100.0/
│   │           ├── AemulusConnect.exe
│   │           ├── *.dll (dependencies)
│   │           └── platform-tools/
│   │               ├── adb.exe
│   │               └── AdbWinApi.dll
│   ├── Shipping/
│   │   ├── AemulusConnect.exe
│   │   ├── platform-tools/
│   │   └── output/
│   │       └── AemulusConnect-Installer.msi  ← Final installer
│   └── installer/
└── tools/
    ├── build_and_package.ps1
    └── verify_prerequisites.ps1
```

## Common Scenarios

### Scenario 1: Daily Development Build

```powershell
cd tools
.\build_and_package.ps1
```
- Quick build with existing artifacts
- Framework-dependent (requires .NET 8 on target machine)
- ~5-10 MB installer

### Scenario 2: Clean Release Build

```powershell
cd tools
.\build_and_package.ps1 -Clean
```
- Removes all previous build artifacts
- Ensures fresh build
- Use before releases

### Scenario 3: Self-Contained Distribution

```powershell
cd tools
.\build_and_package.ps1 -Clean -SelfContained
```
- Includes .NET 8 runtime
- Larger installer (~100+ MB)
- Works without .NET installed on target
- Best for general public distribution

### Scenario 4: Quick Installer Rebuild

```powershell
cd tools
.\build_and_package.ps1 -SkipBuild
```
- Only rebuilds the installer MSI
- Skips the application build step
- Use when only .wxs file changed

### Scenario 5: Pre-Release Checklist

```powershell
# 1. Update version number in installer\AemulusConnect.wxs
# 2. Verify prerequisites
.\verify_prerequisites.ps1 -Detailed

# 3. Clean build
.\build_and_package.ps1 -Clean

# 4. Test on clean VM
# 5. Sign the MSI (if you have a code signing certificate)
```

## PowerShell Features

The PowerShell scripts provide several advantages over batch files:

- ✅ **Better Error Handling**: Comprehensive error checking and reporting
- ✅ **Colored Output**: Easy-to-read status messages with color coding
- ✅ **Parameter Support**: Named parameters with built-in help
- ✅ **Cross-Platform**: Works on Windows, Linux, and macOS (where applicable)
- ✅ **Verbose Mode**: Detailed logging for troubleshooting
- ✅ **Help System**: Use `Get-Help .\build_and_package.ps1 -Detailed` for full documentation

### Getting Help

```powershell
# View script help
Get-Help .\build_and_package.ps1
Get-Help .\build_and_package.ps1 -Detailed
Get-Help .\build_and_package.ps1 -Examples

# List all parameters
Get-Help .\build_and_package.ps1 -Parameter *
```

## Troubleshooting

### "wix: command not found"

**Problem**: WiX Toolset not installed or terminal not restarted

**Solution**:
```powershell
dotnet tool install --global wix
# Close and reopen terminal/PowerShell
wix --version  # Verify installation
```

### "Execution policy" error on Windows

**Problem**: PowerShell execution policy blocking scripts

**Solution**:
```powershell
# Check current policy
Get-ExecutionPolicy

# Set policy for current user (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run with bypass (one-time)
powershell -ExecutionPolicy Bypass -File .\build_and_package.ps1
```

### Build succeeds but installer creation fails

**Problem**: File paths in .wxs don't match build output
 
**Solution**:
1. Check `src\bin\Release\net8.0-windows10.0.26100.0\` exists
2. Verify all files referenced in `AemulusConnect.wxs` exist
3. Update file paths in .wxs if necessary

### "Access denied" when building

**Problem**: Antivirus blocking or files in use

**Solution**:
1. Close the application if running
2. Close Visual Studio if open
3. Add exception to antivirus for the project directory
4. Run as Administrator (last resort)

### MSI installs but app won't run

**Problem**: Missing .NET runtime on target machine

**Solution**:
- Install .NET 8 Desktop Runtime: https://dotnet.microsoft.com/download/dotnet/8.0
- OR use `build_and_package.bat selfcontained` to bundle runtime

## Advanced Usage

### Custom Build Configuration

Edit the build script or use MSBuild directly:

```batch
cd src
dotnet build "AemulusConnect.csproj" ^
  --configuration Release ^
  --runtime win-x64 ^
  /p:PublishReadyToRun=true ^
  /p:SelfContained=false
```

### WiX with Custom Parameters

```powershell
cd installer
wix build AemulusConnect.wxs ^
  -out ..\output\AemulusConnect.msi ^
  -ext WixToolset.UI.wixext ^
  -d ProductVersion=1.2.3.4
```

### Silent Installation Testing

```powershell
# Install silently
msiexec /i src\output\AemulusConnect.msi /quiet /qn /l*v install.log

# Check installation log
notepad install.log

# Uninstall silently
msiexec /x {PRODUCT-CODE} /quiet /qn
```

## Environment Variables (Optional)

You can set these environment variables to customize build behavior:

```batch
# Custom output directory
set INSTALLER_OUTPUT_DIR=C:\Builds\Output

# Custom configuration
set BUILD_CONFIGURATION=Release

# Enable verbose logging
set BUILD_VERBOSE=1
```

## CI/CD Integration

For automated builds in CI/CD pipelines:

### GitHub Actions Example

```yaml
name: Build Installer

on: [push, pull_request]

jobs:
  build:
    runs-on: windows-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'

      - name: Install WiX
        run: dotnet tool install --global wix

      - name: Verify Prerequisites
        working-directory: tools
        run: .\verify_prerequisites.ps1

      - name: Build and Package
        working-directory: tools
        run: .\build_and_package.ps1 -Clean

      - name: Upload Installer
        uses: actions/upload-artifact@v3
        with:
          name: installer
          path: src/Shipping/output/*.msi
```

### Azure DevOps Example

```yaml
trigger:
  - main

pool:
  vmImage: 'windows-latest'

steps:
  - task: UseDotNet@2
    inputs:
      version: '8.0.x'

  - powershell: dotnet tool install --global wix
    displayName: 'Install WiX Toolset'

  - powershell: .\verify_prerequisites.ps1
    workingDirectory: tools
    displayName: 'Verify Prerequisites'

  - powershell: .\build_and_package.ps1 -Clean
    workingDirectory: tools
    displayName: 'Build and Package'

  - task: PublishBuildArtifacts@1
    inputs:
      pathToPublish: 'src/output/AemulusConnect.msi'
      artifactName: 'installer'
```

## Additional Resources

- **Detailed Setup**: See [src/installer/SETUP_GUIDE.md](../src/installer/SETUP_GUIDE.md)
- **Installer Documentation**: See [src/installer/README.md](../src/installer/README.md)
- **WiX Documentation**: https://wixtoolset.org/docs/
- **.NET Publishing**: https://learn.microsoft.com/en-us/dotnet/core/deploying/

## Support

If you encounter issues:

1. Run `verify_prerequisites.bat` to check setup
2. Check the [installer/README.md](../installer/README.md) troubleshooting section
3. Review build output for specific error messages
4. Check Windows Event Viewer for installation errors
