#!/bin/bash
# ==============================================================================
# macOS Build Script for Citron Nightly Builds
# ==============================================================================
# This script builds Citron for macOS (universal)
# It's called by the GitHub Actions workflow with appropriate parameters
#
# Usage: ./build.sh [artifact_basename]
#   artifact_basename: Base name for the output artifact
# ==============================================================================

set -e

ARTIFACT_BASENAME="${1:-Citron-Nightly}"

echo "========================================"
echo "Building Citron for macOS"
echo "Artifact basename: $ARTIFACT_BASENAME"
echo "========================================"

# Install dependencies
echo "Installing dependencies..."
chmod +x ci/macos/get-dependencies.sh
ci/macos/get-dependencies.sh

# Build Citron
echo "Building Citron..."
chmod +x ci/macos/build-citron.sh
ci/macos/build-citron.sh

# Package the build
echo "Packaging build..."
chmod +x ci/macos/package-citron.sh
ci/macos/package-citron.sh "$ARTIFACT_BASENAME"

echo "========================================"
echo "Build completed successfully!"
echo "Artifacts located in: $(pwd)/citron/dist/"
echo "========================================"
