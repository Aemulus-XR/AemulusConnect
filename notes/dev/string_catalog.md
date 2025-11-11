# Localization String Catalog

**Project:** AemulusConnect
**Created:** 2025-11-11
**Purpose:** Complete inventory of all user-facing strings requiring localization

---

## String Inventory Summary

| Category | Count | Status |
|----------|-------|--------|
| Main Form | 4 | Cataloged |
| Connected User Control | 6 | Cataloged |
| Disconnected User Control | 4 | Cataloged |
| Loading User Control | 5 | Cataloged |
| Settings Form | 10 | Cataloged |
| **Total** | **29** | **Ready for Phase 1.2** |

---

## 1. Main Form (frmMain)

### 1.1 Window Title & Version Display

| String Key | English Text | Context | Parameters | Location |
|------------|--------------|---------|------------|----------|
| `MainForm_Title` | `AemulusXR Report` | Main window title bar (Designer) | None | frmMain.Designer.cs:76 |
| `MainForm_WindowTitleWithVersion` | `AemulusConnect v{0}` | Main window title bar (runtime) | {0} = version string | frmMain.cs:28 |
| `MainForm_VersionLabel` | `Version {0}` | Version label in bottom-right corner | {0} = version string | frmMain.cs:27 |
| `MainForm_VersionPrefix` | `Version` | Static "Version" label (Designer default) | None | frmMain.Designer.cs:58 |

**Notes:**
- `MainForm_Title` is set in Designer but gets overwritten at runtime by `MainForm_WindowTitleWithVersion`
- Consider using only `MainForm_WindowTitleWithVersion` to avoid duplication
- Version format: "1.2.3" (semantic versioning)

### 1.2 Error Dialogs

| String Key | English Text | Context | Parameters | Location |
|------------|--------------|---------|------------|----------|
| `Error_GenericMessage` | `An error was encountered running the program. The information is as follows:` | Error message prefix in MessageBox | None | frmMain.cs:83 |
| `Error_RetryDialogTitle` | `Would you like to try again?` | MessageBox title for error retry prompt | None | frmMain.cs:84 |

**Notes:**
- Error dialog format: `{Error_GenericMessage} {e.Message}`
- MessageBox has Yes/No buttons (not localizable - WinForms standard)
- "Yes" retries ADB initialization, "No" exits application

---

## 2. Connected User Control (connectedUserControl)

### 2.1 Labels & Status

| String Key | English Text | Context | Parameters | Location |
|------------|--------------|---------|------------|----------|
| `Connected_StatusLabel` | `AemulusXR Report` | Brand/status label at top of control | None | connectedUserControl.Designer.cs:66 |
| `Connected_ReportCountLabel` | `{0} Reports fetched` | Dynamic label showing number of reports | {0} = integer count | connectedUserControl.cs:48 |

**Notes:**
- Status label appears in both connected and loading states
- Report count is dynamically updated after fetch operation
- Example: "5 Reports fetched", "1 Reports fetched" (may need plural handling in some languages)

### 2.2 Buttons

| String Key | English Text | Context | Parameters | Location |
|------------|--------------|---------|------------|----------|
| `Connected_FetchButton` | `Fetch Reports` | Primary action button to download reports from Quest | None | connectedUserControl.Designer.cs:101 |
| `Connected_ViewButton` | `View Reports` | Button to open file explorer to reports folder | None | connectedUserControl.Designer.cs:123 |
| `Connected_SettingsButton` | `Settings` | Button to open settings dialog (created at runtime) | None | connectedUserControl.cs:22 |

**Notes:**
- Fetch button triggers download/transfer operation
- View button only enabled when reports exist and output folder is valid
- Settings button is dynamically created (not in Designer)

### 2.3 Dialogs

| String Key | English Text | Context | Parameters | Location |
|------------|--------------|---------|------------|----------|
| `Dialog_FolderBrowserDescription` | `Select local output folder` | FolderBrowserDialog description text | None | connectedUserControl.cs:38 (via SettingsForm) |

**Notes:**
- Shared with SettingsForm (same string used in both contexts)
- Appears when user clicks Browse button

---

## 3. Disconnected User Control (disconnectedUserControl)

### 3.1 Step Numbers

| String Key | English Text | Context | Parameters | Location |
|------------|--------------|---------|------------|----------|
| `Disconnected_StepNumber1` | `1` | Step number label | None | disconnectedUserControl.Designer.cs:51 |
| `Disconnected_StepNumber2` | `2` | Step number label | None | disconnectedUserControl.Designer.cs:61 |

**Notes:**
- Numeric step indicators (likely don't need localization, but including for completeness)
- Consider whether to keep as numbers or translate (e.g., French "1ère étape")
- **Recommendation:** Keep as Arabic numerals (1, 2) in all languages for simplicity

### 3.2 Instructions

| String Key | English Text | Context | Parameters | Location |
|------------|--------------|---------|------------|----------|
| `Disconnected_Instruction1` | `Make sure the quest device is plugged into the PC with a USB-C cable` | First setup instruction | None | disconnectedUserControl.Designer.cs:74 |
| `Disconnected_Instruction2` | `Check in-headset for a prompt to trust the PC - check the always allow this computer and click OK` | Second setup instruction | None | disconnectedUserControl.Designer.cs:87 |

**Notes:**
- Critical setup instructions for users
- Must be clear and accurate in all languages
- "USB-C" is a technical term (keep as-is in most languages)
- "in-headset" refers to VR headset display
- Instructions wrap to multiple lines (MaximumSize constraints in Designer)

---

## 4. Loading User Control (loadingUserControl)

### 4.1 Status Label

| String Key | English Text | Context | Parameters | Location |
|------------|--------------|---------|------------|----------|
| `Loading_StatusLabel` | `AemulusXR Report` | Brand/status label (same as connected state) | None | loadingUserControl.Designer.cs:88 |

**Notes:**
- Same text as `Connected_StatusLabel`
- **Recommendation:** Use shared key `Common_AppTitle` or similar

### 4.2 Download Status Messages

| String Key | English Text | Context | Parameters | Location |
|------------|--------------|---------|------------|----------|
| `Loading_StatusNoReports` | `No Reports Found` | Displayed when no reports exist on device | None | loadingUserControl.cs:59 |
| `Loading_StatusDownloading` | `Downloading to PC` | Displayed during active download | None | loadingUserControl.cs:63 |
| `Loading_StatusComplete` | `Downloading Complete` | Displayed when download finishes successfully | None | loadingUserControl.cs:67 |
| `Loading_StatusFailed` | `Downloading Failed` | Displayed when download encounters error | None | loadingUserControl.cs:71 |

**Notes:**
- Mapped from `DownloadStatus` enum values
- Failed status displays in red and bold (ForeColor/Font changed)
- Status changes are driven by QuestHelper events
- These are mutually exclusive states

**Enum Mapping:**
```csharp
DownloadStatus.NoReports → Loading_StatusNoReports
DownloadStatus.Downloading → Loading_StatusDownloading
DownloadStatus.DownloadingComplete → Loading_StatusComplete
DownloadStatus.DownloadFailed → Loading_StatusFailed
```

---

## 5. Settings Form (SettingsForm)

### 5.1 Window & Labels

| String Key | English Text | Context | Parameters | Location |
|------------|--------------|---------|------------|----------|
| `Settings_WindowTitle` | `Settings` | Settings form window title | None | SettingsForm.cs:20 |
| `Settings_ReportsPathLabel` | `Reports remote path:` | Label for reports path textbox | None | SettingsForm.cs:24 |
| `Settings_ArchivePathLabel` | `Archive remote path:` | Label for archive path textbox | None | SettingsForm.cs:27 |
| `Settings_OutputPathLabel` | `Local output folder:` | Label for output folder textbox | None | SettingsForm.cs:30 |

**Notes:**
- Form is modal dialog (ShowDialog)
- Labels include trailing colon (may differ in some languages)
- "Remote path" refers to Quest device file paths
- "Local output folder" is PC destination

### 5.2 Buttons & Dialogs

| String Key | English Text | Context | Parameters | Location |
|------------|--------------|---------|------------|----------|
| `Settings_BrowseButton` | `Browse...` | Button to open folder browser dialog | None | SettingsForm.cs:34 |
| `Settings_SaveButton` | `Save` | Button to save settings and close dialog | None | SettingsForm.cs:44 |
| `Settings_CancelButton` | `Cancel` | Button to close dialog without saving | None | SettingsForm.cs:45 |
| `Settings_FolderBrowserDescription` | `Select local output folder` | FolderBrowserDialog description | None | SettingsForm.cs:38 |

**Notes:**
- Browse button opens standard Windows FolderBrowserDialog
- Save button persists changes to SettingsManager JSON file
- Cancel button discards changes
- FolderBrowserDescription same as in connectedUserControl

### 5.3 Future Additions (Phase 1.4)

| String Key | English Text | Context | Parameters | Location |
|------------|--------------|---------|------------|----------|
| `Settings_LanguageLabel` | `Language:` | Label for language dropdown (to be added) | None | TBD - Phase 1.4 |
| `Settings_RestartMessage` | `Language will change after restarting the application.` | MessageBox notification after language change | None | TBD - Phase 1.4 |
| `Settings_RestartTitle` | `Restart Required` | MessageBox title for restart notification | None | TBD - Phase 1.4 |

**Notes:**
- These strings will be added in Phase 1.4 when implementing language selector UI
- Marked as "TBD" for now

---

## 6. Shared/Common Strings

These strings appear in multiple locations and should be consolidated:

| String Key | English Text | Used In | Locations |
|------------|--------------|---------|-----------|
| `Common_AppTitle` | `AemulusXR Report` | connectedUserControl, loadingUserControl, frmMain | Multiple |
| `Common_FolderBrowserDescription` | `Select local output folder` | SettingsForm, connectedUserControl | Multiple |

**Recommendation:** Create "Common" category in Resources.resx for shared strings

---

## 7. Special Considerations for Translation

### 7.1 Technical Terms to Preserve

The following technical terms should likely remain in English (or use standard localized equivalents):

- **USB-C** - Standard connector type
- **PC** - Personal Computer (widely understood)
- **AemulusXR** - Brand name (DO NOT TRANSLATE)
- **Quest** - Meta Quest device name (DO NOT TRANSLATE unless officially localized by Meta)
- **ADB** - Android Debug Bridge (not user-facing, internal only)

### 7.2 Parameter Formatting

Strings with parameters use C# string formatting:

| Format | Example | Notes |
|--------|---------|-------|
| `{0}` | `Version {0}` | Single parameter (version number) |
| `{0}` | `{0} Reports fetched` | Single parameter (count) |
| `{0}` | `AemulusConnect v{0}` | Single parameter (version) |

**Translation Note:** Ensure placeholders `{0}` are preserved in translations and positioned correctly for target language syntax.

### 7.3 Pluralization Challenges

The string `{0} Reports fetched` has a pluralization issue:
- English: "1 Reports fetched" (grammatically incorrect, should be "1 Report fetched")
- French: Would need "1 Rapport récupéré" vs "5 Rapports récupérés"
- Arabic: Has dual and plural forms

**Current Issue:** No plural logic exists
**Recommendation:**
- Add conditional logic for count == 1 vs count != 1
- Create separate resource keys:
  - `Connected_ReportCountSingular` = `{0} Report fetched`
  - `Connected_ReportCountPlural` = `{0} Reports fetched`

### 7.4 Text Length Considerations

Controls with potential text overflow concerns:

| Control | Max Width | Current Text Length | Risk Level |
|---------|-----------|-------------------|------------|
| `btnTransfer` | Auto-size | "Fetch Reports" (13 chars) | Medium |
| `btnViewReports` | Auto-size | "View Reports" (12 chars) | Low |
| `btnSettings` | Auto-size | "Settings" (8 chars) | Low |
| `textLabel1` | 268px | "Make sure the quest..." (68 chars) | High |
| `textLabel2` | 292px | "Check in-headset..." (98 chars) | High |
| `lblDownloadStatus` | 300px min | Longest: "Downloading Complete" (20 chars) | Medium |

**French Text Expansion Expected:** +20-30%
**Arabic:** Generally comparable or shorter than English

### 7.5 RTL (Right-to-Left) Considerations for Arabic

Forms and controls that will need RTL mirroring:
- ✅ frmMain (entire form)
- ✅ connectedUserControl (buttons, labels)
- ✅ disconnectedUserControl (step numbers, instructions)
- ✅ loadingUserControl (status label, progress bar)
- ✅ SettingsForm (labels, textboxes, buttons)

**Note:** WinForms provides built-in RTL support via `RightToLeft` and `RightToLeftLayout` properties. Interestingly, frmMain.Designer.cs:74 already has `RightToLeft = RightToLeft.Yes` set, which may have been accidental or for testing.

---

## 8. Localization Priority Tiers

### Tier 1: Critical User-Facing Strings (Must Translate First)
- All button text
- All instruction text (disconnected state)
- Error messages
- Status messages
- Window titles

### Tier 2: Secondary UI Elements
- Labels and static text
- Dialog descriptions
- Version display

### Tier 3: Low Priority
- Step numbers (recommend keeping as numerals)
- Technical logging messages (not user-facing)

---

## 9. Resource File Key Naming Strategy

**Adopted Convention:** `{Component}_{ElementType}_{Purpose}`

### Examples:
- `MainForm_Title` - Main form window title
- `MainForm_VersionLabel` - Version label text
- `Connected_FetchButton` - Fetch button in connected state
- `Loading_StatusDownloading` - Downloading status message
- `Settings_SaveButton` - Save button text
- `Error_GenericMessage` - Generic error message
- `Common_AppTitle` - Shared app title

**Benefits:**
- Easy to find related strings
- Clear context from key name
- Alphabetically grouped by component
- Scalable for future additions

---

## 10. Next Steps (Phase 1.2)

1. ✅ String catalog completed (29 strings identified)
2. ⏭️ Open `src/Properties/Resources.resx` in Visual Studio
3. ⏭️ Add all 29 strings with keys as defined above
4. ⏭️ Verify `Resources.Designer.cs` auto-generates correctly
5. ⏭️ Proceed to Phase 2: String Migration

---

## 11. Translation Notes for Translators

### Context Glossary

| Term | Meaning | Translation Notes |
|------|---------|------------------|
| Quest | Meta Quest VR headset device | Check if Meta has official localized name |
| Fetch | Download/retrieve | Choose appropriate verb for "download from device" |
| Reports | Data/log files generated by the application | Technical term - may need context |
| Remote path | File path on the Quest device | "Remote" as in "on the device" not "on the cloud" |
| Local output folder | Destination folder on the PC | "Local" as in "on this computer" |
| In-headset | Inside the VR headset display | VR-specific term |
| Trust the PC | Allow USB debugging | Technical security concept |

---

*Document created: 2025-11-11 during Phase 1.1 audit*
*Total strings identified: 29*
*Status: Ready for Phase 1.2*
