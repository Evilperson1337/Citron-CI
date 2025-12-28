#!/bin/bash
# ==============================================================================
# macOS Dependency Installation Script
# ==============================================================================
# Installs all required dependencies for building Citron on macOS
# ==============================================================================

set -e

echo "========================================"
echo "Installing macOS Dependencies"
echo "========================================"

# Install System Dependencies via Homebrew
echo "Installing Homebrew dependencies..."
brew install ccache ninja boost catch2 cmake enet fmt ffmpeg glslang hidapi libvpx lld llvm nasm nlohmann-json openal-soft sdl2 molten-vk vulkan-headers vulkan-loader webp lz4 zstd openssl@3 pkg-config libusb opus python@3.12

echo "========================================"
echo "Dependencies installed successfully!"
echo "========================================"