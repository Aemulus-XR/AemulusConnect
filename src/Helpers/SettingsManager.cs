using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using AemulusConnect.Strings;
using AemulusConnect.Constants;

namespace AemulusConnect.Helpers
{
    /// <summary>
    /// Simple settings manager that persists key=value pairs to an INI-like file in %APPDATA%\AemulusConnect\settings.ini
    /// Keeps it intentionally small and dependency-free.
    /// </summary>
    public static class SettingsManager
    {
        private static readonly string AppFolder = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "AemulusConnect");
        private static readonly string SettingsFile = Path.Combine(AppFolder, "settings.ini");

        /// <summary>
        /// Current language/culture setting. Defaults to en-US.
        /// </summary>
        public static string Language { get; set; } = LocalizationHelper.DefaultCulture;

        /// <summary>
        /// Maximum number of files to keep in archive before cleanup. Defaults to 100.
        /// </summary>
        public static int MaxArchivedFiles { get; set; } = FileManagement.MaxArchivedFiles;

        /// <summary>
        /// Device status check interval in milliseconds. Defaults to 1000ms (1 second).
        /// </summary>
        public static int StatusCheckIntervalMs { get; set; } = DeviceMonitoring.StatusCheckInterval;

        /// <summary>
        /// Comma-separated list of file extensions to look for, download, and archive. Defaults to ".pdf,.csv".
        /// Extensions should include the dot (e.g., ".pdf,.csv,.txt").
        /// </summary>
        public static string FileExtensions { get; set; } = ".pdf,.csv";

        /// <summary>
        /// Gets the configured file extensions as a list of strings.
        /// Returns empty list if FileExtensions is null or empty.
        /// </summary>
        public static List<string> GetFileExtensionsList()
        {
            if (string.IsNullOrWhiteSpace(FileExtensions))
                return new List<string>();

            return FileExtensions
                .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(ext => ext.Trim().ToLowerInvariant())
                .Where(ext => !string.IsNullOrWhiteSpace(ext))
                .ToList();
        }

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
                        case "Language":
                            Language = value;
                            break;
                        case "MaxArchivedFiles":
                            if (int.TryParse(value, out int maxFiles) && maxFiles > 0)
                                MaxArchivedFiles = maxFiles;
                            break;
                        case "StatusCheckIntervalMs":
                            if (int.TryParse(value, out int interval) && interval >= 100)
                                StatusCheckIntervalMs = interval;
                            break;
                        case "FileExtensions":
                            if (!string.IsNullOrWhiteSpace(value))
                                FileExtensions = value;
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
                sb.AppendLine("# AemulusConnect settings");
                sb.AppendLine($"Language={Language}");
                sb.AppendLine($"ReportsLocation={FSStrings.ReportsLocation}");
                sb.AppendLine($"ArchiveLocation={FSStrings.ArchiveLocation}");
                sb.AppendLine($"OutputLocation={FSStrings.OutputLocation}");
                sb.AppendLine($"ADBEXELocation={FSStrings.ADBEXELocation}");
                sb.AppendLine();
                sb.AppendLine("# File Management");
                sb.AppendLine($"# Maximum number of files to keep in archive before cleanup (default: 100)");
                sb.AppendLine($"MaxArchivedFiles={MaxArchivedFiles}");
                sb.AppendLine();
                sb.AppendLine("# Device Monitoring");
                sb.AppendLine($"# Device status check interval in milliseconds (default: 1000, minimum: 100)");
                sb.AppendLine($"StatusCheckIntervalMs={StatusCheckIntervalMs}");
                sb.AppendLine();
                sb.AppendLine("# File Filtering");
                sb.AppendLine($"# Comma-separated list of file extensions to download and archive (default: .pdf,.csv)");
                sb.AppendLine($"# Extensions should include the dot (e.g., .pdf,.csv,.txt)");
                sb.AppendLine($"FileExtensions={FileExtensions}");

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
