namespace AemulusConnect
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
		}

		private void btnTransfer_Click(object sender, EventArgs e) => BtnTransfer_Click?.Invoke();

		private void btnViewReports_Click(object sender, EventArgs e) => BtnViewReports_Click?.Invoke();

		public void setNumReports(int numReports)
		{
			// Use singular or plural form based on count
			if (numReports == 1)
				lblNumReports.Text = string.Format(Properties.Resources.Connected_ReportCountSingular, numReports);
			else
				lblNumReports.Text = string.Format(Properties.Resources.Connected_ReportCountPlural, numReports);
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
