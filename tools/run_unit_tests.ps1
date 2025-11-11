#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Run AemulusConnect unit tests

.DESCRIPTION
    Executes the xUnit test suite for AemulusConnect. Returns proper exit codes
    for CI/CD integration (0 = success, 1 = failure).

.PARAMETER VerboseOutput
    Enable verbose test output

.PARAMETER Filter
    Run only tests matching the specified filter pattern

.PARAMETER NoBuild
    Skip building the test project (assumes it's already built)

.PARAMETER Coverage
    Generate code coverage report

.EXAMPLE
    .\run_unit_tests.ps1
    Run all tests with normal output

.EXAMPLE
    .\run_unit_tests.ps1 -VerboseOutput
    Run all tests with detailed output

.EXAMPLE
    .\run_unit_tests.ps1 -Filter "LocalizationTests"
    Run only localization tests

.EXAMPLE
    .\run_unit_tests.ps1 -Coverage
    Run tests and generate coverage report

.NOTES
    Exit Codes:
    0 = All tests passed
    1 = One or more tests failed or build error
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Enable verbose test output")]
    [switch]$VerboseOutput,

    [Parameter(HelpMessage = "Filter tests by name pattern")]
    [string]$Filter,

    [Parameter(HelpMessage = "Skip building the test project")]
    [switch]$NoBuild,

    [Parameter(HelpMessage = "Generate code coverage report")]
    [switch]$Coverage
)

# Set error action preference
$ErrorActionPreference = "Stop"

#region Helper Functions

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host " $Message" -ForegroundColor Cyan
    Write-Host "=================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-Host ">" -ForegroundColor Yellow -NoNewline
    Write-Host " $Message" -ForegroundColor White
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK]  " -ForegroundColor Green -NoNewline
    Write-Host $Message
}

function Write-Failure {
    param([string]$Message)
    Write-Host "  [FAIL]" -ForegroundColor Red -NoNewline
    Write-Host " $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [INFO]" -ForegroundColor Blue -NoNewline
    Write-Host " $Message"
}

#endregion

#region Configuration

$ScriptRoot = $PSScriptRoot
$TestProjectDir = Join-Path $ScriptRoot "tests\AemulusConnect.Tests"
$TestProjectFile = Join-Path $TestProjectDir "AemulusConnect.Tests.csproj"
$SrcProjectFile = Join-Path $ScriptRoot "..\src\AemulusConnect.csproj"

#endregion

#region Banner

Write-Header "AemulusConnect - Unit Tests"

#endregion

#region Step 1: Validate Prerequisites

Write-Step "Checking prerequisites..."

# Check .NET SDK
if (-not (Get-Command "dotnet" -ErrorAction SilentlyContinue)) {
    Write-Failure ".NET SDK not found in PATH"
    Write-Info "Please install .NET 8 SDK from https://dotnet.microsoft.com/download"
    exit 1
}

$dotnetVersion = (dotnet --version)
Write-Success ".NET SDK found: $dotnetVersion"

# Check test project exists
if (-not (Test-Path $TestProjectFile)) {
    Write-Failure "Test project not found: $TestProjectFile"
    exit 1
}
Write-Success "Test project found"

# Check main project exists
if (-not (Test-Path $SrcProjectFile)) {
    Write-Failure "Main project not found: $SrcProjectFile"
    exit 1
}
Write-Success "Main project found"

#endregion

#region Step 2: Build Projects (unless -NoBuild)

if (-not $NoBuild) {
    Write-Step "Building projects..."

    # Build main project first (tests depend on it)
    Write-Info "Building AemulusConnect..."
    try {
        $buildArgs = @(
            "build",
            $SrcProjectFile,
            "--configuration", "Debug",
            "--verbosity", "quiet"
        )

        $buildOutput = & dotnet @buildArgs 2>&1

        if ($LASTEXITCODE -ne 0) {
            Write-Failure "Main project build failed"
            Write-Host $buildOutput -ForegroundColor Red
            exit 1
        }

        Write-Success "Main project built"
    }
    catch {
        Write-Failure "Build error: $($_.Exception.Message)"
        exit 1
    }

    # Build test project
    Write-Info "Building test project..."
    try {
        $buildArgs = @(
            "build",
            $TestProjectFile,
            "--configuration", "Debug",
            "--verbosity", "quiet"
        )

        $buildOutput = & dotnet @buildArgs 2>&1

        if ($LASTEXITCODE -ne 0) {
            Write-Failure "Test project build failed"
            Write-Host $buildOutput -ForegroundColor Red
            exit 1
        }

        Write-Success "Test project built"
    }
    catch {
        Write-Failure "Build error: $($_.Exception.Message)"
        exit 1
    }
}
else {
    Write-Step "Skipping build (using existing binaries)"
}

#endregion

#region Step 3: Run Tests

Write-Step "Running tests..."

try {
    # Build test arguments
    $testArgs = @(
        "test",
        $TestProjectFile
    )

    # Add verbosity
    if ($VerboseOutput) {
        $testArgs += "--logger", "console;verbosity=detailed"
    }
    else {
        $testArgs += "--logger", "console;verbosity=normal"
    }

    # Add filter if specified
    if ($Filter) {
        $testArgs += "--filter", $Filter
        Write-Info "Filtering tests: $Filter"
    }

    # Add no-build if specified
    if ($NoBuild) {
        $testArgs += "--no-build"
    }

    # Add coverage if specified
    if ($Coverage) {
        $testArgs += "--collect:XPlat Code Coverage"
        Write-Info "Code coverage enabled"
    }

    # Run tests
    Write-Host ""
    & dotnet @testArgs

    $testExitCode = $LASTEXITCODE

    Write-Host ""

    # Check results
    if ($testExitCode -eq 0) {
        Write-Header "All Tests Passed"
        Write-Success "Test suite completed successfully"

        if ($Coverage) {
            Write-Info "Coverage report generated in TestResults folder"
        }

        exit 0
    }
    else {
        Write-Header "Tests Failed"
        Write-Failure "One or more tests failed"
        Write-Info "Review the test output above for details"
        exit 1
    }
}
catch {
    Write-Failure "Test execution error: $($_.Exception.Message)"
    exit 1
}

#endregion
