using System;
using System.Drawing;
using System.Windows.Forms;
using Aemulus_XR_Reporting_App.Strings;

namespace Aemulus_XR_Reporting_App
{
    public class SettingsForm : Form
    {
        private TextBox txtReportsPath;
        private TextBox txtArchivePath;
        private TextBox txtOutputPath;
        private Button btnSave;
        private Button btnCancel;
        private Action<string, string, string>? _onSave;

        public SettingsForm(string initialReportsPath, string initialArchivePath, string initialOutputPath, Action<string, string, string>? onSave)
        {
            _onSave = onSave;
            Text = "Settings";
            Size = new Size(520, 240);
            StartPosition = FormStartPosition.CenterParent;

            var lbl1 = new Label() { Text = "Reports remote path:", Location = new Point(10, 15), AutoSize = true };
            txtReportsPath = new TextBox() { Location = new Point(10, 35), Width = 480, Text = initialReportsPath };

            var lbl2 = new Label() { Text = "Archive remote path:", Location = new Point(10, 70), AutoSize = true };
            txtArchivePath = new TextBox() { Location = new Point(10, 90), Width = 480, Text = initialArchivePath };

            var lbl3 = new Label() { Text = "Local output folder:", Location = new Point(10, 120), AutoSize = true };
            txtOutputPath = new TextBox() { Location = new Point(10, 140), Width = 360, Text = initialOutputPath };

            // Browse button for output folder
            var btnBrowse = new Button() { Text = "Browse...", Location = new Point(380, 138), Size = new Size(100, 24) };
            btnBrowse.Click += (s, e) =>
            {
                using var dlg = new FolderBrowserDialog();
                dlg.Description = "Select local output folder";
                try { dlg.SelectedPath = txtOutputPath.Text; } catch { }
                if (dlg.ShowDialog() == DialogResult.OK)
                    txtOutputPath.Text = dlg.SelectedPath;
            };

            btnSave = new Button() { Text = "Save", Location = new Point(320, 180), DialogResult = DialogResult.OK };
            btnCancel = new Button() { Text = "Cancel", Location = new Point(410, 180), DialogResult = DialogResult.Cancel };

            btnSave.Click += BtnSave_Click;
            btnCancel.Click += (s, e) => Close();

            Controls.Add(lbl1);
            Controls.Add(txtReportsPath);
            Controls.Add(lbl2);
            Controls.Add(txtArchivePath);
            Controls.Add(lbl3);
            Controls.Add(txtOutputPath);
            Controls.Add(btnBrowse);
            Controls.Add(btnSave);
            Controls.Add(btnCancel);
        }

        private void BtnSave_Click(object? sender, EventArgs e)
        {
            var reports = txtReportsPath.Text?.Trim() ?? string.Empty;
            var archive = txtArchivePath.Text?.Trim() ?? string.Empty;
            var output = txtOutputPath.Text?.Trim() ?? string.Empty;

            // Update static strings
            FSStrings.ReportsLocation = reports;
            FSStrings.ArchiveLocation = archive;
            FSStrings.OutputLocation = output;

            // Persist settings to disk
            try { Helpers.SettingsManager.SaveSettings(); } catch { }

            _onSave?.Invoke(reports, archive, output);
            Close();
        }
    }
}
