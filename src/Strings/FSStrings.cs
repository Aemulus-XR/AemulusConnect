namespace Aemulus_XR_Reporting_App.Strings
{
	public static class FSStrings
	{
		// Changed to the device Documents folder where headset files were found via USB/MTP
		// This maps to /storage/emulated/0/Documents/ on the device
		public static string ReportsLocation = "sdcard\\Documents\\";
		// Keep archive in a Documents/Archive subfolder so fetched reports are moved out of the main Documents listing
		public static string ArchiveLocation = "sdcard\\Documents\\Archive\\";
		public static string OutputLocation = Environment.GetFolderPath(Environment.SpecialFolder.Desktop) + "\\AemulusXRReporting\\";
		public static string ADBEXELocation = $"{Application.StartupPath}platform-tools\\adb.exe";
	}
}
