using AemulusConnect.Enums;
using AdvancedSharpAdbClient;
using AdvancedSharpAdbClient.Models;
using log4net;
using System.Diagnostics;
using System.Text;
using System.Text.RegularExpressions;
using System.Net;
using AemulusConnect.Strings;
using System.Windows.Forms;
using AdvancedSharpAdbClient.Receivers;
using System.Threading;
using System.Threading.Tasks;
using System.IO;
using System.Linq;
using System.Collections.Generic;

namespace AemulusConnect.Helpers
{
	public class QuestHelper
	{
		private AdbClient _adbClient;
		private AdbServer? _adbServer;
		private System.Timers.Timer _timer;
		private DeviceData _deviceData;
		private QuestStatus _lastQuestStatus = QuestStatus.InitPending;
		private DownloadStatus _lastDownloadStatus = DownloadStatus.InitStatus;
		private static readonly ILog _logger = LogManager.GetLogger(typeof(Program));
		private string _remotePath = FSStrings.ReportsLocation;
		private string _localPath = FSStrings.OutputLocation;
		private int maxArchivedFiles = 100;
		private ConsoleOutputReceiver _receiver;

		public event Action<QuestStatus>? OnStatusChanged;
		public event Action<DownloadStatus>? OnDownloadStatusChanged;
		public event Action<Exception>? OnError;
		public event Action<int, int>? OnTransferProgress; // (currentFile, totalFiles)

		public int numReports { get; private set; }

		public QuestHelper()
		{
			_logger.Info("QuestHelper initialized");
			_adbClient = new AdbClient();
			_receiver = new ConsoleOutputReceiver();
			_timer = new System.Timers.Timer(1000);
			_timer.Elapsed += OnTimerElapsed;
		}

		public void InitializeADBServer() => startADBServer();

		public void SetRemotePath(string path)
		{
			FSStrings.ReportsLocation = path;
			_remotePath = path;
		}

		public void SetArchiveLocation(string path)
		{
			FSStrings.ArchiveLocation = path;
		}

		public void SetOutputPath(string path)
		{
			FSStrings.OutputLocation = path;
			_localPath = path;
		}

		private void OnTimerElapsed(object? source, System.Timers.ElapsedEventArgs e) => getDeviceStatusAndNotify();

		public void onStatusChanged(QuestStatus status) => OnStatusChanged?.Invoke(status);
		public void onError(Exception ex) => OnError?.Invoke(ex);
		public void onDownloadStatusChanged(DownloadStatus status) => OnDownloadStatusChanged?.Invoke(status);

		private void getDeviceStatusAndNotify()
		{
			_timer.Stop();

			var devices = _adbClient.GetDevices().ToList();

			if (devices.Count == 0)
			{
				setStatusAndNotifyIfChanged(QuestStatus.Disconnected);
				_timer.Start();
				return;
			}

			_deviceData = devices[0];

			if (_deviceData.State == DeviceState.Unauthorized)
			{
				setStatusAndNotifyIfChanged(QuestStatus.Unauthorized);
				_timer.Start();
				return;
			}

			if (_deviceData.State == DeviceState.Online)
				setStatusAndNotifyIfChanged(QuestStatus.Online);

			_timer.Start();
		}

		private void setStatusAndNotifyIfChanged(QuestStatus newStatus)
		{
			if (newStatus == _lastQuestStatus)
				return;

			if (newStatus == QuestStatus.Online)
				_logger.Info($"Device connected: {_deviceData}");

			OnStatusChanged?.Invoke(newStatus);
			_lastQuestStatus = newStatus;
			_logger.Debug(newStatus);
		}

		private void setDownloadStatusAndNotify(DownloadStatus newDownloadStatus)
		{
			if (newDownloadStatus == _lastDownloadStatus)
				return;

			OnDownloadStatusChanged?.Invoke(newDownloadStatus);
			_lastDownloadStatus = newDownloadStatus;
			_logger.Debug(newDownloadStatus);
		}

		private void startADBServer()
		{
			_logger.Debug("Starting ADB server");

			try
			{
				_adbServer = new AdbServer();
				var result = _adbServer.StartServer(FSStrings.ADBEXELocation, restartServerIfNewer: true);

				Debug.WriteLine($"Server {result}");
				_logger.Debug($"Server status: {result}");

				if (result == StartServerResult.Started
					|| result == StartServerResult.AlreadyRunning
					|| result == StartServerResult.RestartedOutdatedDaemon)
				{
					setStatusAndNotifyIfChanged(QuestStatus.ADBServerReady);
					_timer.Enabled = true;
				}
			}
			catch (Exception ex)
			{
				_logger.Error(ex);
				OnError?.Invoke(ex);
			}
		}

		public async Task copyFiles()
		{
			_logger.Debug("Copying files from device");

			try
			{
				var remoteFiles = await retrieveFileNames(_remotePath);
				numReports = remoteFiles.Count;
				var date = DateTime.Now.ToString("yyyy-MM-dd");
				// Build the dated reports folder inside the configured output path.
				// Use Path.Combine to avoid accidentally concatenating paths without a separator
				// (e.g. when _localPath = "test" this prevents creating "testReports-...").
				var localPath = Path.Combine(_localPath ?? string.Empty, $"Reports-{date}");
				var tempLocalPath = localPath.Replace("\\", "/");
				var tempRemotePath = _remotePath.Replace("\\", "/");

				if (numReports == 0)
				{
					// No reports to transfer - trigger progress with (0, 0) to complete UI transition
					OnTransferProgress?.Invoke(0, 0);
					return;
				}

				await logFolderSize();
				setDownloadStatusAndNotify(DownloadStatus.Downloading);
				createDirectories(localPath);

				int currentFile = 0;
				foreach (var remoteFile in remoteFiles)
				{
					await transferAndRenameFile(remoteFile, tempLocalPath, tempRemotePath, date);
					currentFile++;
					OnTransferProgress?.Invoke(currentFile, numReports);
				}

				Debug.WriteLine($"Files copied successfully");

				setDownloadStatusAndNotify(DownloadStatus.DownloadingComplete);
				await archiveFiles();
			}
			catch (Exception ex)
			{
				_logger.Error(ex);
				OnError?.Invoke(ex);
				setDownloadStatusAndNotify(DownloadStatus.DownloadFailed);
			}
		}

		private void createDirectories(string path)
		{
			try
			{
				if (!Directory.Exists(_localPath))
				{
					_logger.Debug("Creating local directory");
					Directory.CreateDirectory(_localPath);
				}

				if (!Directory.Exists(path))
				{
					_logger.Debug("Creating remote directory");
					Directory.CreateDirectory(path);
				}
			}
			catch (Exception ex)
			{
				_logger.Error(ex);
				OnError?.Invoke(ex);
			}
		}

		/// <summary>
		/// Executes a shell command (uses system adb) with a timeout.
		/// Returns stdout string if successful, throws on error or timeout.
		/// </summary>
		private async Task<string> ExecuteAdbCommand(string command, int timeoutMs = 5000)
		{
			_logger.Debug($"Executing ADB command: {command}");
			using var process = new Process();
			var output = new StringBuilder();
			var error = new StringBuilder();

			process.StartInfo.FileName = "adb";
			process.StartInfo.Arguments = command;
			process.StartInfo.RedirectStandardOutput = true;
			process.StartInfo.RedirectStandardError = true;
			process.StartInfo.CreateNoWindow = true;
			process.StartInfo.UseShellExecute = false;

			var outputTcs = new TaskCompletionSource<bool>();
			process.OutputDataReceived += (s, e) =>
			{
				if (e.Data == null)
					outputTcs.TrySetResult(true);
				else
					output.AppendLine(e.Data);
			};

			process.ErrorDataReceived += (s, e) =>
			{
				if (e.Data != null)
					error.AppendLine(e.Data);
			};

			process.Start();
			process.BeginOutputReadLine();
			process.BeginErrorReadLine();

			using var cts = new CancellationTokenSource();
			var processTask = process.WaitForExitAsync(cts.Token);
			var timeoutTask = Task.Delay(timeoutMs, cts.Token);

			var completed = await Task.WhenAny(processTask, timeoutTask);
			if (completed == timeoutTask)
			{
				_logger.Error("ADB command timed out");
				try { process.Kill(); } catch { }
				throw new TimeoutException($"ADB command timed out after {timeoutMs}ms: {command}");
			}

			// allow small time for remaining output
			await Task.WhenAny(outputTcs.Task, Task.Delay(500));

			if (process.ExitCode != 0 && error.Length > 0)
			{
				var err = error.ToString();
				_logger.Error($"ADB command failed with exit code {process.ExitCode}: {err}");
				throw new Exception($"ADB command failed: {err}");
			}

			return output.ToString();
		}

		private async Task<List<string>> retrieveFileNames(string remotePath)
		{
			_logger.Debug("Reading file names from headset");

			try
			{
				var tempRemotePath = remotePath.Replace("\\", "/").TrimEnd('/');

				// Use -F so directories are suffixed (e.g. name/). Filter out directories.
				var output = await ExecuteAdbCommand($"shell ls -F -tr {tempRemotePath}");
				_logger.Debug("Raw ls output: " + output);

				var remoteFiles = output
					.Split(new[] { '\n' }, StringSplitOptions.RemoveEmptyEntries)
					.Select(s => Regex.Replace(s, @"\t|\r", "").Trim())
					.Where(s => !string.IsNullOrWhiteSpace(s))
					// skip entries marked as directories by ls -F (ending with '/')
					.Where(s => !s.EndsWith("/"))
					.ToList();

				if (remoteFiles.Count == 0)
				{
					_logger.Debug("No files found in remote location (directories ignored)");
					setDownloadStatusAndNotify(DownloadStatus.NoReports);
					return new List<string>();
				}

				return remoteFiles;
			}
			catch (Exception ex)
			{
				onDownloadStatusChanged(DownloadStatus.DownloadFailed);
				_logger.Error($"Failed to retrieve file names: {ex.Message}");
				OnError?.Invoke(ex);
				return new List<string>();
			}
		}

		private async Task transferAndRenameFile(string fileName, string destination, string remotePath, string date)
		{
			_logger.Debug($"Transferring {fileName} from device");

			try
			{
				var newFileName = fileName?.Trim() ?? string.Empty;

				if (string.IsNullOrEmpty(newFileName))
				{
					_logger.Warn("Empty filename received, skipping transfer");
					return;
				}

				// Build remote path and check if it's a directory
				var remoteFilePath = $"{remotePath.TrimEnd('/')}/{newFileName}".Replace("\\", "/");
				try
				{
					var typeOut = await ExecuteAdbCommand($"shell [ -d \"{remoteFilePath}\" ] && echo DIR || echo FILE", 2000);
					if (typeOut.Trim() == "DIR")
					{
						_logger.Debug($"Skipping remote directory {fileName}");
						return;
					}
				}
				catch (Exception ex)
				{
					_logger.Warn($"Could not determine remote type for {fileName}: {ex.Message}");
					// Continue anyway - the pull will fail if it's a directory
				}

				var savedFileName = newFileName;
				if (savedFileName.Contains(".pdf"))
					savedFileName = savedFileName.Replace(".pdf", $"_Archived_{date}.pdf");
				if (savedFileName.Contains(".csv"))
					savedFileName = savedFileName.Replace(".csv", $"_Archived_{date}.csv");

				var localPathWindows = destination.Replace("/", Path.DirectorySeparatorChar.ToString());
				var destPath = Path.Combine(localPathWindows, savedFileName);

				if (File.Exists(destPath))
				{
					_logger.Debug($"File {destPath} already exists, skipping");
					return;
				}

				using var service = new SyncService(_deviceData);
				using (var stream = new FileStream(destPath, FileMode.CreateNew, FileAccess.Write, FileShare.None))
				{
					await service.PullAsync(remoteFilePath, stream);
				}

				_logger.Debug($"Successfully transferred {fileName} to {destPath}");
			}
			catch (Exception ex)
			{
				onDownloadStatusChanged(DownloadStatus.DownloadFailed);
				_logger.Error($"Failed to transfer {fileName}: {ex.Message}");
				OnError?.Invoke(ex);
			}
		}

		private async Task logFolderSize()
		{
			try
			{
				var tempReportsLocation = FSStrings.ReportsLocation.Replace("\\", "/");

				await _adbClient.ExecuteRemoteCommandAsync($"du -hs {tempReportsLocation}", _deviceData, _receiver);
				var fileSize = _receiver.ToString().Split('\t')[0];

				_logger.Info($"{numReports} files fetched, {fileSize}B");
			}
			catch (Exception ex)
			{
				_logger.Error(ex);
				OnError?.Invoke(ex);
			}
		}

		private async Task archiveFiles()
		{
			_logger.Debug("Archiving files on device");

			try
			{
				var tempReportsLocation = FSStrings.ReportsLocation.Replace("\\", "/").TrimEnd('/');
				var tempArchiveLocation = FSStrings.ArchiveLocation.Replace("\\", "/").TrimEnd('/');

				// Use ls -1F to get one file per line and identify directories (they end with /)
				var output = await ExecuteAdbCommand($"shell ls -1F {tempReportsLocation}");
				_logger.Debug($"Files in reports location: {output}");

				if (string.IsNullOrWhiteSpace(output))
				{
					_logger.Debug("No files found to archive");
					return;
				}

				// Create archive directory with timeout protection
				await ExecuteAdbCommand($"shell mkdir -p {tempArchiveLocation}", 3000);

				var files = output.Split(new[] { '\n' }, StringSplitOptions.RemoveEmptyEntries)
					.Select(f => Regex.Replace(f, @"\t|\r", "").Trim())
					.Where(f => !string.IsNullOrEmpty(f))
					.ToList();

				foreach (var file in files)
				{
					// Skip directories (ls -F marks them with trailing /)
					if (file.EndsWith("/"))
					{
						_logger.Debug($"Skipping directory: {file}");
						continue;
					}

					var cleanFile = file.TrimEnd('/'); // remove any trailing slash
					_logger.Debug($"Archiving file: {cleanFile}");

					// Build full source and destination paths
					// Use single quotes for shell to preserve all special characters literally
					var sourcePath = $"'{tempReportsLocation}/{cleanFile}'";
					var destPath = $"'{tempArchiveLocation}/{cleanFile}'";

					try
					{
						// First verify it's a file
						var typeCheck = await ExecuteAdbCommand($"shell [ -f {sourcePath} ] && echo OK", 2000);
						if (typeCheck.Trim() != "OK")
						{
							_logger.Debug($"Skipping non-file {cleanFile}");
							continue;
						}

						// Check if file already exists in archive
						var existsCheck = await ExecuteAdbCommand($"shell [ -f {destPath} ] && echo EXISTS", 2000);
						if (existsCheck.Trim() == "EXISTS")
						{
							// File already archived - just remove from reports location
							_logger.Debug($"File {cleanFile} already in archive, removing from reports");
							await ExecuteAdbCommand($"shell rm {sourcePath}", 2000);
							_logger.Debug($"Removed duplicate: {cleanFile}");
							continue;
						}

						// Copy to archive
						await ExecuteAdbCommand($"shell cp {sourcePath} {destPath} 2>&1", 5000);

						// Verify the copy succeeded
						var verifyResult = await ExecuteAdbCommand($"shell [ -f {destPath} ] && echo OK", 2000);
						if (verifyResult.Trim() == "OK")
						{
							// Remove original only after verified copy
							await ExecuteAdbCommand($"shell rm {sourcePath}", 2000);
							_logger.Debug($"Successfully archived and removed: {cleanFile}");
						}
						else
						{
							_logger.Error($"Failed to verify copy of {cleanFile} to archive");
						}
					}
					catch (TimeoutException tex)
					{
						_logger.Error($"Timeout while archiving {cleanFile}: {tex.Message}");
						continue;
					}
					catch (Exception ex)
					{
						_logger.Error($"Error archiving {cleanFile}: {ex.Message}");
						continue;
					}
				}

				await deleteFilesOverMaxArchive();
				_logger.Debug("Archive process completed successfully");
			}
			catch (Exception ex)
			{
				_logger.Error($"Archive process failed: {ex.Message}");
				OnError?.Invoke(ex);
			}
		}

		private async Task deleteFilesOverMaxArchive()
		{
			_logger.Debug("Checking if max archive size is exceeded");

			try
			{
				var archivedFiles = await retrieveFileNames(FSStrings.ArchiveLocation);
				var tempArchiveLocation = FSStrings.ArchiveLocation.Replace("\\", "/").TrimEnd('/');

				if (archivedFiles.Count <= maxArchivedFiles)
					return;

				_logger.Debug($"Removing {archivedFiles.Count - maxArchivedFiles} files from archive");

				for (int i = 0; i < archivedFiles.Count - maxArchivedFiles; i++)
				{
					var fileName = archivedFiles[i].Trim();
					if (string.IsNullOrEmpty(fileName) || fileName.EndsWith("/"))
						continue;

					try
					{
						var fullPath = $"{tempArchiveLocation}/{fileName}";
						// Verify it's a file first
						var typeCheck = await ExecuteAdbCommand($"shell [ -f \"{fullPath}\" ] && echo OK", 2000);
						if (typeCheck.Trim() != "OK")
						{
							_logger.Debug($"Skipping non-file {fileName} during cleanup");
							continue;
						}

						await ExecuteAdbCommand($"shell rm \"{fullPath}\"", 3000);
						_logger.Debug($"Removed old archive file: {fileName}");
					}
					catch (Exception ex)
					{
						_logger.Error($"Failed to remove old archive file {fileName}: {ex.Message}");
					}
				}
			}
			catch (Exception ex)
			{
				_logger.Error(ex);
				OnError?.Invoke(ex);
			}
		}
	}
}
