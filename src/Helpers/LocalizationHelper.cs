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
                var culture = new CultureInfo(cultureName);
                Thread.CurrentThread.CurrentCulture = culture;
                Thread.CurrentThread.CurrentUICulture = culture;
                CultureInfo.DefaultThreadCurrentCulture = culture;
                CultureInfo.DefaultThreadCurrentUICulture = culture;
            }
            catch
            {
                // If culture is invalid, fall back to default
                var defaultCulture = new CultureInfo(DefaultCulture);
                Thread.CurrentThread.CurrentCulture = defaultCulture;
                Thread.CurrentThread.CurrentUICulture = defaultCulture;
                CultureInfo.DefaultThreadCurrentCulture = defaultCulture;
                CultureInfo.DefaultThreadCurrentUICulture = defaultCulture;
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
                // Arabic will be added in Phase 4
                // new CultureOption("ar-SA", "العربية (Arabic)"),
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
