<#
.SYNOPSIS
    Converts JSON files to CSV format with support for nested objects and arrays.

.DESCRIPTION
    This script converts JSON data to CSV format with intelligent handling of:
    - Nested objects (flattened with dot notation)
    - Arrays (multiple strategies available)
    - Varying schemas across objects
    - Missing/null values

.PARAMETER InputPath
    Path to the input JSON file.

.PARAMETER OutputPath
    Path for the output CSV file. If not specified, outputs to stdout (allows piping/redirection).

.PARAMETER ArrayHandling
    How to handle arrays in the JSON:
    - 'Stringify' (default): Convert arrays to JSON strings
    - 'Concatenate': Join array values with semicolons
    - 'Separate': Create separate rows for each array element (1-to-many)

.PARAMETER MaxDepth
    Maximum nesting depth to flatten. Default is 3.

.PARAMETER Delimiter
    CSV delimiter character. Default is comma (,).

.EXAMPLE
    .\j2c.ps1 -InputPath data.json

.EXAMPLE
    .\j2c.ps1 -InputPath data.json -OutputPath output.csv -ArrayHandling Concatenate

.EXAMPLE
    .\j2c.ps1 -InputPath data.json -MaxDepth 2 -Delimiter ";"

.EXAMPLE
    .\j2c.ps1 -InputPath data.json > output.csv

.EXAMPLE
    .\j2c.ps1 -InputPath data.json | Select-String "pattern"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$InputPath,

    [Parameter(Mandatory=$false)]
    [string]$OutputPath,

    [Parameter(Mandatory=$false)]
    [ValidateSet('Stringify', 'Concatenate', 'Separate')]
    [string]$ArrayHandling = 'Stringify',

    [Parameter(Mandatory=$false)]
    [int]$MaxDepth = 3,

    [Parameter(Mandatory=$false)]
    [string]$Delimiter = ','
)

function Flatten-Object {
    param(
        [Parameter(Mandatory=$true)]
        $Object,

        [Parameter(Mandatory=$false)]
        [string]$Prefix = '',

        [Parameter(Mandatory=$false)]
        [int]$CurrentDepth = 0
    )

    $result = @{}

    foreach ($property in $Object.PSObject.Properties) {
        # Handle empty property names
        $propName = if ([string]::IsNullOrWhiteSpace($property.Name)) { "unnamed_field" } else { $property.Name }
        $key = if ($Prefix) { "$Prefix.$propName" } else { $propName }
        $value = $property.Value

        if ($null -eq $value) {
            $result[$key] = ''
        }
        elseif ($value -is [array]) {
            # Handle arrays based on strategy
            switch ($ArrayHandling) {
                'Stringify' {
                    $result[$key] = ($value | ConvertTo-Json -Compress -Depth 10)
                }
                'Concatenate' {
                    $result[$key] = ($value -join '; ')
                }
                'Separate' {
                    # This requires different logic - return the array for later processing
                    $result[$key] = $value
                }
            }
        }
        elseif ($value -is [PSCustomObject] -and $CurrentDepth -lt $MaxDepth) {
            # Recursively flatten nested objects
            $nested = Flatten-Object -Object $value -Prefix $key -CurrentDepth ($CurrentDepth + 1)
            foreach ($nestedKey in $nested.Keys) {
                $result[$nestedKey] = $nested[$nestedKey]
            }
        }
        else {
            # Primitive value or max depth reached
            $result[$key] = $value
        }
    }

    return $result
}

function Get-AllKeys {
    param(
        [Parameter(Mandatory=$true)]
        [array]$Objects
    )

    $allKeys = @{}

    foreach ($obj in $Objects) {
        $flattened = Flatten-Object -Object $obj
        foreach ($key in $flattened.Keys) {
            $allKeys[$key] = $true
        }
    }

    return $allKeys.Keys | Sort-Object
}

# Main script logic
try {
    # Determine if we're outputting to stdout
    $outputToStdout = [string]::IsNullOrWhiteSpace($OutputPath)

    # Send progress messages to stderr if outputting to stdout, otherwise to stdout
    $progressStream = if ($outputToStdout) { [Console]::Error } else { $null }

    if ($outputToStdout) {
        [Console]::Error.WriteLine("Reading JSON from: $InputPath")
    } else {
        Write-Host "Reading JSON from: $InputPath" -ForegroundColor Cyan
    }

    if (-not (Test-Path $InputPath)) {
        throw "Input file not found: $InputPath"
    }

    # Pre-validation: Check for empty keys in the JSON
    $rawJson = Get-Content -Path $InputPath -Raw
    if ($rawJson -match '""[\s]*:') {
        throw "Invalid JSON: Found empty string as property name. JSON contains '"""":', which is not supported by PowerShell. Please fix the source data to use meaningful property names."
    }

    $jsonContent = $rawJson | ConvertFrom-Json

    # Handle both single object and array of objects
    if ($jsonContent -is [array]) {
        $dataArray = $jsonContent
    }
    else {
        $dataArray = @($jsonContent)
    }

    if ($outputToStdout) {
        [Console]::Error.WriteLine("Found $($dataArray.Count) object(s) to convert")
    } else {
        Write-Host "Found $($dataArray.Count) object(s) to convert" -ForegroundColor Cyan
    }

    # Discover all possible keys across all objects
    if ($outputToStdout) {
        [Console]::Error.WriteLine("Discovering schema...")
    } else {
        Write-Host "Discovering schema..." -ForegroundColor Cyan
    }

    $allKeys = Get-AllKeys -Objects $dataArray

    # Filter out any empty or whitespace keys
    $allKeys = $allKeys | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    if ($outputToStdout) {
        [Console]::Error.WriteLine("Found $($allKeys.Count) unique field(s)")
    } else {
        Write-Host "Found $($allKeys.Count) unique field(s)" -ForegroundColor Cyan
    }

    # Flatten all objects
    $flattenedData = @()
    foreach ($item in $dataArray) {
        $flattened = Flatten-Object -Object $item

        # Ensure all keys are present (fill missing with empty string)
        $row = [ordered]@{}
        foreach ($key in $allKeys) {
            $row[$key] = if ($flattened.ContainsKey($key)) { $flattened[$key] } else { '' }
        }

        $flattenedData += [PSCustomObject]$row
    }

    # Output to stdout or file
    if ($outputToStdout) {
        [Console]::Error.WriteLine("Writing CSV to stdout...")
        # Convert to CSV and output to stdout using Write-Output for proper PowerShell redirection
        $csvOutput = $flattenedData | ConvertTo-Csv -NoTypeInformation -Delimiter $Delimiter
        Write-Output $csvOutput

        [Console]::Error.WriteLine("SUCCESS: Conversion complete!")
        [Console]::Error.WriteLine("  Rows:   $($flattenedData.Count)")
        [Console]::Error.WriteLine("  Columns: $($allKeys.Count)")
    }
    else {
        Write-Host "Writing CSV to: $OutputPath" -ForegroundColor Cyan

        # Export to CSV file
        $flattenedData | Export-Csv -Path $OutputPath -NoTypeInformation -Delimiter $Delimiter -Encoding UTF8

        Write-Host "SUCCESS: Conversion complete!" -ForegroundColor Green
        Write-Host "  Input:  $InputPath" -ForegroundColor Gray
        Write-Host "  Output: $OutputPath" -ForegroundColor Gray
        Write-Host "  Rows:   $($flattenedData.Count)" -ForegroundColor Gray
        Write-Host "  Columns: $($allKeys.Count)" -ForegroundColor Gray
    }
}
catch {
    [Console]::Error.WriteLine("ERROR: $($_.Exception.Message)")
    exit 1
}
