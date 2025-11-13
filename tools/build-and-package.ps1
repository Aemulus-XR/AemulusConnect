#!/usr/bin/env pwsh
<#
.SYNOPSIS
    AemulusConnect - Build and Package Script (Modular)

.DESCRIPTION
    Orchestrates the complete build process by calling modular build scripts.
    This is the main entry point for building the application and installer.

    Build steps:
    1. Check prerequisites (.NET SDK, WiX Toolset)
    2. Update version numbers across project
    3. Clean previous build artifacts (optional)
    4. Restore NuGet packages
    5. Build application
    6. Stage files to Shipping folder
    7. Convert documentation (Markdown → RTF/PDF)
    8. Build WiX installer MSI

.PARAMETER Clean
    Perform a clean build (removes bin/obj directories first)

.PARAMETER SelfContained
    Build self-contained version with .NET runtime included (~100+ MB)

.PARAMETER SkipBuild
    Skip the build step and only create the installer (assumes build is up to date)

.PARAMETER Verbose
    Enable verbose output for debugging

.EXAMPLE
    .\build-and-package.ps1
    Standard build with existing artifacts

.EXAMPLE
    .\build-and-package.ps1 -Clean
    Clean build, removes all previous build artifacts

.EXAMPLE
    .\build-and-package.ps1 -SelfContained
    Build self-contained version with .NET runtime included

.NOTES
    Prerequisites:
    - .NET 8 SDK installed
    - WiX Toolset v4 or v5 installed (dotnet tool install --global wix)
    - Pandoc installed (optional, for documentation conversion)
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
    [Alias("VerboseOutput")]
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

# Build script directory
$BuildScriptsDir = Join-Path $PSScriptRoot "build"

# Configuration
$Configuration = "Release"

#region Banner

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host " AemulusConnect - Build and Package (Modular)" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Build Configuration: $Configuration" -ForegroundColor Gray
if ($SelfContained) {
    Write-Host "  Build Type: Self-contained (with .NET runtime)" -ForegroundColor Gray
}
else {
    Write-Host "  Build Type: Framework-dependent (requires .NET 8)" -ForegroundColor Gray
}
Write-Host ""

#endregion

#region Helper Function

function Invoke-BuildStep {
    param(
        [string]$ScriptName,
        [string]$StepName,
        [int]$Step,
        [int]$Total,
        [hashtable]$Arguments = @{},
        [switch]$Optional
    )

    Write-Host ""
    Write-Host "[Step $Step/$Total] " -ForegroundColor Yellow -NoNewline
    Write-Host "$StepName" -ForegroundColor Yellow

    $scriptPath = Join-Path $BuildScriptsDir "$ScriptName.ps1"

    if (-not (Test-Path $scriptPath)) {
        if ($Optional) {
            Write-Host "  [SKIP] Script not found: $ScriptName.ps1" -ForegroundColor Yellow
            return $true
        }
        else {
            Write-Host "  [ERROR] Required script not found: $scriptPath" -ForegroundColor Red
            return $false
        }
    }

    try {
        & $scriptPath @Arguments

        if ($LASTEXITCODE -ne 0) {
            if ($Optional) {
                Write-Host "  [WARN] Step completed with warnings" -ForegroundColor Yellow
                return $true
            }
            else {
                Write-Host "  [ERROR] Step failed with exit code $LASTEXITCODE" -ForegroundColor Red
                return $false
            }
        }

        return $true
    }
    catch {
        Write-Host "  [ERROR] $($_.Exception.Message)" -ForegroundColor Red
        if (-not $Optional) {
            return $false
        }
        return $true
    }
}

#endregion

#region Build Steps

$totalSteps = 8
$currentStep = 0

# Step 1: Check Prerequisites
$currentStep++
if (-not (Invoke-BuildStep -ScriptName "check-prerequisites" -StepName "Checking prerequisites" -Step $currentStep -Total $totalSteps)) {
    exit 1
}

# Step 2: Update Version Numbers
$currentStep++
$versionArgs = @{}
if ($Verbose) { $versionArgs['VerboseOutput'] = $true }
Invoke-BuildStep -ScriptName "update-version" -StepName "Updating version numbers" -Step $currentStep -Total $totalSteps -Arguments $versionArgs -Optional | Out-Null

# Step 3: Clean (Optional)
$currentStep++
if ($Clean) {
    $cleanArgs = @{ Configuration = $Configuration }
    if (-not (Invoke-BuildStep -ScriptName "clean" -StepName "Cleaning previous builds" -Step $currentStep -Total $totalSteps -Arguments $cleanArgs)) {
        exit 1
    }
}
else {
    Write-Host ""
    Write-Host "[Step $currentStep/$totalSteps] " -ForegroundColor Yellow -NoNewline
    Write-Host "Cleaning previous builds" -ForegroundColor Yellow
    Write-Host "  [SKIP] Skipping clean (use -Clean to clean build artifacts)" -ForegroundColor Yellow
}

# Step 4: Restore NuGet Packages
if (-not $SkipBuild) {
    $currentStep++
    $restoreArgs = @{}
    if ($Verbose) { $restoreArgs['Verbose'] = $true }
    if (-not (Invoke-BuildStep -ScriptName "restore-packages" -StepName "Restoring NuGet packages" -Step $currentStep -Total $totalSteps -Arguments $restoreArgs)) {
        exit 1
    }
}

# Step 5: Build Application
if (-not $SkipBuild) {
    $currentStep++
    $buildArgs = @{ Configuration = $Configuration }
    if ($SelfContained) { $buildArgs['SelfContained'] = $true }
    if ($Verbose) { $buildArgs['Verbose'] = $true }

    if (-not (Invoke-BuildStep -ScriptName "build-application" -StepName "Building application" -Step $currentStep -Total $totalSteps -Arguments $buildArgs)) {
        exit 1
    }
}
else {
    $currentStep++
    Write-Host ""
    Write-Host "[Step $currentStep/$totalSteps] " -ForegroundColor Yellow -NoNewline
    Write-Host "Building application" -ForegroundColor Yellow
    Write-Host "  [SKIP] Using existing build artifacts" -ForegroundColor Yellow
}

# Step 6: Stage Shipping Folder
$currentStep++
$stageArgs = @{ Configuration = $Configuration }
if ($SelfContained) { $stageArgs['SelfContained'] = $true }
if (-not (Invoke-BuildStep -ScriptName "stage-shipping" -StepName "Staging files to Shipping folder" -Step $currentStep -Total $totalSteps -Arguments $stageArgs)) {
    exit 1
}

# Step 7: Convert Documentation
$currentStep++
Invoke-BuildStep -ScriptName "convert-docs" -StepName "Converting documentation" -Step $currentStep -Total $totalSteps -Optional | Out-Null

# Step 8: Build Installer
$currentStep++
$installerArgs = @{}
if ($Verbose) { $installerArgs['Verbose'] = $true }
if (-not (Invoke-BuildStep -ScriptName "build-installer" -StepName "Building WiX installer" -Step $currentStep -Total $totalSteps -Arguments $installerArgs)) {
    exit 1
}

#endregion

#region Summary

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host " Build Complete!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output locations:" -ForegroundColor Gray
Write-Host "  Application: src/Shipping/" -ForegroundColor Gray
Write-Host "  Installer:   src/Shipping/installer/" -ForegroundColor Gray
Write-Host ""

#endregion

exit 0
