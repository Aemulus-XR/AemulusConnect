# Contributing Translations

Thank you for your interest in translating AemulusConnect! This guide will help you get started with contributing translations to the project.

## Overview

We use [Crowdin](https://crowdin.com) to manage translations. Crowdin provides a user-friendly web interface where you can translate strings without any technical knowledge or need to edit code files directly.

## Getting Started

### 1. Create a Crowdin Account

If you don't already have one, sign up for a free account at [crowdin.com](https://crowdin.com).

### 2. Join the AemulusConnect Project

Visit the AemulusConnect project on Crowdin:
- **Project URL:** `[TO BE ADDED AFTER CROWDIN PROJECT SETUP]`

Click "Join" to become a translator.

### 3. Select Your Language

1. Browse the list of available languages
2. Click on the language you want to translate
3. If your language isn't listed, you can request it to be added by opening a GitHub issue

### 4. Start Translating

1. Click on the file `Resources.resx`
2. You'll see a list of English strings on the left
3. Enter your translation in the text box on the right
4. Click "Save" to submit your translation

## Translation Guidelines

### General Rules

- **Be consistent**: Use the same terminology throughout all translations
- **Keep formatting**: Preserve any special characters like `{0}`, `{1}` - these are placeholders for dynamic content
- **Match the tone**: Try to match the friendly, professional tone of the English text
- **Keep it concise**: Try to keep translations similar in length to the English version when possible

### Special Formatting

- **Placeholders**: Text like `{0}` or `{1}` must remain exactly as-is in your translation
  - Example: `"Welcome, {0}!"` → `"Bienvenue, {0} !"`
- **Line breaks**: `\n` represents a line break - keep these in your translation
- **Keyboard shortcuts**: Preserve `&` characters - they indicate keyboard shortcuts
  - Example: `"&File"` → `"&Fichier"`

### Context

Some strings may have context or descriptions to help you understand where they appear in the application. Click the "Context" tab to see screenshots or additional information.

### Questions?

If you're unsure about a translation:
1. Leave a comment in Crowdin asking for clarification
2. Check other similar strings for consistency
3. Open a GitHub issue if you need help from the development team

## How Translations Get Into the App

1. You submit translations on Crowdin
2. Once translations reach a certain completion threshold, they're automatically synchronized
3. A pull request is created on GitHub with your translations
4. The development team reviews and merges the translations
5. Your translations appear in the next release!

You'll be credited in the release notes for your contribution.

## Testing Your Translations

Once your translations are merged:

1. Download the latest development build (or wait for the next release)
2. Run AemulusConnect
3. Go to Settings → Language
4. Select your language
5. Verify that all translations look correct in context

If you notice any issues, you can update the translations on Crowdin, and they'll be synchronized in the next update.

## Supported Languages

Currently supported languages:
- Arabic (Saudi Arabia) - ar-SA
- German (Germany) - de-DE
- Spanish (Spain) - es-ES
- French (France) - fr-FR

Want to add a new language? Open a GitHub issue requesting it!

## Questions or Issues?

- **Crowdin help**: Check the [Crowdin documentation](https://support.crowdin.com/)
- **Project-specific questions**: Open an issue on [GitHub](https://github.com/Aemulus-XR/AemulusConnect/issues)
- **Contact the team**: Reach out through GitHub discussions

Thank you for helping make AemulusConnect accessible to users around the world! 🌍
