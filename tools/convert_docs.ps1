#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Converts documentation files for the installer
.DESCRIPTION
    Converts LICENSE.md to RTF and USER_README.md to PDF for inclusion in the installer
.PARAMETER SkipPdf
    Skip PDF generation (useful if wkhtmltopdf is not installed)
#>

param(
    [switch]$SkipPdf
)

#region Helper Functions

function Write-Step {
    param([string]$Message)
    Write-Host "[CONVERT] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK]   " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [INFO] " -ForegroundColor Gray -NoNewline
    Write-Host $Message
}

function Write-Error {
    param([string]$Message)
    Write-Host "  [ERROR] " -ForegroundColor Red -NoNewline
    Write-Host $Message
}

function Test-CommandExists {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Get-PandocPath {
    # Try to find pandoc in PATH first
    $pandoc = Get-Command pandoc -ErrorAction SilentlyContinue
    if ($pandoc) {
        return $pandoc.Source
    }

    # Common installation paths
    $commonPaths = @(
        "$env:LOCALAPPDATA\Pandoc\pandoc.exe",
        "$env:ProgramFiles\Pandoc\pandoc.exe",
        "${env:ProgramFiles(x86)}\Pandoc\pandoc.exe"
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

function Get-WkhtmltopdfPath {
    # Try to find wkhtmltopdf in PATH first
    $wkhtmltopdf = Get-Command wkhtmltopdf -ErrorAction SilentlyContinue
    if ($wkhtmltopdf) {
        return $wkhtmltopdf.Source
    }

    # Common installation paths
    $commonPaths = @(
        "$env:ProgramFiles\wkhtmltopdf\bin\wkhtmltopdf.exe",
        "${env:ProgramFiles(x86)}\wkhtmltopdf\bin\wkhtmltopdf.exe",
        "$env:LOCALAPPDATA\Programs\wkhtmltopdf\bin\wkhtmltopdf.exe"
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

#endregion

#region Configuration

$ScriptRoot = Split-Path -Parent $PSScriptRoot
$LicenseMd = Join-Path $ScriptRoot "LICENSE.md"
$UserReadmeMd = Join-Path $ScriptRoot "notes\USER_README.md"
$InstallerDir = Join-Path $ScriptRoot "src\installer"
$LicenseRtf = Join-Path $InstallerDir "license.rtf"
$UserManualPdf = Join-Path $InstallerDir "UserManual.pdf"

#endregion

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host " Documentation Conversion for Installer" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

#region Convert LICENSE.md to RTF

Write-Step "Converting LICENSE.md to license.rtf..."

if (-not (Test-Path $LicenseMd)) {
    Write-Error "LICENSE.md not found at: $LicenseMd"
    exit 1
}

# Check for pandoc
$pandocPath = Get-PandocPath
if ($pandocPath) {
    Write-Info "Using pandoc for conversion: $pandocPath"

    try {
        & $pandocPath $LicenseMd -s -o $LicenseRtf --metadata title="License Agreement"

        if ($LASTEXITCODE -eq 0 -and (Test-Path $LicenseRtf)) {
            Write-Success "License RTF created: $LicenseRtf"
        }
        else {
            throw "Pandoc conversion failed"
        }
    }
    catch {
        Write-Error "Failed to convert LICENSE.md with pandoc"
        Write-Info "Falling back to manual RTF generation"
        $useFallback = $true
    }
}
else {
    Write-Info "Pandoc not found, using built-in RTF generation"
    $useFallback = $true
}

# Fallback: Create RTF manually
if ($useFallback) {
    $licenseContent = Get-Content $LicenseMd -Raw

    # Simple RTF wrapper with proper formatting
    $rtfContent = @"
{\rtf1\ansi\ansicpg1252\deff0\nouicompat{\fonttbl{\f0\fnil\fcharset0 Courier New;}{\f1\fnil\fcharset0 Calibri;}}
{\*\generator Custom PowerShell RTF Generator}
\viewkind4\uc1
\pard\sa200\sl276\slmult1\f1\fs22\lang9

"@

    # Convert markdown content to RTF
    $lines = $licenseContent -split "`r?`n"
    foreach ($line in $lines) {
        if ($line -match "^#+ (.+)") {
            # Header
            $rtfContent += "\b\fs28 $($matches[1])\b0\fs22\par`n"
        }
        elseif ($line.Trim() -eq "") {
            # Empty line
            $rtfContent += "\par`n"
        }
        else {
            # Regular text - escape RTF special characters
            $escapedLine = $line -replace '\\', '\\\\' -replace '{', '\{' -replace '}', '\}'
            $rtfContent += "$escapedLine\par`n"
        }
    }

    $rtfContent += "}`n"

    Set-Content -Path $LicenseRtf -Value $rtfContent -Encoding ASCII
    Write-Success "License RTF created (fallback method): $LicenseRtf"
}

#endregion

#region Convert USER_README.md to PDF

if (-not $SkipPdf) {
    Write-Step "Converting USER_README.md to PDF..."

    if (-not (Test-Path $UserReadmeMd)) {
        Write-Error "USER_README.md not found at: $UserReadmeMd"
        Write-Info "Skipping PDF generation"
    }
    else {
        # Check for pandoc with PDF support
        $pandocPath = Get-PandocPath
        if ($pandocPath) {
            Write-Info "Using pandoc for PDF conversion"

            # Check for wkhtmltopdf
            $wkhtmltopdfPath = Get-WkhtmltopdfPath
            if ($wkhtmltopdfPath) {
                Write-Info "Found wkhtmltopdf: $wkhtmltopdfPath"
            }

            try {
                # Try using pandoc with wkhtmltopdf or other PDF engine
                # Set resource path to the directory containing the markdown file so images can be found
                $UserReadmeDir = Split-Path -Parent $UserReadmeMd
                $pdfArgs = @(
                    $UserReadmeMd,
                    "-o", $UserManualPdf,
                    "--metadata", "title=Aemulus XR Reporting - User Manual",
                    "--resource-path=$UserReadmeDir"
                )

                if ($wkhtmltopdfPath) {
                    $pdfArgs += "--pdf-engine=$wkhtmltopdfPath"
                }

                & $pandocPath @pdfArgs 2>&1 | Out-Null

                if ($LASTEXITCODE -eq 0 -and (Test-Path $UserManualPdf)) {
                    Write-Success "User Manual PDF created: $UserManualPdf"
                }
                else {
                    throw "Pandoc PDF conversion failed"
                }
            }
            catch {
                Write-Warning "Pandoc PDF conversion failed (wkhtmltopdf may not be installed)"
                Write-Info "Trying alternative PDF engine..."

                # Try with different engines
                $engines = @("xelatex", "pdflatex", "context")
                $success = $false

                foreach ($engine in $engines) {
                    try {
                        $UserReadmeDir = Split-Path -Parent $UserReadmeMd
                        & $pandocPath $UserReadmeMd -o $UserManualPdf --metadata title="Aemulus XR Reporting - User Manual" --resource-path="$UserReadmeDir" --pdf-engine=$engine 2>&1 | Out-Null

                        if ($LASTEXITCODE -eq 0 -and (Test-Path $UserManualPdf)) {
                            Write-Success "User Manual PDF created using $engine`: $UserManualPdf"
                            $success = $true
                            break
                        }
                    }
                    catch {
                        # Try next engine
                    }
                }

                if (-not $success) {
                    Write-Warning "Could not generate PDF with any available engine"
                    Write-Info "Install wkhtmltopdf from https://wkhtmltopdf.org/ or a LaTeX distribution"
                    Write-Info "To skip PDF generation, use: .\convert_docs.ps1 -SkipPdf"
                }
            }
        }
        else {
            Write-Warning "Pandoc not found - cannot generate PDF"
            Write-Info "Install pandoc from https://pandoc.org/ to enable PDF generation"
            Write-Info "Or use: .\convert_docs.ps1 -SkipPdf to skip PDF generation"
        }
    }
}
else {
    Write-Info "Skipping PDF generation (use without -SkipPdf to enable)"
}

#endregion

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host " Conversion Complete" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

exit 0
