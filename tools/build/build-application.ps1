#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Builds the AemulusConnect application

.DESCRIPTION
    Compiles the application using dotnet build.
    Supports both framework-dependent and self-contained builds.

.PARAMETER Configuration
    Build configuration (Debug or Release). Default: Release

.PARAMETER SelfContained
    Build self-contained version with .NET runtime included (~100+ MB)

.PARAMETER Verbose
    Enable verbose build output

.EXAMPLE
    .\build-application.ps1

.EXAMPLE
    .\build-application.ps1 -Configuration Debug -Verbose

.EXAMPLE
    .\build-application.ps1 -SelfContained
#>

[CmdletBinding()]
param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",

    [switch]$SelfContained,

    [switch]$Verbose
)

# Import helpers
. (Join-Path $PSScriptRoot "helpers.ps1")

# Configuration
$TargetFramework = "net8.0-windows10.0.26100.0"
$RuntimeIdentifier = "win-x64"

Write-Host "Building application..." -ForegroundColor Cyan

try {
    $buildType = if ($SelfContained) {
        "self-contained (includes .NET runtime)"
    }
    else {
        "framework-dependent (requires .NET 8)"
    }

    Write-Host "  Build type: $buildType" -ForegroundColor Gray
    Write-Host "  Configuration: $Configuration" -ForegroundColor Gray
    Write-Host ""

    $buildArgs = @(
        "build",
        $ProjectFile,
        "--configuration", $Configuration
    )

    if ($SelfContained) {
        $buildArgs += "--runtime", $RuntimeIdentifier
        $buildArgs += "--self-contained", "true"
    }

    if (-not $Verbose) {
        $buildArgs += "--verbosity", "minimal"
    }
    else {
        $buildArgs += "--verbosity", "detailed"
    }

    Write-Host "  Running dotnet build..." -NoNewline
    & dotnet @buildArgs

    if ($LASTEXITCODE -ne 0) {
        Write-Host " FAILED" -ForegroundColor Red
        throw "Build failed with exit code $LASTEXITCODE"
    }

    Write-Host " OK" -ForegroundColor Green

    # Determine build output path
    if ($SelfContained) {
        $BuildOutputPath = Join-Path $SrcDir "bin\$Configuration\$TargetFramework\$RuntimeIdentifier"
    }
    else {
        $BuildOutputPath = Join-Path $SrcDir "bin\$Configuration\$TargetFramework"
    }

    # Check output and display size
    $exePath = Join-Path $BuildOutputPath "AemulusConnect.exe"
    if (Test-Path $exePath) {
        $size = Get-FormattedFileSize $exePath
        Write-Host "    Executable: $size" -ForegroundColor Gray
        Write-Host "    Output: $BuildOutputPath" -ForegroundColor Gray
    }

    # Store build output path for other scripts to use
    $Global:BuildOutputPath = $BuildOutputPath
    [System.Environment]::SetEnvironmentVariable("BUILD_OUTPUT_PATH", $BuildOutputPath, "Process")

    Write-Host ""
    Write-Host "Build completed successfully!" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host ""
    Write-Host "  ERROR: Build failed" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
