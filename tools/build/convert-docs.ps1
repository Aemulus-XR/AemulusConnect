#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Converts documentation from Markdown to RTF/PDF

.DESCRIPTION
    Wrapper script that calls the main convert_docs.ps1 script.
    Converts LICENSE.md to license.rtf and USER_GUIDE.md to UserManual.pdf.

.EXAMPLE
    .\convert-docs.ps1
#>

[CmdletBinding()]
param()

# Import helpers
. (Join-Path $PSScriptRoot "helpers.ps1")

Write-Host "Converting documentation..." -ForegroundColor Cyan

# Call the main convert_docs.ps1 script
$convertDocsScript = Join-Path $ToolsDir "convert_docs.ps1"

if (-not (Test-Path $convertDocsScript)) {
    Write-Host "  WARNING: Document conversion script not found: $convertDocsScript" -ForegroundColor Yellow
    Write-Host "  Skipping documentation conversion" -ForegroundColor Yellow
    exit 0
}

try {
    & $convertDocsScript

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  WARNING: Document conversion script returned non-zero exit code" -ForegroundColor Yellow
        Write-Host "  Continuing anyway..." -ForegroundColor Yellow
        exit 0  # Don't fail the build
    }

    Write-Host "  Documentation converted successfully" -ForegroundColor Green
    exit 0
}
catch {
    Write-Host "  WARNING: Failed to run document conversion script: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "  Continuing with build..." -ForegroundColor Yellow
    exit 0  # Don't fail the build
}
