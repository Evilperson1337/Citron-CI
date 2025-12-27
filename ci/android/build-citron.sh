#!/bin/bash
# ==============================================================================
# Android Build Script for Citron
# ==============================================================================
# Builds Citron for Android
# ==============================================================================

set -e

# --- Setup ccache ---
export CCACHE_DIR="${CCACHE_DIR:-$HOME/.ccache}"
export CCACHE_COMPILERCHECK=content
export CCACHE_SLOPPINESS=time_macros
ccache --show-stats || true

echo "========================================"
echo "Building Citron for Android"
echo "========================================"

# Clone source
echo "Cloning source repository..."
git clone --recursive "https://git.citron-emu.org/Citron/Emulator.git" citron

# Configure CMake for Android
echo "Configuring CMake for Android..."
cd citron
cmake -B build-android -S . \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-30 \
  -DANDROID_ARM_NEON=ON \
  -DENABLE_QT=OFF \
  -DENABLE_SDL2=OFF \
  -DENABLE_WEB_SERVICE=OFF \
  -DENABLE_OPENSSL=OFF \
  -DCITRON_USE_BUNDLED_VCPKG=ON \
  -DCITRON_USE_BUNDLED_FFMPEG=ON \
  -DCITRON_ENABLE_LTO=ON

# Build
echo "Building Citron..."
cmake --build build-android --config Release --parallel $(nproc)

# --- Show ccache statistics ---
echo "========================================"
echo "ccache statistics:"
echo "========================================"
ccache --show-stats

echo "========================================"
echo "Build completed successfully!"
echo "========================================"