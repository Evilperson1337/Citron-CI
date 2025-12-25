#!/bin/bash
# ==============================================================================
# macOS Packaging Script for Citron
# ==============================================================================
# Packages Citron build into a DMG archive
# ==============================================================================

set -e

ARTIFACT_BASENAME="${1:-Citron-Nightly}"

echo "========================================"
echo "Packaging Citron for macOS"
echo "Artifact Basename: $ARTIFACT_BASENAME"
echo "========================================"

# Package macOS Build
echo "Packaging macOS build..."
cd citron
mkdir -p dist

# Find the .app bundle
APP_BUNDLE_PATH=$(find build -name "citron.app" | head -n 1)
if [ -z "$APP_BUNDLE_PATH" ]; then
  echo "::error::Could not find citron.app bundle after build!"
  exit 1
fi
echo "Found .app bundle at: $APP_BUNDLE_PATH"

# Run macdeployqt
MACDEPLOYQT_PATH="build/externals/qt/6.7.3/macos/bin/macdeployqt"
QT_LIB_PATH="build/externals/qt/6.7.3/macos/lib"
if [ ! -f "$MACDEPLOYQT_PATH" ]; then
  echo "::error::Could not find macdeployqt!"
  exit 1
fi

"$MACDEPLOYQT_PATH" "$APP_BUNDLE_PATH" -libpath="$QT_LIB_PATH" -verbose=1 -always-overwrite

# Handle dependencies and rpaths (all the complex library fixing logic)
FRAMEWORKS_PATH="$APP_BUNDLE_PATH/Contents/Frameworks"

# Create Vulkan ICD json to ensure bundled MoltenVK is used
echo "Setting up Vulkan ICD for bundled MoltenVK..."
VULKAN_ICD_DIR="$APP_BUNDLE_PATH/Contents/Resources/vulkan/icd.d"
mkdir -p "$VULKAN_ICD_DIR"
cat > "$VULKAN_ICD_DIR/MoltenVK_icd.json" << 'ICDEOF'
{
    "file_format_version": "1.0.0",
    "ICD": {
        "library_path": "../../../Frameworks/libMoltenVK.dylib",
        "api_version": "1.4.0",
        "is_portability_driver": true
    }
}
ICDEOF
echo "Created MoltenVK ICD at $VULKAN_ICD_DIR/MoltenVK_icd.json"

# Copy missing transitive dependencies
echo "Checking for missing transitive dependencies..."
copy_missing_deps() {
  find "$FRAMEWORKS_PATH" -name "*.dylib" -type f | while read -r dylib; do
    # Handle @rpath/ references
    otool -L "$dylib" 2>/dev/null | grep -E "^\s+@rpath/" | awk '{print $1}' | sed 's|@rpath/||' | while read -r dep; do
      if [ ! -f "$FRAMEWORKS_PATH/$dep" ]; then
        HOMEBREW_LIB=$(find /opt/homebrew/lib /opt/homebrew/Cellar /usr/local/lib -name "$dep" 2>/dev/null | head -1)
        if [ -n "$HOMEBREW_LIB" ] && [ -f "$HOMEBREW_LIB" ]; then
          echo "Copying missing @rpath dependency: $dep"
          cp "$HOMEBREW_LIB" "$FRAMEWORKS_PATH/"
          chmod u+w "$FRAMEWORKS_PATH/$dep"
          install_name_tool -id "@rpath/$dep" "$FRAMEWORKS_PATH/$dep" 2>/dev/null || true
        fi
      fi
    done
    # Handle absolute homebrew path references (critical for portability!)
    otool -L "$dylib" 2>/dev/null | grep -E "^\s+(/opt/homebrew|/usr/local)" | awk '{print $1}' | while read -r abs_dep; do
      dep_name=$(basename "$abs_dep")
      if [ ! -f "$FRAMEWORKS_PATH/$dep_name" ] && [ -f "$abs_dep" ]; then
        echo "Copying missing absolute-path dependency: $dep_name (from $abs_dep)"
        cp "$abs_dep" "$FRAMEWORKS_PATH/"
        chmod u+w "$FRAMEWORKS_PATH/$dep_name"
        install_name_tool -id "@rpath/$dep_name" "$FRAMEWORKS_PATH/$dep_name" 2>/dev/null || true
      fi
    done
  done
}

# Run multiple passes to catch nested dependencies
for i in 1 2 3 4 5; do
  echo "Pass $i: checking dependencies..."
  copy_missing_deps
done

# Fix rpaths in executable
EXECUTABLE_PATH="$APP_BUNDLE_PATH/Contents/MacOS/citron"
install_name_tool -add_rpath "@executable_path/../Frameworks" "$EXECUTABLE_PATH" 2>/dev/null || true

# Remove all hardcoded homebrew/system rpaths from executable - CRITICAL for portability
echo "Removing hardcoded rpaths from executable..."
otool -l "$EXECUTABLE_PATH" | grep -A2 LC_RPATH | grep "path " | awk '{print $2}' | while read -r rpath; do
  case "$rpath" in
    @executable_path*|@loader_path*|@rpath*)
      echo "Keeping relative rpath: $rpath"
      ;;
    *)
      echo "Removing absolute rpath: $rpath"
      install_name_tool -delete_rpath "$rpath" "$EXECUTABLE_PATH" 2>/dev/null || true
      ;;
  esac
done

# Fix rpaths in all dylibs
find "$FRAMEWORKS_PATH" -name "*.dylib" -type f | while read -r dylib; do
  dylib_name=$(basename "$dylib")
  install_name_tool -id "@rpath/$dylib_name" "$dylib" 2>/dev/null || true
  # Rewrite absolute paths to @rpath
  otool -L "$dylib" 2>/dev/null | grep -E "^\s+/" | awk '{print $1}' | while read -r dep; do
    dep_name=$(basename "$dep")
    if [ -f "$FRAMEWORKS_PATH/$dep_name" ]; then
      install_name_tool -change "$dep" "@rpath/$dep_name" "$dylib" 2>/dev/null || true
    fi
  done
  # Remove hardcoded rpaths from dylibs - CRITICAL for portability
  otool -l "$dylib" 2>/dev/null | grep -A2 LC_RPATH | grep "path " | awk '{print $2}' | while read -r rpath; do
    case "$rpath" in
      @executable_path*|@loader_path*|@rpath*)
        ;;
      *)
        echo "Removing absolute rpath from $dylib_name: $rpath"
        install_name_tool -delete_rpath "$rpath" "$dylib" 2>/dev/null || true
        ;;
    esac
  done
  # Add @loader_path rpath so dylibs can find their sibling dylibs
  install_name_tool -add_rpath "@loader_path" "$dylib" 2>/dev/null || true
done

# Fix executable's library references
otool -L "$EXECUTABLE_PATH" 2>/dev/null | grep -E "^\s+/" | awk '{print $1}' | while read -r dep; do
  dep_name=$(basename "$dep")
  if [ -f "$FRAMEWORKS_PATH/$dep_name" ]; then
    install_name_tool -change "$dep" "@rpath/$dep_name" "$EXECUTABLE_PATH" 2>/dev/null || true
  fi
done

# Fix framework library IDs
find "$FRAMEWORKS_PATH" -name "*.framework" -type d | while read -r framework_dir; do
  framework_name=$(basename "$framework_dir" .framework)
  framework_binary="$framework_dir/Versions/A/$framework_name"
  [ ! -f "$framework_binary" ] && framework_binary="$framework_dir/$framework_name"
  [ -f "$framework_binary" ] && install_name_tool -id "@rpath/$framework_name.framework/Versions/A/$framework_name" "$framework_binary" 2>/dev/null || true
done

# Codesign the app
chmod -R u+w "$APP_BUNDLE_PATH"
codesign --force --deep -s- "$APP_BUNDLE_PATH"

# Create the final DMG
echo "Creating final DMG..."
DMG_FILENAME="${ARTIFACT_BASENAME}-macos-universal.dmg"
hdiutil create -fs HFS+ -srcfolder "$APP_BUNDLE_PATH" -volname "Citron Nightly" "./$DMG_FILENAME"
mv "$DMG_FILENAME" ./dist/

echo "========================================"
echo "Packaging completed successfully!"
echo "Artifact: dist/$DMG_FILENAME"
echo "========================================"