using log4net;
using log4net.Config;
using System.Reflection;

namespace Aemulus_XR_Reporting_App
{
	internal static class Program
	{
		/// <summary>
		///  The main entry point for the application.
		/// </summary>
		private static readonly ILog log = LogManager.GetLogger(typeof(Program));

		[STAThread]
		static void Main()
		{
			// Load persisted settings (if any) before UI starts
			try { Helpers.SettingsManager.LoadSettings(); } catch { }
			var logRepository = LogManager.GetRepository(Assembly.GetEntryAssembly());
			XmlConfigurator.Configure(logRepository, new FileInfo("log4net.config"));

			// To customize application configuration such as set high DPI settings or default font,
			// see https://aka.ms/applicationconfiguration.
			ApplicationConfiguration.Initialize();
			Application.Run(new frmMain());
		}
	}
}