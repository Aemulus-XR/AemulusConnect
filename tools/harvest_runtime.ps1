#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Harvest .NET runtime files using WiX Heat tool

.DESCRIPTION
    This script uses WiX Heat to automatically generate a WiX fragment
    containing all .NET runtime DLLs for self-contained deployment.

.PARAMETER BuildOutputPath
    Path to the build output directory containing runtime files

.EXAMPLE
    .\harvest_runtime.ps1 -BuildOutputPath "..\src\bin\Release\net8.0-windows10.0.26100.0\win-x64"

.NOTES
    This is useful for self-contained deployments where you need to include
    all .NET runtime DLLs (~400+ files, ~100MB).
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$BuildOutputPath
)

$ErrorActionPreference = "Stop"

Write-Host "WiX Heat - Runtime File Harvester" -ForegroundColor Cyan
Write-Host "=" * 60

# Check if Heat is available
if (-not (Get-Command "wix" -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: WiX Toolset not found" -ForegroundColor Red
    Write-Host "Install with: dotnet tool install --global wix"
    exit 1
}

# Check if build output exists
if (-not (Test-Path $BuildOutputPath)) {
    Write-Host "ERROR: Build output path not found: $BuildOutputPath" -ForegroundColor Red
    exit 1
}

$OutputFile = Join-Path $PSScriptRoot "..\src\installer\RuntimeFiles.wxs"

Write-Host "Harvesting files from: " -NoNewline
Write-Host $BuildOutputPath -ForegroundColor Yellow

# Run Heat to harvest files
$heatArgs = @(
    "build",
    "heat",
    "dir", $BuildOutputPath,
    "-cg", "RuntimeFiles",
    "-dr", "INSTALLFOLDER",
    "-gg",
    "-sfrag",
    "-srd",
    "-out", $OutputFile
)

Write-Host "Running Heat..." -ForegroundColor Yellow
& wix @heatArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: Runtime files harvested" -ForegroundColor Green
    Write-Host "Output: $OutputFile"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Review the generated RuntimeFiles.wxs file"
    Write-Host "2. Add <ComponentGroupRef Id='RuntimeFiles'/> to your main .wxs file"
    Write-Host "3. Rebuild the installer"
} else {
    Write-Host "ERROR: Heat failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit 1
}
