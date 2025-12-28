#!/bin/bash
# ==============================================================================
# macOS Build Script for Citron
# ==============================================================================
# Builds Citron for macOS
# ==============================================================================

set -euo pipefail

# --- Standardized Logging Functions ---
log_info() {
    echo "ℹ️  INFO: $*"
}

log_success() {
    echo "✅ SUCCESS: $*"
}

log_warning() {
    echo "⚠️  WARNING: $*" >&2
}

log_error() {
    echo "❌ ERROR: $*" >&2
}

log_section() {
    echo ""
    echo "========================================"
    echo "$*"
    echo "========================================"
}

# Retry function for flaky operations
retry_operation() {
    local -r max_attempts=5
    local -r delay=15
    local attempt=1
    
    while (( attempt <= max_attempts )); do
        if "$@"; then
            return 0
        fi
        
        if (( attempt == max_attempts )); then
            log_error "Operation failed after $max_attempts attempts: $*"
            return 1
        fi
        
        log_warning "Attempt $attempt failed. Retrying in $delay seconds..."
        sleep $delay
        ((attempt++))
    done
}

# --- Setup ccache ---
export CCACHE_DIR="${CCACHE_DIR:-$HOME/.ccache}"
export CCACHE_COMPILERCHECK=content
export CCACHE_SLOPPINESS=time_macros
export CCACHE_MAXSIZE=10G
export CCACHE_COMPRESS=1
export CCACHE_COMPRESSLEVEL=6
mkdir -p "$CCACHE_DIR"
ccache --show-stats || true

log_section "Building Citron for macOS"

# Clone Citron Source with retry logic
log_info "Cloning Citron source repository"
retry_operation git clone --recursive "https://git.citron-emu.org/Citron/Emulator.git" citron
log_success "Repository cloned successfully"

cd citron

# Patch AGL in Qt FindWrapOpenGL.cmake
log_info "Patching Qt FindWrapOpenGL.cmake"
QT_OPENGL_CMAKE="externals/qt/6.7.3/macos/lib/cmake/Qt6/FindWrapOpenGL.cmake"
if [ -f "$QT_OPENGL_CMAKE" ]; then
  awk 'NR>=40 && NR<=46 {if(NR==40) print "          set(__opengl_agl_fw_path \"\")"; next}1' "$QT_OPENGL_CMAKE" > "$QT_OPENGL_CMAKE.tmp" && mv "$QT_OPENGL_CMAKE.tmp" "$QT_OPENGL_CMAKE"
  log_success "Qt AGL patch applied"
else
  log_warning "$QT_OPENGL_CMAKE not found, skipping AGL patch"
fi

# Set up Python 3.12 venv
log_info "Setting up Python virtual environment"
python3.12 -m venv venv
source venv/bin/activate
pip install jsonschema jinja2
echo "VIRTUAL_ENV=$PWD/venv" >> $GITHUB_ENV
echo "$PWD/venv/bin" >> $GITHUB_PATH
log_success "Python virtual environment configured"

# Configure CMake
log_info "Configuring CMake"
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
log_success "CMake configuration completed"

# Build Citron
log_info "Building Citron"
cmake --build build --config Release
log_success "Build completed successfully"

# --- Show ccache statistics ---
echo "========================================"
echo "ccache statistics:"
echo "========================================"
ccache --show-stats

echo "========================================"
echo "Build completed successfully!"
echo "========================================"