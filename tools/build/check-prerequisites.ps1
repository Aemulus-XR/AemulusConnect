#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Checks build prerequisites for AemulusConnect

.DESCRIPTION
    Validates that all required tools and files are present:
    - .NET 8 SDK
    - WiX Toolset v4+
    - Project files
    - WiX source files

.EXAMPLE
    .\check-prerequisites.ps1

.NOTES
    Exit codes:
    0 - All prerequisites met
    1 - One or more prerequisites missing
#>

[CmdletBinding()]
param()

# Import helpers
. (Join-Path $PSScriptRoot "helpers.ps1")

# Set error action
$ErrorActionPreference = "Stop"

Write-Host "Checking prerequisites..." -ForegroundColor Cyan

# Check .NET SDK
Write-Host "  Checking .NET SDK..." -NoNewline
if (-not (Test-CommandExists "dotnet")) {
    Write-Host " FAILED" -ForegroundColor Red
    Write-Host "  ERROR: .NET SDK is not installed or not in PATH" -ForegroundColor Red
    Write-Host "  Please install .NET 8 SDK from https://dotnet.microsoft.com/download"
    exit 1
}

$dotnetVersion = (dotnet --version)
Write-Host " OK" -ForegroundColor Green
Write-Host "    Version: $dotnetVersion" -ForegroundColor Gray

# Check WiX Toolset
Write-Host "  Checking WiX Toolset..." -NoNewline
if (-not (Test-CommandExists "wix")) {
    Write-Host " FAILED" -ForegroundColor Red
    Write-Host "  ERROR: WiX Toolset is not installed" -ForegroundColor Red
    Write-Host "  Please install WiX: dotnet tool install --global wix"
    Write-Host "  After installation, restart your terminal"
    exit 1
}

$wixVersion = (wix --version 2>&1 | Select-Object -First 1)
Write-Host " OK" -ForegroundColor Green
Write-Host "    Version: $wixVersion" -ForegroundColor Gray

# Check project file
Write-Host "  Checking project file..." -NoNewline
if (-not (Test-Path $ProjectFile)) {
    Write-Host " FAILED" -ForegroundColor Red
    Write-Host "  ERROR: Project file not found: $ProjectFile" -ForegroundColor Red
    exit 1
}
Write-Host " OK" -ForegroundColor Green
Write-Host "    Path: $ProjectFile" -ForegroundColor Gray

# Check WiX source file
Write-Host "  Checking WiX source file..." -NoNewline
if (-not (Test-Path $WxsFile)) {
    Write-Host " FAILED" -ForegroundColor Red
    Write-Host "  ERROR: WiX source file not found: $WxsFile" -ForegroundColor Red
    exit 1
}
Write-Host " OK" -ForegroundColor Green
Write-Host "    Path: $WxsFile" -ForegroundColor Gray

# Optional: Check Pandoc for documentation conversion
Write-Host "  Checking Pandoc (optional)..." -NoNewline
if (Test-CommandExists "pandoc") {
    $pandocVersion = (pandoc --version | Select-Object -First 1)
    Write-Host " OK" -ForegroundColor Green
    Write-Host "    Version: $pandocVersion" -ForegroundColor Gray
}
else {
    Write-Host " NOT FOUND" -ForegroundColor Yellow
    Write-Host "    Documentation conversion will be skipped" -ForegroundColor Gray
}

Write-Host ""
Write-Host "All required prerequisites met!" -ForegroundColor Green
exit 0
