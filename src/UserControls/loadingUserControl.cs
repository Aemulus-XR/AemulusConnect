using AemulusConnect.Enums;
using System.ComponentModel;

namespace AemulusConnect
{
	public partial class loadingUserControl : UserControl
	{
		private BackgroundWorker _backgroundWorker;
		private int maxProgress;

		public event Action? OnLoadingComplete;

		public loadingUserControl()
		{
			InitializeComponent();

			maxProgress = progressBar.Maximum;

			_backgroundWorker = new BackgroundWorker();
			_backgroundWorker.WorkerReportsProgress = true;
			_backgroundWorker.DoWork += BackgroundWorker_DoWork;
			_backgroundWorker.ProgressChanged += BackgroundWorker_ProgressChanged;
			_backgroundWorker.RunWorkerCompleted += BackgroundWorker_RunWorkerCompleted;
		}

		public void resetProgressBar()
		{
			_backgroundWorker.RunWorkerAsync();
		}

		private void BackgroundWorker_DoWork(object? sender, DoWorkEventArgs e)
		{
			for (int i = 0; i <= maxProgress; i++)
			{
				Thread.Sleep(10);

				if (i >= maxProgress)
					_backgroundWorker.ReportProgress(maxProgress);
				else
					_backgroundWorker.ReportProgress(i + 1);
			}
		}

		private void BackgroundWorker_ProgressChanged(object? sender, ProgressChangedEventArgs e) => progressBar.Value = e.ProgressPercentage;

		private void BackgroundWorker_RunWorkerCompleted(object? sender, RunWorkerCompletedEventArgs e) => onLoadingComplete();

		private void onLoadingComplete()
		{
			Thread.Sleep(2000);
			OnLoadingComplete?.Invoke();
		}

		public void setDownloadStatus(DownloadStatus downloadStatus)
		{
			switch (downloadStatus)
			{
				case DownloadStatus.NoReports:
					lblDownloadStatus.Text = Properties.Resources.Loading_StatusNoReports;
					lblDownloadStatus.Font = new Font(lblDownloadStatus.Font, FontStyle.Regular);
					break;
				case DownloadStatus.Downloading:
					lblDownloadStatus.Text = Properties.Resources.Loading_StatusDownloading;
					lblDownloadStatus.Font = new Font(lblDownloadStatus.Font, FontStyle.Regular);
					break;
				case DownloadStatus.DownloadingComplete:
					lblDownloadStatus.Text = Properties.Resources.Loading_StatusComplete;
					lblDownloadStatus.Font = new Font(lblDownloadStatus.Font, FontStyle.Regular);
					break;
				case DownloadStatus.DownloadFailed:
					lblDownloadStatus.Text = Properties.Resources.Loading_StatusFailed;
					lblDownloadStatus.ForeColor = Color.Red;
					lblDownloadStatus.Font = new Font(lblDownloadStatus.Font, FontStyle.Bold);
					break;
			}
		}
	}
}