# ===============================================================
# Copyright (c) 2025, Scott Kirvan, Aemulus-XR
# All rights reserved.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
# ===============================================================

# ===============================================================
# message_slack.ps1
# Sends deployment notification to Slack webhook
#
# Usage:
#   .\tools\message_slack.ps1 [-Version <version>] [-ReleaseUrl <url>]
#
# Parameters:
#   -Version: Version number (if not provided, reads from notes/VERSION.md)
#   -ReleaseUrl: GitHub release URL (optional)
#
# Environment Variables:
#   SLACK_WEBHOOK_URL: Slack webhook URL (required)
#
# What it does:
#   1. Reads version information from notes/VERSION.md or parameter
#   2. Formats a deployment message for AemulusConnect
#   3. Sends notification to Slack via webhook
# ===============================================================

param(
    [string]$Version,
    [string]$ReleaseUrl
)

# Check for Slack webhook URL in environment variable
$slackWebhook = $env:SLACK_WEBHOOK_URL
if ([string]::IsNullOrWhiteSpace($slackWebhook)) {
    Write-Host "ERROR: SLACK_WEBHOOK_URL environment variable not set" -ForegroundColor Red
    Write-Host "Please set the SLACK_WEBHOOK_URL environment variable with your Slack webhook URL" -ForegroundColor Yellow
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
        } else {
            Write-Host "ERROR: Could not parse version from VERSION.md" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "ERROR: VERSION.md not found and no version specified" -ForegroundColor Red
        exit 1
    }
}

# Build the deployment message
$deploymentMessage = "*New AemulusConnect Release!*`n`n*Version:* $Version"

if (-not [string]::IsNullOrWhiteSpace($ReleaseUrl)) {
    $deploymentMessage += "`n*Download:* <$ReleaseUrl|GitHub Release>"
}

# Slack webhook expects "text" field
$message = @{
    text = $deploymentMessage
} | ConvertTo-Json -Compress

Write-Host "Sending deployment notification to Slack..." -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Gray
if (-not [string]::IsNullOrWhiteSpace($ReleaseUrl)) {
    Write-Host "Release URL: $ReleaseUrl" -ForegroundColor Gray
}

# Send to Slack using Invoke-RestMethod (cross-platform)
try {
    $response = Invoke-RestMethod -Uri $slackWebhook -Method Post -Body $message -ContentType 'application/json'
    Write-Host "Slack notification sent successfully!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to send Slack notification" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
