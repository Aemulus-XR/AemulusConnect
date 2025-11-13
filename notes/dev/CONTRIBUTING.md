# Contributing to AemulusConnect

First off, thank you for considering contributing to AemulusConnect! Whether you're fixing bugs, adding features, improving documentation, or helping with testing, your contributions make this project better for everyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Architecture](#project-architecture)
- [Building the Project](#building-the-project)
- [How to Contribute](#how-to-contribute)
  - [Contributing Translations](#contributing-translations)
- [Crowdin Setup](#crowdin-setup)
- [Coding Guidelines](#coding-guidelines)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Windows 10/11** (or Windows Server 2019+)
- **.NET 8 SDK**: https://dotnet.microsoft.com/download/dotnet/8.0
- **WiX Toolset v4+**: `dotnet tool install --global wix`
- **Git**: https://git-scm.com/downloads
- **Visual Studio 2022** or **VS Code** (recommended)
- **PowerShell 5.1+** or **PowerShell Core 7+**

### Setting Up Your Development Environment

1. **Fork the repository** on GitHub

2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/AemulusConnect.git
   cd AemulusConnect
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/Aemulus-XR/AemulusConnect.git
   ```

4. **Verify prerequisites**:
   ```powershell
   cd tools
   .\verify_prerequisites.ps1
   ```

5. **Open in Visual Studio**:
   - Open `src/AemulusConnect.sln`
   - Restore NuGet packages
   - Build the solution (Ctrl+Shift+B)

## Development Setup

### Project Structure

```
AemulusConnect/
├── src/                              # Application source code
│   ├── Enums/                        # Application state enumerations
│   │   ├── QuestStatus.cs            # Device connection states
│   │   └── DownloadStatus.cs         # File transfer states
│   ├── Helpers/                      # Core business logic
│   │   ├── QuestHelper.cs            # ADB operations & file transfers
│   │   └── SettingsManager.cs        # Configuration persistence
│   ├── Properties/                   # Assembly resources
│   ├── Resources/                    # Image assets
│   ├── Strings/                      # Configuration strings
│   │   └── FSStrings.cs              # File paths and constants
│   ├── UserControls/                 # UI state screens
│   │   ├── disconnectedUserControl.cs     # Setup/disconnected state
│   │   ├── connectedUserControl.cs        # Ready/connected state
│   │   └── loadingUserControl.cs          # Transfer progress state
│   ├── VisualElements/               # Custom UI controls
│   │   ├── CustomProgressBar.cs      # Custom progress bar
│   │   └── RoundedButton.cs          # Rounded button control
│   ├── installer/                    # WiX installer configuration
│   │   ├── AemulusConnect.wxs        # WiX source file
│   │   ├── AemulusConnect.wixproj    # WiX project file
│   │   └── *.md                      # Installer documentation
│   ├── platform-tools/               # ADB binaries
│   ├── frmMain.cs                    # Main application form
│   ├── SettingsForm.cs               # Settings dialog
│   ├── Program.cs                    # Application entry point
│   ├── log4net.config                # Logging configuration
│   ├── AemulusConnect.csproj         # Project file
│   └── AemulusConnect.sln            # Solution file
├── tools/                            # Build automation scripts
│   ├── build_and_package.ps1         # Main build script
│   ├── verify_prerequisites.ps1      # Prerequisites checker
│   ├── convert_docs.ps1              # Documentation converter
│   └── README.md                     # Tools documentation
├── notes/                            # Project documentation
│   ├── USER_GUIDE.md                # User guide
│   ├── BUILD.md                      # Build quick reference
│   ├── CONTRIBUTING.md               # This file
│   ├── CODE_OF_CONDUCT.md            # Community guidelines
│   ├── CHANGELOG.md                  # Version history
│   └── TODO.md                       # Task tracking
├── assets/                           # Media and styling
│   ├── media/                        # Images, logos, sounds
│   └── css/                          # GitHub Pages styling
├── .github/                          # GitHub configuration
│   ├── workflows/                    # GitHub Actions
│   └── ISSUE_TEMPLATE/               # Issue templates
└── README.md                         # Main readme
```

### Key Dependencies

- **AdvancedSharpAdbClient 3.3.13** - ADB communication library
- **log4net 3.0.3** - Logging framework
- **.NET 8** (net8.0-windows10.0.26100.0) - Target framework
- **Windows Forms** - UI framework

## Project Architecture

### Overview

AemulusConnect follows an **Event-Driven Architecture** with state management through user control switching.

```
┌─────────────────────┐
│     frmMain         │ ← Main Form (State Coordinator)
│  (Fixed: 602x335)   │
└──────────┬──────────┘
           │ manages state transitions
           ↓
┌──────────────────────────────────────────┐
│  User Controls (3 States)                │
│  • disconnectedUserControl               │ ← Setup Instructions
│  • connectedUserControl                  │ ← Main Menu
│  • loadingUserControl                    │ ← Transfer Progress
└──────────────┬───────────────────────────┘
               │ raises events
               ↓
┌──────────────────────────────────────────┐
│         QuestHelper                      │ ← Business Logic Layer
│  • ADB Server Management                 │
│  • Device Detection (1s polling)         │
│  • File Transfer Operations              │
│  • Archive Management (max 100 files)    │
│  • Event Notifications                   │
└──────────────┬───────────────────────────┘
               │ uses
               ↓
┌──────────────────────────────────────────┐
│   External Dependencies                  │
│  • AdvancedSharpAdbClient                │
│  • log4net                                │
│  • ADB Platform Tools                    │
└──────────────────────────────────────────┘
```

### Design Patterns

**Observer Pattern**: Event-driven communication between UI and business logic
- `QuestHelper` raises events: `OnStatusChanged`, `OnDownloadStatusChanged`, `OnError`
- `frmMain` subscribes to these events and updates UI accordingly

**State Pattern**: Three distinct UI states as separate UserControls
- Enables clean separation of state-specific UI and behavior
- Simplifies state transitions

**Singleton Behavior**: Static configuration classes (`FSStrings`, `SettingsManager`)
- Provides global access to configuration
- Trade-off: Limits testability but simplifies usage

### Key Components

#### 1. frmMain.cs - Main Application Window
**Responsibilities**:
- Initialize QuestHelper and wire up events
- Handle device state changes
- Manage UI state transitions
- Display error dialogs

**Key Methods**:
```csharp
Form1_Load()                      // Initialize components
questHelper_OnStatusChanged()     // Handle device state changes
questHelper_OnDownloadStatusChanged()  // Handle transfer status
SwitchToUserControl()             // Manage UI state transitions
```

#### 2. QuestHelper.cs - Core Business Logic
**Responsibilities**:
- ADB server management
- Device detection and monitoring
- File transfer operations
- Archive management

**Key Methods**:
```csharp
StartADBServer()                  // Initialize ADB server
MonitorDevices()                  // Poll device status (1s interval)
FetchReportsAsync()               // Download files from Quest
ArchiveReports()                  // Move files to archive folder
DeleteOldArchiveFiles()           // Maintain max 100 archive files
```

**File Transfer Flow**:
1. Get list of files from `sdcard\Documents\`
2. Copy files to `Desktop\AemulusConnect\`
3. Verify file integrity (compare sizes)
4. Move originals to `sdcard\Documents\Archive\`
5. Cleanup old archive files (keep most recent 100)

#### 3. SettingsManager.cs - Configuration Persistence
**Location**: `%APPDATA%\AemulusConnect\settings.ini`

**Format**: Simple key=value pairs
```ini
# AemulusConnect settings
ReportsLocation=sdcard\Documents\
ArchiveLocation=sdcard\Documents\Archive\
OutputLocation=C:\Users\...\Desktop\AemulusConnect\
ADBEXELocation=...
```

## Building the Project

### Quick Build

```powershell
# Navigate to tools directory
cd tools

# Verify prerequisites
.\verify_prerequisites.ps1

# Build application and create MSI installer
.\build_and_package.ps1 -Clean
```

### Build Options

| Command                                  | Description           | Output Size |
| ---------------------------------------- | --------------------- | ----------- |
| `.\build_and_package.ps1`                | Standard build        | ~5-10 MB    |
| `.\build_and_package.ps1 -Clean`         | Clean build           | ~5-10 MB    |
| `.\build_and_package.ps1 -SelfContained` | Includes .NET runtime | ~100+ MB    |
| `.\build_and_package.ps1 -SkipBuild`     | Only rebuild MSI      | N/A         |

**Output**: `src\output\AemulusConnect.msi`

### Manual Build (Without Scripts)

```powershell
# Build application
cd src
dotnet restore
dotnet build AemulusConnect.csproj --configuration Release

# Create installer
cd installer
wix build AemulusConnect.wxs -out ..\output\AemulusConnect.msi
```

For detailed build instructions, see [BUILD.md](BUILD.md).

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check [existing issues](https://github.com/Aemulus-XR/AemulusConnect/issues) to avoid duplicates.

**Use our bug report template** and include:
- Clear, descriptive title
- Steps to reproduce the problem
- Expected vs. actual behavior
- Screenshots (if applicable)
- Environment details (OS, .NET version, Quest model)
- Log file excerpts (`AemulusConnect.log`)

### Suggesting Features

Enhancement suggestions are tracked as GitHub issues. Use our **feature request template** and include:

- Clear, descriptive title
- Detailed description of the proposed feature
- Use cases and examples
- Why this would be useful to users
- Potential implementation approach (optional)

### Submitting Code Changes

1. **Create a new branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Follow our [coding guidelines](#coding-guidelines)
   - Add/update tests if applicable
   - Update documentation

3. **Test your changes**:
   - Build the project successfully
   - Test the application manually
   - Verify the installer works

4. **Commit your changes**:
   - Follow our [commit message guidelines](#commit-message-guidelines)
   - Make atomic commits (one logical change per commit)

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request** on GitHub

### Contributing Translations

We use Crowdin to manage translations for multiple languages. Non-technical contributors can help translate the application into their native language through a user-friendly web interface.

**For translators**: See [CONTRIBUTING_TRANSLATIONS.md](../CONTRIBUTING_TRANSLATIONS.md) for instructions on using Crowdin.

**For developers**: See [Crowdin Setup](#crowdin-setup) below for initial integration setup.

## Crowdin Setup

This section is for maintainers who need to set up or manage the Crowdin integration. If you're just contributing translations, see the [Contributing Translations](#contributing-translations) section above.

### Initial Setup (One-time)

The project already has Crowdin configuration files in place:
- `crowdin.yml` - Configuration for source/translation file mapping
- `.github/workflows/crowdin.yml` - GitHub Actions workflow for automatic sync
- `CONTRIBUTING_TRANSLATIONS.md` - User-facing translator documentation
- `CROWDIN_GUIDE.md` - Complete workflow guide and setup checklist

For a detailed explanation of how the translation workflow works, see [CROWDIN_GUIDE.md](../CROWDIN_GUIDE.md).

To complete the Crowdin integration:

1. **Create a Crowdin Account** (if not already done):
   - Go to [crowdin.com](https://crowdin.com)
   - Sign up for a free account (free for open source projects)

2. **Create a Crowdin Project**:
   - Click "Create Project"
   - Name: "AemulusConnect"
   - Source language: English
   - Target languages: Select the languages you want to support (currently: ar-SA, de-DE, es-ES, fr-FR)

3. **Get Crowdin Credentials**:
   - **Project ID**: Found in project Settings → API (looks like a number, e.g., "123456")
   - **Personal Access Token**:
     - Go to Account Settings → API
     - Click "New Token"
     - Name it "GitHub Actions"
     - Scope: Select all permissions
     - Copy the token (you won't see it again!)

4. **Add GitHub Secrets**:
   - Go to your GitHub repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Add two secrets:
     - Name: `CROWDIN_PROJECT_ID`, Value: [your project ID]
     - Name: `CROWDIN_PERSONAL_TOKEN`, Value: [your personal access token]

5. **Update Documentation**:
   - Edit `CONTRIBUTING_TRANSLATIONS.md` line 18
   - Replace `[TO BE ADDED AFTER CROWDIN PROJECT SETUP]` with your actual Crowdin project URL
   - Example: `https://crowdin.com/project/aemulusconnect`

6. **Initial Sync**:
   - Push the `crowdin.yml` file to the `main` branch
   - The GitHub Action will automatically run and upload `Resources.resx` to Crowdin
   - You can also manually trigger it: GitHub Actions → Crowdin Sync → Run workflow

### How It Works

Once configured, the integration works automatically:

1. **Source File Updates**: When `src/Properties/Resources.resx` is modified and pushed to main, GitHub Actions uploads the changes to Crowdin
2. **Translation Workflow**: Translators work in Crowdin's web interface to translate strings
3. **Download Translations**: Daily at midnight UTC, the workflow downloads new translations from Crowdin
4. **Pull Requests**: Completed translations are automatically submitted as a PR to the `l10n_crowdin_translations` branch
5. **Review & Merge**: Maintainers review the PR and merge it into main

### Managing Translations

**Add a new language**:
1. Add the language in Crowdin project settings
2. Update `crowdin.yml` to include the language code mapping:
   ```yaml
   languages_mapping:
     locale_with_underscore:
       ja-JP: ja-JP  # Add new language here
   ```
3. Commit and push the change

**Force sync manually**:
- Go to GitHub Actions → Crowdin Sync → Run workflow

**Check sync status**:
- View the Actions tab in GitHub to see sync logs
- Check Crowdin project dashboard for translation progress

### Adding Custom/Non-Standard Languages

For fun languages like "Pirate" (en-PIRATE) that don't follow standard locale codes:

1. These should NOT be added to Crowdin (they're excluded in `crowdin.yml`)
2. Create the `.resx` file manually: `src/Properties/Resources.en-PIRATE.resx`
3. The build system will automatically handle them via the custom MSBuild target in `src/AemulusConnect.csproj`
4. Add to the language exclusion list in `crowdin.yml`:
   ```yaml
   ignore:
     - /src/Properties/Resources.en-PIRATE.resx
     - /src/Properties/Resources.en-L33T.resx  # Example
   ```

## Coding Guidelines

### C# Coding Style

We follow Microsoft's [C# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions):

- **Naming**:
  - PascalCase for classes, methods, properties: `QuestHelper`, `FetchReportsAsync()`
  - camelCase for local variables: `deviceStatus`, `fileCount`
  - Prefix private fields with underscore: `_questHelper`, `_logger`

- **Formatting**:
  - Use tabs for indentation
  - Place opening braces on new line
  - Use explicit types (avoid `var` unless type is obvious)

- **Best Practices**:
  - Use async/await for I/O operations
  - Dispose IDisposable objects properly
  - Use meaningful variable names
  - Add XML documentation comments for public APIs
  - Keep methods focused and small

### Example:

```csharp
/// <summary>
/// Fetches report files from the connected Quest device.
/// </summary>
/// <returns>True if successful, false otherwise.</returns>
public async Task<bool> FetchReportsAsync()
{
    try
    {
        var files = GetListOfFiles(ReportsLocation);
        if (files.Count == 0)
        {
            _logger.Info("No reports found");
            return false;
        }

        foreach (var file in files)
        {
            await TransferFileAsync(file);
        }

        return true;
    }
    catch (Exception ex)
    {
        _logger.Error("Failed to fetch reports", ex);
        return false;
    }
}
```

## Commit Message Guidelines

We use [Conventional Commits](https://www.conventionalcommits.org/) with Semantic Versioning:

### Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat:` - New feature (bumps MINOR version)
- `fix:` - Bug fix (bumps PATCH version)
- `feat!:` or `fix!:` - Breaking change (bumps MAJOR version)
- `docs:` - Documentation only changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `perf:` - Performance improvements
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks
- `build:` - Build system changes
- `ci:` - CI/CD changes

### Examples

```
feat: add progress reporting for file transfers
fix: resolve device detection timeout issue
docs: update USER_GUIDE with troubleshooting steps
refactor: extract file validation logic to separate method
feat!: change settings file location to AppData
```

## Testing

### Manual Testing Checklist

Before submitting a PR, manually test:

- [ ] Application launches successfully
- [ ] Device detection works (plug/unplug Quest)
- [ ] File transfers complete successfully
- [ ] Archive management works correctly
- [ ] Settings dialog saves and loads correctly
- [ ] Error handling displays appropriate messages
- [ ] Installer builds and installs correctly
- [ ] Application uninstalls cleanly

### Unit Testing (Future)

We're planning to add unit tests. Contributions in this area are welcome! See:
- [CodeReview.md](CodeReview.md) - Task 3.1: Add Unit Tests

### Test Environments

Please test on:
- Windows 10 (minimum build 26100)
- Windows 11
- Both with and without .NET 8 runtime pre-installed

## Pull Request Process

1. **Update documentation**:
   - Update README.md if adding features
   - Update USER_GUIDE.md for user-facing changes
   - Update BUILD.md for build system changes

2. **Ensure CI passes**:
   - All automated checks must pass
   - No merge conflicts with `main`

3. **Request review**:
   - Assign appropriate reviewers
   - Respond to review comments promptly

4. **After approval**:
   - Squash commits if requested
   - Maintainer will merge your PR

### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Commits follow conventional commit format
- [ ] Documentation updated
- [ ] Manual testing completed
- [ ] No unnecessary files committed (bin/, obj/, etc.)
- [ ] PR description clearly explains changes

## Questions and Help

Need help? Here's how to reach us:

- **Discord**: [Join our server](https://discord.gg/gQH4mXWQRT) - Ask questions, discuss ideas
- **GitHub Discussions**: [Start a discussion](https://github.com/Aemulus-XR/AemulusConnect/discussions)
- **Issues**: [Create an issue](https://github.com/Aemulus-XR/AemulusConnect/issues/new) - For bugs or features
- **LinkedIn**: [Scott Kirvan](https://www.linkedin.com/in/scottkirvan/)

## Additional Resources

- **[USER_GUIDE.md](USER_GUIDE.md)** - User documentation
- **[BUILD.md](BUILD.md)** - Build quick reference
- **[CodeReview.md](CodeReview.md)** - Technical analysis and improvement suggestions
- **[CHANGELOG.md](CHANGELOG.md)** - Version history
- **[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)** - Community guidelines

## License

By contributing to AemulusConnect, you agree that your contributions will be licensed under the [MIT License](LICENSE.md).

---

Thank you for contributing to AemulusConnect! Your efforts help make this project better for everyone. 🙏
