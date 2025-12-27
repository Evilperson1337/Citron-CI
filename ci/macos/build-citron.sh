#!/bin/bash
# ==============================================================================
# macOS Build Script for Citron
# ==============================================================================
# Builds Citron for macOS
# ==============================================================================

set -e

# --- Setup ccache ---
export CCACHE_DIR="${CCACHE_DIR:-$HOME/.ccache}"
export CCACHE_COMPILERCHECK=content
export CCACHE_SLOPPINESS=time_macros
ccache --show-stats || true

echo "========================================"
echo "Building Citron for macOS"
echo "========================================"

# Clone Citron Source with retry logic
for i in {1..5}; do
  echo "Attempting to clone repository (Attempt $i of 5)..."
  if git clone --recursive "https://git.citron-emu.org/Citron/Emulator.git" citron; then
    echo "✅ Clone successful."
    break
  fi
  
  if [ "$i" -eq 5 ]; then
    echo "❌ Failed to clone repository after 5 attempts."
    exit 1
  fi
  echo "⚠️ Clone failed. Retrying in 15 seconds..."
  sleep 15
done

cd citron

# Patch AGL in Qt FindWrapOpenGL.cmake
echo "Patching Qt FindWrapOpenGL.cmake..."
QT_OPENGL_CMAKE="externals/qt/6.7.3/macos/lib/cmake/Qt6/FindWrapOpenGL.cmake"
if [ -f "$QT_OPENGL_CMAKE" ]; then
  awk 'NR>=40 && NR<=46 {if(NR==40) print "          set(__opengl_agl_fw_path \"\")"; next}1' "$QT_OPENGL_CMAKE" > "$QT_OPENGL_CMAKE.tmp" && mv "$QT_OPENGL_CMAKE.tmp" "$QT_OPENGL_CMAKE"
else
  echo "Warning: $QT_OPENGL_CMAKE not found, skipping AGL patch"
fi

# Set up Python 3.12 venv
echo "Setting up Python virtual environment..."
python3.12 -m venv venv
source venv/bin/activate
pip install jsonschema jinja2
echo "VIRTUAL_ENV=$PWD/venv" >> $GITHUB_ENV
echo "$PWD/venv/bin" >> $GITHUB_PATH

# Configure CMake
echo "Configuring CMake..."
OPENAL_DIR="$(brew --prefix openal-soft)"
SDL2_DIR="$(brew --prefix sdl2)"
cmake -B build -S . -G "Ninja" \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_PREFIX_PATH="$OPENAL_DIR;$SDL2_DIR" \
  -DCITRON_USE_FASTER_LD=OFF \
  -DCITRON_USE_BUNDLED_VCPKG=OFF \
  -DENABLE_QT=ON \
  -DCITRON_ENABLE_LTO=ON \
  -DCITRON_TESTS=OFF \
  -DUSE_DISCORD_PRESENCE=ON \
  -DENABLE_WEB_SERVICE=ON \
  -DENABLE_OPENSSL=ON \
  -DENABLE_SDL2=ON \
  -DCITRON_USE_EXTERNAL_SDL2=OFF

# Build Citron
echo "Building Citron..."
cmake --build build --config Release

# --- Show ccache statistics ---
echo "========================================"
echo "ccache statistics:"
echo "========================================"
ccache --show-stats

echo "========================================"
echo "Build completed successfully!"
echo "========================================"