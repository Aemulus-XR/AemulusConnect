#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Cleans build artifacts for AemulusConnect

.DESCRIPTION
    Removes bin and obj directories from:
    - Main project (src/)
    - Installer project (src/installer/)
    Runs dotnet clean for thorough cleanup.

.PARAMETER Configuration
    Build configuration (Debug or Release). Default: Release

.EXAMPLE
    .\clean.ps1

.EXAMPLE
    .\clean.ps1 -Configuration Debug
#>

[CmdletBinding()]
param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release"
)

# Import helpers
. (Join-Path $PSScriptRoot "helpers.ps1")

Write-Host "Cleaning previous builds..." -ForegroundColor Cyan

# Clean with dotnet
Write-Host "  Running dotnet clean..." -NoNewline
& dotnet clean $ProjectFile --configuration $Configuration --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host " OK" -ForegroundColor Green
}
else {
    Write-Host " WARNING" -ForegroundColor Yellow
}

# Remove directories
$dirsToRemove = @(
    (Join-Path $SrcDir "bin"),
    (Join-Path $SrcDir "obj"),
    (Join-Path $InstallerDir "obj"),
    (Join-Path $InstallerDir "bin")
)

Write-Host "  Removing build artifacts..." -NoNewline
$removedCount = 0
foreach ($dir in $dirsToRemove) {
    if (Test-Path $dir) {
        Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        $removedCount++
    }
}
Write-Host " OK" -ForegroundColor Green
Write-Host "    Removed $removedCount directories" -ForegroundColor Gray

Write-Host ""
Write-Host "Clean completed!" -ForegroundColor Green
exit 0
