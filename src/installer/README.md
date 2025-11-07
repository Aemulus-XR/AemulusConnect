# Aemulus XR Reporting - WiX Installer

This directory contains the WiX Toolset installer configuration for creating MSI packages.

## Prerequisites

Before building the installer, you need:

1. **.NET 8 SDK**
   - Download from: https://dotnet.microsoft.com/download/dotnet/8.0
   - Required for building the application

2. **WiX Toolset v4 or v5**
   - Install globally: `dotnet tool install --global wix`
   - After installation, restart your terminal/command prompt

## Quick Start

### Automated Build (Recommended)

Use the provided PowerShell script to build everything:

```powershell
cd tools
.\build_and_package.ps1
```

This will:
1. Check prerequisites
2. Restore NuGet packages
3. Build the application in Release mode
4. Create the MSI installer
5. Open the output folder

### Build Options

```powershell
# Clean build (removes previous build artifacts)
.\build_and_package.ps1 -Clean

# Self-contained build (includes .NET runtime, ~100MB larger)
.\build_and_package.ps1 -SelfContained

# Both options together
.\build_and_package.ps1 -Clean -SelfContained

# Skip build, only rebuild installer
.\build_and_package.ps1 -SkipBuild

# Verbose output for debugging
.\build_and_package.ps1 -Verbose
```

## Manual Build Process

If you prefer to build manually:

### 1. Build the Application

```powershell
cd src
dotnet restore "Aemulus XR Reporting App.csproj"
dotnet build "Aemulus XR Reporting App.csproj" --configuration Release
```

### 2. Build the Installer

```powershell
cd installer
wix build AemulusXRReporting.wxs -out ..\output\AemulusXRReporting.msi -ext WixToolset.UI.wixext
```

## Important: UpgradeCode GUID

**Before your first build**, you must generate a unique UpgradeCode GUID:

1. Generate a new GUID:
   ```powershell
   [guid]::NewGuid()
   ```

2. Replace the placeholder in [AemulusXRReporting.wxs](AemulusXRReporting.wxs#L11):
   ```xml
   <?define UpgradeCode = "YOUR-NEW-GUID-HERE" ?>
   ```

3. **IMPORTANT**: Keep this GUID the same for all future versions! This allows Windows to properly upgrade installations.

## Installer Features

The MSI installer includes:

- **Main Application Files**: Core executable and dependencies
- **ADB Platform Tools**: Required for Quest device communication
- **Start Menu Shortcuts**: Application launcher and uninstaller
- **Desktop Shortcut**: Optional desktop icon (can be deselected during install)
- **.NET Runtime Check**: Warns if .NET 8 Desktop Runtime is not installed
- **Automatic Upgrades**: Newer versions replace older versions automatically
- **Clean Uninstall**: Removes all files and registry entries

## Configuration

### Version Number

Update version in [AemulusXRReporting.wxs](AemulusXRReporting.wxs#L9):
```xml
<?define ProductVersion = "1.0.0.0" ?>
```

### Install Location

Default: `C:\Program Files\Aemulus XR\Aemulus XR Reporting\`

### File Inclusions

If you add new files to the project, update the `<ComponentGroup Id="ProductComponents">` section in the .wxs file.

## Output

The build process creates:
- **Location**: `output/AemulusXRReporting.msi`
- **Type**: Windows Installer Package (.msi)
- **Size**: ~5-10 MB (framework-dependent) or ~100+ MB (self-contained)

## Framework-Dependent vs Self-Contained

### Framework-Dependent (Default)
- **Pros**: Smaller installer (~5-10 MB), uses system .NET runtime
- **Cons**: Requires users to have .NET 8 Desktop Runtime installed
- **Best for**: Enterprise environments, technical users

### Self-Contained
- **Pros**: No .NET installation required, works on any Windows 10+ system
- **Cons**: Larger installer (~100+ MB), includes entire .NET runtime
- **Best for**: Consumer distribution, air-gapped systems

## Troubleshooting

### "wix: command not found"
- Install WiX: `dotnet tool install --global wix`
- Restart your terminal after installation

### "File not found" errors during WiX build
- Ensure you've built the application first (Release configuration)
- Check that file paths in .wxs match your actual build output
- Verify bin\Release\net8.0-windows10.0.26100.0\ directory exists

### Installer won't upgrade existing version
- Check that UpgradeCode hasn't changed between versions
- Increment ProductVersion for each new release
- Never reuse the same version number

### Application won't start after installation
- Verify .NET 8 Desktop Runtime is installed
- Check Windows Event Viewer for error details
- Ensure all dependencies are included in the installer

## Testing the Installer

1. **Install Test**:
   ```batch
   msiexec /i output\AemulusXRReporting.msi /l*v install.log
   ```

2. **Verify Installation**:
   - Check Start Menu for shortcuts
   - Run the application
   - Verify files in Program Files

3. **Upgrade Test**:
   - Increment version number
   - Rebuild installer
   - Install over existing version
   - Verify settings/data preserved

4. **Uninstall Test**:
   - Uninstall via Add/Remove Programs
   - Verify all files removed
   - Check no orphaned registry keys

## Distribution

### Code Signing (Recommended for Production)

For production releases, sign your MSI:

```batch
signtool sign /f certificate.pfx /p password /tr http://timestamp.digicert.com /td sha256 /fd sha256 output\AemulusXRReporting.msi
```

Benefits:
- Prevents "Unknown Publisher" warnings
- Builds user trust
- Required for some enterprise deployments

### Silent Installation

For automated deployments:

```batch
# Silent install
msiexec /i AemulusXRReporting.msi /quiet /qn

# Silent uninstall
msiexec /x {PRODUCT-CODE} /quiet /qn
```

## Additional Resources

- [WiX Toolset Documentation](https://wixtoolset.org/docs/)
- [MSI Best Practices](https://learn.microsoft.com/en-us/windows/win32/msi/installer-development-best-practices)
- [.NET Deployment Guide](https://learn.microsoft.com/en-us/dotnet/core/deploying/)
