<#
.SYNOPSIS
    Wrapper for j2c.ps1 - Converts JSON files to CSV format.

.DESCRIPTION
    This is a convenience wrapper that calls j2c.ps1 with all the same parameters.
    Use this for the full PowerShell-style name, or use j2c.ps1 directly for brevity.

.PARAMETER InputPath
    Path to the input JSON file.

.PARAMETER OutputPath
    Path for the output CSV file.

.PARAMETER ArrayHandling
    How to handle arrays: 'Stringify', 'Concatenate', or 'Separate'.

.PARAMETER MaxDepth
    Maximum nesting depth to flatten.

.PARAMETER Delimiter
    CSV delimiter character.

.EXAMPLE
    .\ConvertTo-Csv.ps1 -InputPath data.json

.EXAMPLE
    .\ConvertTo-Csv.ps1 -InputPath data.json -OutputPath output.csv
#>

& "$PSScriptRoot\j2c.ps1" @args
