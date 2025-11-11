# AemulusConnect - Unit Tests

This directory contains automated tests for the AemulusConnect application.

## Test Projects

### AemulusConnect.Tests
Unit tests for localization parity and functionality.

## Running Tests

### From Command Line

```bash
# Run all tests
cd tools/tests/AemulusConnect.Tests
dotnet test

# Run with detailed output
dotnet test --logger "console;verbosity=detailed"

# Run specific test
dotnet test --filter "FullyQualifiedName~LocalizationTests.AllLanguages_ShouldHaveSameNumberOfStrings"
```

### From Visual Studio
1. Open Test Explorer (Test → Test Explorer)
2. Click "Run All" to execute all tests
3. Click individual tests to run specific ones

### From VS Code
1. Install C# Dev Kit extension
2. Open Testing panel
3. Click "Run All Tests" or individual test runs

## Localization Tests

The `LocalizationTests` class validates:

### ✅ Resource File Validation
- **AllResourceFiles_ShouldExist**: Verifies English, French, and Arabic .resx files exist
- **AllLanguages_ShouldHaveSameNumberOfStrings**: Ensures parity across all languages
- **AllLanguages_ShouldHaveAllRequiredKeys**: Checks that all languages have identical resource keys
- **AllLanguages_ShouldNotHaveEmptyValues**: Validates no empty/missing translations

### ✅ Translation Quality
- **AllLanguages_ShouldPreservePlaceholders**: Verifies `{0}` placeholders are preserved in all translations
- **PluralForms_ShouldExistForAllLanguages**: Ensures singular and plural forms exist

### ✅ Runtime Functionality
- **Resources_ShouldBeAccessibleAtRuntime**: Tests that resources load correctly
- **Resources_ShouldLoadCorrectCulture**: Validates correct language loads for fr-FR and ar-SA
- **SetCulture_ShouldChangeCultureInfo**: Tests culture switching

### ✅ RTL Support
- **IsRightToLeft_ShouldReturnCorrectValue**: Validates RTL detection for Arabic
- **GetAvailableCultures_ShouldReturnAllThreeLanguages**: Ensures all 3 languages are available

## Test Results (Current)

```
Test Run Successful.
Total tests: 14
     Passed: 14
     Failed: 0
  Total time: ~1.2 seconds
```

## Adding New Tests

To add new localization tests:

1. Open `LocalizationTests.cs`
2. Add a new `[Fact]` or `[Theory]` method
3. Follow existing patterns for .resx validation
4. Run `dotnet test` to verify

Example:
```csharp
[Fact]
public void NewLanguage_ShouldHaveCorrectEncoding()
{
    // Arrange
    var filePath = Path.Combine(_baseResourcePath, "Resources.es-ES.resx");

    // Act
    var doc = XDocument.Load(filePath);

    // Assert
    Assert.NotNull(doc);
}
```

## Continuous Integration

These tests should be run:
- Before committing localization changes
- In CI/CD pipeline before deployment
- When adding new languages
- When modifying existing translations

## Test Coverage

**Localization Coverage:**
- ✅ File existence validation
- ✅ String count parity
- ✅ Key consistency across languages
- ✅ Placeholder preservation
- ✅ Plural form validation
- ✅ Runtime resource loading
- ✅ Culture switching
- ✅ RTL support validation

**Future Test Areas:**
- UI layout testing with different languages
- Text truncation/overflow detection
- Performance benchmarks for resource loading
- Memory usage validation

## Troubleshooting

### Tests fail with "Resource file not found"
- Ensure you've built the main project first: `dotnet build ../../../src/AemulusConnect.csproj`
- Check that .resx files are copied to TestData folder in output

### Tests fail with "inaccessible due to protection level"
- Verify `InternalsVisibleTo` is set in `src/AemulusConnect.csproj`
- Rebuild both projects

### Culture tests fail
- Ensure satellite assemblies are built (`ar-SA` and `fr-FR` folders)
- Check that culture codes match exactly (case-sensitive)

## Dependencies

- **xUnit** v2.9.2 - Testing framework
- **Microsoft.NET.Test.Sdk** v17.12.0 - Test platform
- **coverlet.collector** v6.0.2 - Code coverage

## License

Same as parent project (see root LICENSE file)
