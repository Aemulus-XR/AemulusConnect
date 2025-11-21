using System;
using System.Drawing;
using System.Windows.Forms;
using AemulusConnect.Strings;
using AemulusConnect.Helpers;

namespace AemulusConnect
{
    public class SettingsForm : Form
    {
        private TextBox txtOutputPath;
        private ComboBox cmbLanguage;
        private NumericUpDown numMaxArchivedFiles;
        private NumericUpDown numStatusCheckInterval;
        private Button btnSave;
        private Button btnCancel;
        private Action<string, string, string>? _onSave;
        private string _initialLanguage;
        private int _initialMaxArchivedFiles;
        private int _initialStatusCheckInterval;
        // Keep the initial remote paths for backend persistence, but don't expose in UI
        private string _reportsPath;
        private string _archivePath;

        public SettingsForm(string initialReportsPath, string initialArchivePath, string initialOutputPath, Action<string, string, string>? onSave)
        {
            _onSave = onSave;
            _initialLanguage = SettingsManager.Language;
            _initialMaxArchivedFiles = SettingsManager.MaxArchivedFiles;
            _initialStatusCheckInterval = SettingsManager.StatusCheckIntervalMs;
            _reportsPath = initialReportsPath;
            _archivePath = initialArchivePath;
            Text = Properties.Resources.Settings_WindowTitle;
            Size = new Size(520, 330);
            StartPosition = FormStartPosition.CenterParent;

            // Output path (PC location)
            var lblOutput = new Label() { Text = Properties.Resources.Settings_OutputPathLabel, Location = new Point(10, 15), AutoSize = true };
            txtOutputPath = new TextBox() { Location = new Point(10, 38), Width = 360, Text = initialOutputPath };

            // Browse button for output folder
            var btnBrowse = new Button() { Text = Properties.Resources.Settings_BrowseButton, Location = new Point(380, 36), Size = new Size(100, 24) };
            btnBrowse.Click += (s, e) =>
            {
                using var dlg = new FolderBrowserDialog();
                dlg.Description = Properties.Resources.Settings_FolderBrowserDescription;
                try { dlg.SelectedPath = txtOutputPath.Text; } catch { }
                if (dlg.ShowDialog() == DialogResult.OK)
                    txtOutputPath.Text = dlg.SelectedPath;
            };

            // Language selector
            var lblLanguage = new Label() { Text = Properties.Resources.Settings_LanguageLabel, Location = new Point(10, 80), AutoSize = true };
            cmbLanguage = new ComboBox()
            {
                Location = new Point(10, 103),
                Width = 200,
                DropDownStyle = ComboBoxStyle.DropDownList
            };

            // Populate language dropdown
            var availableCultures = LocalizationHelper.GetAvailableCultures();
            foreach (var culture in availableCultures)
            {
                cmbLanguage.Items.Add(culture);
            }

            // Select current language
            var currentCulture = availableCultures.Find(c => c.Code == _initialLanguage);
            if (currentCulture != null)
            {
                cmbLanguage.SelectedItem = currentCulture;
            }
            else
            {
                // Default to first item (English) if current language not found
                if (cmbLanguage.Items.Count > 0)
                    cmbLanguage.SelectedIndex = 0;
            }

            // Max archived files setting
            var lblMaxFiles = new Label()
            {
                Text = "Max Archived Files:",
                Location = new Point(10, 145),
                AutoSize = true
            };
            numMaxArchivedFiles = new NumericUpDown()
            {
                Location = new Point(10, 168),
                Width = 100,
                Minimum = 10,
                Maximum = 1000,
                Value = SettingsManager.MaxArchivedFiles
            };
            var lblMaxFilesHelp = new Label()
            {
                Text = "(10-1000, lower = less storage used on Quest)",
                Location = new Point(120, 170),
                AutoSize = true,
                ForeColor = Color.Gray,
                Font = new Font(lblMaxFiles.Font.FontFamily, 8)
            };

            // Status check interval setting
            var lblStatusInterval = new Label()
            {
                Text = "Device Check Interval (ms):",
                Location = new Point(10, 205),
                AutoSize = true
            };
            numStatusCheckInterval = new NumericUpDown()
            {
                Location = new Point(10, 228),
                Width = 100,
                Minimum = 100,
                Maximum = 10000,
                Increment = 100,
                Value = SettingsManager.StatusCheckIntervalMs
            };
            var lblStatusIntervalHelp = new Label()
            {
                Text = "(100-10000, higher = better for flaky USB)",
                Location = new Point(120, 230),
                AutoSize = true,
                ForeColor = Color.Gray,
                Font = new Font(lblStatusInterval.Font.FontFamily, 8)
            };

            btnSave = new Button() { Text = Properties.Resources.Settings_SaveButton, Location = new Point(320, 265), DialogResult = DialogResult.OK };
            btnCancel = new Button() { Text = Properties.Resources.Settings_CancelButton, Location = new Point(410, 265), DialogResult = DialogResult.Cancel };

            btnSave.Click += BtnSave_Click;
            btnCancel.Click += (s, e) => Close();

            Controls.Add(lblOutput);
            Controls.Add(txtOutputPath);
            Controls.Add(btnBrowse);
            Controls.Add(lblLanguage);
            Controls.Add(cmbLanguage);
            Controls.Add(lblMaxFiles);
            Controls.Add(numMaxArchivedFiles);
            Controls.Add(lblMaxFilesHelp);
            Controls.Add(lblStatusInterval);
            Controls.Add(numStatusCheckInterval);
            Controls.Add(lblStatusIntervalHelp);
            Controls.Add(btnSave);
            Controls.Add(btnCancel);

            // Apply RTL layout if Arabic is selected
            LocalizationHelper.ApplyRTLToForm(this);

            // Apply culture-specific fonts
            LocalizationHelper.ApplyCultureSpecificFont(this);
        }

        private void BtnSave_Click(object? sender, EventArgs e)
        {
            // Use the stored remote paths (unchanged by user)
            var reports = _reportsPath;
            var archive = _archivePath;
            var output = txtOutputPath.Text?.Trim() ?? string.Empty;

            // Get selected language
            var selectedCulture = cmbLanguage.SelectedItem as CultureOption;
            var selectedLanguage = selectedCulture?.Code ?? LocalizationHelper.DefaultCulture;

            // Update static strings (remote paths remain as they were)
            FSStrings.ReportsLocation = reports;
            FSStrings.ArchiveLocation = archive;
            FSStrings.OutputLocation = output;
            SettingsManager.Language = selectedLanguage;

            // Update file management and device monitoring settings
            SettingsManager.MaxArchivedFiles = (int)numMaxArchivedFiles.Value;
            SettingsManager.StatusCheckIntervalMs = (int)numStatusCheckInterval.Value;

            // Persist settings to disk
            try { SettingsManager.SaveSettings(); } catch { }

            // Show restart notification if any settings that require restart have changed
            bool needsRestart = selectedLanguage != _initialLanguage ||
                               SettingsManager.MaxArchivedFiles != _initialMaxArchivedFiles ||
                               SettingsManager.StatusCheckIntervalMs != _initialStatusCheckInterval;

            if (needsRestart)
            {
                MessageBox.Show(
                    Properties.Resources.Settings_RestartMessage,
                    Properties.Resources.Settings_RestartTitle,
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information
                );
            }

            _onSave?.Invoke(reports, archive, output);
            Close();
        }
    }
}
