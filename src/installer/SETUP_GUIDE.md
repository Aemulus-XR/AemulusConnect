# WiX Installer Setup Guide

This guide will walk you through the one-time setup required before you can build installers.

## Step 1: Install Prerequisites

### Install .NET 8 SDK (if not already installed)

1. Download from: https://dotnet.microsoft.com/download/dotnet/8.0
2. Run the installer
3. Verify installation:
   ```batch
   dotnet --version
   ```
   Should show `8.0.x` or higher

### Install WiX Toolset

1. Open PowerShell or Command Prompt
2. Run:
   ```powershell
   dotnet tool install --global wix
   ```
3. **Important**: Close and reopen your terminal/PowerShell after installation
4. Verify installation:
   ```powershell
   wix --version
   ```
   Should show version 4.x or 5.x

## Step 2: Generate Unique UpgradeCode GUID

This is **critical** - the UpgradeCode allows Windows to properly upgrade installations.

### Generate the GUID:

**PowerShell:**
```powershell
[guid]::NewGuid()
```

**Command Prompt (using PowerShell):**
```batch
powershell -Command "[guid]::NewGuid()"
```

**Example output:**
```
a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

### Update the WiX file:

1. Open [AemulusXRReporting.wxs](AemulusXRReporting.wxs)
2. Find line 11 (around the top):
   ```xml
   <?define UpgradeCode = "12345678-1234-1234-1234-123456789012" ?>
   ```
3. Replace `12345678-1234-1234-1234-123456789012` with your generated GUID
4. Save the file

**WARNING**: Once you release your first version with this GUID, **NEVER CHANGE IT**. This GUID is how Windows knows that a new installer is an upgrade of the existing product.

## Step 3: Build Your First Installer

### Option A: Automated Build (Recommended)

```powershell
cd tools
.\build_and_package.ps1
```

### Option B: Manual Build

```powershell
# Build the application
cd src
dotnet restore "Aemulus XR Reporting App.csproj"
dotnet build "Aemulus XR Reporting App.csproj" --configuration Release

# Build the installer
cd installer
wix build AemulusXRReporting.wxs -out ..\output\AemulusXRReporting.msi
```

## Step 4: Test the Installer

1. Locate the MSI file in the `src\output` folder
2. **Test Installation**:
   - Double-click the MSI to install
   - Check that shortcuts appear in Start Menu
   - Launch the application
   - Verify it works correctly

3. **Test Uninstallation**:
   - Go to Windows Settings > Apps > Installed Apps
   - Find "Aemulus XR Reporting"
   - Click Uninstall
   - Verify all files are removed

## Troubleshooting

### Error: "wix: command not found"

**Cause**: WiX tool not installed or terminal not restarted

**Solution**:
1. Install WiX: `dotnet tool install --global wix`
2. **Close and reopen your terminal/PowerShell**
3. Try again

### Error: "Execution policy" blocking PowerShell script

**Cause**: Windows PowerShell execution policy restrictions

**Solution**:
```powershell
# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run with bypass (one-time)
powershell -ExecutionPolicy Bypass -File .\build_and_package.ps1
```

### Error: "The system cannot find the file specified"

**Cause**: Application not built before creating installer

**Solution**:
1. Build the application first:
   ```powershell
   cd src
   dotnet build "Aemulus XR Reporting App.csproj" --configuration Release
   ```
2. Verify files exist in: `src\bin\Release\net8.0-windows10.0.26100.0\`
3. Try building installer again

### Error: "LGHT0204: ICE38: Component references file in wrong directory"

**Cause**: File paths in .wxs don't match actual build output

**Solution**:
1. Check the build output directory structure
2. Update file paths in AemulusXRReporting.wxs to match

### MSI builds but won't install

**Cause**: Missing dependencies or runtime requirements

**Solution**:
1. Install .NET 8 Desktop Runtime on the target machine
2. Check Windows Event Viewer for detailed error messages
3. Test on a clean VM to identify missing dependencies

## Next Steps

### For Development Builds

Use the automated script for quick builds:
```powershell
cd tools
.\build_and_package.ps1 -Clean
```

### For Release Builds

1. Update version number in [AemulusXRReporting.wxs](AemulusXRReporting.wxs):
   ```xml
   <?define ProductVersion = "1.0.0.0" ?>
   ```

2. Build with clean slate:
   ```powershell
   cd tools
   .\build_and_package.ps1 -Clean
   ```

3. Test thoroughly on clean systems

4. (Optional) Code sign the MSI:
   ```powershell
   signtool sign /f certificate.pfx /p password /tr http://timestamp.digicert.com output\AemulusXRReporting.msi
   ```

### For Distribution

1. Test installer on multiple Windows versions (Win 10, Win 11)
2. Test on clean systems without .NET installed
3. Document system requirements for end users
4. Consider code signing for production releases

## Support

For more information:
- WiX Documentation: https://wixtoolset.org/docs/
- See [README.md](README.md) for detailed installer documentation
- Check [troubleshooting section](README.md#troubleshooting) in README

## Quick Reference

```powershell
# Build everything (clean)
cd tools
.\build_and_package.ps1 -Clean

# Build with .NET runtime included
.\build_and_package.ps1 -Clean -SelfContained

# Get help on build script
Get-Help .\build_and_package.ps1 -Detailed

# Verify prerequisites
.\verify_prerequisites.ps1

# Install with logging (for debugging)
msiexec /i src\output\AemulusXRReporting.msi /l*v install.log

# Silent install
msiexec /i src\output\AemulusXRReporting.msi /quiet /qn

# Check WiX version
wix --version

# Check .NET version
dotnet --version
```
