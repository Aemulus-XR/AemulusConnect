#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Converts documentation from Markdown to RTF/PDF

.DESCRIPTION
    Wrapper script that calls the main convert_docs.ps1 script.
    Converts LICENSE.md to LICENSE.rtf and USER_GUIDE.md to USER_GUIDE.pdf.
    Outputs to src/Shipping/documentation/ directory.

.EXAMPLE
    .\convert-docs.ps1
#>

[CmdletBinding()]
param()

# Import helpers
. (Join-Path $PSScriptRoot "helpers.ps1")

Write-Host "Converting documentation..." -ForegroundColor Cyan

# Call the main convert_docs.ps1 script with output to Shipping/documentation
$convertDocsScript = Join-Path $ToolsDir "convert_docs.ps1"

if (-not (Test-Path $convertDocsScript)) {
    Write-Host "  WARNING: Document conversion script not found: $convertDocsScript" -ForegroundColor Yellow
    Write-Host "  Skipping documentation conversion" -ForegroundColor Yellow
    exit 0
}

try {
    # Output to Shipping/documentation directory
    Write-Host "  Output directory: $ShippingDocsDir" -ForegroundColor Gray

    & $convertDocsScript -OutputDir $ShippingDocsDir

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  WARNING: Document conversion script returned non-zero exit code" -ForegroundColor Yellow
        Write-Host "  Continuing anyway..." -ForegroundColor Yellow
        exit 0  # Don't fail the build
    }

    Write-Host "  Documentation converted successfully" -ForegroundColor Green

    # Show what was created
    $licenseRtf = Join-Path $ShippingDocsDir "LICENSE.rtf"
    $userGuidePdf = Join-Path $ShippingDocsDir "USER_GUIDE.pdf"

    if (Test-Path $licenseRtf) {
        Write-Host "    Created: LICENSE.rtf" -ForegroundColor Gray
    }
    if (Test-Path $userGuidePdf) {
        Write-Host "    Created: USER_GUIDE.pdf" -ForegroundColor Gray
    }

    exit 0
}
catch {
    Write-Host "  WARNING: Failed to run document conversion script: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "  Continuing with build..." -ForegroundColor Yellow
    exit 0  # Don't fail the build
}
