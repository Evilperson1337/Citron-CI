#!/bin/bash
# ==============================================================================
# Linux Build Script for Citron Nightly Builds
# ==============================================================================
# This script builds Citron for Linux platforms (x86_64, x86_64-v3, aarch64)
# It's called by the GitHub Actions workflow with appropriate parameters
#
# Usage: ./build.sh [arch] [artifact_basename]
#   arch: x86_64, x86_64_v3, or aarch64
#   artifact_basename: Base name for the output artifact
# ==============================================================================

set -e

# Parse arguments
ARCH="${1:-x86_64}"
ARTIFACT_BASENAME="$2"
BUILD_ARG="${3:-}"

echo "========================================"
echo "Building Citron for Linux ($ARCH)"
echo "Artifact basename: $ARTIFACT_BASENAME"
echo "Build args: $BUILD_ARG"
echo "========================================"

# Install system dependencies
pacman -Syu --noconfirm --needed git

# Copy build scripts to emulator directory
cp ci/linux/get-dependencies.sh ci/linux/build-citron.sh ci/linux/package-citron.sh emulator/
chmod +x emulator/*.sh

# Navigate to emulator directory
cd emulator

# Install dependencies
./get-dependencies.sh

# Determine number of parallel jobs
JOBS=$(nproc --all)
[ "$JOBS" -gt 4 ] && JOBS=4

# Build Citron
echo "Building with $JOBS parallel jobs..."
JOBS=$JOBS DEVEL=true ./build-citron.sh $BUILD_ARG

# Set environment variables for packaging
export HASH="${GIT_SHA:-$(git rev-parse --short HEAD)}"
export APP_VERSION="${GIT_SHA:-$(git rev-parse --short HEAD)}"
export VERSION="${GIT_SHA:-$(git rev-parse --short HEAD)}"
export ARCH_SUFFIX="${BUILD_ARG:+_$BUILD_ARG}"
export DEVEL="true"

# Package the build
./package-citron.sh

# Rename AppImage to follow naming convention
echo "Renaming AppImage to follow naming convention..."
cd dist

# Determine architecture suffix for filename
case "$ARCH" in
  x86_64)
    ARCH_SUFFIX="-linux-amd64"
    ;;
  x86_64_v3)
    ARCH_SUFFIX="-linux-amd64-v3"
    ;;
  aarch64)
    ARCH_SUFFIX="-linux-arm64"
    ;;
  *)
    ARCH_SUFFIX="-linux-unknown"
    ;;
esac

# Rename all AppImage files
for file in *.AppImage*; do
  if [ -f "$file" ]; then
    ext="${file##*.}"
    new_name="${ARTIFACT_BASENAME}${ARCH_SUFFIX}.${ext}"
    echo "Renaming: $file -> $new_name"
    mv "$file" "$new_name"
  fi
done

cd ..

echo "========================================"
echo "Build completed successfully!"
echo "Artifacts located in: $(pwd)/dist/"
echo "========================================"