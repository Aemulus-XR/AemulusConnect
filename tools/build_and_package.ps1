#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Aemulus XR Reporting - Build and Package Script

.DESCRIPTION
    This script automates the process of building the application and creating
    the MSI installer package using WiX Toolset.

.PARAMETER Clean
    Perform a clean build (removes bin/obj directories first)

.PARAMETER SelfContained
    Build self-contained version with .NET runtime included

.PARAMETER SkipBuild
    Skip the build step and only create the installer (assumes build is up to date)

.PARAMETER Verbose
    Enable verbose output for debugging

.EXAMPLE
    .\build_and_package.ps1
    Standard build with existing artifacts

.EXAMPLE
    .\build_and_package.ps1 -Clean
    Clean build, removes all previous build artifacts

.EXAMPLE
    .\build_and_package.ps1 -SelfContained
    Build self-contained version with .NET runtime included

.EXAMPLE
    .\build_and_package.ps1 -Clean -SelfContained
    Clean build with self-contained deployment

.NOTES
    Prerequisites:
    - .NET 8 SDK installed
    - WiX Toolset v4 or v5 installed (dotnet tool install --global wix)
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Perform a clean build")]
    [switch]$Clean,

    [Parameter(HelpMessage = "Build self-contained version with .NET runtime")]
    [switch]$SelfContained,

    [Parameter(HelpMessage = "Skip the build step and only create installer")]
    [switch]$SkipBuild,

    [Parameter(HelpMessage = "Enable verbose output")]
    [switch]$VerboseOutput
)

# Set error action preference
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

#region Helper Functions

function Write-Step {
    param([string]$Message, [int]$Step, [int]$Total)
    Write-Host ""
    Write-Host "[Step $Step/$Total] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK]   " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Info {
    param([string]$Message)
    Write-Host "  " -NoNewline
    Write-Host $Message
}

function Write-Warning {
    param([string]$Message)
    Write-Host "  [WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-Error {
    param([string]$Message)
    Write-Host "  [ERROR] " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor Red
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Get-FormattedFileSize {
    param([string]$FilePath)

    if (Test-Path $FilePath) {
        $size = (Get-Item $FilePath).Length
        $sizeMB = [math]::Round($size / 1MB, 2)
        return "$sizeMB MB"
    }
    return "N/A"
}

#endregion

#region Configuration

$ScriptRoot = Split-Path -Parent $PSScriptRoot
$SrcDir = Join-Path $ScriptRoot "src"
$InstallerDir = Join-Path $SrcDir "installer"
$OutputDir = Join-Path $SrcDir "output"
$ShippingDir = Join-Path $SrcDir "Shipping"
$ProjectFile = Join-Path $SrcDir "Aemulus XR Reporting App.csproj"
$WxsFile = Join-Path $InstallerDir "AemulusXRReporting.wxs"
$OutputMsi = Join-Path $OutputDir "AemulusXRReporting.msi"

$BuildConfig = "Release"
$TargetFramework = "net8.0-windows10.0.26100.0"
$RuntimeIdentifier = "win-x64"

#endregion

#region Banner

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host " Aemulus XR Reporting - Build and Package" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

#endregion

#region Step 1: Check Prerequisites

Write-Step "Checking prerequisites..." 1 8

# Check .NET SDK
if (-not (Test-CommandExists "dotnet")) {
    Write-Error "ERROR: .NET SDK is not installed or not in PATH"
    Write-Info "Please install .NET 8 SDK from https://dotnet.microsoft.com/download"
    exit 1
}

$dotnetVersion = (dotnet --version)
Write-Success ".NET SDK found: $dotnetVersion"

# Check WiX Toolset
if (-not (Test-CommandExists "wix")) {
    Write-Error "ERROR: WiX Toolset is not installed"
    Write-Info "Please install WiX: dotnet tool install --global wix"
    Write-Info "After installation, restart your terminal"
    exit 1
}

$wixVersion = (wix --version 2>&1 | Select-Object -First 1)
Write-Success "WiX Toolset found: $wixVersion"

# Check project file
if (-not (Test-Path $ProjectFile)) {
    Write-Error "ERROR: Project file not found: $ProjectFile"
    exit 1
}
Write-Success "Project file found"

# Check WXS file
if (-not (Test-Path $WxsFile)) {
    Write-Error "ERROR: WiX source file not found: $WxsFile"
    exit 1
}
Write-Success "WiX source file found"

#endregion

#region Step 2: Clean Build (Optional)

Write-Step "Build preparation..." 2 8

if ($Clean) {
    Write-Info "Cleaning previous builds..."

    # Clean with dotnet
    & dotnet clean $ProjectFile --configuration $BuildConfig --verbosity quiet

    # Remove directories
    $dirsToRemove = @(
        (Join-Path $SrcDir "bin"),
        (Join-Path $SrcDir "obj"),
        (Join-Path $InstallerDir "obj"),
        (Join-Path $InstallerDir "bin")
    )

    foreach ($dir in $dirsToRemove) {
        if (Test-Path $dir) {
            Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Success "Clean completed"
}
else {
    Write-Info "Skipping clean (use -Clean to clean build artifacts)"
}

#endregion

#region Step 3: Restore NuGet Packages

if (-not $SkipBuild) {
    Write-Step "Restoring NuGet packages..." 3 7

    try {
        $restoreArgs = @(
            "restore",
            $ProjectFile
        )

        if (-not $VerboseOutput) {
            $restoreArgs += "--verbosity", "minimal"
        }

        & dotnet @restoreArgs

        if ($LASTEXITCODE -ne 0) {
            throw "NuGet restore failed with exit code $LASTEXITCODE"
        }

        Write-Success "Restore completed"
    }
    catch {
        Write-Error "ERROR: NuGet restore failed"
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Step "Skipping NuGet restore..." 3 8
    Write-Info "Build step skipped as requested"
}

#endregion

#region Step 4: Build Application

if (-not $SkipBuild) {
    Write-Step "Building application..." 4 8

    try {
        $buildType = if ($SelfContained) { "self-contained (includes .NET runtime)" } else { "framework-dependent (requires .NET 8)" }
        Write-Info "Building $buildType"

        $buildArgs = @(
            "build",
            $ProjectFile,
            "--configuration", $BuildConfig
        )

        if ($SelfContained) {
            $buildArgs += "--runtime", $RuntimeIdentifier
            $buildArgs += "--self-contained", "true"
        }

        if (-not $VerboseOutput) {
            $buildArgs += "--verbosity", "minimal"
        }
        else {
            $buildArgs += "--verbosity", "detailed"
        }

        & dotnet @buildArgs

        if ($LASTEXITCODE -ne 0) {
            throw "Build failed with exit code $LASTEXITCODE"
        }

        Write-Success "Build completed"
    }
    catch {
        Write-Error "ERROR: Build failed"
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Step "Skipping build..." 4 8
    Write-Info "Using existing build artifacts"
}

#endregion

#region Step 5: Create Output Directory

Write-Step "Preparing output directory..." 5 8

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Success "Output directory created"
}
else {
    Write-Info "Output directory exists"
}

# Remove old MSI if exists
if (Test-Path $OutputMsi) {
    Remove-Item $OutputMsi -Force
    Write-Info "Removed previous installer"
}

#endregion

#region Step 6: Create Shipping Folder

Write-Step "Creating Shipping folder..." 6 8

# Determine the correct build output path
if ($SelfContained) {
    $BuildOutputPath = Join-Path $SrcDir "bin\$BuildConfig\$TargetFramework\$RuntimeIdentifier"
}
else {
    $BuildOutputPath = Join-Path $SrcDir "bin\$BuildConfig\$TargetFramework"
}

# Create Shipping directory structure
if (Test-Path $ShippingDir) {
    Remove-Item -Path $ShippingDir -Recurse -Force
}
New-Item -ItemType Directory -Path $ShippingDir -Force | Out-Null
$ShippingPlatformTools = Join-Path $ShippingDir "platform-tools"
New-Item -ItemType Directory -Path $ShippingPlatformTools -Force | Out-Null

Write-Info "Copying files to Shipping folder..."

# Copy main application files
$mainFiles = @(
    "Aemulus XR Reporting App.exe",
    "Aemulus XR Reporting App.dll",
    "Aemulus XR Reporting App.runtimeconfig.json",
    "Aemulus XR Reporting App.deps.json",
    "AdvancedSharpAdbClient.dll",
    "log4net.dll",
    "log4net.config"
)

foreach ($file in $mainFiles) {
    $sourcePath = Join-Path $BuildOutputPath $file
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $ShippingDir -Force
    }
    else {
        Write-Warning "File not found: $file"
    }
}

# Copy platform-tools
$platformToolsFiles = @(
    "adb.exe",
    "AdbWinApi.dll"
)

$sourcePlatformTools = Join-Path $BuildOutputPath "platform-tools"
foreach ($file in $platformToolsFiles) {
    $sourcePath = Join-Path $sourcePlatformTools $file
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $ShippingPlatformTools -Force
    }
    else {
        Write-Warning "Platform tool not found: $file"
    }
}

Write-Success "Shipping folder created with installation layout"
Write-Info "Location: $ShippingDir"

#endregion

#region Step 7: Convert Documentation

Write-Step "Converting documentation..." 7 8

try {
    $ConvertDocsScript = Join-Path $PSScriptRoot "convert_docs.ps1"

    if (Test-Path $ConvertDocsScript) {
        # Run doc conversion (LICENSE.md -> RTF, USER_README.md -> PDF)
        & powershell.exe -NoProfile -File $ConvertDocsScript

        if ($LASTEXITCODE -eq 0) {
            Write-Success "Documentation converted successfully"
        }
        else {
            Write-Warning "Documentation conversion had warnings, but continuing..."
        }
    }
    else {
        Write-Warning "convert_docs.ps1 not found, skipping documentation conversion"
    }
}
catch {
    Write-Warning "Documentation conversion failed: $($_.Exception.Message)"
    Write-Info "Continuing with build..."
}

#endregion

#region Step 8: Build WiX Installer

Write-Step "Building WiX installer..." 8 8

try {
    # Determine the correct build output path
    if ($SelfContained) {
        $BuildOutputPath = Join-Path $SrcDir "bin\$BuildConfig\$TargetFramework\$RuntimeIdentifier"
    }
    else {
        $BuildOutputPath = Join-Path $SrcDir "bin\$BuildConfig\$TargetFramework"
    }

    Write-Info "Using build output from: $BuildOutputPath"

    # Build using dotnet build with wixproj
    $WixProj = Join-Path $InstallerDir "AemulusXRReporting.wixproj"

    if (Test-Path $WixProj) {
        # Use wixproj for build (supports WiX 4 UI extension)
        $buildArgs = @(
            "build",
            $WixProj,
            "-p:BuildOutputPath=`"$BuildOutputPath`"",
            "-o", $OutputDir
        )

        if ($VerboseOutput) {
            $buildArgs += "-v", "detailed"
        }
        else {
            $buildArgs += "-v", "minimal"
        }

        & dotnet @buildArgs

        if ($LASTEXITCODE -ne 0) {
            throw "WiX installer build failed with exit code $LASTEXITCODE"
        }
    }
    else {
        # Fallback to direct wix build
        Push-Location $InstallerDir

        try {
            $wixArgs = @(
                "build",
                $WxsFile,
                "-out", $OutputMsi,
                "-d", "BuildOutputPath=$BuildOutputPath"
            )

            if ($VerboseOutput) {
                $wixArgs += "-v"
            }

            & wix @wixArgs

            if ($LASTEXITCODE -ne 0) {
                throw "WiX build failed with exit code $LASTEXITCODE"
            }
        }
        finally {
            Pop-Location
        }
    }

    Write-Success "Installer created successfully"
}
catch {
    Write-Error "ERROR: WiX installer build failed"
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  - Check that all file paths in the .wxs file exist"
    Write-Host "  - Verify that the build output directory has the expected structure"
    Write-Host "  - Make sure the UpgradeCode GUID in the .wxs file has been generated"
    exit 1
}

#endregion

#region Summary

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host " Build Summary" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Success "SUCCESS: Build and packaging completed!"

Write-Host ""
Write-Host "  Output location: " -NoNewline
Write-Host $OutputMsi -ForegroundColor Cyan

Write-Host "  Build type:      " -NoNewline
if ($SelfContained) {
    Write-Host "Self-contained (includes .NET runtime)" -ForegroundColor Cyan
}
else {
    Write-Host "Framework-dependent (requires .NET 8)" -ForegroundColor Cyan
}

if (Test-Path $OutputMsi) {
    $fileSize = Get-FormattedFileSize $OutputMsi
    Write-Host "  Installer size:  " -NoNewline
    Write-Host $fileSize -ForegroundColor Cyan
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

#endregion

#region Open Output Folder

<#
if (Test-Path $OutputMsi) {
    Write-Host "Opening output folder..." -ForegroundColor Gray

    if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
        # Windows
        Start-Process explorer.exe -ArgumentList $OutputDir
    } elseif ($IsMacOS) {
        # macOS
        & open $OutputDir
    } elseif ($IsLinux) {
        # Linux
        if (Test-CommandExists "xdg-open") {
            & xdg-open $OutputDir
        }
    }
}
#>

#endregion

Write-Host "Done!" -ForegroundColor Green
Write-Host ""
exit 0
