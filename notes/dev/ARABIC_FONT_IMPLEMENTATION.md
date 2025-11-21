# Arabic Font Implementation

## Overview

The application uses a custom Arabic font (Al-Mohanad) when the Arabic language (ar-SA) is selected. This document describes the implementation and important considerations.

## Problem: Designer-Generated Fonts Override Custom Fonts

### The Challenge

Windows Forms Designer generates code in `.Designer.cs` files that hardcodes font assignments:

```csharp
statusLabel.Font = new Font("Arial", 16F, FontStyle.Bold);
lblNumReports.Font = new Font("Arial", 14F);
```

These assignments happen in `InitializeComponent()` which is called in the constructor of each form/control. This means:

1. Form/Control constructor runs
2. `InitializeComponent()` runs → **Fonts set to Arial**
3. Custom font application code runs → Fonts changed to Al-Mohanad
4. ✅ This works for forms initialized after app startup

However, for user controls that are initialized as fields:

```csharp
public partial class frmMain : Form
{
    private disconnectedUserControl _disconnectedUserControl = new disconnectedUserControl();
    // ^ This runs BEFORE the frmMain constructor
}
```

The sequence becomes:
1. Field initializers run (user controls created, InitializeComponent called, fonts set to Arial)
2. frmMain constructor runs
3. Custom font application runs
4. ✅ **Solution: Explicitly apply fonts to user controls after main form initialization**

## Implementation

### File Structure

```
src/
├── Helpers/
│   ├── FontHelper.cs              # Loads and manages custom fonts
│   └── LocalizationHelper.cs      # Culture-specific font application
├── frmMain.cs                     # Applies fonts to all controls
├── SettingsForm.cs                # Applies fonts to settings dialog
└── AemulusConnect.csproj          # Configures font files to copy to output

res/
└── fonts/
    └── arfonts-al-mohanad_all/
        ├── al-mohanad.ttf         # Regular (used by default)
        ├── al-mohanad-bold.ttf
        ├── al-mohanad-thick.ttf
        ├── al-mohanad-extra-bold-extra-bold.ttf
        └── al-mohanad-long-kaf.ttf

tools/build/
└── stage-shipping.ps1             # Copies fonts to Shipping folder

src/installer/
└── AemulusConnect.wxs             # Includes fonts in MSI installer
```

### Key Classes

#### FontHelper.cs

Manages loading and applying custom fonts:

```csharp
// Load Al-Mohanad font from disk
FontFamily? AlMohanadFontFamily { get; }

// Apply font to all controls in a form/control tree
void ApplyAlMohanadFontToForm(Control control)

// Reset to default Arial font
void ResetToDefaultFont(Control control)
```

**Important:** Fonts are loaded from the file system at runtime using `PrivateFontCollection.AddFontFile()`. The font path is:
```
{AppDomain.CurrentDomain.BaseDirectory}\res\fonts\arfonts-al-mohanad_all\al-mohanad.ttf
```

#### LocalizationHelper.cs

Determines when to apply culture-specific fonts:

```csharp
// Overloaded for both Form and Control
void ApplyCultureSpecificFont(Form form)
void ApplyCultureSpecificFont(Control control)
```

Logic:
- If culture is "ar-SA" → Apply Al-Mohanad font
- Otherwise → Reset to Arial

### Application Points

#### 1. Main Form (frmMain.cs)

```csharp
public frmMain()
{
    InitializeComponent(); // Designer sets all fonts to Arial

    // Apply RTL layout if Arabic is selected
    LocalizationHelper.ApplyRTLToForm(this);

    // Apply culture-specific fonts to the main form
    LocalizationHelper.ApplyCultureSpecificFont(this);

    // CRITICAL: Apply fonts to user controls that were initialized as fields
    // These were created BEFORE this constructor ran, so we must explicitly
    // override their Designer-generated fonts
    LocalizationHelper.ApplyCultureSpecificFont(_disconnectedUserControl);
    LocalizationHelper.ApplyCultureSpecificFont(_connectedUserControl);
    LocalizationHelper.ApplyCultureSpecificFont(_loadingUserControl);
}
```

#### 2. Settings Form (SettingsForm.cs)

```csharp
public SettingsForm(...)
{
    // ... initialization code ...

    // Apply RTL layout if Arabic is selected
    LocalizationHelper.ApplyRTLToForm(this);

    // Apply culture-specific fonts
    LocalizationHelper.ApplyCultureSpecificFont(this);
}
```

## Build System Integration

### Project File (AemulusConnect.csproj)

```xml
<ItemGroup>
  <Content Include="..\res\fonts\arfonts-al-mohanad_all\*.ttf">
    <Link>res\fonts\arfonts-al-mohanad_all\%(Filename)%(Extension)</Link>
    <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
  </Content>
</ItemGroup>
```

This copies all `.ttf` files to:
```
bin/{Configuration}/{Framework}/res/fonts/arfonts-al-mohanad_all/*.ttf
```

### Staging Script (stage-shipping.ps1)

```powershell
# Copy font resources to bin/res/fonts/
Write-Host "  Copying font resources to bin/res/fonts/..." -NoNewline
$sourceResDir = Join-Path $BuildOutputPath "res"
if (Test-Path $sourceResDir) {
    $destResDir = Join-Path $ShippingBinDir "res"
    Copy-Item -Path $sourceResDir -Destination $destResDir -Recurse -Force

    $fontCount = (Get-ChildItem -Path (Join-Path $destResDir "fonts") -Recurse -Filter "*.ttf").Count
    Write-Host " OK ($fontCount font files)" -ForegroundColor Green
}
```

This copies fonts from build output to:
```
Shipping/bin/res/fonts/arfonts-al-mohanad_all/*.ttf
```

### Installer (AemulusConnect.wxs)

```xml
<!-- Installation directory structure -->
<Directory Id="BINFOLDER" Name="bin">
  <Directory Id="RESFOLDER" Name="res">
    <Directory Id="FONTSFOLDER" Name="fonts">
      <Directory Id="ARABICFONTSFOLDER" Name="arfonts-al-mohanad_all" />
    </Directory>
  </Directory>
</Directory>

<!-- Arabic Font Files -->
<ComponentGroup Id="ArabicFontComponents" Directory="ARABICFONTSFOLDER">
  <Component Id="ArabicFont_AlMohanad" Guid="6f3d0b7f-4c8d-9e6f-3a2b-7c8d9e0f1a2b">
    <File Source="$(var.BuildOutputPath)\bin\res\fonts\arfonts-al-mohanad_all\al-mohanad.ttf" KeyPath="yes" />
    <File Source="$(var.BuildOutputPath)\bin\res\fonts\arfonts-al-mohanad_all\al-mohanad-bold.ttf" />
    <!-- ... other font files ... -->
  </Component>
</ComponentGroup>

<!-- Include in main feature -->
<Feature Id="ProductFeature" ...>
  <ComponentGroupRef Id="ArabicFontComponents" />
  <!-- ... other components ... -->
</Feature>
```

## RTL Content Swapping

### The Challenge

Windows Forms `RightToLeftLayout` mirrors control **positions** but not **content**. For the disconnected screen with steps:

```
LTR:  [Step 1] [Step 2]  (user reads left-to-right: 1, 2)
RTL:  [Step 1] [Step 2]  (positions mirrored, user reads right-to-left: 1, 2) ✅
```

Wait, that's correct! But visually it **looks wrong** because:
- LTR: Step 1 on left, Step 2 on right
- RTL: Step 1 on right, Step 2 on left

The user expects to see step 2 content on the left (because the physical control moved there), but the content didn't swap.

### Solution: Programmatic Content Swapping

In [disconnectedUserControl.cs:13-35](../src/UserControls/disconnectedUserControl.cs), we swap step content for RTL:

```csharp
if (Helpers.LocalizationHelper.IsRightToLeft(CultureInfo.CurrentUICulture.Name))
{
    // Swap step numbers
    var temp = label1.Text;
    label1.Text = label2.Text;
    label2.Text = temp;

    // Swap instruction text
    var tempText = textLabel1.Text;
    textLabel1.Text = textLabel2.Text;
    textLabel2.Text = tempText;

    // Swap the images and their sizes
    // Note: We do NOT swap locations - RightToLeftLayout handles position mirroring automatically
    var tempImage = pictureBox1.Image;
    pictureBox1.Image = pictureBox2.Image;
    pictureBox2.Image = tempImage;

    // Swap the picture box sizes (they're different dimensions)
    var tempSize = pictureBox1.Size;
    pictureBox1.Size = pictureBox2.Size;
    pictureBox2.Size = tempSize;
}
```

**Critical: Only swap content, not positions!**
- **Image**: The actual graphic content (Quest headset vs computer cable) ✅ SWAP
- **Size**: Different aspect ratios (125x97 vs 268x117) - prevents stretching ✅ SWAP
- **Location**: Control positions (84,46 vs 311,46) ❌ **DO NOT SWAP** - `RightToLeftLayout` already handles this automatically

If you swap locations manually, you're undoing the automatic RTL mirroring, causing controls to stay in LTR positions!

Now the complete step content swaps:
- `pictureBox1` (moved to right) shows step 2 image
- `label1` (moved to right) displays "٢" (step 2)
- `textLabel1` (moved to right) shows step 2 instructions
- `pictureBox2` (moved to left) shows step 1 image
- `label2` (moved to left) displays "١" (step 1)
- `textLabel2` (moved to left) shows step 1 instructions
- User reads right-to-left and sees complete step 2, then complete step 1 ✅

## User Experience

1. User installs application → Fonts installed to `Program Files/Aemulus XR/AemulusConnect/bin/res/fonts/arfonts-al-mohanad_all/`
2. User opens Settings → Changes language to Arabic → Saves
3. Application restarts (required for language change)
4. On startup:
   - `LocalizationHelper.SetCulture("ar-SA")` is called
   - Main form initializes
   - Arabic font is applied to all forms and controls
   - RTL layout is applied
   - Step content is swapped for correct RTL reading order
5. All text now appears in Arabic using the Al-Mohanad font with correct RTL layout

## Testing

To test the font switching:

1. Build the application:
   ```powershell
   .\tools\build\build-application.ps1 -Configuration Release
   ```

2. Stage to Shipping:
   ```powershell
   .\tools\build\stage-shipping.ps1 -Configuration Release
   ```

3. Verify fonts were copied:
   ```powershell
   ls src\Shipping\bin\res\fonts\arfonts-al-mohanad_all\
   ```

4. Run from Shipping folder:
   ```powershell
   .\src\Shipping\bin\AemulusConnect.exe
   ```

5. Change language to Arabic in Settings → Restart

6. Verify:
   - All text uses Al-Mohanad font
   - Text is right-to-left
   - UI elements are mirrored

## Troubleshooting

### Fonts Not Applying

If fonts aren't changing when Arabic is selected:

1. **Check font file exists:**
   ```powershell
   Test-Path "$env:ProgramFiles\Aemulus XR\AemulusConnect\bin\res\fonts\arfonts-al-mohanad_all\al-mohanad.ttf"
   ```

2. **Check application logs** for font loading errors:
   - Look for "Failed to load Al-Mohanad font" warnings
   - Check `log4net.config` for log output location

3. **Verify culture is set correctly:**
   - Check `%APPDATA%\AemulusConnect\settings.ini`
   - Should contain `Language=ar-SA`

4. **Designer overrides:**
   - If new forms/controls are added, make sure to call `LocalizationHelper.ApplyCultureSpecificFont()` after initialization
   - See examples in `frmMain.cs` and `SettingsForm.cs`

### Adding New Forms/Controls

When adding new forms or user controls:

```csharp
public class MyNewForm : Form
{
    public MyNewForm()
    {
        InitializeComponent(); // Designer sets fonts

        // Apply RTL if needed
        LocalizationHelper.ApplyRTLToForm(this);

        // Apply culture-specific fonts
        LocalizationHelper.ApplyCultureSpecificFont(this);
    }
}
```

If the form creates user controls as fields, apply fonts to them too:

```csharp
public class MyForm : Form
{
    private MyUserControl _myControl = new MyUserControl();

    public MyForm()
    {
        InitializeComponent();
        LocalizationHelper.ApplyCultureSpecificFont(this);

        // Apply to user control that was initialized before constructor
        LocalizationHelper.ApplyCultureSpecificFont(_myControl);
    }
}
```

## Related Files

- Implementation: `src/Helpers/FontHelper.cs`, `src/Helpers/LocalizationHelper.cs`
- Application: `src/frmMain.cs`, `src/SettingsForm.cs`
- Build: `src/AemulusConnect.csproj`
- Staging: `tools/build/stage-shipping.ps1`
- Installer: `src/installer/AemulusConnect.wxs`
- Fonts: `res/fonts/arfonts-al-mohanad_all/*.ttf`

## Future Enhancements

Potential improvements:

1. **Support for other RTL languages** (Hebrew, Urdu, etc.)
2. **Per-language font configuration** (JSON config file mapping culture → font)
3. **Font variant selection** (bold, thick, etc. based on UI element)
4. **Embedded font resources** (embed in assembly instead of file system)
5. **Font fallback chain** (if Al-Mohanad missing, try another Arabic font)

## Notes

- Language changes require application restart (existing behavior)
- Font loading uses `PrivateFontCollection` to avoid system font installation
- Only the regular weight (`al-mohanad.ttf`) is currently used; bold/thick variants are included but not yet utilized
- Font size and style (bold/italic) from Designer are preserved when switching fonts
