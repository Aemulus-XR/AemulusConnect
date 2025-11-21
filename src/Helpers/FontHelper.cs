using System.Drawing;
using System.Drawing.Text;
using System.Runtime.InteropServices;

namespace AemulusConnect.Helpers;

/// <summary>
/// Helper class for managing custom fonts in the application
/// </summary>
public static class FontHelper
{
    private static PrivateFontCollection? _privateFonts;
    private static FontFamily? _alMohanadFontFamily;
    private static readonly object _lock = new object();

    /// <summary>
    /// Initializes the custom font collection by loading fonts from embedded resources
    /// </summary>
    private static void InitializeFonts()
    {
        if (_privateFonts != null)
            return;

        lock (_lock)
        {
            if (_privateFonts != null)
                return;

            _privateFonts = new PrivateFontCollection();

            try
            {
                // Load the regular Al-Mohanad font from embedded resource
                var fontPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "res", "fonts", "arfonts-al-mohanad_all", "al-mohanad.ttf");

                if (File.Exists(fontPath))
                {
                    // Load font from file
                    _privateFonts.AddFontFile(fontPath);
                    _alMohanadFontFamily = _privateFonts.Families.FirstOrDefault(f => f.Name.Contains("Al-Mohanad"));

                    if (_alMohanadFontFamily == null && _privateFonts.Families.Length > 0)
                    {
                        _alMohanadFontFamily = _privateFonts.Families[0];
                    }
                }
                else
                {
                    log4net.LogManager.GetLogger(typeof(FontHelper)).Warn($"Al-Mohanad font file not found at: {fontPath}");
                }
            }
            catch (Exception ex)
            {
                log4net.LogManager.GetLogger(typeof(FontHelper)).Error("Failed to load Al-Mohanad font", ex);
            }
        }
    }

    /// <summary>
    /// Gets the Al-Mohanad font family, or null if not loaded
    /// </summary>
    public static FontFamily? AlMohanadFontFamily
    {
        get
        {
            InitializeFonts();
            return _alMohanadFontFamily;
        }
    }

    /// <summary>
    /// Creates a font using Al-Mohanad font family, falling back to the original font if unavailable
    /// </summary>
    /// <param name="size">Font size</param>
    /// <param name="style">Font style</param>
    /// <param name="fallbackFont">Fallback font to use if Al-Mohanad is not available</param>
    /// <returns>A Font object</returns>
    public static Font CreateAlMohanadFont(float size, FontStyle style = FontStyle.Regular, Font? fallbackFont = null)
    {
        InitializeFonts();

        if (_alMohanadFontFamily != null)
        {
            try
            {
                return new Font(_alMohanadFontFamily, size, style);
            }
            catch
            {
                // If creation fails, fall back
            }
        }

        // Fallback to provided font or Arial
        if (fallbackFont != null)
        {
            return new Font(fallbackFont.FontFamily, size, style);
        }

        return new Font("Arial", size, style);
    }

    /// <summary>
    /// Applies the Al-Mohanad font to all controls in a form recursively
    /// </summary>
    /// <param name="control">The root control to start from</param>
    public static void ApplyAlMohanadFontToForm(Control control)
    {
        if (_alMohanadFontFamily == null)
        {
            InitializeFonts();
        }

        if (_alMohanadFontFamily == null)
        {
            log4net.LogManager.GetLogger(typeof(FontHelper)).Warn("Al-Mohanad font family not available, cannot apply to form");
            return;
        }

        ApplyFontToControlRecursive(control, _alMohanadFontFamily);
    }

    /// <summary>
    /// Applies a specific font family to all controls recursively
    /// </summary>
    private static void ApplyFontToControlRecursive(Control control, FontFamily fontFamily)
    {
        try
        {
            if (control.Font != null)
            {
                var currentFont = control.Font;
                control.Font = new Font(fontFamily, currentFont.Size, currentFont.Style);
            }
        }
        catch (Exception ex)
        {
            log4net.LogManager.GetLogger(typeof(FontHelper)).Debug($"Could not apply font to control {control.Name}", ex);
        }

        foreach (Control child in control.Controls)
        {
            ApplyFontToControlRecursive(child, fontFamily);
        }
    }

    /// <summary>
    /// Resets all controls in a form to use the default system font (Arial)
    /// </summary>
    /// <param name="control">The root control to start from</param>
    public static void ResetToDefaultFont(Control control)
    {
        ResetFontToControlRecursive(control);
    }

    /// <summary>
    /// Resets font to Arial recursively
    /// </summary>
    private static void ResetFontToControlRecursive(Control control)
    {
        try
        {
            if (control.Font != null)
            {
                var currentFont = control.Font;
                control.Font = new Font("Arial", currentFont.Size, currentFont.Style);
            }
        }
        catch (Exception ex)
        {
            log4net.LogManager.GetLogger(typeof(FontHelper)).Debug($"Could not reset font on control {control.Name}", ex);
        }

        foreach (Control child in control.Controls)
        {
            ResetFontToControlRecursive(child);
        }
    }

    /// <summary>
    /// Disposes of the private font collection
    /// </summary>
    public static void Dispose()
    {
        _privateFonts?.Dispose();
        _privateFonts = null;
        _alMohanadFontFamily = null;
    }
}
