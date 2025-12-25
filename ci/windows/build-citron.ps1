# ==============================================================================
# Windows Build Script for Citron
# ==============================================================================
# Builds Citron for Windows platforms
# ==============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$Arch = "x86_64"
)

Write-Host "========================================"
Write-Host "Building Citron for Windows"
Write-Host "Architecture: $Arch"
Write-Host "========================================"

# Determine CMake architecture argument
if ($Arch -eq "x86_64") {
    $cmakeArch = "x64"
} else {
    $cmakeArch = "ARM64"
}

# Configure CMake
Write-Host "Configuring CMake..."
cmake -B build -S . -G "Visual Studio 17 2022" -A $cmakeArch `
    -DCITRON_USE_BUNDLED_VCPKG=ON `
    -DCITRON_BUILD_TYPE=Nightly `
    -DCITRON_ENABLE_LTO=ON `
    -DCITRON_USE_BUNDLED_QT=ON `
    -DENABLE_QT6=ON `
    -DCITRON_TESTS=OFF `
    -DUSE_DISCORD_PRESENCE=ON `
    -DENABLE_WEB_SERVICE=ON `
    -DENABLE_OPENSSL=ON `
    -DCITRON_USE_AUTO_UPDATER=ON `
    -DCITRON_ENABLE_LIBARCHIVE=ON

# Build
Write-Host "Building Citron..."
cmake --build build --config Release --parallel

Write-Host "========================================"
Write-Host "Build completed successfully!"
Write-Host "========================================"