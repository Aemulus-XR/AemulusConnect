<#
.SYNOPSIS
    Validates JSON file syntax and structure.

.DESCRIPTION
    Checks if a JSON file is valid by attempting to parse it.
    Optionally checks for empty property names which may cause issues with some parsers.

.PARAMETER Path
    Path to the JSON file to validate.

.PARAMETER CheckEmptyKeys
    If specified, also checks for empty string property names ("":) which are valid JSON
    but not supported by PowerShell's ConvertFrom-Json.

.PARAMETER Quiet
    Suppress output and only use exit codes (0 = valid, 1 = invalid).

.EXAMPLE
    .\validate-json.ps1 -Path data.json

.EXAMPLE
    .\validate-json.ps1 -Path data.json -CheckEmptyKeys

.EXAMPLE
    .\validate-json.ps1 -Path data.json -Quiet
    if ($LASTEXITCODE -eq 0) { Write-Host "Valid!" }
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Path,

    [Parameter(Mandatory=$false)]
    [switch]$CheckEmptyKeys,

    [Parameter(Mandatory=$false)]
    [switch]$Quiet
)

function Write-Output-Conditional {
    param([string]$Message, [string]$Color = "White")
    if (-not $Quiet) {
        Write-Host $Message -ForegroundColor $Color
    }
}

try {
    # Check file exists
    if (-not (Test-Path $Path)) {
        Write-Output-Conditional "ERROR: File not found: $Path" "Red"
        exit 1
    }

    Write-Output-Conditional "Validating JSON file: $Path" "Cyan"

    # Read the file
    $content = Get-Content -Path $Path -Raw

    if ([string]::IsNullOrWhiteSpace($content)) {
        Write-Output-Conditional "ERROR: File is empty" "Red"
        exit 1
    }

    # Check for empty keys if requested
    if ($CheckEmptyKeys -and $content -match '""[\s]*:') {
        Write-Output-Conditional "WARNING: Found empty string as property name ('':)" "Yellow"
        Write-Output-Conditional "  This is valid JSON but not supported by PowerShell's ConvertFrom-Json" "Yellow"
        if (-not $Quiet) {
            Write-Host ""
        }
    }

    # Attempt to parse JSON
    $json = $content | ConvertFrom-Json -ErrorAction Stop

    # Success
    Write-Output-Conditional "SUCCESS: Valid JSON" "Green"

    # Provide some stats
    if (-not $Quiet) {
        if ($json -is [array]) {
            Write-Host "  Type: Array" -ForegroundColor Gray
            Write-Host "  Items: $($json.Count)" -ForegroundColor Gray
        }
        elseif ($json -is [PSCustomObject]) {
            Write-Host "  Type: Object" -ForegroundColor Gray
            $propCount = ($json.PSObject.Properties | Measure-Object).Count
            Write-Host "  Properties: $propCount" -ForegroundColor Gray
        }
        else {
            Write-Host "  Type: $($json.GetType().Name)" -ForegroundColor Gray
        }

        $lines = ($content -split "`n").Count
        Write-Host "  Lines: $lines" -ForegroundColor Gray

        $sizeKB = [math]::Round((Get-Item $Path).Length / 1KB, 2)
        Write-Host "  Size: $sizeKB KB" -ForegroundColor Gray
    }

    exit 0
}
catch {
    Write-Output-Conditional "ERROR: Invalid JSON" "Red"
    Write-Output-Conditional "  $($_.Exception.Message)" "Red"
    exit 1
}
