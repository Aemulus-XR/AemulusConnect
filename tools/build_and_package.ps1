#!/usr/bin/env pwsh
<#
.SYNOPSIS
    AemulusConnect - Build and Package Script

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
$ShippingDir = Join-Path $SrcDir "Shipping"
$OutputDir = Join-Path $ShippingDir "installer"
$ProjectFile = Join-Path $SrcDir "AemulusConnect.csproj"
$WxsFile = Join-Path $InstallerDir "AemulusConnect.wxs" # Used as fallback
$OutputMsi = Join-Path $OutputDir "AemulusConnect-Installer.msi"

$BuildConfig = "Release"
$TargetFramework = "net8.0-windows10.0.26100.0"
$RuntimeIdentifier = "win-x64"

#endregion

#region Banner

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host " AemulusConnect - Build and Package" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

#endregion

#region Step 1: Check Prerequisites

Write-Step "Checking prerequisites..." 1 9

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

#region Step 2: Update Version Numbers

Write-Step "Updating version numbers..." 2 9

$updateVersionScript = Join-Path $PSScriptRoot "update_version.ps1"
if (Test-Path $updateVersionScript) {
    try {
        $versionArgs = @()
        if ($VerboseOutput) {
            $versionArgs += "-VerboseOutput"
        }

        & $updateVersionScript @versionArgs

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Version update script failed, continuing anyway..."
        }
        else {
            Write-Success "Version numbers updated"
        }
    }
    catch {
        Write-Warning "Failed to run version update script: $($_.Exception.Message)"
        Write-Info "Continuing with build..."
    }
}
else {
    Write-Warning "Version update script not found, skipping..."
}

#endregion

#region Step 3: Clean Build (Optional)

Write-Step "Build preparation..." 3 9

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

#region Step 4: Restore NuGet Packages

if (-not $SkipBuild) {
    Write-Step "Restoring NuGet packages..." 4 9

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
    Write-Step "Skipping NuGet restore..." 4 9
    Write-Info "Build step skipped as requested"
}

#endregion

#region Step 5: Build Application

if (-not $SkipBuild) {
    Write-Step "Building application..." 5 9

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
    Write-Step "Skipping build..." 5 9
    Write-Info "Using existing build artifacts"
}

#endregion

#region Step 6: Create Output Directory

Write-Step "Preparing output directory..." 6 9

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Success "Output directory created at $OutputDir"
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

#region Step 7: Create Shipping Folder

Write-Step "Creating Shipping folder..." 7 9

# Determine the correct build output path
if ($SelfContained) {
    $BuildOutputPath = Join-Path $SrcDir "bin\$BuildConfig\$TargetFramework\$RuntimeIdentifier"
}
else {
    $BuildOutputPath = Join-Path $SrcDir "bin\$BuildConfig\$TargetFramework"
}

# Create Shipping directory structure
if (Test-Path $ShippingDir) {
    Write-Info "Clearing previous Shipping folder..."
    Remove-Item -Path $ShippingDir -Recurse -Force -ErrorAction SilentlyContinue

    # Validation step to ensure the directory was removed
    if (Test-Path $ShippingDir) {
        Write-Error "Failed to clear the Shipping folder. It may be locked by another process."
        Write-Info "Close any open files or explorers in '$ShippingDir' and try again."
        exit 1
    }
}
New-Item -ItemType Directory -Path $ShippingDir -Force | Out-Null
$ShippingPlatformTools = Join-Path $ShippingDir "platform-tools"
New-Item -ItemType Directory -Path $ShippingPlatformTools -Force | Out-Null
# Re-create the output directory inside Shipping
$OutputDir = Join-Path $ShippingDir "installer"
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

Write-Info "Copying files to Shipping folder..."

# Copy main application files
$mainFiles = @(
    "AemulusConnect.exe",
    "AemulusConnect.dll",
    "AemulusConnect.runtimeconfig.json",
    "AemulusConnect.deps.json",
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

# Copy localization folders (e.g., 'fr', 'es-ES')
$cultureFolders = Get-ChildItem -Path $BuildOutputPath -Directory | Where-Object { $_.Name -match '^[a-z]{2}(-[A-Z]{2})?$' }
if ($cultureFolders) {
    Write-Info "Copying localization folders..."
    foreach ($folder in $cultureFolders) {
        $destPath = Join-Path $ShippingDir $folder.Name
        Copy-Item -Path $folder.FullName -Destination $destPath -Recurse -Force
        Write-Info "  - Copied $($folder.Name)"
    }
}

# Copy converted documentation
$docsToCopy = @{
    (Join-Path $InstallerDir "license.rtf")    = (Join-Path $ShippingDir "license.rtf")
    (Join-Path $InstallerDir "UserManual.pdf") = (Join-Path $ShippingDir "UserManual.pdf")
}

foreach ($source in $docsToCopy.Keys) {
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $docsToCopy[$source] -Force
        Write-Info "Copied $($source | Split-Path -Leaf) to Shipping folder"
    }
    else {
        Write-Warning "Documentation file not found, skipping: $($source | Split-Path -Leaf)"
    }
}

Write-Success "Shipping folder created with installation layout"
Write-Info "Location: $ShippingDir"

#endregion

#region Step 8: Convert Documentation

Write-Step "Converting documentation..." 8 9

try {
    $ConvertDocsScript = Join-Path $PSScriptRoot "convert_docs.ps1"

    if (Test-Path $ConvertDocsScript) {
        # Run doc conversion (notes/LICENSE.md -> RTF, notes/USER_GUIDE.md -> PDF)
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

#region Step 9: Build WiX Installer

Write-Step "Building WiX installer..." 9 9

try {
    $BuildOutputPath = $ShippingDir # All installer content is now in the Shipping folder
    Write-Info "Using build output from: $BuildOutputPath"

    # Build using dotnet build with wixproj
    $WixProj = Join-Path $InstallerDir "AemulusConnect.wixproj"

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

    <#
    # Rename MSI with version number
    $versionFile = Join-Path (Split-Path -Parent $ScriptRoot) "notes\VERSION.md"
    if (Test-Path $versionFile) {
        $versionContent = Get-Content $versionFile -Raw
        if ($versionContent -match 'version=(\d+\.\d+\.\d+)') {
            $version = $matches[1]
            $versionedMsi = Join-Path $OutputDir "AemulusConnect-$version.msi"

            if (Test-Path $OutputMsi) {
                Copy-Item $OutputMsi $versionedMsi -Force
                Write-Info "Created versioned installer: AemulusConnect-$version.msi"
            }
        }
    }
    #>

    # Rename MSI with version number
    $versionFile = Join-Path (Split-Path -Parent $ScriptRoot) "AemulusConnect\notes\VERSION.md"
    if (Test-Path $versionFile) {
        $versionContent = Get-Content $versionFile -Raw
        Write-Info "Version file content: $versionContent"  # Debug output

        if ($versionContent -match 'version=(\d+\.\d+\.\d+)') {
            $version = $matches[1]
            $versionedMsi = Join-Path $OutputDir "AemulusConnect-Installer-$version.msi"
            # The wixproj build outputs 'AemulusConnect.msi' by default.
            $builtMsiPath = Join-Path $OutputDir "AemulusConnect.msi"

            if (Test-Path $builtMsiPath) {
                Write-Info "Renaming installer..."
                Write-Info "  From: $($builtMsiPath | Split-Path -Leaf)"
                Write-Info "  To:   $($versionedMsi | Split-Path -Leaf)"
                Rename-Item -Path $builtMsiPath -NewName ($versionedMsi | Split-Path -Leaf) -Force
                Write-Success "Installer renamed to: $($versionedMsi | Split-Path -Leaf)"
            }
            else {
                Write-Error "ERROR: The built MSI file does not exist: $builtMsiPath"
            }
        }
        else {
            Write-Error "ERROR: Version pattern not found in file."
        }
    }
    else {
        Write-Error "ERROR: Version file not found: $versionFile"
    }

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
Write-Host $versionedMsi -ForegroundColor Cyan

Write-Host "  Build type:      " -NoNewline
if ($SelfContained) {
    Write-Host "Self-contained (includes .NET runtime)" -ForegroundColor Cyan
}
else {
    Write-Host "Framework-dependent (requires .NET 8)" -ForegroundColor Cyan
}

if (Test-Path $OutputMsi) {
    $fileSize = Get-FormattedFileSize $OutputMsi
    Write-Host "  Installer size:  " -NoNewline # Note: This shows size of the un-versioned MSI
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

$player = New-Object System.Media.SoundPlayer
$player.SoundLocation = "assets/media/done.wav"
$player.PlaySync()  # Plays the sound synchronously (blocking)

exit 0
