namespace Aemulus_XR_Reporting_App
{
	using Strings;

	public partial class connectedUserControl : UserControl
	{
		public event Action? BtnTransfer_Click;
		public event Action? BtnViewReports_Click;

		public connectedUserControl()
		{
			InitializeComponent();

			if (Directory.Exists(FSStrings.OutputLocation))
				btnViewReports.Enabled = true;
			else
				btnViewReports.Enabled = false;

			// Add Settings button
			var settingsBtn = new Button()
			{
				Text = "Settings",
				AutoSize = true,
				Location = new Point(10, 10)
			};
			settingsBtn.Click += (s, e) =>
			{
				var settingsForm = new SettingsForm(FSStrings.ReportsLocation, FSStrings.ArchiveLocation, FSStrings.OutputLocation, (r, a, o) =>
				{
					// Notify the main form that settings have changed
					var mainForm = FindForm() as frmMain;
					if (mainForm != null)
					{
						mainForm.UpdateQuestHelperPaths(r, a, o);
					}
				});
				settingsForm.ShowDialog(this);
			};
			this.Controls.Add(settingsBtn);
		}

		private void btnTransfer_Click(object sender, EventArgs e) => BtnTransfer_Click?.Invoke();

		private void btnViewReports_Click(object sender, EventArgs e) => BtnViewReports_Click?.Invoke();

		public void setNumReports(int numReports)
		{
			lblNumReports.Text = $"{numReports} Reports fetched";
			// Enable the View Reports button when there are reports and the output folder exists
			try
			{
				btnViewReports.Enabled = numReports > 0 && Directory.Exists(FSStrings.OutputLocation);
			}
			catch
			{
				// If anything goes wrong checking the directory, don't crash the UI; leave the existing state
			}
		}
	}
}
