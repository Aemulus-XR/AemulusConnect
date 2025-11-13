namespace AemulusConnect.Constants
{
	/// <summary>
	/// ADB command timeout values in milliseconds
	/// </summary>
	public static class AdbTimeouts
	{
		/// <summary>
		/// Default timeout for standard ADB commands
		/// </summary>
		public const int DefaultCommand = 5000;

		/// <summary>
		/// Timeout for file type and existence checks
		/// </summary>
		public const int FileCheck = 2000;

		/// <summary>
		/// Timeout for creating directories
		/// </summary>
		public const int Mkdir = 3000;

		/// <summary>
		/// Timeout for file copy operations (archiving)
		/// </summary>
		public const int Copy = 5000;

		/// <summary>
		/// Timeout for file removal operations
		/// </summary>
		public const int Remove = 2000;

		/// <summary>
		/// Timeout for cleanup operations
		/// </summary>
		public const int Cleanup = 3000;

		/// <summary>
		/// Delay to allow remaining ADB output to flush
		/// </summary>
		public const int OutputFlush = 500;
	}

	/// <summary>
	/// UI delay and timing values in milliseconds
	/// </summary>
	public static class UiDelays
	{
		/// <summary>
		/// Delay before triggering loading completion notification
		/// </summary>
		public const int CompletionNotification = 500;

		/// <summary>
		/// Delay before final loading complete callback
		/// </summary>
		public const int LoadingComplete = 2000;
	}

	/// <summary>
	/// File management configuration values
	/// </summary>
	public static class FileManagement
	{
		/// <summary>
		/// Maximum number of files to keep in archive before cleanup
		/// </summary>
		public const int MaxArchivedFiles = 100;
	}

	/// <summary>
	/// Device monitoring configuration values
	/// </summary>
	public static class DeviceMonitoring
	{
		/// <summary>
		/// Interval in milliseconds for checking device connection status
		/// </summary>
		public const int StatusCheckInterval = 1000;
	}
}
