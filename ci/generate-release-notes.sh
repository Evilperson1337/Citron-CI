#!/bin/bash

# Generate release notes from template with variable substitution
# Usage: generate-release-notes.sh <commit_hash> <full_hash> <branch> <version> <date> <time>

COMMIT_HASH="$1"
FULL_HASH="$2"
BRANCH_NAME="$3"
VERSION="$4"
DATE="$5"
TIME="$6"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Read the template from the same directory as the script
TEMPLATE_PATH="$SCRIPT_DIR/NIGHTLY_RELEASE_TEMPLATE.md"

if [ ! -f "$TEMPLATE_PATH" ]; then
    echo "Error: Template file not found at $TEMPLATE_PATH"
    exit 1
fi

# Read template content
TEMPLATE_CONTENT=$(cat "$TEMPLATE_PATH")

# Generate asset download URLs
# Assets follow the naming pattern: Citron-Nightly_<hash>-<platform>-<arch>.<ext>
REPO_URL="https://github.com/$GITHUB_REPOSITORY"
RELEASE_URL="$REPO_URL/releases/download/citron-nightly"

ASSET_LINUX_AMD64="$RELEASE_URL/Citron-Nightly_$COMMIT_HASH-linux-amd64.AppImage"
ASSET_LINUX_AMD64_V3="$RELEASE_URL/Citron-Nightly_$COMMIT_HASH-linux-amd64-v3.AppImage"
ASSET_LINUX_ARM64="$RELEASE_URL/Citron-Nightly_$COMMIT_HASH-linux-arm64.AppImage"
ASSET_WINDOWS_AMD64="$RELEASE_URL/Citron-Nightly_$COMMIT_HASH-windows-amd64.zip"
ASSET_MACOS_ARM64="$RELEASE_URL/Citron-Nightly_$COMMIT_HASH-macos-universal.dmg"
ASSET_ANDROID_ARM64="$RELEASE_URL/Citron-Nightly_$COMMIT_HASH-android-arm64.apk"

# Replace all placeholders with actual values
RELEASE_NOTES="${TEMPLATE_CONTENT//\{commit_hash\}/$COMMIT_HASH}"
RELEASE_NOTES="${RELEASE_NOTES//\{full_hash\}/$FULL_HASH}"
RELEASE_NOTES="${RELEASE_NOTES//\{branch_name\}/$BRANCH_NAME}"
RELEASE_NOTES="${RELEASE_NOTES//\{version\}/$VERSION}"
RELEASE_NOTES="${RELEASE_NOTES//\{date\}/$DATE}"
RELEASE_NOTES="${RELEASE_NOTES//\{time\}/$TIME}"

# Replace asset placeholders
RELEASE_NOTES="${RELEASE_NOTES//\{asset_linux_amd64\}/$ASSET_LINUX_AMD64}"
RELEASE_NOTES="${RELEASE_NOTES//\{asset_linux_amd64_v3\}/$ASSET_LINUX_AMD64_V3}"
RELEASE_NOTES="${RELEASE_NOTES//\{asset_linux_arm64\}/$ASSET_LINUX_ARM64}"
RELEASE_NOTES="${RELEASE_NOTES//\{asset_windows_amd64\}/$ASSET_WINDOWS_AMD64}"
RELEASE_NOTES="${RELEASE_NOTES//\{asset_macos_arm64\}/$ASSET_MACOS_ARM64}"
RELEASE_NOTES="${RELEASE_NOTES//\{asset_android_arm64\}/$ASSET_ANDROID_ARM64}"

# Output the generated release notes
echo "$RELEASE_NOTES"