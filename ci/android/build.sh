#!/bin/bash
# ==============================================================================
# Android Build Script for Citron Nightly Builds
# ==============================================================================
# This script builds Citron for Android (arm64-v8a)
# It's called by the GitHub Actions workflow with appropriate parameters
#
# Usage: ./build.sh [artifact_basename]
#   artifact_basename: Base name for the output artifact
# ==============================================================================

set -euo pipefail

ARTIFACT_BASENAME="${1:-Citron-Nightly}"

echo "========================================"
echo "Building Citron for Android"
echo "Artifact basename: $ARTIFACT_BASENAME"
echo "========================================"

# Store the original directory
ORIGINAL_DIR="$(pwd)"

# Install dependencies
echo "Installing dependencies..."
chmod +x ci/android/get-dependencies.sh
source ci/android/get-dependencies.sh

# Build Citron
echo "Building Citron..."
chmod +x ci/android/build-citron.sh
source ci/android/build-citron.sh

# Package the build
echo "Packaging build..."
cd "$ORIGINAL_DIR"
chmod +x ci/android/package-citron.sh
source ci/android/package-citron.sh "$ARTIFACT_BASENAME"

echo "========================================"
echo "Build completed successfully!"
echo "Artifacts located in: $(pwd)/emulator/dist/"
echo "========================================"