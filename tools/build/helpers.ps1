#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Shared helper functions and configuration for AemulusConnect build scripts

.DESCRIPTION
    This module provides common functions and path configurations used across
    all build scripts. Import this at the beginning of each build script.

.EXAMPLE
    . (Join-Path $PSScriptRoot "helpers.ps1")
#>

#region Output Functions

function Write-Step {
    <#
    .SYNOPSIS
        Writes a step header to the console
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter(Mandatory)]
        [int]$Step,

        [Parameter(Mandatory)]
        [int]$Total
    )

    Write-Host ""
    Write-Host "[Step $Step/$Total] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message -ForegroundColor Yellow
}

function Write-Success {
    <#
    .SYNOPSIS
        Writes a success message to the console
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "  [OK]   " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Info {
    <#
    .SYNOPSIS
        Writes an informational message to the console
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "  " -NoNewline
    Write-Host $Message
}

function Write-Warning {
    <#
    .SYNOPSIS
        Writes a warning message to the console
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "  [WARN] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message
}

function Write-ErrorMessage {
    <#
    .SYNOPSIS
        Writes an error message to the console
    .NOTES
        Renamed from Write-Error to avoid conflict with PowerShell built-in
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "  [ERROR] " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor Red
}

#endregion

#region Utility Functions

function Test-CommandExists {
    <#
    .SYNOPSIS
        Tests if a command exists in the current session
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Command
    )

    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Get-FormattedFileSize {
    <#
    .SYNOPSIS
        Gets the formatted file size in MB
    #>
    param(
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    if (Test-Path $FilePath) {
        $size = (Get-Item $FilePath).Length
        $sizeMB = [math]::Round($size / 1MB, 2)
        return "$sizeMB MB"
    }
    return "N/A"
}

#endregion

#region Path Configuration

# Root directory (AemulusConnect/)
$Script:RootDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# Source directories
$Script:SrcDir = Join-Path $RootDir "src"
$Script:ProjectFile = Join-Path $SrcDir "AemulusConnect.csproj"

# Installer directories
$Script:InstallerDir = Join-Path $SrcDir "installer"
$Script:WxsFile = Join-Path $InstallerDir "AemulusConnect.wxs"
$Script:WixProjectFile = Join-Path $InstallerDir "AemulusConnect.wixproj"

# Shipping directory (staging area)
$Script:ShippingDir = Join-Path $SrcDir "Shipping"
$Script:ShippingBinDir = Join-Path $ShippingDir "bin"
$Script:ShippingDocsDir = Join-Path $ShippingDir "documentation"
$Script:ShippingInstallerDir = Join-Path $ShippingDir "installer"

# Build output directory
$Script:BuildOutputPath = ""  # Will be set dynamically based on build configuration

# Tools directories
$Script:ToolsDir = Join-Path $RootDir "tools"
$Script:NotesDir = Join-Path $RootDir "notes"

# Export path variables for use in other scripts
$Global:RootDir = $Script:RootDir
$Global:SrcDir = $Script:SrcDir
$Global:ProjectFile = $Script:ProjectFile
$Global:InstallerDir = $Script:InstallerDir
$Global:WxsFile = $Script:WxsFile
$Global:WixProjectFile = $Script:WixProjectFile
$Global:ShippingDir = $Script:ShippingDir
$Global:ShippingBinDir = $Script:ShippingBinDir
$Global:ShippingDocsDir = $Script:ShippingDocsDir
$Global:ShippingInstallerDir = $Script:ShippingInstallerDir
$Global:ToolsDir = $Script:ToolsDir
$Global:NotesDir = $Script:NotesDir

#endregion

#region Exports

# Export functions
Export-ModuleMember -Function @(
    'Write-Step',
    'Write-Success',
    'Write-Info',
    'Write-Warning',
    'Write-ErrorMessage',
    'Test-CommandExists',
    'Get-FormattedFileSize'
)

# Export variables
Export-ModuleMember -Variable @(
    'RootDir',
    'SrcDir',
    'ProjectFile',
    'InstallerDir',
    'WxsFile',
    'WixProjectFile',
    'ShippingDir',
    'ShippingBinDir',
    'ShippingDocsDir',
    'ShippingInstallerDir',
    'ToolsDir',
    'NotesDir'
)

#endregion

# Ensure error action preference is set
if (-not $Global:ErrorActionPreference) {
    $Global:ErrorActionPreference = "Stop"
}

Write-Verbose "Build helpers loaded. Root directory: $RootDir"
