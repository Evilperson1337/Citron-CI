#!/bin/bash
# ==============================================================================
# Android Packaging Script for Citron
# ==============================================================================
# Packages Citron build into an APK
# ==============================================================================

set -e

ARTIFACT_BASENAME="${1:-Citron-Nightly}"

echo "========================================"
echo "Packaging Citron for Android"
echo "Artifact Basename: $ARTIFACT_BASENAME"
echo "========================================"

# Build APK
echo "Building APK..."
cd citron/src/android
export ANDROID_SDK_ROOT="$ANDROID_HOME"
chmod +x gradlew
./gradlew assembleMainlineRelease -Pcmake.args="-DENABLE_WEB_SERVICE=OFF -DENABLE_OPENSSL=OFF"

# Rename APK
echo "Renaming APK..."
APK_PATH=$(find app/build/outputs/apk -type f -name "*.apk" | head -n 1)
mkdir -p ../../dist
APK_NAME="${ARTIFACT_BASENAME}-android-arm64.apk"
mv "$APK_PATH" "../../dist/$APK_NAME"

echo "========================================"
echo "Packaging completed successfully!"
echo "Artifact: dist/$APK_NAME"
echo "========================================"