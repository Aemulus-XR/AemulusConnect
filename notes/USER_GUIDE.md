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
   - Click Install

4. **Launch AemulusConnect** from the Start Menu or desktop shortcut

> **Note**: If you don't have .NET 8 Desktop Runtime installed, the installer will direct you to download it from Microsoft.

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

- **Reports Location** - Where to find reports on your Quest (default: `sdcard\Documents\`)
- **Archive Location** - Where to store archived files on Quest (default: `sdcard\Documents\Archive\`)
- **Output Location** - Where to save reports on your PC (default: `Desktop\AemulusConnect\`)

> **Tip**: Most users don't need to change these settings. Only modify if you have a custom setup.

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

Current version documentation: **2.0.1**

---

For developer documentation, build instructions, and contribution guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).
