#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Updates version numbers across the project

.DESCRIPTION
    Wrapper script that calls the main update_version.ps1 script.
    Synchronizes version from notes/VERSION.md to all project files.

.PARAMETER VerboseOutput
    Enable verbose output

.EXAMPLE
    .\update-version.ps1

.EXAMPLE
    .\update-version.ps1 -VerboseOutput
#>

[CmdletBinding()]
param(
    [switch]$VerboseOutput
)

# Import helpers
. (Join-Path $PSScriptRoot "helpers.ps1")

Write-Host "Updating version numbers..." -ForegroundColor Cyan

# Call the main update_version.ps1 script
$updateVersionScript = Join-Path $ToolsDir "update_version.ps1"

if (-not (Test-Path $updateVersionScript)) {
    Write-Host "  ERROR: Version update script not found: $updateVersionScript" -ForegroundColor Red
    exit 1
}

try {
    $versionArgs = @()
    if ($VerboseOutput) {
        $versionArgs += "-VerboseOutput"
    }

    & $updateVersionScript @versionArgs

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  WARNING: Version update script returned non-zero exit code" -ForegroundColor Yellow
        Write-Host "  Continuing anyway..." -ForegroundColor Yellow
        exit 0  # Don't fail the build for version update issues
    }

    Write-Host "  Version numbers updated successfully" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host "  WARNING: Failed to run version update script: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "  Continuing with build..." -ForegroundColor Yellow
    exit 0  # Don't fail the build
}
