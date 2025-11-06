#!/usr/bin/env pwsh
# Encoding checker for PowerShell scripts

$scripts = @("build_and_package.ps1", "verify_prerequisites.ps1")

foreach ($script in $scripts) {
    Write-Host "`nChecking: $script" -ForegroundColor Cyan
    Write-Host "=" * 60

    if (Test-Path $script) {
        # Check file encoding
        $bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $script).Path)

        # Check for BOM
        if ($bytes.Length -ge 3) {
            $bom = $bytes[0..2]
            if ($bom[0] -eq 0xEF -and $bom[1] -eq 0xBB -and $bom[2] -eq 0xBF) {
                Write-Host "Encoding: UTF-8 with BOM" -ForegroundColor Yellow
            }
            elseif ($bom[0] -eq 0xFF -and $bom[1] -eq 0xFE) {
                Write-Host "Encoding: UTF-16 LE" -ForegroundColor Yellow
            }
            elseif ($bom[0] -eq 0xFE -and $bom[1] -eq 0xFF) {
                Write-Host "Encoding: UTF-16 BE" -ForegroundColor Yellow
            }
            else {
                Write-Host "Encoding: UTF-8 without BOM (or ASCII)" -ForegroundColor Green
            }
        }

        # Try to parse the script
        Write-Host "Syntax Check: " -NoNewline
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize(
            (Get-Content $script -Raw),
            [ref]$errors
        )

        if ($errors) {
            Write-Host "FAILED" -ForegroundColor Red
            foreach ($err in $errors) {
                Write-Host "  Line $($err.Token.StartLine), Col $($err.Token.StartColumn): $($err.Message)" -ForegroundColor Red
            }
        }
        else {
            Write-Host "PASSED" -ForegroundColor Green
        }

        # File size
        $size = (Get-Item $script).Length
        Write-Host "File Size: $size bytes"

        # Line count
        $lines = (Get-Content $script).Count
        Write-Host "Line Count: $lines"
    }
    else {
        Write-Host "File not found!" -ForegroundColor Red
    }
}

Write-Host "`n" -NoNewline
