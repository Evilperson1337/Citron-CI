#!/bin/bash
# ==============================================================================
# Android Snapdragon Build Script for Citron Nightly Builds
# ==============================================================================
# This script builds Citron for Android with Snapdragon 8 Elite specific patches
# It's called by the GitHub Actions workflow with appropriate parameters
#
# Usage: ./build-snapdragon.sh [artifact_basename] [branch_name]
#   artifact_basename: Base name for the output artifact
#   branch_name: Upstream branch to build from
# ==============================================================================

set -e

ARTIFACT_BASENAME="${1:-Citron-Nightly}"
BRANCH_NAME="${2:-main}"

echo "========================================"
echo "Building Citron for Android (Snapdragon 8 Elite)"
echo "Artifact basename: $ARTIFACT_BASENAME"
echo "Branch: $BRANCH_NAME"
echo "========================================"

# Set up environment
export TARGET=Lyb
export MODEL="8 Elite"
export CCACHE_DIR="${GITHUB_WORKSPACE:-.}/.ccache"
export CCACHE_COMPILERCHECK=content
export CCACHE_SLOPPINESS=time_macros

# Install build dependencies
echo "Installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y ccache glslang-tools libvulkan-dev python3-requests patch

# Checkout this repo for patches
echo "Cloning CI repo..."
git clone --depth 1 https://github.com/${GITHUB_REPOSITORY:-Citron-CI/Citron-CI}.git ci-repo

# Clone Citron source
echo "Cloning Citron source..."
git clone --recurse-submodules --depth 1 -b "$BRANCH_NAME" \
  "https://git.citron-emu.org/Citron/Emulator.git" citron

# Apply Snapdragon 8 Elite patches
cd citron
echo "Applying Snapdragon 8 Elite patches..."

# Patch 1: Force System Driver Load (native.cpp)
sed -i '/if (!handle) {/,/}/c\    if (!handle) {\n        handle = dlopen("libvulkan.so", RTLD_NOW);\n    }' src/android/app/src/main/jni/native.cpp

# Patch 2: 8 Elite Fixes for Qualcomm (vulkan_device.h)
sed -i '/bool IsShaderInt64Supported() const {/a \        const auto driver = GetDriverID();\n        if (driver == VK_DRIVER_ID_QUALCOMM_PROPRIETARY) {\n            return false;\n        }' src/video_core/vulkan_common/vulkan_device.h
sed -i '/bool IsExtShaderAtomicInt64Supported() const {/a \        const auto driver = GetDriverID();\n        if (driver == VK_DRIVER_ID_QUALCOMM_PROPRIETARY) {\n            return false;\n        }' src/video_core/vulkan_common/vulkan_device.h

# Patch 3: 8 Elite & Cleanup Fixes (vulkan_device.cpp)
sed -i '/const auto device_id =/d' src/video_core/vulkan_common/vulkan_device.cpp
sed -i 's/\bdevice_id\b/properties.properties.deviceID/g' src/video_core/vulkan_common/vulkan_device.cpp
sed -i 's/if (is_qualcomm) {/if (driver_id == VK_DRIVER_ID_QUALCOMM_PROPRIETARY) {/' src/video_core/vulkan_common/vulkan_device.cpp

cd ..

# Run the standard Android build script
echo "Running standard Android build script..."
chmod +x ci/android/build.sh
ci/android/build.sh "$ARTIFACT_BASENAME" snapdragon

echo "========================================"
echo "Build completed successfully!"
echo "Artifacts located in: $(pwd)/citron/dist/"
echo "========================================"