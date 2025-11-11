#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Update version numbers across all documentation files

.DESCRIPTION
    Reads the version from notes/VERSION.md and updates all documentation files
    that reference version numbers to ensure consistency.

.PARAMETER VerboseOutput
    Enable verbose output for debugging

.EXAMPLE
    .\update_version.ps1

.EXAMPLE
    .\update_version.ps1 -VerboseOutput

.NOTES
    This script is automatically called during the build process.
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Enable verbose output")]
    [switch]$VerboseOutput
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Determine script root (tools directory)
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptRoot

Write-Host "============================================================================"
Write-Host " AemulusConnect - Version Update"
Write-Host "============================================================================"
Write-Host ""

# Read version from VERSION.md
$versionFile = Join-Path $RepoRoot "notes\VERSION.md"
if (-not (Test-Path $versionFile)) {
    Write-Host "  [ERROR] VERSION.md not found at: $versionFile" -ForegroundColor Red
    exit 1
}

Write-Host "[Step 1/3] Reading version from VERSION.md..."
$versionContent = Get-Content $versionFile -Raw
if ($versionContent -match 'version=(\d+\.\d+\.\d+)') {
    $version = $matches[1]
    Write-Host "  [OK]   Version found: $version" -ForegroundColor Green
}
else {
    Write-Host "  [ERROR] Could not parse version from VERSION.md" -ForegroundColor Red
    exit 1
}

# Files to update with their specific patterns
$filesToUpdate = @(
    @{
        Path        = "README.md"
        Pattern     = '\*\*Current Version\*\*: \d+\.\d+\.\d+'
        Replacement = "**Current Version**: $version"
        Description = "Main README"
    },
    @{
        Path        = "notes\USER_GUIDE.md"
        Pattern     = 'Current version documentation: \*\*\d+\.\d+\.\d+\*\*'
        Replacement = "Current version documentation: **$version**"
        Description = "User README"
    },
    @{
        Path        = "src\installer\AemulusConnect.wxs"
        Pattern     = '<\?define ProductVersion = "\d+\.\d+\.\d+\.0" \?>'
        Replacement = "<?define ProductVersion = `"$version.0`" ?>"
        Description = "WiX installer ProductVersion"
    },
    @{
        Path        = "src\AemulusConnect.csproj"
        Pattern     = '<Version>[\d\.]+</Version>'
        Replacement = "<Version>$version</Version>"
        Description = "Project file Version"
    },
    @{
        Path        = "src\AemulusConnect.csproj"
        Pattern     = '<FileVersion>[\d\.]+</FileVersion>'
        Replacement = "<FileVersion>$version</FileVersion>"
        Description = "Project file FileVersion"
    },
    @{
        Path        = "src\AemulusConnect.csproj"
        Pattern     = '<AssemblyVersion>[\d\.]+</AssemblyVersion>'
        Replacement = "<AssemblyVersion>$version</AssemblyVersion>"
        Description = "Project file AssemblyVersion"
    }
)

Write-Host ""
Write-Host "[Step 2/3] Updating version references..."
$updatedCount = 0
$skippedCount = 0

foreach ($file in $filesToUpdate) {
    $fullPath = Join-Path $RepoRoot $file.Path

    if (-not (Test-Path $fullPath)) {
        Write-Host "  [WARN] File not found, skipping: $($file.Path)" -ForegroundColor Yellow
        $skippedCount++
        continue
    }

    $content = Get-Content $fullPath -Raw

    if ($content -match $file.Pattern) {
        $newContent = $content -replace $file.Pattern, $file.Replacement
        Set-Content $fullPath -Value $newContent -NoNewline
        Write-Host "  [OK]   Updated: $($file.Description)" -ForegroundColor Green
        $updatedCount++

        if ($VerboseOutput) {
            Write-Host "         File: $($file.Path)" -ForegroundColor Gray
            Write-Host "         Pattern: $($file.Pattern)" -ForegroundColor Gray
            Write-Host "         Replacement: $($file.Replacement)" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "  [SKIP] Pattern not found in: $($file.Description)" -ForegroundColor Yellow
        $skippedCount++

        if ($VerboseOutput) {
            Write-Host "         File: $($file.Path)" -ForegroundColor Gray
            Write-Host "         Pattern: $($file.Pattern)" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "[Step 3/3] Verification..."
Write-Host "  Files updated: $updatedCount" -ForegroundColor Cyan
Write-Host "  Files skipped: $skippedCount" -ForegroundColor Cyan
Write-Host "  Current version: $version" -ForegroundColor Cyan

Write-Host ""
Write-Host "============================================================================"
Write-Host "  SUCCESS: Version update completed!" -ForegroundColor Green
Write-Host "============================================================================"
Write-Host ""

exit 0
