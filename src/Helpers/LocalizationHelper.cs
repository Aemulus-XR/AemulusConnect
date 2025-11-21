using System.Globalization;

namespace AemulusConnect.Helpers
{
    /// <summary>
    /// Helper class for managing application localization and culture settings
    /// </summary>
    public static class LocalizationHelper
    {
        /// <summary>
        /// Default language/culture code
        /// </summary>
        public const string DefaultCulture = "en-US";

        /// <summary>
        /// Sets the culture for the current thread and all future threads
        /// </summary>
        /// <param name="cultureName">Culture code (e.g., "en-US", "fr-FR", "ar-SA")</param>
        public static void SetCulture(string cultureName)
        {
            try
            {
                // Special handling for custom cultures that .NET doesn't recognize
                if (cultureName == "en-PIRATE")
                {
                    // For pirate language, we need to:
                    // 1. Use en-US as the base culture for formatting
                    // 2. Manually load the pirate satellite assembly and inject it into the ResourceManager
                    var baseCulture = new CultureInfo("en-US");
                    Thread.CurrentThread.CurrentCulture = baseCulture;
                    Thread.CurrentThread.CurrentUICulture = baseCulture;
                    CultureInfo.DefaultThreadCurrentCulture = baseCulture;
                    CultureInfo.DefaultThreadCurrentUICulture = baseCulture;

                    // Force reload of Resources with pirate satellite assembly
                    LoadPirateResources();
                }
                else
                {
                    var culture = new CultureInfo(cultureName);
                    Thread.CurrentThread.CurrentCulture = culture;
                    Thread.CurrentThread.CurrentUICulture = culture;
                    CultureInfo.DefaultThreadCurrentCulture = culture;
                    CultureInfo.DefaultThreadCurrentUICulture = culture;
                    Properties.Resources.Culture = null; // Let it use thread culture

                    // Reset ResourceManager to use standard culture
                    ResetResourceManager();
                }
            }
            catch
            {
                // If culture is invalid, fall back to default
                var defaultCulture = new CultureInfo(DefaultCulture);
                Thread.CurrentThread.CurrentCulture = defaultCulture;
                Thread.CurrentThread.CurrentUICulture = defaultCulture;
                CultureInfo.DefaultThreadCurrentCulture = defaultCulture;
                CultureInfo.DefaultThreadCurrentUICulture = defaultCulture;
                Properties.Resources.Culture = null; // Reset to use thread culture
                ResetResourceManager();
            }
        }

        /// <summary>
        /// Loads the pirate satellite assembly by manually loading it from disk
        /// and replacing the ResourceManager entirely
        /// </summary>
        private static void LoadPirateResources()
        {
            try
            {
                LogPirate("Starting LoadPirateResources()");

                // Find the satellite assembly DLL
                var assemblyDir = System.AppDomain.CurrentDomain.BaseDirectory;
                var satellitePath = System.IO.Path.Combine(assemblyDir, "en-PIRATE", "AemulusConnect.resources.dll");

                LogPirate($"Looking for satellite assembly at: {satellitePath}");
                LogPirate($"Satellite assembly exists: {System.IO.File.Exists(satellitePath)}");

                if (!System.IO.File.Exists(satellitePath))
                {
                    LogPirate("ERROR: Satellite assembly not found!");
                    return;
                }

                // Load the satellite assembly
                var satelliteAssembly = System.Reflection.Assembly.LoadFrom(satellitePath);
                LogPirate($"Loaded satellite assembly: {satelliteAssembly.FullName}");

                // Get the embedded resource names to verify
                var resourceNames = string.Join(", ", satelliteAssembly.GetManifestResourceNames());
                LogPirate($"Embedded resources: {resourceNames}");

                // Create a ResourceSet directly from the embedded resource
                var resourceStream = satelliteAssembly.GetManifestResourceStream("AemulusConnect.Properties.Resources.en-PIRATE.resources");
                if (resourceStream == null)
                {
                    LogPirate("ERROR: Could not find embedded resource stream!");
                    return;
                }

                LogPirate("Found embedded resource stream");

                var pirateResourceSet = new System.Resources.ResourceSet(resourceStream);
                LogPirate("Created ResourceSet from stream");

                // Verify the pirate resources are actually in the ResourceSet
                var testValue = pirateResourceSet.GetString("Settings_WindowTitle");
                LogPirate($"Direct ResourceSet test: Settings_WindowTitle = '{testValue}'");

                // Create a custom ResourceManager that always returns pirate resources
                var pirateResourceManager = new PirateResourceManager(pirateResourceSet);
                LogPirate("Created PirateResourceManager");

                // Replace the ResourceManager in Properties.Resources with our custom one
                var resourceManField = typeof(Properties.Resources).GetField("resourceMan",
                    System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.NonPublic);

                if (resourceManField != null)
                {
                    resourceManField.SetValue(null, pirateResourceManager);
                    LogPirate("Replaced Properties.Resources.resourceMan with PirateResourceManager");
                }

                // Set culture to en-US (but it won't matter because our custom manager ignores it)
                Properties.Resources.Culture = new CultureInfo("en-US");

                // Test load a string to verify it works
                var testString = Properties.Resources.Settings_WindowTitle;
                LogPirate($"Test string loaded: '{testString}'");
                LogPirate($"Success! Pirate={testString != "Settings"}");
            }
            catch (Exception ex)
            {
                LogPirate($"ERROR: {ex.Message}");
                LogPirate($"Stack: {ex.StackTrace}");
            }
        }

        /// <summary>
        /// Custom ResourceManager that always returns resources from a specific ResourceSet
        /// </summary>
        private class PirateResourceManager : System.Resources.ResourceManager
        {
            private readonly System.Resources.ResourceSet _pirateResourceSet;

            public PirateResourceManager(System.Resources.ResourceSet pirateResourceSet)
            {
                _pirateResourceSet = pirateResourceSet;
            }

            public override string? GetString(string name)
            {
                return _pirateResourceSet.GetString(name);
            }

            public override string? GetString(string name, CultureInfo? culture)
            {
                return _pirateResourceSet.GetString(name);
            }

            public override object? GetObject(string name)
            {
                return _pirateResourceSet.GetObject(name);
            }

            public override object? GetObject(string name, CultureInfo? culture)
            {
                return _pirateResourceSet.GetObject(name);
            }
        }

        /// <summary>
        /// Logs pirate language debug information to a file
        /// </summary>
        private static void LogPirate(string message)
        {
            try
            {
                var logPath = System.IO.Path.Combine(
                    System.AppDomain.CurrentDomain.BaseDirectory,
                    "pirate-debug.txt");
                var timestamp = System.DateTime.Now.ToString("HH:mm:ss.fff");
                System.IO.File.AppendAllText(logPath, $"[{timestamp}] {message}\n");
            }
            catch
            {
                // Ignore logging errors
            }
        }

        /// <summary>
        /// Resets the ResourceManager to clear any custom culture overrides
        /// </summary>
        private static void ResetResourceManager()
        {
            try
            {
                var resourceManField = typeof(Properties.Resources).GetField("resourceMan",
                    System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.NonPublic);

                if (resourceManField != null)
                {
                    var resourceManager = (System.Resources.ResourceManager)resourceManField.GetValue(null);
                    if (resourceManager != null)
                    {
                        // Clear the internal cache
                        var resourceSetsField = typeof(System.Resources.ResourceManager).GetField("_resourceSets",
                            System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);

                        if (resourceSetsField != null)
                        {
                            var resourceSets = resourceSetsField.GetValue(resourceManager);
                            if (resourceSets is System.Collections.IDictionary dict)
                            {
                                dict.Clear();
                            }
                        }
                    }
                }
            }
            catch
            {
                // If reset fails, ignore
            }
        }


        /// <summary>
        /// Gets the list of available cultures/languages supported by the application
        /// </summary>
        /// <returns>List of culture options</returns>
        public static List<CultureOption> GetAvailableCultures()
        {
            return new List<CultureOption>
            {
                new CultureOption("en-US", "English"),
                new CultureOption("fr-FR", "Français (French)"),
                new CultureOption("es-ES", "Español (Spanish)"),
                new CultureOption("de-DE", "Deutsch (German)"),
                new CultureOption("ar-SA", "العربية (Arabic)"),
                new CultureOption("en-PIRATE", "Ahoy Tharr (Pirate)"),
            };
        }

        /// <summary>
        /// Gets the current UI culture code
        /// </summary>
        /// <returns>Culture code string (e.g., "en-US")</returns>
        public static string GetCurrentCulture()
        {
            return CultureInfo.CurrentUICulture.Name;
        }

        /// <summary>
        /// Checks if a culture uses Right-to-Left text direction
        /// </summary>
        /// <param name="cultureName">Culture code to check</param>
        /// <returns>True if culture is RTL, false otherwise</returns>
        public static bool IsRightToLeft(string cultureName)
        {
            try
            {
                var culture = new CultureInfo(cultureName);
                return culture.TextInfo.IsRightToLeft;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Applies RTL layout to a form if the current culture requires it
        /// </summary>
        /// <param name="form">Form to apply RTL layout to</param>
        public static void ApplyRTLToForm(Form form)
        {
            if (IsRightToLeft(CultureInfo.CurrentUICulture.Name))
            {
                form.RightToLeft = RightToLeft.Yes;
                form.RightToLeftLayout = true;
            }
            else
            {
                form.RightToLeft = RightToLeft.No;
                form.RightToLeftLayout = false;
            }
        }

        /// <summary>
        /// Applies culture-specific fonts to a form (e.g., Al-Mohanad for Arabic)
        /// </summary>
        /// <param name="form">Form to apply fonts to</param>
        public static void ApplyCultureSpecificFont(Form form)
        {
            ApplyCultureSpecificFont((Control)form);
        }

        /// <summary>
        /// Applies culture-specific fonts to a control (e.g., Al-Mohanad for Arabic)
        /// </summary>
        /// <param name="control">Control to apply fonts to</param>
        public static void ApplyCultureSpecificFont(Control control)
        {
            var currentCulture = CultureInfo.CurrentUICulture.Name;

            // Apply Al-Mohanad font for Arabic
            if (currentCulture == "ar-SA")
            {
                FontHelper.ApplyAlMohanadFontToForm(control);
            }
            else
            {
                // Reset to default system font for other languages
                FontHelper.ResetToDefaultFont(control);
            }
        }
    }

    /// <summary>
    /// Represents a culture/language option for display in UI
    /// </summary>
    public class CultureOption
    {
        /// <summary>
        /// Culture code (e.g., "en-US", "fr-FR")
        /// </summary>
        public string Code { get; set; }

        /// <summary>
        /// Display name for the culture (e.g., "English", "Français")
        /// </summary>
        public string DisplayName { get; set; }

        public CultureOption(string code, string displayName)
        {
            Code = code;
            DisplayName = displayName;
        }

        public override string ToString()
        {
            return DisplayName;
        }
    }
}
