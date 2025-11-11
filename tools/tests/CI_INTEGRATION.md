# CI/CD Integration Guide

This document explains how to integrate the unit tests into various CI/CD pipelines.

## Exit Codes

The test runner (`tools/run_unit_tests.ps1`) returns proper exit codes:
- **0** = All tests passed ✅
- **1** = Tests failed or build error ❌

This makes it perfect for CI/CD integration - the pipeline will automatically fail if tests fail.

## GitHub Actions

Create `.github/workflows/test.yml`:

```yaml
name: Unit Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: windows-latest

    steps:
    - uses: actions/checkout@v4

    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'

    - name: Run Unit Tests
      run: |
        cd tools
        pwsh -File run_unit_tests.ps1
      shell: pwsh

    - name: Upload Test Results
      if: always()
      uses: actions/upload-artifact@v4
      with:
        name: test-results
        path: tools/tests/AemulusConnect.Tests/TestResults/
```

## Azure Pipelines

Create `azure-pipelines.yml`:

```yaml
trigger:
- main
- develop

pool:
  vmImage: 'windows-latest'

steps:
- task: UseDotNet@2
  displayName: 'Install .NET SDK'
  inputs:
    version: '8.0.x'

- task: PowerShell@2
  displayName: 'Run Unit Tests'
  inputs:
    filePath: 'tools/run_unit_tests.ps1'
    workingDirectory: 'tools'
    failOnStderr: true

- task: PublishTestResults@2
  condition: always()
  inputs:
    testResultsFormat: 'VSTest'
    testResultsFiles: '**/TestResults/*.trx'
```

## GitLab CI

Create `.gitlab-ci.yml`:

```yaml
test:
  stage: test
  image: mcr.microsoft.com/dotnet/sdk:8.0-windowsservercore-ltsc2022
  script:
    - cd tools
    - pwsh -File run_unit_tests.ps1
  artifacts:
    when: always
    paths:
      - tools/tests/AemulusConnect.Tests/TestResults/
    reports:
      junit: tools/tests/AemulusConnect.Tests/TestResults/*.xml
```

## Jenkins

Create `Jenkinsfile`:

```groovy
pipeline {
    agent {
        label 'windows'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                powershell '''
                    cd tools
                    .\\run_unit_tests.ps1
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'tools/tests/AemulusConnect.Tests/TestResults/**/*', allowEmptyArchive: true
        }
    }
}
```

## Local Development

### Quick Test
```bash
# Run all tests
tools/run_unit_tests.ps1

# Run with verbose output
tools/run_unit_tests.ps1 -VerboseOutput

# Run specific tests
tools/run_unit_tests.ps1 -Filter "LocalizationTests"

# Skip rebuild (faster for repeated runs)
tools/run_unit_tests.ps1 -NoBuild
```

### With Code Coverage
```bash
# Generate coverage report
tools/run_unit_tests.ps1 -Coverage

# View coverage in TestResults folder
# Look for: tools/tests/AemulusConnect.Tests/TestResults/.../coverage.cobertura.xml
```

## Pre-Commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/sh

echo "Running unit tests..."
cd tools
powershell.exe -ExecutionPolicy Bypass -File run_unit_tests.ps1

if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi

echo "All tests passed!"
exit 0
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Test Reports

### Viewing Results

The test runner outputs:
- Console output (immediate feedback)
- TRX files (for CI systems)
- Coverage reports (if `-Coverage` flag used)

### Failed Test Example

When a test fails, you'll see:
```
[FAIL] One or more tests failed
[INFO] Review the test output above for details
Exit code: 1
```

The pipeline will automatically fail, preventing bad code from being merged.

## Best Practices

1. **Run tests before commits**
   - Use pre-commit hooks
   - Or manually run: `tools/run_unit_tests.ps1`

2. **Run tests in CI on every PR**
   - Prevents broken code from reaching main branch
   - Catches localization parity issues early

3. **Monitor test duration**
   - Current suite runs in ~1 second
   - If it grows > 10 seconds, consider parallelization

4. **Update tests when adding languages**
   - Tests automatically validate new languages
   - No code changes needed - just add .resx file

5. **Don't skip tests**
   - If a test fails, fix it - don't disable it
   - Test failures indicate real issues

## Troubleshooting CI

### Issue: PowerShell not found
**Solution:** Use `pwsh` (PowerShell Core) or `powershell.exe` (Windows PowerShell)

### Issue: .NET SDK not installed
**Solution:** Add .NET setup step to CI pipeline (see examples above)

### Issue: Tests pass locally but fail in CI
**Solution:**
- Check .NET SDK version matches (8.0.x)
- Verify .resx files are committed to repo
- Check file paths are correct (case-sensitive on Linux)

### Issue: Exit code not captured
**Solution:** Ensure CI runner checks `$LASTEXITCODE` (PowerShell) or `$?` (bash)

## Adding More Tests

When you add new test classes:
1. Place them in `tools/tests/AemulusConnect.Tests/`
2. Use xUnit attributes: `[Fact]` or `[Theory]`
3. Run `dotnet test` or use the script
4. No CI configuration changes needed - automatically discovered

## Summary

The unit test suite is **fully CI-ready** with:
- ✅ Proper exit codes (0 = pass, 1 = fail)
- ✅ Console output for immediate feedback
- ✅ Test result files for CI systems
- ✅ Fast execution (~1 second)
- ✅ No manual intervention needed
- ✅ Automatic test discovery

Just add the appropriate CI configuration file for your platform and tests will run automatically on every commit/PR!
