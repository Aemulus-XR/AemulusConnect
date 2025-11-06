using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using Aemulus_XR_Reporting_App.Strings;

namespace Aemulus_XR_Reporting_App.Helpers
{
    /// <summary>
    /// Simple settings manager that persists key=value pairs to an INI-like file in %APPDATA%\AemulusXR\settings.ini
    /// Keeps it intentionally small and dependency-free.
    /// </summary>
    public static class SettingsManager
    {
        private static readonly string AppFolder = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "AemulusXR");
        private static readonly string SettingsFile = Path.Combine(AppFolder, "settings.ini");

        public static void LoadSettings()
        {
            try
            {
                if (!File.Exists(SettingsFile))
                    return;

                var lines = File.ReadAllLines(SettingsFile, Encoding.UTF8);
                foreach (var raw in lines)
                {
                    var line = raw.Trim();
                    if (string.IsNullOrEmpty(line) || line.StartsWith("#") || line.StartsWith(";"))
                        continue;

                    var idx = line.IndexOf('=');
                    if (idx <= 0)
                        continue;

                    var key = line.Substring(0, idx).Trim();
                    var value = line.Substring(idx + 1).Trim();

                    switch (key)
                    {
                        case "ReportsLocation":
                            FSStrings.ReportsLocation = value;
                            break;
                        case "ArchiveLocation":
                            FSStrings.ArchiveLocation = value;
                            break;
                        case "OutputLocation":
                            FSStrings.OutputLocation = value;
                            break;
                        case "ADBEXELocation":
                            FSStrings.ADBEXELocation = value;
                            break;
                        default:
                            // unknown keys ignored
                            break;
                    }
                }
            }
            catch
            {
                // Best-effort load; if it fails, keep defaults and continue.
            }
        }

        public static void SaveSettings()
        {
            try
            {
                if (!Directory.Exists(AppFolder))
                    Directory.CreateDirectory(AppFolder);

                var sb = new StringBuilder();
                sb.AppendLine("# Aemulus XR Reporting App settings");
                sb.AppendLine($"ReportsLocation={FSStrings.ReportsLocation}");
                sb.AppendLine($"ArchiveLocation={FSStrings.ArchiveLocation}");
                sb.AppendLine($"OutputLocation={FSStrings.OutputLocation}");
                sb.AppendLine($"ADBEXELocation={FSStrings.ADBEXELocation}");

                var temp = SettingsFile + ".tmp";
                File.WriteAllText(temp, sb.ToString(), Encoding.UTF8);
                File.Copy(temp, SettingsFile, true);
                File.Delete(temp);
            }
            catch
            {
                // swallow errors — saving is best-effort
            }
        }
    }
}
