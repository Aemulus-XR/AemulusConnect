using log4net;
using log4net.Config;
using System.Reflection;

namespace AemulusConnect
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
			// Configure logging first
			var assembly = Assembly.GetEntryAssembly() ?? throw new InvalidOperationException("Entry assembly not found");
			var logRepository = LogManager.GetRepository(assembly);
			XmlConfigurator.Configure(logRepository, new FileInfo("log4net.config"));

			// Initialize application configuration
			ApplicationConfiguration.Initialize();

			// Load settings after application is initialized
			try
			{
				log.Debug($"Application.StartupPath before loading settings: {Application.StartupPath}");
				Helpers.SettingsManager.LoadSettings();
				log.Debug($"Application.StartupPath after loading settings: {Application.StartupPath}");
			}
			catch (Exception ex)
			{
				log.Error("Failed to load settings", ex);
			}

			// Apply saved language/culture before creating forms
			try
			{
				Helpers.LocalizationHelper.SetCulture(Helpers.SettingsManager.Language);
				log.Info($"Applied culture: {Helpers.SettingsManager.Language}");
			}
			catch (Exception ex)
			{
				log.Error("Failed to set culture", ex);
			}

			Application.Run(new frmMain());
		}
	}
}