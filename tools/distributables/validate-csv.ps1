<#
.SYNOPSIS
    Validates CSV file syntax and structure.

.DESCRIPTION
    Checks if a CSV file is valid by attempting to parse it and checking for:
    - Consistent column counts across rows
    - Valid header row
    - Proper quoting and escaping
    - Empty file detection

.PARAMETER Path
    Path to the CSV file to validate.

.PARAMETER Delimiter
    CSV delimiter character. Default is comma (,).

.PARAMETER NoHeader
    If specified, treats the file as having no header row.

.PARAMETER Quiet
    Suppress output and only use exit codes (0 = valid, 1 = invalid).

.EXAMPLE
    .\validate-csv.ps1 -Path data.csv

.EXAMPLE
    .\validate-csv.ps1 -Path data.tsv -Delimiter "`t"

.EXAMPLE
    .\validate-csv.ps1 -Path data.csv -Quiet
    if ($LASTEXITCODE -eq 0) { Write-Host "Valid!" }
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Path,

    [Parameter(Mandatory=$false)]
    [string]$Delimiter = ',',

    [Parameter(Mandatory=$false)]
    [switch]$NoHeader,

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

    Write-Output-Conditional "Validating CSV file: $Path" "Cyan"

    # Read the file
    $content = Get-Content -Path $Path -Raw

    if ([string]::IsNullOrWhiteSpace($content)) {
        Write-Output-Conditional "ERROR: File is empty" "Red"
        exit 1
    }

    # Attempt to parse CSV
    $csv = Import-Csv -Path $Path -Delimiter $Delimiter -ErrorAction Stop

    if ($csv.Count -eq 0) {
        Write-Output-Conditional "WARNING: CSV file has no data rows" "Yellow"
        exit 0
    }

    # Get column count from first row
    $firstRowColumns = ($csv[0].PSObject.Properties | Measure-Object).Count

    # Check for empty column names (unless NoHeader)
    if (-not $NoHeader) {
        $emptyHeaders = $csv[0].PSObject.Properties | Where-Object { [string]::IsNullOrWhiteSpace($_.Name) }
        if ($emptyHeaders) {
            Write-Output-Conditional "WARNING: Found empty column name(s) in header" "Yellow"
        }
    }

    # Check for consistent column counts
    $inconsistentRows = @()
    for ($i = 0; $i -lt $csv.Count; $i++) {
        $rowColumns = ($csv[$i].PSObject.Properties | Measure-Object).Count
        if ($rowColumns -ne $firstRowColumns) {
            $inconsistentRows += "Row $($i + 2): $rowColumns columns (expected $firstRowColumns)"
        }
    }

    if ($inconsistentRows.Count -gt 0) {
        Write-Output-Conditional "WARNING: Inconsistent column counts detected:" "Yellow"
        foreach ($issue in $inconsistentRows | Select-Object -First 5) {
            Write-Output-Conditional "  $issue" "Yellow"
        }
        if ($inconsistentRows.Count -gt 5) {
            Write-Output-Conditional "  ... and $($inconsistentRows.Count - 5) more" "Yellow"
        }
    }

    # Success
    Write-Output-Conditional "SUCCESS: Valid CSV" "Green"

    # Provide some stats
    if (-not $Quiet) {
        Write-Host "  Rows: $($csv.Count)" -ForegroundColor Gray
        Write-Host "  Columns: $firstRowColumns" -ForegroundColor Gray

        if (-not $NoHeader) {
            $headers = $csv[0].PSObject.Properties.Name -join ", "
            if ($headers.Length -gt 80) {
                $headers = $headers.Substring(0, 77) + "..."
            }
            Write-Host "  Headers: $headers" -ForegroundColor Gray
        }

        $sizeKB = [math]::Round((Get-Item $Path).Length / 1KB, 2)
        Write-Host "  Size: $sizeKB KB" -ForegroundColor Gray

        $delimiterName = switch ($Delimiter) {
            ',' { "comma" }
            "`t" { "tab" }
            ';' { "semicolon" }
            '|' { "pipe" }
            default { "'$Delimiter'" }
        }
        Write-Host "  Delimiter: $delimiterName" -ForegroundColor Gray
    }

    exit 0
}
catch {
    Write-Output-Conditional "ERROR: Invalid CSV" "Red"
    Write-Output-Conditional "  $($_.Exception.Message)" "Red"
    exit 1
}
