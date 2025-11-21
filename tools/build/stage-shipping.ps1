#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Stages files to the Shipping folder

.DESCRIPTION
    Copies build output and resources to src/Shipping/ directory.
    This is a staging area that mirrors what will be installed.

    NOTE: In Phase 1, maintains current structure. Will be reorganized
    in Phase 2 to use bin/, documentation/, installer/ subdirectories.

.PARAMETER Configuration
    Build configuration (Debug or Release). Default: Release

.PARAMETER SelfContained
    Indicates if this is a self-contained build

.EXAMPLE
    .\stage-shipping.ps1

.EXAMPLE
    .\stage-shipping.ps1 -Configuration Debug -SelfContained
#>

[CmdletBinding()]
param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",

    [switch]$SelfContained
)

# Import helpers
. (Join-Path $PSScriptRoot "helpers.ps1")

# Configuration
$TargetFramework = "net8.0-windows10.0.26100.0"
$RuntimeIdentifier = "win-x64"

Write-Host "Staging files to Shipping folder..." -ForegroundColor Cyan

# Kill ADB server and related processes to prevent file locks
Write-Host "  Stopping ADB server and related processes..." -NoNewline
try {
    # Try to kill ADB gracefully first
    $adbPath = Join-Path $SrcDir "platform-tools\adb.exe"
    if (Test-Path $adbPath) {
        & $adbPath kill-server 2>&1 | Out-Null
    }

    # Force kill any remaining adb.exe processes
    Get-Process -Name "adb" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    # Also kill AemulusConnect if running (it may have AdbWinApi.dll loaded)
    Get-Process -Name "AemulusConnect" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    # Give processes time to release file handles
    Start-Sleep -Milliseconds 1000

    Write-Host " OK" -ForegroundColor Green
}
catch {
    Write-Host " SKIPPED" -ForegroundColor Yellow
}

# Determine the correct build output path
if ($SelfContained) {
    $BuildOutputPath = Join-Path $SrcDir "bin\$Configuration\$TargetFramework\$RuntimeIdentifier"
}
else {
    $BuildOutputPath = Join-Path $SrcDir "bin\$Configuration\$TargetFramework"
}

# Check if build exists from environment variable (set by build-application.ps1)
if ([System.Environment]::GetEnvironmentVariable("BUILD_OUTPUT_PATH", "Process")) {
    $BuildOutputPath = [System.Environment]::GetEnvironmentVariable("BUILD_OUTPUT_PATH", "Process")
}

Write-Host "  Build output: $BuildOutputPath" -ForegroundColor Gray

if (-not (Test-Path $BuildOutputPath)) {
    Write-Host "  ERROR: Build output not found at $BuildOutputPath" -ForegroundColor Red
    Write-Host "  Run build-application.ps1 first" -ForegroundColor Red
    exit 1
}

# Clear and recreate Shipping directory with retry
if (Test-Path $ShippingDir) {
    Write-Host "  Clearing previous Shipping folder..." -NoNewline

    $maxRetries = 5
    $retryCount = 0
    $cleared = $false

    while (-not $cleared -and $retryCount -lt $maxRetries) {
        Remove-Item -Path $ShippingDir -Recurse -Force -ErrorAction SilentlyContinue

        if (-not (Test-Path $ShippingDir)) {
            $cleared = $true
        }
        else {
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Start-Sleep -Milliseconds 500
            }
        }
    }

    if (-not $cleared) {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Host ""
        Write-Host "  ERROR: Failed to clear the Shipping folder after $maxRetries attempts." -ForegroundColor Red
        Write-Host "  The folder may be locked by another process." -ForegroundColor Red
        Write-Host ""
        Write-Host "  Try the following:" -ForegroundColor Yellow
        Write-Host "    1. Close File Explorer if viewing $ShippingDir" -ForegroundColor Yellow
        Write-Host "    2. Close any antivirus software that may be scanning the folder" -ForegroundColor Yellow
        Write-Host "    3. Kill any remaining ADB processes manually:" -ForegroundColor Yellow
        Write-Host "       taskkill /F /IM adb.exe" -ForegroundColor Gray
        Write-Host "       taskkill /F /IM AemulusConnect.exe" -ForegroundColor Gray
        Write-Host ""
        exit 1
    }

    if ($retryCount -gt 0) {
        Write-Host " OK (after $retryCount retries)" -ForegroundColor Green
    }
    else {
        Write-Host " OK" -ForegroundColor Green
    }
}

# Create directory structure (bin/, documentation/, installer/)
Write-Host "  Creating directory structure..." -NoNewline
New-Item -ItemType Directory -Path $ShippingDir -Force | Out-Null
New-Item -ItemType Directory -Path $ShippingBinDir -Force | Out-Null
New-Item -ItemType Directory -Path $ShippingDocsDir -Force | Out-Null
New-Item -ItemType Directory -Path $ShippingInstallerDir -Force | Out-Null

# Create bin/platform-tools subdirectory
$ShippingBinPlatformTools = Join-Path $ShippingBinDir "platform-tools"
New-Item -ItemType Directory -Path $ShippingBinPlatformTools -Force | Out-Null
Write-Host " OK" -ForegroundColor Green

# Copy main application files to bin/
Write-Host "  Copying application files to bin/..." -NoNewline
$mainFiles = @(
    "AemulusConnect.exe",
    "AemulusConnect.dll",
    "AemulusConnect.runtimeconfig.json",
    "AemulusConnect.deps.json",
    "AdvancedSharpAdbClient.dll",
    "log4net.dll",
    "log4net.config",
    "Microsoft.Windows.SDK.NET.dll",
    "WinRT.Runtime.dll"
)

$copiedCount = 0
foreach ($file in $mainFiles) {
    $sourcePath = Join-Path $BuildOutputPath $file
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $ShippingBinDir -Force
        $copiedCount++
    }
}
Write-Host " OK ($copiedCount files)" -ForegroundColor Green

# Copy platform-tools to bin/platform-tools/
Write-Host "  Copying platform-tools to bin/platform-tools/..." -NoNewline
$platformToolsFiles = @("adb.exe", "AdbWinApi.dll")
$sourcePlatformTools = Join-Path $BuildOutputPath "platform-tools"
$toolsCopied = 0

foreach ($file in $platformToolsFiles) {
    $sourcePath = Join-Path $sourcePlatformTools $file
    if (Test-Path $sourcePath) {
        Copy-Item -Path $sourcePath -Destination $ShippingBinPlatformTools -Force
        $toolsCopied++
    }
}
Write-Host " OK ($toolsCopied files)" -ForegroundColor Green

# Copy localization folders to bin/
Write-Host "  Copying localization folders to bin/..." -NoNewline
$cultureFolders = Get-ChildItem -Path $BuildOutputPath -Directory |
    Where-Object { $_.Name -match '^[a-z]{2}(-[A-Z]{2})?$' -or $_.Name -eq 'en-PIRATE' }

$cultureCopied = 0
if ($cultureFolders) {
    foreach ($folder in $cultureFolders) {
        $destPath = Join-Path $ShippingBinDir $folder.Name
        Copy-Item -Path $folder.FullName -Destination $destPath -Recurse -Force
        $cultureCopied++
    }
}
Write-Host " OK ($cultureCopied cultures)" -ForegroundColor Green

# Copy font resources to bin/res/fonts/
Write-Host "  Copying font resources to bin/res/fonts/..." -NoNewline
$sourceResDir = Join-Path $BuildOutputPath "res"
if (Test-Path $sourceResDir) {
    $destResDir = Join-Path $ShippingBinDir "res"
    Copy-Item -Path $sourceResDir -Destination $destResDir -Recurse -Force

    # Count font files
    $fontCount = (Get-ChildItem -Path (Join-Path $destResDir "fonts") -Recurse -Filter "*.ttf" -ErrorAction SilentlyContinue).Count
    Write-Host " OK ($fontCount font files)" -ForegroundColor Green
}
else {
    Write-Host " SKIPPED (res folder not found)" -ForegroundColor Yellow
}

# Copy utilities folder from tools/distributables/
Write-Host "  Copying utility scripts to utilities/..." -NoNewline
$sourceUtilitiesDir = Join-Path $PSScriptRoot "..\distributables"
if (Test-Path $sourceUtilitiesDir) {
    $destUtilitiesDir = Join-Path $ShippingDir "utilities"
    Copy-Item -Path $sourceUtilitiesDir -Destination $destUtilitiesDir -Recurse -Force

    # Count utility files (ps1 and sh scripts)
    $utilityCount = (Get-ChildItem -Path $destUtilitiesDir -Include "*.ps1","*.sh" -Recurse -ErrorAction SilentlyContinue).Count
    Write-Host " OK ($utilityCount scripts)" -ForegroundColor Green
}
else {
    Write-Host " SKIPPED (distributables folder not found)" -ForegroundColor Yellow
}

# Note: Documentation files are created by convert-docs.ps1 directly into documentation/
# This includes license.rtf and UserManual.pdf which are generated from Markdown sources

Write-Host ""
Write-Host "Shipping folder staged successfully!" -ForegroundColor Green
Write-Host "  Structure:" -ForegroundColor Gray
Write-Host "    bin/              - Application binaries and runtime files" -ForegroundColor Gray
Write-Host "    utilities/        - Data conversion and validation utilities" -ForegroundColor Gray
Write-Host "    documentation/    - User documentation (license, manual)" -ForegroundColor Gray
Write-Host "    installer/        - MSI installer output" -ForegroundColor Gray
Write-Host ""
Write-Host "  You can test the application by running:" -ForegroundColor Cyan
Write-Host "    $ShippingBinDir\AemulusConnect.exe" -ForegroundColor Gray
exit 0
