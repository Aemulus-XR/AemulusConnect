using AemulusConnect.Enums;
using AemulusConnect.Constants;
using System.ComponentModel;

namespace AemulusConnect
{
	public partial class loadingUserControl : UserControl
	{
		public event Action? OnLoadingComplete;

		public loadingUserControl()
		{
			InitializeComponent();
		}

		public void resetProgressBar()
		{
			// Reset progress bar to initial state
			if (InvokeRequired)
			{
				Invoke(new Action(() =>
				{
					progressBar.Value = 0;
					progressBar.Maximum = 100;
				}));
			}
			else
			{
				progressBar.Value = 0;
				progressBar.Maximum = 100;
			}
		}

		public void updateProgress(int current, int total)
		{
			// Update progress bar based on actual file transfer progress
			if (InvokeRequired)
			{
				Invoke(new Action(() => updateProgressInternal(current, total)));
			}
			else
			{
				updateProgressInternal(current, total);
			}
		}

		private void updateProgressInternal(int current, int total)
		{
			// Handle zero-total case (no files to transfer) - trigger completion immediately
			if (total <= 0)
			{
				Task.Run(async () =>
				{
					await Task.Delay(UiDelays.CompletionNotification);
					onLoadingComplete();
				});
				return;
			}

			progressBar.Maximum = total;
			progressBar.Value = Math.Min(current, total);

			// When complete, trigger the completion event after a short delay
			if (current >= total)
			{
				Task.Run(async () =>
				{
					await Task.Delay(UiDelays.CompletionNotification);
					onLoadingComplete();
				});
			}
		}

		private void onLoadingComplete()
		{
			Thread.Sleep(UiDelays.LoadingComplete);
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