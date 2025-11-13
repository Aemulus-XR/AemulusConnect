# Building and Packaging Guide

Quick reference for building the AemulusConnect Application and creating installers.

## Quick Start

### Prerequisites

1. Install .NET 8 SDK: https://dotnet.microsoft.com/download/dotnet/8.0
2. Install WiX Toolset:
   ```powershell
   dotnet tool install --global wix
   ```
3. Install Pandoc (for documentation conversion): https://pandoc.org/installing.html
4. Install TeX Live (for PDF generation):
   - Download from: https://tug.org/texlive/acquire-netinstall.html
   - Run `install-tl-windows.exe` and choose "Simple install"
   - Installation takes 30-60 minutes (~7GB)
   - Provides `pdflatex` and `xelatex` PDF engines for pandoc
5. Restart your terminal after installations

### Build Installer (One Command)

```powershell
cd tools
.\build-and-package.ps1 -Clean
```

This creates `src\output\AemulusConnect.msi`

## Development Workflow

### Daily Development
```powershell
# Quick build
cd tools
.\build-and-package.ps1
```

### Release Build
```powershell
# Update version in src\installer\AemulusConnect.wxs first
cd tools
.\build-and-package.ps1 -Clean
```

## Build Options

| Command | Description | Installer Size |
|---------|-------------|----------------|
| `.\build-and-package.ps1` | Standard build | ~5-10 MB |
| `.\build-and-package.ps1 -Clean` | Clean build | ~5-10 MB |
| `.\build-and-package.ps1 -SkipBuild` | Only rebuild MSI | N/A |

## Verify Setup

Check if everything is installed correctly:

```powershell
cd tools
.\verify_prerequisites.ps1
```

## Important Notes

- The UpgradeCode GUID is already set in `src\installer\AemulusConnect.wxs` (line 12)
- **Never change this GUID** - it's required for automatic upgrades to work
- The version is managed through VERSION.md and automatically synchronized

## Getting Help

```powershell
# View detailed help
Get-Help .\build-and-package.ps1 -Detailed

# View examples
Get-Help .\build-and-package.ps1 -Examples

# View all parameters
Get-Help .\build-and-package.ps1 -Parameter *
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
.\build-and-package.ps1 -Clean -Verbose
```

### PDF Generation Issues

If `convert_docs.ps1` creates placeholder PDFs instead of proper documentation:

1. **Check Pandoc Installation**:
   ```powershell
   pandoc --version
   ```
   If not found, install from: https://pandoc.org/installing.html

2. **Check PDF Engine (TeX Live)**:
   ```powershell
   pdflatex --version
   ```
   If not found, install TeX Live:
   - Download: https://tug.org/texlive/acquire-netinstall.html
   - Run installer and choose "Simple install"
   - Restart terminal after installation

3. **Verify Installation**:
   ```powershell
   cd tools
   .\convert_docs.ps1
   ```
   Should show which PDF engine is being used (pdflatex, xelatex, or wkhtmltopdf)

## Directory Structure

```
AemulusConnect/
├── src/                        # Application source code
│   ├── installer/              # WiX installer configuration
│   │   ├── AemulusConnect.wxs
│   │   └── AemulusConnect.wixproj
│   ├── Shipping/               # Staged files for packaging
│   │   ├── bin/                # Application files
│   │   ├── documentation/      # RTF and PDF docs
│   │   └── installer/          # Final MSI installer
│   └── output/                 # Build output (created automatically)
│       └── AemulusConnect.msi
└── tools/                      # Build automation scripts
    ├── build-and-package.ps1
    ├── verify_prerequisites.ps1
    └── build/                  # Build system internals
```

## Detailed Documentation

- **[INSTALLER_SETUP_SUMMARY.md](INSTALLER_SETUP_SUMMARY.md)** - Installer setup summary
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Complete build and contribution guide

## Manual Build (Without Scripts)

```powershell
# Build application
cd src
dotnet build "AemulusConnect.csproj" --configuration Release

# Stage files (run staging script)
cd ..\tools\build
.\stage-shipping.ps1

# Create installer
cd ..\..\src\installer
wix build AemulusConnect.wxs -out ..\output\AemulusConnect.msi
```

## Distribution

### Test Installation
```powershell
# Install with logging
msiexec /i src\output\AemulusConnect.msi /l*v install.log

# Silent install
msiexec /i src\output\AemulusConnect.msi /quiet /qn
```

### Code Signing (Optional)
```powershell
signtool sign /f certificate.pfx /p password /tr http://timestamp.digicert.com src\output\AemulusConnect.msi
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
- Check [CONTRIBUTING.md](CONTRIBUTING.md) for detailed build instructions
- Review build output for error messages
- Run `.\verify_prerequisites.ps1` in the tools/ directory for diagnostic info
