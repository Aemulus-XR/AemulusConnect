#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Prerequisites Verification Script

.DESCRIPTION
    This script checks if all required tools are installed for building
    the installer package.

.PARAMETER Detailed
    Show detailed version information for all tools

.EXAMPLE
    .\verify_prerequisites.ps1
    Check all prerequisites

.EXAMPLE
    .\verify_prerequisites.ps1 -Detailed
    Check prerequisites with detailed version information

.NOTES
    Checks for:
    - .NET SDK (version 8 or higher)
    - WiX Toolset (version 4 or higher)
    - Project files
    - Installer configuration
    - UpgradeCode GUID customization
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Show detailed version information")]
    [switch]$Detailed
)

# Set error action preference
$ErrorActionPreference = "Stop"

#region Helper Functions

function Write-CheckResult {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Pass', 'Fail', 'Warning')]
        [string]$Status,

        [Parameter(Mandatory)]
        [string]$Message
    )

    switch ($Status) {
        'Pass' {
            Write-Host "  [OK]   " -ForegroundColor Green -NoNewline
            Write-Host $Message
        }
        'Fail' {
            Write-Host "  [FAIL] " -ForegroundColor Red -NoNewline
            Write-Host $Message -ForegroundColor Red
            $script:AllOk = $false
        }
        'Warning' {
            Write-Host "  [WARN] " -ForegroundColor Yellow -NoNewline
            Write-Host $Message
        }
    }
}

function Write-DetailInfo {
    param([string]$Message)
    Write-Host "        $Message" -ForegroundColor Gray
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Get-DotNetVersion {
    try {
        $version = (dotnet --version 2>&1) | Select-Object -First 1
        return $version.Trim()
    }
    catch {
        return $null
    }
}

function Get-WixVersion {
    try {
        $version = (wix --version 2>&1) | Select-Object -First 1
        return $version.Trim()
    }
    catch {
        return $null
    }
}

#endregion

#region Configuration

$ScriptRoot = Split-Path -Parent $PSScriptRoot
$SrcDir = Join-Path $ScriptRoot "src"
$InstallerDir = Join-Path $SrcDir "installer"
$ProjectFile = Join-Path $SrcDir "Aemulus XR Reporting App.csproj"
$WxsFile = Join-Path $InstallerDir "AemulusXRReporting.wxs"

$AllOk = $true

#endregion

#region Banner

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host " Aemulus XR Reporting - Prerequisites Check" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

#endregion

#region Check .NET SDK

Write-Host "Checking .NET SDK..." -ForegroundColor Yellow

if (Test-CommandExists "dotnet") {
    $dotnetVersion = Get-DotNetVersion

    if ($dotnetVersion) {
        # Extract major version
        $majorVersion = [int]($dotnetVersion -split '\.')[0]

        if ($majorVersion -ge 8) {
            Write-CheckResult -Status Pass -Message ".NET SDK version: $dotnetVersion"

            if ($Detailed) {
                $sdks = dotnet --list-sdks 2>&1 | Where-Object { $_ -match '^\d+\.\d+' }
                Write-DetailInfo "Installed SDKs:"
                foreach ($sdk in $sdks) {
                    Write-DetailInfo "  $sdk"
                }
            }
        }
        else {
            Write-CheckResult -Status Warning -Message ".NET 8 SDK recommended, found $dotnetVersion"
            Write-DetailInfo "Download from: https://dotnet.microsoft.com/download/dotnet/8.0"
        }
    }
    else {
        Write-CheckResult -Status Fail -Message ".NET SDK version could not be determined"
    }
}
else {
    Write-CheckResult -Status Fail -Message ".NET SDK is not installed"
    Write-DetailInfo "Install from: https://dotnet.microsoft.com/download/dotnet/8.0"
}

Write-Host ""

#endregion

#region Check WiX Toolset

Write-Host "Checking WiX Toolset..." -ForegroundColor Yellow

if (Test-CommandExists "wix") {
    $wixVersion = Get-WixVersion

    if ($wixVersion) {
        Write-CheckResult -Status Pass -Message "WiX Toolset version: $wixVersion"

        if ($Detailed) {
            $wixPath = (Get-Command wix).Source
            Write-DetailInfo "Location: $wixPath"

            # Check for extensions
            $extensions = wix extension list 2>&1
            if ($extensions) {
                Write-DetailInfo "Extensions installed:"
                Write-DetailInfo "  (use 'wix extension list' for details)"
            }
        }
    }
    else {
        Write-CheckResult -Status Warning -Message "WiX Toolset found but version could not be determined"
    }
}
else {
    Write-CheckResult -Status Fail -Message "WiX Toolset is not installed"
    Write-DetailInfo "Install with: dotnet tool install --global wix"
    Write-DetailInfo "Then restart your terminal/PowerShell session"
}

Write-Host ""

#endregion

#region Check Project Files

Write-Host "Checking project files..." -ForegroundColor Yellow

if (Test-Path $ProjectFile) {
    Write-CheckResult -Status Pass -Message "Project file found"

    if ($Detailed) {
        Write-DetailInfo "Path: $ProjectFile"

        # Try to read target framework
        try {
            [xml]$projectXml = Get-Content $ProjectFile
            $targetFramework = $projectXml.Project.PropertyGroup.TargetFramework
            if ($targetFramework) {
                Write-DetailInfo "Target Framework: $targetFramework"
            }
        }
        catch {
            # Ignore errors reading project file
        }
    }
}
else {
    Write-CheckResult -Status Fail -Message "Project file not found: $ProjectFile"
}

Write-Host ""

#endregion

#region Check Installer Configuration

Write-Host "Checking installer configuration..." -ForegroundColor Yellow

if (Test-Path $WxsFile) {
    Write-CheckResult -Status Pass -Message "WiX source file found"

    # Check if UpgradeCode has been changed from default
    $wxsContent = Get-Content $WxsFile -Raw

    if ($wxsContent -match '12345678-1234-1234-1234-123456789012') {
        Write-CheckResult -Status Warning -Message "UpgradeCode still has default value"
        Write-DetailInfo "Generate a unique GUID: [guid]::NewGuid()"
        Write-DetailInfo "Update line 11 in AemulusXRReporting.wxs"
        Write-DetailInfo "See installer\SETUP_GUIDE.md for details"
    }
    else {
        Write-CheckResult -Status Pass -Message "UpgradeCode has been customized"

        if ($Detailed) {
            # Extract UpgradeCode, ProductVersion, etc.
            if ($wxsContent -match '\$\(var\.UpgradeCode\)\s*=\s*"([^"]+)"' -or
                $wxsContent -match 'UpgradeCode\s*=\s*"([^"]+)"') {
                $upgradeCode = $matches[1]
                Write-DetailInfo "UpgradeCode: $upgradeCode"
            }

            if ($wxsContent -match '\$\(var\.ProductVersion\)\s*=\s*"([^"]+)"' -or
                $wxsContent -match 'ProductVersion\s*=\s*"([^"]+)"') {
                $productVersion = $matches[1]
                Write-DetailInfo "Product Version: $productVersion"
            }

            if ($wxsContent -match '\$\(var\.ProductName\)\s*=\s*"([^"]+)"' -or
                $wxsContent -match 'ProductName\s*=\s*"([^"]+)"') {
                $productName = $matches[1]
                Write-DetailInfo "Product Name: $productName"
            }
        }
    }
}
else {
    Write-CheckResult -Status Fail -Message "WiX source file not found: $WxsFile"
}

Write-Host ""

#endregion

#region Check Build Output (Optional)

Write-Host "Checking build output..." -ForegroundColor Yellow

$buildOutputDir = Join-Path $SrcDir "bin\Release\net8.0-windows10.0.26100.0"

if (Test-Path $buildOutputDir) {
    $exePath = Join-Path $buildOutputDir "Aemulus XR Reporting App.exe"

    if (Test-Path $exePath) {
        Write-CheckResult -Status Pass -Message "Previous build output found"

        if ($Detailed) {
            $fileInfo = Get-Item $exePath
            Write-DetailInfo "Build date: $($fileInfo.LastWriteTime)"
            Write-DetailInfo "Size: $([math]::Round($fileInfo.Length / 1MB, 2)) MB"
        }
    }
    else {
        Write-CheckResult -Status Warning -Message "Build output directory exists but no executable found"
        Write-DetailInfo "Run a build before creating installer"
    }
}
else {
    Write-CheckResult -Status Warning -Message "No previous build output found"
    Write-DetailInfo "This is normal for first-time builds"
}

Write-Host ""

#endregion

#region Summary

Write-Host "============================================================================" -ForegroundColor Cyan

if ($AllOk) {
    Write-Host ""
    Write-Host "  SUCCESS: All prerequisites are met!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  You can now build the installer:" -ForegroundColor Cyan
    Write-Host "    .\build_and_package.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "  Options:" -ForegroundColor Cyan
    Write-Host "    .\build_and_package.ps1 -Clean" -ForegroundColor White
    Write-Host "    .\build_and_package.ps1 -SelfContained" -ForegroundColor White
    Write-Host "    .\build_and_package.ps1 -Clean -SelfContained" -ForegroundColor White
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "  ERROR: Some prerequisites are missing or need attention." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Please install missing components and try again." -ForegroundColor Yellow
    Write-Host "  See src\installer\SETUP_GUIDE.md for detailed setup instructions." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

#endregion

# Return appropriate exit code
if ($AllOk) {
    exit 0
}
else {
    exit 1
}
