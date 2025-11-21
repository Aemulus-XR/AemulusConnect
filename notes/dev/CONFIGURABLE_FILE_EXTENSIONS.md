# Configurable File Extensions

## Overview

File extensions for download and archiving are now configurable via the `settings.ini` file. This addresses the code review finding about hard-coded `.pdf` and `.csv` extensions.

## Configuration

### Location

`%APPDATA%\AemulusConnect\settings.ini`

Example: `C:\Users\YourName\AppData\Roaming\AemulusConnect\settings.ini`

### Setting

```ini
# File Filtering
# Comma-separated list of file extensions to download and archive (default: .pdf,.csv)
# Extensions should include the dot (e.g., .pdf,.csv,.txt)
FileExtensions=.pdf,.csv
```

### Examples

**Download only PDF files:**
```ini
FileExtensions=.pdf
```

**Download PDF, CSV, and TXT files:**
```ini
FileExtensions=.pdf,.csv,.txt
```

**Download JSON and XML files:**
```ini
FileExtensions=.json,.xml
```

**Download all files (leave empty or omit):**
```ini
FileExtensions=
```

## Implementation Details

### Code Changes

#### 1. SettingsManager.cs

**New Property:**
```csharp
/// <summary>
/// Comma-separated list of file extensions to look for, download, and archive.
/// Defaults to ".pdf,.csv".
/// Extensions should include the dot (e.g., ".pdf,.csv,.txt").
/// </summary>
public static string FileExtensions { get; set; } = ".pdf,.csv";
```

**Helper Method:**
```csharp
/// <summary>
/// Gets the configured file extensions as a list of strings.
/// Returns empty list if FileExtensions is null or empty.
/// </summary>
public static List<string> GetFileExtensionsList()
{
    if (string.IsNullOrWhiteSpace(FileExtensions))
        return new List<string>();

    return FileExtensions
        .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
        .Select(ext => ext.Trim().ToLowerInvariant())
        .Where(ext => !string.IsNullOrWhiteSpace(ext))
        .ToList();
}
```

**LoadSettings:** Parses `FileExtensions` from INI file
**SaveSettings:** Persists `FileExtensions` to INI file with comments

#### 2. QuestHelper.cs

**retrieveFileNames() - File Filtering:**
```csharp
var extensions = SettingsManager.GetFileExtensionsList();
var remoteFiles = output
    .Split(new[] { '\n' }, StringSplitOptions.RemoveEmptyEntries)
    .Select(s => Regex.Replace(s, @"\t|\r", "").Trim())
    .Where(s => !string.IsNullOrWhiteSpace(s))
    // skip entries marked as directories by ls -F (ending with '/')
    .Where(s => !s.EndsWith("/"))
    // Filter by configured file extensions (if any)
    .Where(s =>
    {
        if (extensions.Count == 0)
            return true; // No extensions configured, include all files
        return extensions.Any(ext => s.EndsWith(ext, StringComparison.OrdinalIgnoreCase));
    })
    .ToList();
```

**transferAndRenameFile() - Archive Naming:**
```csharp
var savedFileName = newFileName;
// Replace extension with archived version for any configured extension
var extensions = SettingsManager.GetFileExtensionsList();
foreach (var ext in extensions)
{
    if (savedFileName.Contains(ext, StringComparison.OrdinalIgnoreCase))
    {
        var position = savedFileName.LastIndexOf(ext, StringComparison.OrdinalIgnoreCase);
        if (position >= 0)
        {
            savedFileName = savedFileName.Substring(0, position) + $"_Archived_{date}" + ext;
            break;
        }
    }
}
```

## Behavior

### File Discovery

When the application lists files on the Quest device:
1. Retrieves all files from the configured reports path
2. Filters out directories (marked with `/` by `ls -F`)
3. **Filters by configured file extensions** (case-insensitive)
4. Returns matching files for download

### Archive Naming

When files are archived on the device:
1. Original: `report.pdf` → Archived: `report_Archived_2025-01-21.pdf`
2. Original: `data.csv` → Archived: `data_Archived_2025-01-21.csv`
3. Original: `log.txt` → Archived: `log_Archived_2025-01-21.txt`

The archive suffix is inserted before the extension for any configured file type.

### Empty Configuration

If `FileExtensions` is empty or not specified:
- **File listing:** Returns ALL files (no filtering by extension)
- **Archive naming:** Files are transferred but not renamed with archive suffix

## Use Cases

### XR Development Reports

Default configuration for Quest XR development reports:
```ini
FileExtensions=.pdf,.csv
```

### Custom Telemetry Files

For custom telemetry or logging formats:
```ini
FileExtensions=.json,.log,.txt
```

### Media Files

For screenshots or recordings:
```ini
FileExtensions=.png,.jpg,.mp4
```

### Debug All Files

To download everything regardless of extension:
```ini
FileExtensions=
```
Or simply omit the line from settings.ini.

## Migration

### Upgrading from Pre-2.5.2

Existing installations will continue to work with the default `.pdf,.csv` extensions. The setting is automatically added to `settings.ini` when the application saves settings (e.g., after changing language or paths).

### Manual Configuration

1. Run the application once to generate `settings.ini`
2. Close the application
3. Edit `%APPDATA%\AemulusConnect\settings.ini`
4. Add or modify the `FileExtensions` line
5. Restart the application

The new configuration will take effect immediately.

## Testing

### Test Scenarios

1. **Default behavior:** Leave `FileExtensions=.pdf,.csv` and verify only PDF/CSV files are listed
2. **Single extension:** Set `FileExtensions=.pdf` and verify only PDFs are listed
3. **Multiple extensions:** Set `FileExtensions=.pdf,.csv,.txt` and verify all three types are listed
4. **Empty extensions:** Set `FileExtensions=` and verify all files are listed
5. **Case insensitivity:** Files with `.PDF`, `.Pdf`, `.pdf` should all match
6. **Archive naming:** Verify archived files get the correct `_Archived_YYYY-MM-DD` suffix before extension

### Example Test

1. Create test files on Quest:
   ```bash
   adb shell touch /sdcard/Android/data/com.example.app/files/test.pdf
   adb shell touch /sdcard/Android/data/com.example.app/files/test.csv
   adb shell touch /sdcard/Android/data/com.example.app/files/test.txt
   adb shell touch /sdcard/Android/data/com.example.app/files/test.json
   ```

2. Set `FileExtensions=.pdf,.txt`

3. Run application → Should see only `test.pdf` and `test.txt` in the reports count

4. Transfer files → Should download only those two files

5. Check archive folder → Files should be renamed with `_Archived_` suffix

## Related Files

- Implementation: [SettingsManager.cs](../src/Helpers/SettingsManager.cs)
- File filtering: [QuestHelper.cs:299-313](../src/Helpers/QuestHelper.cs)
- Archive naming: [QuestHelper.cs:356-370](../src/Helpers/QuestHelper.cs)
- Code review reference: [CodeReview.md:341](CodeReview.md)

## Future Enhancements

Potential improvements:

1. **UI Configuration** - Add file extension setting to SettingsForm instead of manual INI editing
2. **Regex Patterns** - Support wildcards or regex patterns (e.g., `report_*.pdf`)
3. **Exclusions** - Support exclude patterns (e.g., `!*.tmp` to skip temp files)
4. **File Size Limits** - Skip files over a certain size
5. **Date Filtering** - Only download files modified after a certain date
6. **Content-Type Detection** - Validate files match their extension (e.g., actual PDF content)

## Notes

- Extension matching is **case-insensitive** (`.PDF` = `.pdf`)
- Extensions are trimmed and normalized to lowercase internally
- The dot (`.`) is required in the configuration
- Empty or whitespace-only extensions are ignored
- Invalid configurations fall back to default (`.pdf,.csv`)
- The setting persists across application restarts
