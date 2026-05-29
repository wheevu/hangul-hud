#!/bin/bash
set -euo pipefail

APP_NAME="HangulHUD"
BUILD_DIR=".build"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS}/MacOS"
RESOURCES_DIR="${CONTENTS}/Resources"

echo "Building ${APP_NAME} in release mode..."
swift build -c release 2>&1

# Find the built binary
BINARY="${BUILD_DIR}/release/${APP_NAME}"
if [ ! -f "$BINARY" ]; then
    echo "Error: Binary not found at ${BINARY}"
    exit 1
fi

# Clean previous bundle
rm -rf "${APP_BUNDLE}"

# Create .app bundle structure
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy binary
cp "${BINARY}" "${MACOS_DIR}/${APP_NAME}"
chmod +x "${MACOS_DIR}/${APP_NAME}"

# Copy app icon
cp "HangulHUD/Resources/AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"

# Copy SwiftPM resource bundles, including bundled fonts.
for RESOURCE_BUNDLE in "${BUILD_DIR}"/release/*.bundle; do
    if [ -d "${RESOURCE_BUNDLE}" ]; then
        cp -R "${RESOURCE_BUNDLE}" "${RESOURCES_DIR}/"
    fi
done

# Create Info.plist (resolve EXECUTABLE_NAME placeholder)
sed "s/\$(EXECUTABLE_NAME)/${APP_NAME}/g" "HangulHUD/Info.plist" > "${CONTENTS}/Info.plist"

# Ad-hoc code sign to avoid Gatekeeper issues
echo "Code signing (ad-hoc)..."
codesign --force --deep --sign - "${APP_BUNDLE}" 2>/dev/null

echo ""
echo "Done! Built ${APP_BUNDLE}"
echo ""
echo "To install:"
echo "  1. Drag ${APP_BUNDLE} to /Applications"
echo "  2. Double-click to launch (runs in menu bar, no dock icon)"
echo ""
echo "To auto-start at login:"
echo "  System Settings → General → Login Items → add ${APP_NAME}"
