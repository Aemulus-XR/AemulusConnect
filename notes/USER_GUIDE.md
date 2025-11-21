# AemulusConnect User Guide

## What is AemulusConnect?

AemulusConnect is a Windows application that helps you transfer report files from your Oculus Quest VR headset to your PC. It uses a secure connection (Android Debug Bridge) to automatically detect your Quest device, download your reports, and organize them on your computer.

## System Requirements

- **Operating System**: Windows 10 (Build 26100+) or Windows 11
- **Required Software**: .NET 8 Desktop Runtime (installer will prompt if needed)
- **Hardware**: USB cable to connect your Quest device
- **Quest Device**: Oculus Quest or Quest 2 with USB debugging enabled

## Installation

1. **Download** the latest `AemulusConnect.msi` installer from the [Releases page](https://github.com/Aemulus-XR/AemulusConnect/releases)

2. **Run the installer** by double-clicking the downloaded `.msi` file

3. **Follow the installation wizard**:
   - Accept the license agreement
   - Choose your installation location (default recommended)
   - Optionally select "Create desktop shortcut"
   - Optionally select "Utility Scripts" (data conversion and validation tools for advanced users)
   - Click Install

4. **Launch AemulusConnect** from the Start Menu or desktop shortcut

> **Note**: If you don't have .NET 8 Desktop Runtime installed, the installer will direct you to download it from Microsoft.
>
> **Utility Scripts**: If you selected this option during installation, you'll find PowerShell and Bash scripts in the `utilities` folder within your installation directory. These scripts help with data conversion (JSON to CSV) and validation. See the README.md in that folder for details.

## First Time Setup

### Enable USB Debugging on Your Quest

Before using AemulusConnect, you need to enable USB debugging on your Quest device:

1. Put on your Quest headset
2. Go to **Settings** → **System** → **Developer**
3. Enable **USB Debugging**
4. Connect your Quest to your PC with a USB cable
5. You'll see a prompt in the headset asking to "Allow USB Debugging"
6. Check "Always allow from this computer" and tap **OK**

## Using AemulusConnect

### Basic Workflow
![](../assets/media/Pasted%20image%2020251107084934.png)

1. **Connect Your Quest**
   - Plug your Quest device into your PC using a USB cable
   - AemulusConnect will automatically detect the connection
   - The main interface will appear when the device is ready

2. **Fetch Reports**
   - Click the **"Fetch Reports"** button
   - The application will copy all report files from your Quest
   - A progress indicator shows the transfer status
   - Files are saved to: `Desktop\AemulusConnect\`

3. **View Reports**
   - After fetching, click **"View Reports"** to open the folder
   - Reports are organized by date and type (PDF and CSV files)
   - Original files are archived on your Quest device for safekeeping

### Application States

**Setup Screen (No Device Detected)**
![](../assets/media/Pasted%20image%2020251107084951.png)

- Shows connection instructions
- Guides you through USB debugging setup
- Automatically disappears when Quest is detected

**Ready Screen (Device Connected)**
![](../assets/media/Pasted%20image%2020251107085147.png)

- Shows the AemulusConnect logo
- Displays "Fetch Reports" button
- Shows count of previously fetched reports (if any)

**Transfer Screen (Downloading)**

![](../assets/media/Pasted%20image%2020251107085159.png)

- Displays progress bar
- Shows current status:
  - "No Reports Found" - No files to download
  - "Downloading to PC" - Transfer in progress
  - "Downloading Complete" - Successfully downloaded
  - "Downloading Failed" - Error occurred (see troubleshooting)

**Default Screen (Fetch/View)**

![](../assets/media/Pasted%20image%2020251107085211.png)
- Once reports have been fetched, show number of reports found at bottom of page, and make visible the 2nd button, "View Reports"

## File Organization

Reports are saved to your desktop in the following structure:

```
Desktop\
└── AemulusConnect\
    ├── Report-files-2025-01-15.pdf
    ├── Report-files-2025-01-15.csv
    ├── Report-files-2025-01-14.pdf
    └── Report-files-2025-01-14.csv
```

On your Quest device, fetched files are moved to:
```
sdcard\Documents\Archive\
```

> **Note**: The Quest archive automatically maintains the most recent 100 files to save storage space.

## Troubleshooting

### Quest Device Not Detected

**Problem**: The setup screen doesn't disappear after connecting Quest

**Solutions**:
1. Check your USB cable is properly connected
2. Verify USB debugging is enabled on Quest (see [First Time Setup](#first-time-setup))
3. Try a different USB port on your PC
4. Restart the AemulusConnect application
5. Unplug and reconnect your Quest device

### "Allow USB Debugging" Prompt Keeps Appearing

**Problem**: Quest repeatedly asks for USB debugging permission

**Solution**:
- Make sure to check "Always allow from this computer" before tapping OK
- If the problem persists, go to Quest Settings → Developer → "Revoke USB Debugging Authorizations", then reconnect and authorize again

### Download Failed Error

**Problem**: Reports fail to download

**Solutions**:
1. Ensure your Quest has files in `sdcard\Documents\` folder
2. Check that you have enough free space on your desktop
3. Verify your Quest is still connected (check USB connection)
4. Try restarting both AemulusConnect and your Quest device
5. Check the application logs (see [Log Files](#log-files))

### .NET Runtime Not Found

**Problem**: Application won't launch, error about missing .NET

**Solution**:
- Download and install .NET 8 Desktop Runtime from: https://dotnet.microsoft.com/download/dotnet/8.0
- Select "Run desktop apps" → "Download x64"
- After installation, restart AemulusConnect

### Application Crashes or Freezes

**Solutions**:
1. Close and restart AemulusConnect
2. Disconnect and reconnect your Quest device
3. Check Task Manager and close any stuck "AemulusConnect.exe" processes
4. Restart your computer if problems persist
5. Review log files for error details (see below)

## Log Files

AemulusConnect creates log files to help diagnose issues:

**Location**: Same directory as the application executable
**File**: `AemulusConnect.log`

If you need help troubleshooting:
1. Locate the log file
2. Open it with Notepad or any text editor
3. Look for entries marked "ERROR" or "WARN"
4. Include relevant log excerpts when reporting issues

## Settings

Click the gear icon (⚙️) in the top-right corner to customize:

- **Language** - Choose your preferred language (English, Arabic, German, Spanish, French, or Pirate)
- **Output Location** - Where to save reports on your PC (default: `Desktop\AemulusConnect\`)
- **Max Archived Files** - Maximum number of files to keep in Quest archive before automatic cleanup (default: 100)
  - Range: 10-1000 files
  - **Lower values** (10-50): Good for devices with limited storage
  - **Higher values** (200-1000): Keep more history for power users
  - Cleanup happens automatically when limit is exceeded, removing oldest files first
- **Device Check Interval** - How often to check for Quest device connection, in milliseconds (default: 1000)
  - Range: 100-10000 ms
  - **Lower values** (100-500): Faster device detection, uses more CPU
  - **Recommended**: 1000 (1 second - good balance)
  - **Higher values** (2000-10000): May help with flaky USB connections or reduce CPU usage

> **Note**: Changes to Max Archived Files and Device Check Interval require restarting AemulusConnect to take effect.

### Advanced Settings (settings.ini)

Advanced users can manually edit the `settings.ini` file for additional control:

**Location**: `%APPDATA%\AemulusConnect\settings.ini`
(Typically: `C:\Users\YourUsername\AppData\Roaming\AemulusConnect\settings.ini`)

**Available Settings**:

#### Quest Device Paths
These settings control where files are stored on your Quest device and cannot be changed through the UI:
- `ReportsLocation` - Where reports are initially saved (default: `sdcard\Documents\`)
- `ArchiveLocation` - Where archived reports are moved (default: `sdcard\Documents\Archive\`)

> **⚠️ Warning**: Only modify these paths if you know what you're doing. Incorrect paths will prevent the app from finding your reports.

### File Filtering
- Comma-separated list of file extensions to download and archive (default: .pdf,.csv)
- Extensions should include the dot (e.g., .pdf,.csv,.txt)
FileExtensions=.pdf,.csv

**Example settings.ini**:
```ini
# AemulusConnect settings
Language=en
ReportsLocation=sdcard\Documents\
ArchiveLocation=sdcard\Documents\Archive\
OutputLocation=Desktop\AemulusConnect\

# File Management
# Maximum number of files to keep in archive before cleanup (default: 100)
MaxArchivedFiles=100

# Device Monitoring
# Device status check interval in milliseconds (default: 1000, minimum: 100)
StatusCheckIntervalMs=1000

# File Extensions to transfer (default: .pdf,.csv)
FileExtensions=.pdf,.csv
```

> **⚠️ Note**: Changes to `settings.ini` require restarting AemulusConnect to take effect. Invalid values will be ignored and defaults will be used instead.

## Uninstalling

To remove AemulusConnect:

1. Open Windows **Settings** → **Apps** → **Installed apps**
2. Find "AemulusConnect" in the list
3. Click the three dots (...) → **Uninstall**
4. Follow the uninstall wizard

Or use the Start Menu shortcut:
- **Start Menu** → **AemulusConnect** → **Uninstall AemulusConnect**

## Support and Feedback

- **Report Issues**: [GitHub Issues](https://github.com/Aemulus-XR/AemulusConnect/issues)
- **Feature Requests**: [Request a Feature](https://github.com/Aemulus-XR/AemulusConnect/issues/new?template=feature_request.md)
- **Questions**: Visit our [Discord community](https://discord.gg/gQH4mXWQRT)
- **Aemulus XR Website**: https://www.aemulus-xr.com/

## Privacy and Data

- AemulusConnect only accesses the specific report folders on your Quest device
- No data is sent to external servers
- All file transfers happen directly between your Quest and your PC
- Reports are stored locally on your computer only

## Version Information

Check your installed version:
- **Start Menu** → **AemulusConnect** → **About**
- Or check the title bar of the application window

Current version documentation: **2.5.2**

---

For developer documentation, build instructions, and contribution guidelines, see [CONTRIBUTING.md](dev/CONTRIBUTING.md).
