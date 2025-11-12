# Crowdin Setup Checklist

This is a quick checklist for setting up the Crowdin integration. For detailed instructions, see [CONTRIBUTING.md - Crowdin Setup](notes/CONTRIBUTING.md#crowdin-setup).

## Prerequisites ✓

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
