#!/usr/bin/env pwsh
# Test .NET Desktop Runtime detection logic

Write-Host "Testing .NET Desktop Runtime Detection" -ForegroundColor Cyan
Write-Host "=" * 60

# Test 1: Check if directory exists
$programFiles = $env:ProgramFiles
$desktopAppPath = Join-Path $programFiles "dotnet\shared\Microsoft.WindowsDesktop.App"

Write-Host "`nTest 1: Directory Existence Check"
Write-Host "Looking for: $desktopAppPath"

if (Test-Path $desktopAppPath) {
    Write-Host "[PASS] Directory exists" -ForegroundColor Green

    # List versions
    $versions = Get-ChildItem $desktopAppPath | Select-Object -ExpandProperty Name
    Write-Host "`nInstalled versions:"
    foreach ($ver in $versions) {
        Write-Host "  - $ver" -ForegroundColor Yellow
    }
} else {
    Write-Host "[FAIL] Directory does not exist" -ForegroundColor Red
}

# Test 2: Check 32-bit Program Files (x86)
if (Test-Path "C:\Program Files (x86)") {
    $programFilesX86 = ${env:ProgramFiles(x86)}
    $desktopAppPathX86 = Join-Path $programFilesX86 "dotnet\shared\Microsoft.WindowsDesktop.App"

    Write-Host "`nTest 2: 32-bit Program Files Check"
    Write-Host "Looking for: $desktopAppPathX86"

    if (Test-Path $desktopAppPathX86) {
        Write-Host "[PASS] Directory exists (32-bit)" -ForegroundColor Green
        $versionsX86 = Get-ChildItem $desktopAppPathX86 | Select-Object -ExpandProperty Name
        Write-Host "`nInstalled versions (32-bit):"
        foreach ($ver in $versionsX86) {
            Write-Host "  - $ver" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[INFO] No 32-bit .NET installation" -ForegroundColor Gray
    }
}

Write-Host "`n" -NoNewline
Write-Host "=" * 60
Write-Host "`nConclusion:"

if (Test-Path $desktopAppPath) {
    Write-Host "WiX DirectorySearch should find: $desktopAppPath" -ForegroundColor Green
    Write-Host "The installer SHOULD allow installation to proceed." -ForegroundColor Green
} else {
    Write-Host "WiX DirectorySearch will NOT find the directory" -ForegroundColor Red
    Write-Host "The installer will show .NET requirement error." -ForegroundColor Red
}

Write-Host ""
