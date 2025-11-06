# AMXR_Report

## Overview
AMXR_Report is a Windows PC application developed in C# for fetching and reporting data from an Oculus Quest device. The application uses the Android Debug Bridge (ADB) to communicate with the Quest device, retrieve reports, and display the status of these operations to the user.

## Key Features
- **Device Detection**: Detects when an Oculus Quest device is connected or disconnected.
- **Report Fetching**: Copies all available reports from the Quest device to the PC.
- **Status Updates**: Provides real-time status updates on the connection and file transfer processes.
- **Error Handling**: Displays error messages and allows the user to retry operations or exit the application.
- **User Interface**: Uses different user controls to display various states of the application (disconnected, connected, loading).

## User Interface Flow
1. **Setup Screen**: Displayed when no Quest device is detected.
2. **Default Screen**: Displayed when a Quest device is detected, showing the app name and a "Fetch Reports" button.
3. **Downloading Screen**: Displayed when the "Fetch Reports" button is clicked, showing a loading bar and status messages.
4. **Default Screen**: Displayed again after reports have been fetched, showing the number of reports found and a "View Reports" button.

## Key Components

### `frmMain` Class
- Manages the main form of the application.
- Handles initialization, user interface updates, and interactions with the `QuestHelper` class.
- Responds to status changes and errors from the `QuestHelper`.

### `QuestHelper` Class
- Manages the ADB server, device status, and file transfer operations.
- Raises events to notify the `frmMain` class of status changes and errors.

### User Controls
- **`disconnectedUserControl`**: Displayed when the Quest device is not connected.
- **`connectedUserControl`**: Displayed when the Quest device is connected. Includes buttons for fetching and viewing reports.
- **`loadingUserControl`**: Displayed during the file transfer process. Shows a progress bar and status messages.

### `loadingUserControl` Class
- Manages the loading screen displayed during file transfers.
- Uses a `BackgroundWorker` to simulate progress and update the progress bar.
- Provides status messages based on the current download status.

## File Structure
- **`frmMain.cs`**: Main form of the application.
- **`QuestHelper.cs`**: Manages ADB server and file transfer operations.
- **`UserControls`**: Contains user controls for different application states.
  - `disconnectedUserControl.cs`
  - `connectedUserControl.cs`
  - `loadingUserControl.cs`
- **`Strings/FSStrings.cs`**: Contains file path strings used in the application.
- **`Program.cs`**: Entry point of the application.

## Technologies Used
- **C# 12.0**
- **.NET 8**
- **Windows Forms**
- **ADB (Android Debug Bridge)**
- **log4net**: For logging

## Usage
1. Run the application.
2. Connect an Oculus Quest device.
3. Click "Fetch Reports" to copy reports from the device to the PC.
4. View the reports by clicking "View Reports".

For more information about the Oculus Quest app, visit the [Aemulus XR site](https://www.aemulus-xr.com/).

# AMXR_Report (Original Project Requirements)
A fetching / reporting app for Aemulus XR
To be developed in C# for Windows PC

For the Oculus Quest App - See Aemulus XR site for info about the full XR app - https://www.aemulus-xr.com/





WireFrame Flow:
![image](https://github.com/user-attachments/assets/58ffbb13-9c46-4103-a34f-2f872b041bcd)


**Screen 1: Setup Screen** 

If no quest is detected (via adb)
![image](https://github.com/user-attachments/assets/a79df923-3869-41fc-9ec5-d561581ce6ef)

* This screen should only stay up until a quest device is detected.
* We're assuming detection == usb debugging allowed, so once detection is possible, this screen should go away and Screen 2 should be visible/active. (if this assumption is wrong, we can re-work this page's requirements / UX as needed)

**Screen 2: Default Screen** 

Once a quest is detected, we show logo and the app name, and the "Fetch reports" button
![image](https://github.com/user-attachments/assets/5c67faad-7fd4-4d07-9bda-940e0ae6c3ab)

**Screen 3: Downloading Screen** 

Once fetch Reports has been clicked, use loading bar to indicate reports are being fetched
![image](https://github.com/user-attachments/assets/6bc33131-ea4d-4017-a858-30b6604ce6ca)

* hide button / buttons whenever loading bar is visible
* even if no files exist in the saved report directory, show loading bar for a default of 1 second (minimum loading bar time is 1 second)
* while loading bar is active, display text below:
* * No Reports found (while app directory doesn't exist or it exists but has no reports)
* * Downloading to PC (while reports found and are downloading)
* * Downloading Complete (if reports existed and were downloaded and the process is complete.)
* * Downloading Failed (Bold and in red, if something went wrong during the download process)
* once loading bar is filled/doanload is complete, wait 2 seconds to return to normal screen

**Screen 4: Default Screen**

Once reports have been fetched, show number of reports found at bottom of page, and make visible the 2nd button, "View Reports"
![image](https://github.com/user-attachments/assets/1dbf733f-6de1-48ca-85ff-6d9c150ec510)



**Buttons:**
Fetch Reports button should always copy all available reports to the PC.

Copy all files from the Quest Aemulus Directory: 

(there should eventually be both PDFs and CSV files with matching names.)

To a folder with the copy date as it's name:
Desktop/AemulusXRReporting/Reports-[YYYY-MM-DD]/

When copying down to desktop, add "_Archived_[YYYY-MM-DD]" to the copied file name.

View Reports button should always open the directory on the PC: Desktop/AemulusXRReporting/


