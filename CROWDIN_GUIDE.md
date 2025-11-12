# Crowdin Setup & Workflow Guide

This document explains how to set up Crowdin integration and how the translation workflow works for developers, project managers, and contributors.

## Table of Contents

- [What is Crowdin?](#what-is-crowdin)
- [How the Translation Workflow Works](#how-the-translation-workflow-works)
- [Setup Checklist](#setup-checklist)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## What is Crowdin?

Crowdin is a localization management platform that allows non-technical contributors to translate applications through a user-friendly web interface. It integrates with GitHub to automatically sync translations.

**Key Benefits:**
- ✅ Non-technical people can contribute translations (no code knowledge needed)
- ✅ Automatic synchronization between GitHub and Crowdin
- ✅ Translation memory (reuses previous translations)
- ✅ Visual dashboard showing completion percentage per language
- ✅ Maintains existing translations and only shows what needs updating
- ✅ Free for open source projects

## How the Translation Workflow Works

### For Existing Translations

When you first sync with Crowdin, all your existing translation files are uploaded:
- `Resources.ar-SA.resx` → Arabic translations imported to Crowdin
- `Resources.de-DE.resx` → German translations imported to Crowdin
- `Resources.es-ES.resx` → Spanish translations imported to Crowdin
- `Resources.fr-FR.resx` → French translations imported to Crowdin

**Benefits:**
- Translators can see what's already translated
- They can review and improve existing translations
- Dashboard shows completion percentage (e.g., "French: 100%, Arabic: 95%")
- All future updates happen through Crowdin's web interface

### When You Add New Interface Text

Here's the complete workflow when a developer adds new strings:

#### Step 1: Developer Updates Source File

Developer adds new text to the English source file `src/Properties/Resources.resx`:

```xml
<data name="NewFeature_Title" xml:space="preserve">
  <value>New Feature</value>
</data>
```

And uses it in code:
```csharp
this.Text = Properties.Resources.NewFeature_Title;
```

#### Step 2: Commit and Push

```bash
git add src/Properties/Resources.resx
git commit -m "feat: add new feature title string"
git push origin main
```

#### Step 3: Automatic Sync to Crowdin

GitHub Action automatically detects the change (configured to watch `Resources.resx`):
- ✅ Uploads "New Feature" string to Crowdin
- ✅ All languages show as incomplete (e.g., "French: 98% → 95%")
- ✅ Translators can be notified by email (optional)

#### Step 4: Translators Work in Crowdin

Translators log into Crowdin's web interface and see:
- **English:** "New Feature"
- **French:** [Empty - needs translation]
- **German:** [Empty - needs translation]
- **Spanish:** [Empty - needs translation]

They add translations:
- **French:** "Nouvelle Fonctionnalité"
- **German:** "Neue Funktion"
- **Spanish:** "Nueva Característica"
- **Arabic:** "ميزة جديدة"

No code editing required! Everything happens in a user-friendly web form.

#### Step 5: Automatic Pull Request

Daily at midnight UTC (or when manually triggered):
- ✅ GitHub Action downloads completed translations from Crowdin
- ✅ Creates a pull request titled "New Crowdin translations"
- ✅ PR updates all language files:
  - `src/Properties/Resources.fr-FR.resx`
  - `src/Properties/Resources.de-DE.resx`
  - `src/Properties/Resources.es-ES.resx`
  - `src/Properties/Resources.ar-SA.resx`

#### Step 6: Review and Merge

Maintainer reviews the PR:
```diff
Modified: src/Properties/Resources.fr-FR.resx
+ <data name="NewFeature_Title" xml:space="preserve">
+   <value>Nouvelle Fonctionnalité</value>
+ </data>

Modified: src/Properties/Resources.de-DE.resx
+ <data name="NewFeature_Title" xml:space="preserve">
+   <value>Neue Funktion</value>
+ </data>
```

Merge the PR → Next release includes all translations! 🎉

### Current Workflow vs. After Crowdin

| Scenario | **Before Crowdin** | **After Crowdin** |
|----------|-------------------|-------------------|
| **Add new text** | Manually edit 4+ `.resx` files or wait for PR | Edit only English, Crowdin handles the rest |
| **Translation status** | Unknown which languages are complete | Dashboard shows "French: 98%, German: 100%" |
| **Who can translate** | Only devs or people who understand `.resx` XML | Anyone with a web browser |
| **Quality control** | Manual review of XML files | Crowdin has built-in validation and suggestions |
| **Translation memory** | None - translators start from scratch | Crowdin suggests similar translations |
| **Coordination** | Manual coordination in issues/Discord | Translators work independently on Crowdin |

### Example: Adding a Dark Mode Setting

**Developer adds:**
```xml
<data name="Settings_EnableDarkMode" xml:space="preserve">
  <value>Enable Dark Mode</value>
</data>
```

**What happens automatically:**
1. ✅ Push to `main` → GitHub Action uploads to Crowdin
2. ✅ French translator sees new string → translates to "Activer le mode sombre"
3. ✅ Spanish translator translates to "Activar modo oscuro"
4. ✅ German translator translates to "Dunkelmodus aktivieren"
5. ✅ Next day: Crowdin creates PR with all 3 translations
6. ✅ Merge PR → All users see localized text

**Developer never touched the French/Spanish/German files!**

## Setup Checklist

### Prerequisites ✓

- [x] `crowdin.yml` configuration file created
- [x] `.github/workflows/crowdin.yml` GitHub Actions workflow created
- [x] `CONTRIBUTING_TRANSLATIONS.md` translator documentation created

## Setup Steps

### 1. Create Crowdin Account & Project

- [ ] Go to [crowdin.com](https://crowdin.com) and create an account
- [ ] Click "Create Project"
  - [ ] Name: "AemulusConnect"
  - [ ] Source language: English
  - [ ] Target languages: ar-SA, de-DE, es-ES, fr-FR (and any others you want)

### 2. Get Credentials

- [ ] Get **Project ID** from Crowdin project Settings → API
  - Write it here: `_________________`
- [ ] Create **Personal Access Token**:
  - [ ] Go to Account Settings → API → New Token
  - [ ] Name: "GitHub Actions"
  - [ ] Scope: Select all permissions
  - [ ] Copy token (save it securely, you won't see it again!)
  - Write it here (temporarily): `_________________`

### 3. Add GitHub Secrets

- [ ] Go to GitHub repository Settings → Secrets and variables → Actions
- [ ] Add secret `CROWDIN_PROJECT_ID` with value from step 2
- [ ] Add secret `CROWDIN_PERSONAL_TOKEN` with value from step 2
- [ ] **IMPORTANT**: Delete the credentials you wrote above after adding to GitHub!

### 4. Update Documentation

- [ ] Edit `CONTRIBUTING_TRANSLATIONS.md` line 18
- [ ] Replace `[TO BE ADDED AFTER CROWDIN PROJECT SETUP]` with your Crowdin project URL
  - Format: `https://crowdin.com/project/aemulusconnect`

### 5. Test the Integration

- [ ] Push `crowdin.yml` to the `main` branch (if not already pushed)
- [ ] Go to GitHub Actions tab
- [ ] Manually trigger "Crowdin Sync" workflow
- [ ] Verify workflow completes successfully
- [ ] Check Crowdin project - `Resources.resx` should be uploaded
- [ ] Check that existing translations (ar-SA, de-DE, es-ES, fr-FR) were uploaded

### 6. Invite Translators (Optional)

- [ ] Share the Crowdin project URL with potential translators
- [ ] Add URL to project README or documentation
- [ ] Announce in Discord/community channels

## Verification

After setup, verify everything works:

- [ ] Source file changes in `Resources.resx` trigger Crowdin upload
- [ ] Translations in Crowdin create pull requests to GitHub
- [ ] Daily sync runs automatically at midnight UTC
- [ ] Translation files are correctly named (e.g., `Resources.fr-FR.resx`)

## Troubleshooting

If the GitHub Action fails:
1. Check the Actions log for error messages
2. Verify GitHub secrets are set correctly
3. Verify Crowdin Project ID is correct
4. Verify Personal Access Token has necessary permissions
5. Check `crowdin.yml` syntax

If translations aren't syncing:
1. Check Crowdin project dashboard for translation completion percentage
2. Verify language codes match between Crowdin and `crowdin.yml`
3. Manually trigger the workflow to test

## Done!

Once all checkboxes are complete, delete this file or move it to a `notes/` folder for future reference.

For ongoing management, see [CONTRIBUTING.md - Managing Translations](notes/CONTRIBUTING.md#managing-translations).
