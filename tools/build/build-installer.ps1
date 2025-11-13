#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Builds the WiX installer MSI

.DESCRIPTION
    Creates the MSI installer package using WiX Toolset.
    Sources files from the Shipping folder and outputs to Shipping/installer/.

.PARAMETER Verbose
    Enable verbose build output

.EXAMPLE
    .\build-installer.ps1

.EXAMPLE
    .\build-installer.ps1 -Verbose
#>

[CmdletBinding()]
param(
    [switch]$Verbose
)

# Import helpers
. (Join-Path $PSScriptRoot "helpers.ps1")

Write-Host "Building WiX installer..." -ForegroundColor Cyan

try {
    # Installer sources from Shipping folder
    $BuildOutputPath = $ShippingDir
    Write-Host "  Source files: $BuildOutputPath" -ForegroundColor Gray

    # Output directory
    $OutputDir = Join-Path $ShippingDir "installer"
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }

    # Remove old MSI if exists
    $OldMsi = Join-Path $OutputDir "AemulusConnect.msi"
    if (Test-Path $OldMsi) {
        Remove-Item $OldMsi -Force
    }

    # Build using dotnet build with wixproj
    $WixProj = Join-Path $InstallerDir "AemulusConnect.wixproj"

    if (Test-Path $WixProj) {
        # Use wixproj for build (supports WiX 4 UI extension)
        Write-Host "  Using WiX project: AemulusConnect.wixproj" -ForegroundColor Gray

        $buildArgs = @(
            "build",
            $WixProj,
            "-p:BuildOutputPath=`"$BuildOutputPath`"",
            "-o", $OutputDir
        )

        if ($Verbose) {
            $buildArgs += "-v", "detailed"
        }
        else {
            $buildArgs += "-v", "minimal"
        }

        Write-Host "  Running dotnet build..." -NoNewline
        & dotnet @buildArgs

        if ($LASTEXITCODE -ne 0) {
            Write-Host " FAILED" -ForegroundColor Red
            throw "WiX installer build failed with exit code $LASTEXITCODE"
        }
        Write-Host " OK" -ForegroundColor Green
    }
    else {
        # Fallback to direct wix build
        Write-Host "  Using direct wix build" -ForegroundColor Gray

        Push-Location $InstallerDir
        try {
            $OutputMsi = Join-Path $OutputDir "AemulusConnect.msi"
            $wixArgs = @(
                "build",
                $WxsFile,
                "-out", $OutputMsi,
                "-d", "BuildOutputPath=$BuildOutputPath"
            )

            if ($Verbose) {
                $wixArgs += "-v"
            }

            Write-Host "  Running wix build..." -NoNewline
            & wix @wixArgs

            if ($LASTEXITCODE -ne 0) {
                Write-Host " FAILED" -ForegroundColor Red
                throw "WiX build failed with exit code $LASTEXITCODE"
            }
            Write-Host " OK" -ForegroundColor Green
        }
        finally {
            Pop-Location
        }
    }

    # Rename MSI with version number
    $versionFile = Join-Path $NotesDir "VERSION.md"
    if (Test-Path $versionFile) {
        $versionContent = Get-Content $versionFile -Raw

        if ($versionContent -match 'version=(\d+\.\d+\.\d+)') {
            $version = $matches[1]
            $versionedMsi = Join-Path $OutputDir "AemulusConnect-Installer-$version.msi"
            $builtMsiPath = Join-Path $OutputDir "AemulusConnect.msi"

            if (Test-Path $builtMsiPath) {
                Write-Host "  Renaming installer..." -NoNewline
                Rename-Item -Path $builtMsiPath -NewName ($versionedMsi | Split-Path -Leaf) -Force
                Write-Host " OK" -ForegroundColor Green

                $size = Get-FormattedFileSize $versionedMsi
                Write-Host "    Installer: AemulusConnect-Installer-$version.msi ($size)" -ForegroundColor Gray
            }
            else {
                Write-Host "  WARNING: Built MSI not found: $builtMsiPath" -ForegroundColor Yellow
            }
        }
    }

    Write-Host ""
    Write-Host "Installer created successfully!" -ForegroundColor Green
    Write-Host "  Location: $OutputDir" -ForegroundColor Gray
    exit 0
}
catch {
    Write-Host ""
    Write-Host "  ERROR: WiX installer build failed" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
