#!/bin/bash
set -e

APP_NAME="McpSwitcher"
VERSION="1.0.0"
BUILD_DIR=".build/release"
DMG_DIR="dmg_build"
APP_BUNDLE="${DMG_DIR}/${APP_NAME}.app"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"

echo "🔨 Creating DMG package for ${APP_NAME}..."

# Clean up previous build
rm -rf "${DMG_DIR}"
rm -f "${DMG_NAME}"

# Create app bundle structure
echo "📦 Creating app bundle..."
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy binary
cp "${BUILD_DIR}/mcp-tray" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Create Info.plist
cat > "${APP_BUNDLE}/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.bivex.mcpswitcher</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 Bivex. All rights reserved.</string>
</dict>
</plist>
PLIST

# Create simple icon (optional - using text-based icon for now)
# If you have an icon file, copy it here:
# cp icon.icns "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"

# Copy CLI tool to Resources
mkdir -p "${APP_BUNDLE}/Contents/Resources/bin"
cp "${BUILD_DIR}/mcp-switcher" "${APP_BUNDLE}/Contents/Resources/bin/"
chmod +x "${APP_BUNDLE}/Contents/Resources/bin/mcp-switcher"

# Copy documentation
cp README.md "${DMG_DIR}/" 2>/dev/null || echo "No README.md found"
cp INSTALL.md "${DMG_DIR}/" 2>/dev/null || echo "No INSTALL.md found"

# Create Applications symlink for easy installation
ln -s /Applications "${DMG_DIR}/Applications"

echo "💿 Creating DMG..."
# Create DMG using hdiutil
hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${DMG_DIR}" \
    -ov -format UDZO \
    "${DMG_NAME}"

# Show result
echo ""
echo "✅ DMG package created successfully!"
echo "📦 Package: ${DMG_NAME}"
echo "📊 Size: $(du -h "${DMG_NAME}" | cut -f1)"
echo ""
echo "🎯 To install:"
echo "   1. Open ${DMG_NAME}"
echo "   2. Drag ${APP_NAME}.app to Applications folder"
echo "   3. Launch from Applications or menu bar"
echo ""
