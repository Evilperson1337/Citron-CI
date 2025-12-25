# ==============================================================================
# Windows Build Script for Citron Nightly Builds
# ==============================================================================
# This script builds Citron for Windows platforms (x86_64, ARM64)
# It's called by the GitHub Actions workflow with appropriate parameters
#
# Usage: .\build.ps1 -Arch [x86_64|arm64] -ArtifactBasename [basename]
#   Arch: Target architecture (x86_64 or arm64)
#   ArtifactBasename: Base name for the output artifact
# ==============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$Arch = "x86_64",
    
    [Parameter(Mandatory=$false)]
    [string]$ArtifactBasename
)

Write-Host "========================================"
Write-Host "Building Citron for Windows ($Arch)"
Write-Host "Artifact basename: $ArtifactBasename"
Write-Host "========================================"

# Clone source
Write-Host "Cloning Citron source..."
git clone --recursive "https://git.citron-emu.org/Citron/Emulator.git" emulator

# Navigate to emulator directory
cd emulator

# Copy build scripts to emulator directory
Write-Host "Copying build scripts..."
Copy-Item "..\ci\windows\get-dependencies.ps1" -Destination ".\get-dependencies.ps1"
Copy-Item "..\ci\windows\build-citron.ps1" -Destination ".\build-citron.ps1"
Copy-Item "..\ci\windows\package-citron.ps1" -Destination ".\package-citron.ps1"

# Install dependencies
Write-Host "Installing dependencies..."
.\get-dependencies.ps1 -Arch $Arch

# Build Citron
Write-Host "Building Citron..."
.\build-citron.ps1 -Arch $Arch

# Package the build
Write-Host "Packaging build..."
.\package-citron.ps1 -ArtifactBasename $ArtifactBasename -Arch $Arch

Write-Host "========================================"
Write-Host "Build completed successfully!"
Write-Host "Artifacts located in: $(Resolve-Path .\dist)"
Write-Host "========================================"