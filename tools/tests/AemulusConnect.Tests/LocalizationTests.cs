using System.Globalization;
using System.Resources;
using System.Xml.Linq;
using AemulusConnect.Helpers;

namespace AemulusConnect.Tests;

/// <summary>
/// Tests to verify localization parity across all supported languages
/// </summary>
public class LocalizationTests
{
    private readonly string _baseResourcePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "TestData");

    [Fact]
    public void AllResourceFiles_ShouldExist()
    {
        // Arrange
        var expectedFiles = new[]
        {
            "Resources.resx",       // English (default)
            "Resources.fr-FR.resx", // French
            "Resources.ar-SA.resx"  // Arabic
        };

        // Act & Assert
        foreach (var file in expectedFiles)
        {
            var filePath = Path.Combine(_baseResourcePath, file);
            Assert.True(File.Exists(filePath), $"Resource file not found: {file}");
        }
    }

    [Fact]
    public void AllLanguages_ShouldHaveSameNumberOfStrings()
    {
        // Arrange
        var resourceFiles = new Dictionary<string, string>
        {
            { "English", Path.Combine(_baseResourcePath, "Resources.resx") },
            { "French", Path.Combine(_baseResourcePath, "Resources.fr-FR.resx") },
            { "Arabic", Path.Combine(_baseResourcePath, "Resources.ar-SA.resx") }
        };

        var stringCounts = new Dictionary<string, int>();

        // Act
        foreach (var (language, filePath) in resourceFiles)
        {
            stringCounts[language] = GetAllResourceKeys(filePath).Count;
        }

        // Assert
        var englishCount = stringCounts["English"];
        Assert.Equal(englishCount, stringCounts["French"]);
        Assert.Equal(englishCount, stringCounts["Arabic"]);

        // All languages should have same count
        Assert.True(englishCount > 0, "Should have at least one string");
    }

    [Fact]
    public void AllLanguages_ShouldHaveAllRequiredKeys()
    {
        // Arrange
        var expectedKeys = GetAllResourceKeys(Path.Combine(_baseResourcePath, "Resources.resx"));
        var languages = new Dictionary<string, string>
        {
            { "French", Path.Combine(_baseResourcePath, "Resources.fr-FR.resx") },
            { "Arabic", Path.Combine(_baseResourcePath, "Resources.ar-SA.resx") }
        };

        // Act & Assert
        foreach (var (language, filePath) in languages)
        {
            var keys = GetAllResourceKeys(filePath);
            var missingKeys = expectedKeys.Except(keys).ToList();
            var extraKeys = keys.Except(expectedKeys).ToList();

            Assert.Empty(missingKeys);
            Assert.Empty(extraKeys);
        }
    }

    [Fact]
    public void AllLanguages_ShouldNotHaveEmptyValues()
    {
        // Arrange
        var resourceFiles = new Dictionary<string, string>
        {
            { "English", Path.Combine(_baseResourcePath, "Resources.resx") },
            { "French", Path.Combine(_baseResourcePath, "Resources.fr-FR.resx") },
            { "Arabic", Path.Combine(_baseResourcePath, "Resources.ar-SA.resx") }
        };

        // Act & Assert
        foreach (var (language, filePath) in resourceFiles)
        {
            var doc = XDocument.Load(filePath);
            var emptyValues = doc.Descendants("data")
                .Where(e => e.Attribute("name") != null)
                .Where(e => string.IsNullOrWhiteSpace(e.Element("value")?.Value))
                .Select(e => e.Attribute("name")!.Value)
                .ToList();

            Assert.Empty(emptyValues);
        }
    }

    [Fact]
    public void AllLanguages_ShouldPreservePlaceholders()
    {
        // Arrange
        var englishFile = Path.Combine(_baseResourcePath, "Resources.resx");
        var placeholderKeys = GetKeysWithPlaceholders(englishFile);

        var otherLanguages = new Dictionary<string, string>
        {
            { "French", Path.Combine(_baseResourcePath, "Resources.fr-FR.resx") },
            { "Arabic", Path.Combine(_baseResourcePath, "Resources.ar-SA.resx") }
        };

        // Act & Assert
        foreach (var (language, filePath) in otherLanguages)
        {
            foreach (var (key, englishValue) in placeholderKeys)
            {
                var translatedValue = GetResourceValue(filePath, key);
                Assert.NotNull(translatedValue);

                // Check that all placeholders from English are present in translation
                var englishPlaceholders = ExtractPlaceholders(englishValue);
                var translatedPlaceholders = ExtractPlaceholders(translatedValue);

                Assert.Equal(englishPlaceholders.Count, translatedPlaceholders.Count);
                foreach (var placeholder in englishPlaceholders)
                {
                    Assert.Contains(placeholder, translatedPlaceholders);
                }
            }
        }
    }

    [Theory]
    [InlineData("en-US", false)]
    [InlineData("fr-FR", false)]
    [InlineData("ar-SA", true)]
    public void IsRightToLeft_ShouldReturnCorrectValue(string cultureName, bool expectedRTL)
    {
        // Act
        var isRTL = LocalizationHelper.IsRightToLeft(cultureName);

        // Assert
        Assert.Equal(expectedRTL, isRTL);
    }

    [Fact]
    public void GetAvailableCultures_ShouldReturnAllThreeLanguages()
    {
        // Act
        var cultures = LocalizationHelper.GetAvailableCultures();

        // Assert
        Assert.Equal(3, cultures.Count);
        Assert.Contains(cultures, c => c.Code == "en-US");
        Assert.Contains(cultures, c => c.Code == "fr-FR");
        Assert.Contains(cultures, c => c.Code == "ar-SA");
    }

    [Fact]
    public void SetCulture_ShouldChangeCultureInfo()
    {
        // Arrange
        var originalCulture = CultureInfo.CurrentUICulture;

        try
        {
            // Act
            LocalizationHelper.SetCulture("fr-FR");

            // Assert
            Assert.Equal("fr-FR", CultureInfo.CurrentUICulture.Name);

            // Act
            LocalizationHelper.SetCulture("ar-SA");

            // Assert
            Assert.Equal("ar-SA", CultureInfo.CurrentUICulture.Name);
        }
        finally
        {
            // Cleanup - restore original culture
            LocalizationHelper.SetCulture(originalCulture.Name);
        }
    }

    [Fact]
    public void Resources_ShouldBeAccessibleAtRuntime()
    {
        // Act & Assert - verify we can access resources through the generated class
        Assert.NotNull(Properties.Resources.Common_AppTitle);
        Assert.NotNull(Properties.Resources.MainForm_VersionLabel);
        Assert.NotNull(Properties.Resources.Connected_FetchButton);
        Assert.NotNull(Properties.Resources.Menu_File);
    }

    [Theory]
    [InlineData("fr-FR")]
    [InlineData("ar-SA")]
    public void Resources_ShouldLoadCorrectCulture(string cultureName)
    {
        // Arrange
        var originalCulture = CultureInfo.CurrentUICulture;

        try
        {
            // Act
            LocalizationHelper.SetCulture(cultureName);

            // Force resource manager to reload
            var fetchButton = Properties.Resources.Connected_FetchButton;

            // Assert - verify it's not the English version
            Assert.NotNull(fetchButton);
            Assert.NotEmpty(fetchButton);

            // For French, should contain French text
            if (cultureName == "fr-FR")
            {
                Assert.Contains("Récupérer", fetchButton);
            }
            // For Arabic, should contain Arabic text
            else if (cultureName == "ar-SA")
            {
                Assert.Contains("جلب", fetchButton);
            }
        }
        finally
        {
            // Cleanup
            LocalizationHelper.SetCulture(originalCulture.Name);
        }
    }

    [Fact]
    public void PluralForms_ShouldExistForAllLanguages()
    {
        // Arrange
        var resourceFiles = new Dictionary<string, string>
        {
            { "English", Path.Combine(_baseResourcePath, "Resources.resx") },
            { "French", Path.Combine(_baseResourcePath, "Resources.fr-FR.resx") },
            { "Arabic", Path.Combine(_baseResourcePath, "Resources.ar-SA.resx") }
        };

        // Act & Assert
        foreach (var (language, filePath) in resourceFiles)
        {
            var singular = GetResourceValue(filePath, "Connected_ReportCountSingular");
            var plural = GetResourceValue(filePath, "Connected_ReportCountPlural");

            Assert.NotNull(singular);
            Assert.NotNull(plural);
            Assert.NotEqual(singular, plural);
        }
    }

    #region Helper Methods

    private List<string> GetAllResourceKeys(string filePath)
    {
        var doc = XDocument.Load(filePath);
        return doc.Descendants("data")
            .Where(e => e.Attribute("name") != null)
            .Select(e => e.Attribute("name")!.Value)
            .ToList();
    }

    private Dictionary<string, string> GetKeysWithPlaceholders(string filePath)
    {
        var doc = XDocument.Load(filePath);
        return doc.Descendants("data")
            .Where(e => e.Attribute("name") != null)
            .Where(e => e.Element("value")?.Value.Contains("{") == true)
            .ToDictionary(
                e => e.Attribute("name")!.Value,
                e => e.Element("value")!.Value
            );
    }

    private string? GetResourceValue(string filePath, string key)
    {
        var doc = XDocument.Load(filePath);
        return doc.Descendants("data")
            .Where(e => e.Attribute("name")?.Value == key)
            .Select(e => e.Element("value")?.Value)
            .FirstOrDefault();
    }

    private List<string> ExtractPlaceholders(string text)
    {
        var placeholders = new List<string>();
        var index = 0;
        while ((index = text.IndexOf('{', index)) != -1)
        {
            var endIndex = text.IndexOf('}', index);
            if (endIndex != -1)
            {
                placeholders.Add(text.Substring(index, endIndex - index + 1));
                index = endIndex + 1;
            }
            else
            {
                break;
            }
        }
        return placeholders;
    }

    #endregion
}
