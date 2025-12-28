#!/bin/bash
# ==============================================================================
# Android Build Script for Citron
# ==============================================================================
# Builds Citron for Android
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
ccache --show-stats || true

log_section "Building Citron for Android"
 
# Use already downloaded source
log_info "Using downloaded source from emulator/"
if [ ! -d "emulator" ]; then
    log_error "emulator/ directory not found!"
    log_error "Expected to find source code in $(pwd)/emulator/"
    ls -la
    exit 1
fi
log_success "Source directory found"
 
# Configure CMake for Android
log_info "Configuring CMake for Android"
cd emulator
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
log_success "CMake configuration completed"

# Build
log_info "Building Citron"
cmake --build build-android --config Release --parallel $(nproc)
log_success "Build completed successfully"

# --- Show ccache statistics ---
echo "========================================"
echo "ccache statistics:"
echo "========================================"
ccache --show-stats

echo "========================================"
echo "Build completed successfully!"
echo "========================================"