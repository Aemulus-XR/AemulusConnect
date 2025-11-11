namespace AemulusConnect
{
	using Helpers;
	using Enums;
	using log4net;
	using System.Diagnostics;
	using AemulusConnect.Strings;
	using System.Drawing;

	public partial class frmMain : Form
	{
		private QuestHelper _questHelper = null!;
		private static readonly ILog _logger = LogManager.GetLogger(typeof(Program));
		private disconnectedUserControl _disconnectedUserControl = new disconnectedUserControl();
		private connectedUserControl _connectedUserControl = new connectedUserControl();
		private loadingUserControl _loadingUserControl = new loadingUserControl();
		private string fullVersion = Application.ProductVersion.ToString();
		private string[] versionParts;
		private string version;
		private static OperatingSystem os = Environment.OSVersion;

		public frmMain()
		{
			InitializeComponent();
			versionParts = fullVersion.Split('+');
			version = versionParts[0];
			lblVersion.Text = string.Format(Properties.Resources.MainForm_VersionLabel, version);
			Text = string.Format(Properties.Resources.MainForm_WindowTitleWithVersion, version);
			_logger.Info($"AemulusConnect version {version} initialized at {DateTime.Now.ToString()}");
			_logger.Info($"Operating System: {os}");

		}

		public void UpdateQuestHelperPaths(string reportsPath, string archivePath, string outputPath)
		{
			// Update QuestHelper paths at runtime if available
			// Update global FSStrings first
			FSStrings.ReportsLocation = reportsPath;
			FSStrings.ArchiveLocation = archivePath;
			FSStrings.OutputLocation = outputPath;

			if (_questHelper != null)
			{
				_questHelper.SetRemotePath(reportsPath);
				_questHelper.SetArchiveLocation(archivePath);
				_questHelper.SetOutputPath(outputPath);
			}
		}

		private void questHelper_OnStatusChanged(QuestStatus status)
		{
			if (pnlMain.InvokeRequired)
			{
				pnlMain.Invoke(new Action(() => questHelper_OnStatusChanged(status)));
				return;
			}

			Debug.WriteLine("Status: " + status.ToString());

			switch (status)
			{
				case QuestStatus.ADBServerReady:
					pnlMain.Controls.Clear();
					pnlMain.Controls.Add(_disconnectedUserControl);
					return;
				case QuestStatus.Unauthorized:
					pnlMain.Controls.Clear();
					pnlMain.Controls.Add(_disconnectedUserControl);
					return;
				case QuestStatus.Disconnected:
					pnlMain.Controls.Clear();
					pnlMain.Controls.Add(_disconnectedUserControl);
					return;
				case QuestStatus.Online:
					pnlMain.Controls.Clear();
					pnlMain.Controls.Add(_connectedUserControl);
					return;
			}
		}

		private void questHelper_OnError(Exception e)
		{
			string message = Properties.Resources.Error_GenericMessage;
			var result = MessageBox.Show($"{message} {e.Message}", Properties.Resources.Error_RetryDialogTitle, MessageBoxButtons.YesNo);

			if (result == DialogResult.Yes)
				_questHelper.InitializeADBServer();
			else
				Application.Exit();
		}

		private void frmMain_Shown(object sender, EventArgs e)
		{
			_questHelper = new QuestHelper();
			_questHelper.OnStatusChanged += questHelper_OnStatusChanged;
			_questHelper.OnDownloadStatusChanged += questHelper_OnDownloadStatusChanged;
			_questHelper.OnError += questHelper_OnError;
			_questHelper.InitializeADBServer();

			_loadingUserControl.OnLoadingComplete += loadingUserControl_OnLoadingComplete;
			_connectedUserControl.BtnTransfer_Click += async () => await connectedUserControl_btnTransfer_Click();
			_connectedUserControl.BtnViewReports_Click += connectedUserControl_btnViewReports_Click;
		}

		private void loadingUserControl_OnLoadingComplete()
		{
			if (pnlMain.InvokeRequired)
			{
				pnlMain.Invoke(new Action(() => loadingUserControl_OnLoadingComplete()));
				return;
			}

			_connectedUserControl.setNumReports(_questHelper.numReports);
			pnlMain.Controls.Clear();
			pnlMain.Controls.Add(_connectedUserControl);
		}

		private async Task connectedUserControl_btnTransfer_Click()
		{
			if (pnlMain.InvokeRequired)
			{
				pnlMain.Invoke(new Action(async () => await connectedUserControl_btnTransfer_Click()));
				return;
			}

			pnlMain.Controls.Clear();
			pnlMain.Controls.Add(_loadingUserControl);
			_loadingUserControl.resetProgressBar();
			await _questHelper.copyFiles();
		}

		private void connectedUserControl_btnViewReports_Click() => Process.Start("explorer.exe", FSStrings.OutputLocation);

		private void questHelper_OnDownloadStatusChanged(DownloadStatus downloadStatus)
		{
			if (pnlMain.InvokeRequired)
			{
				pnlMain.Invoke(new Action(() => questHelper_OnDownloadStatusChanged(downloadStatus)));
				return;
			}

			_loadingUserControl.setDownloadStatus(downloadStatus);
		}

		private void settingsToolStripMenuItem_Click(object sender, EventArgs e)
		{
			var settingsForm = new SettingsForm(
				FSStrings.ReportsLocation,
				FSStrings.ArchiveLocation,
				FSStrings.OutputLocation,
				(r, a, o) => UpdateQuestHelperPaths(r, a, o)
			);
			settingsForm.ShowDialog(this);
		}

		private void exitToolStripMenuItem_Click(object sender, EventArgs e)
		{
			Application.Exit();
		}
	}
}