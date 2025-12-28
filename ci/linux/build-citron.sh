#!/bin/bash
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

# --- Architecture and Compiler Flag Setup ---
ARCH="${ARCH:-$(uname -m)}"

if [ "${1:-}" = 'v3' ] && [ "$ARCH" = 'x86_64' ]; then
    ARCH_FLAGS="-march=x86-64-v3 -O3 -USuccess -UNone -fuse-ld=lld"
elif [ "$ARCH" = 'x86_64' ]; then
    ARCH_FLAGS="-march=x86-64 -mtune=generic -O3 -USuccess -UNone -fuse-ld=lld"
else
    ARCH_FLAGS="-march=armv8-a -mtune=generic -O3 -USuccess -UNone -fuse-ld=lld"
fi

# --- Source Code Checkout and Versioning ---
log_section "Using Downloaded Source Code"
cd ./emulator
log_success "Source directory found"

if [ "$DEVEL" = 'true' ]; then
    CITRON_TAG="$(git rev-parse --short HEAD)"
    VERSION="$CITRON_TAG"
else
    CITRON_TAG=$(git describe --tags)
    git checkout "$CITRON_TAG"
    VERSION="$(echo "$CITRON_TAG" | awk -F'-' '{print $1}')"
fi

# --- Apply Necessary Source Code Patches for Compatibility ---
find . -type f \( -name '*.cpp' -o -name '*.h' \) | xargs sed -i 's/\bboost::asio::io_service\b/boost::asio::io_context/g'
find . -type f \( -name '*.cpp' -o -name '*.h' \) | xargs sed -i 's/\bboost::asio::io_service::strand\b/boost::asio::strand<boost::asio::io_context::executor_type>/g'
find . -type f \( -name '*.cpp' -o -name '*.h' \) | xargs sed -i 's|#include *<boost/process/async_pipe.hpp>|#include <boost/process/v1/async_pipe.hpp>|g'
find . -type f \( -name '*.cpp' -o -name '*.h' \) | xargs sed -i 's/\bboost::process::async_pipe\b/boost::process::v1::async_pipe/g'
sed -i '/sse2neon/d' ./src/video_core/CMakeLists.txt
sed -i 's/cmake_minimum_required(VERSION 2.8)/cmake_minimum_required(VERSION 3.5)/' externals/xbyak/CMakeLists.txt

# --- Find Qt6 Private Headers ---
log_info "Locating Qt6 private headers"
HEADER_PATH=$(pacman -Ql qt6-base | grep 'qpa/qplatformnativeinterface.h$' | awk '{print $2}')
if [ -z "$HEADER_PATH" ]; then
    log_error "Could not find qplatformnativeinterface.h path"
    exit 1
fi
QT_PRIVATE_INCLUDE_DIR=$(dirname "$(dirname "$HEADER_PATH")")
CXX_FLAGS_EXTRA="-I${QT_PRIVATE_INCLUDE_DIR}"
log_success "Qt6 private headers located at: $QT_PRIVATE_INCLUDE_DIR"

# --- Build Process ---
log_section "Building Citron"
JOBS=$(nproc --all)
log_info "Using $JOBS parallel jobs for compilation"

mkdir build && cd build

# Configure the build using CMake
log_info "Configuring build with CMake"
cmake .. -GNinja \
    -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
    -DCITRON_USE_BUNDLED_VCPKG=OFF \
    -DCITRON_USE_BUNDLED_QT=OFF \
    -DUSE_SYSTEM_QT=ON \
    -DENABLE_QT6=ON \
    -DCITRON_USE_BUNDLED_FFMPEG=OFF \
    -DCITRON_USE_BUNDLED_SDL2=ON \
    -DCITRON_USE_EXTERNAL_SDL2=OFF \
    -DCITRON_TESTS=OFF \
    -DCITRON_CHECK_SUBMODULES=OFF \
    -DCITRON_USE_LLVM_DEMANGLE=OFF \
    -DCITRON_ENABLE_LTO=ON \
    -DCITRON_USE_QT_MULTIMEDIA=ON \
    -DCITRON_USE_QT_WEB_ENGINE=OFF \
    -DENABLE_QT_TRANSLATION=ON \
    -DUSE_DISCORD_PRESENCE=ON \
    -DENABLE_WEB_SERVICE=ON \
    -DENABLE_OPENSSL=ON \
    -DBUNDLE_SPEEX=ON \
    -DCITRON_USE_FASTER_LD=OFF \
    -DCITRON_USE_EXTERNAL_Vulkan_HEADERS=ON \
    -DCITRON_USE_EXTERNAL_VULKAN_UTILITY_LIBRARIES=ON \
    -DCITRON_USE_AUTO_UPDATER=ON \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_CXX_FLAGS="$ARCH_FLAGS -Wno-error -w ${CXX_FLAGS_EXTRA}" \
    -DCMAKE_C_FLAGS="$ARCH_FLAGS" \
    -DCMAKE_SYSTEM_PROCESSOR="$(uname -m)" \
    -DCITRON_BUILD_TYPE=Nightly \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
log_success "CMake configuration completed"

# Compile and install the project
log_info "Starting compilation"
ninja -j${JOBS}
log_success "Compilation completed successfully"

log_info "Installing Citron"
sudo ninja install
log_success "Installation completed"

# --- Show ccache statistics ---
echo "========================================"
echo "ccache statistics:"
echo "========================================"
ccache --show-stats

# --- Output Version Info ---
echo "$VERSION" >~/version
