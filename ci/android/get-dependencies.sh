#!/bin/bash
# ==============================================================================
# Android Dependency Installation Script
# ==============================================================================
# Installs all required dependencies for building Citron on Android
# ==============================================================================

set -e

echo "========================================"
echo "Installing Android Dependencies"
echo "========================================"

# Check if Android SDK is already cached
if [ -d "$ANDROID_HOME" ] && [ -d "$ANDROID_NDK_HOME" ]; then
    echo "Using cached Android SDK and NDK..."
    echo "ANDROID_HOME: $ANDROID_HOME"
    echo "ANDROID_NDK_HOME: $ANDROID_NDK_HOME"
    
    # Still need to install system dependencies even if SDK is cached
    echo "Installing system dependencies..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq wget unzip curl git cmake build-essential pkg-config zip glslang-tools nasm perl autoconf automake libtool yasm ccache
    
    echo "========================================"
    echo "Dependencies already available from cache!"
    echo "========================================"
    exit 0
fi

# Install dependencies
echo "Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq wget unzip curl git cmake build-essential pkg-config zip glslang-tools nasm perl autoconf automake libtool yasm ccache

# Setup JDK 17
echo "Setting up JDK 17..."
echo "JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-amd64" >> $GITHUB_ENV
echo "/usr/lib/jvm/temurin-17-jdk-amd64/bin" >> $GITHUB_PATH

# Install Android SDK
echo "Installing Android SDK..."
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip -q commandlinetools-linux-11076708_latest.zip
mkdir -p android-sdk/cmdline-tools
mv cmdline-tools android-sdk/cmdline-tools/latest
export ANDROID_HOME=$PWD/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# Accept licenses and install NDK
echo "Installing Android NDK..."
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses > /dev/null || true
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "ndk;26.1.10909125"
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/26.1.10909125

echo "========================================"
echo "Dependencies installed successfully!"
echo "ANDROID_HOME: $ANDROID_HOME"
echo "ANDROID_NDK_HOME: $ANDROID_NDK_HOME"
echo "========================================"