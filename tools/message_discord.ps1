# ===============================================================
# Copyright (c) 2025, Scott Kirvan, Aemulus-XR
# All rights reserved.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
# ===============================================================

# ===============================================================
# message_discord.ps1
# Sends deployment notification to Discord webhook
#
# Usage:
#   .\tools\message_discord.ps1 [-Version <version>] [-ReleaseUrl <url>]
#
# Parameters:
#   -Version: Version number (if not provided, reads from notes/VERSION.md)
#   -ReleaseUrl: GitHub release URL (optional)
#
# Environment Variables:
#   DISCORD_WEBHOOK_URL: Discord webhook URL (required)
#
# What it does:
#   1. Reads version information from notes/VERSION.md or parameter
#   2. Formats a deployment message for AemulusConnect
#   3. Sends notification to Discord via webhook
# ===============================================================

param(
    [string]$Version,
    [string]$ReleaseUrl
)

# Check for Discord webhook URL in environment variable
$discordWebhook = $env:DISCORD_WEBHOOK_URL
if ([string]::IsNullOrWhiteSpace($discordWebhook)) {
    Write-Host "ERROR: DISCORD_WEBHOOK_URL environment variable not set" -ForegroundColor Red
    Write-Host "Please set the DISCORD_WEBHOOK_URL environment variable with your Discord webhook URL" -ForegroundColor Yellow
    exit 1
}

# Get version information
if ([string]::IsNullOrWhiteSpace($Version)) {
    # Read from VERSION.md
    $versionFile = Join-Path $PSScriptRoot "..\notes\VERSION.md"
    if (Test-Path $versionFile) {
        $versionContent = Get-Content $versionFile -Raw
        if ($versionContent -match 'version=(\d+\.\d+\.\d+)') {
            $Version = $matches[1]
        }
        else {
            Write-Host "ERROR: Could not parse version from VERSION.md" -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "ERROR: VERSION.md not found and no version specified" -ForegroundColor Red
        exit 1
    }
}

# Build the deployment message
$deploymentMessage = "**New AemulusConnect Release!**`n`n**Version:** $Version"

if (-not [string]::IsNullOrWhiteSpace($ReleaseUrl)) {
    $deploymentMessage += "`n**Download:** $ReleaseUrl"
}

# Discord webhook expects "content" field
$message = @{
    content = $deploymentMessage
} | ConvertTo-Json -Compress

Write-Host "Sending deployment notification to Discord..." -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Gray
if (-not [string]::IsNullOrWhiteSpace($ReleaseUrl)) {
    Write-Host "Release URL: [GitHub Release]($ReleaseUrl?)" -ForegroundColor Gray
}

# Send to Discord using Invoke-RestMethod (cross-platform)
try {
    $response = Invoke-RestMethod -Uri $discordWebhook -Method Post -Body $message -ContentType 'application/json'
    Write-Host "Discord notification sent successfully!" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to send Discord notification" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
