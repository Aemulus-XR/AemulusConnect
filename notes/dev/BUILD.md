# Building and Packaging Guide

Quick reference for building the AemulusConnect Application and creating installers.

## Quick Start

### Prerequisites

1. Install .NET 8 SDK: https://dotnet.microsoft.com/download/dotnet/8.0
2. Install WiX Toolset:
   ```powershell
   dotnet tool install --global wix
   ```
3. Restart your terminal after WiX installation

### Build Installer (One Command)

```powershell
cd tools
.\build_and_package.ps1 -Clean
```

This creates `output\AemulusConnect.msi`

## Development Workflow

### Daily Development
```powershell
# Quick build
cd tools
.\build_and_package.ps1
```

### Release Build
```powershell
# Update version in installer\AemulusConnect.wxs first
cd tools
.\build_and_package.ps1 -Clean
```

### Self-Contained (No .NET Required)
```powershell
cd tools
.\build_and_package.ps1 -Clean -SelfContained
```

## Build Options

| Command | Description | Installer Size |
|---------|-------------|----------------|
| `.\build_and_package.ps1` | Standard build | ~5-10 MB |
| `.\build_and_package.ps1 -Clean` | Clean build | ~5-10 MB |
| `.\build_and_package.ps1 -SelfContained` | Includes .NET runtime | ~100+ MB |
| `.\build_and_package.ps1 -SkipBuild` | Only rebuild MSI | N/A |

## Verify Setup

Check if everything is installed correctly:

```powershell
cd tools
.\verify_prerequisites.ps1
```

## First Time Setup

If this is your first time building:

1. **Generate UpgradeCode GUID**:
   ```powershell
   [guid]::NewGuid()
   ```

2. **Update `installer\AemulusConnect.wxs` line 11** with the generated GUID

3. **Never change this GUID** after your first release!

## Getting Help

```powershell
# View detailed help
Get-Help .\build_and_package.ps1 -Detailed

# View examples
Get-Help .\build_and_package.ps1 -Examples

# View all parameters
Get-Help .\build_and_package.ps1 -Parameter *
```

## Troubleshooting

### PowerShell Execution Policy Error

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "wix: command not found"

1. Install: `dotnet tool install --global wix`
2. **Restart your terminal**
3. Verify: `wix --version`

### Build Fails

```powershell
# Clean everything and rebuild
.\build_and_package.ps1 -Clean -Verbose
```

## Directory Structure

```
AemulusConnect/
├── src/                    # Application source code
├── installer/              # WiX installer configuration
│   ├── AemulusConnect.wxs
│   ├── README.md          # Detailed installer documentation
│   └── SETUP_GUIDE.md     # Step-by-step setup guide
├── tools/                  # Build automation scripts
│   ├── build_and_package.ps1
│   ├── verify_prerequisites.ps1
│   └── README.md          # Tools documentation
└── output/                 # Build output (created automatically)
    └── AemulusConnect.msi
```

## Detailed Documentation

- **[installer/SETUP_GUIDE.md](installer/SETUP_GUIDE.md)** - First-time setup walkthrough
- **[installer/README.md](installer/README.md)** - Complete installer documentation
- **[tools/README.md](tools/README.md)** - Build automation reference

## Manual Build (Without Scripts)

```powershell
# Build application
cd src
dotnet build "AemulusConnect.csproj" --configuration Release

# Create installer
cd ..\installer
wix build AemulusConnect.wxs -out ..\output\AemulusConnect.msi
```

## Distribution

### Test Installation
```powershell
# Install with logging
msiexec /i output\AemulusConnect.msi /l*v install.log

# Silent install
msiexec /i output\AemulusConnect.msi /quiet /qn
```

### Code Signing (Optional)
```powershell
signtool sign /f certificate.pfx /p password /tr http://timestamp.digicert.com output\AemulusConnect.msi
```

## System Requirements

### Build Requirements
- Windows 10/11 (or Windows Server 2019+)
- .NET 8 SDK
- WiX Toolset v4/v5
- PowerShell 5.1 or PowerShell Core 7+

### Runtime Requirements (for end users)
- Windows 10 Build 26100+ or Windows 11
- .NET 8 Desktop Runtime (unless using self-contained build)

## Support

For issues or questions:
- Check [installer/README.md](installer/README.md#troubleshooting) troubleshooting section
- Review build output for error messages
- Run `.\verify_prerequisites.ps1 -Detailed` for diagnostic info
