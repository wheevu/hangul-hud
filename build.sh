#!/bin/bash
set -euo pipefail

APP_NAME="HangulHUD"
BIN_DIR="$(swift build -c release --show-bin-path)"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS}/MacOS"
RESOURCES_DIR="${CONTENTS}/Resources"

build_dmg() {
  echo "Building ${APP_NAME} in release mode..."
  swift build -c release 2>&1

  # Find the built binary
  BINARY="${BIN_DIR}/${APP_NAME}"
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
  for RESOURCE_BUNDLE in "${BIN_DIR}"/*.bundle; do
    if [ -d "${RESOURCE_BUNDLE}" ]; then
      cp -R "${RESOURCE_BUNDLE}" "${RESOURCES_DIR}/"
    fi
  done
  if [ ! -d "${RESOURCES_DIR}/"*"${APP_NAME}".bundle ]; then
    echo "Error: No resource bundle found in ${BIN_DIR}"
    exit 1
  fi

  # Create Info.plist (resolve EXECUTABLE_NAME placeholder)
  sed "s/\$(EXECUTABLE_NAME)/${APP_NAME}/g" "HangulHUD/Info.plist" > "${CONTENTS}/Info.plist"

  # Ad-hoc code sign to avoid Gatekeeper issues
  echo "Code signing (ad-hoc)..."
  codesign --force --deep --sign - "${APP_BUNDLE}" 2>/dev/null

  # Create DMG
  DMG_NAME="${APP_NAME}.dmg"
  DMG_TEMP="${APP_NAME}.dmg.tmp"
  STAGING_DIR="${DMG_TEMP}/staging"

  echo "Creating DMG..."
  rm -rf "${DMG_TEMP}"
  mkdir -p "${STAGING_DIR}"

  cp -R "${APP_BUNDLE}" "${STAGING_DIR}/"
  ln -s /Applications "${STAGING_DIR}/Applications"

  hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${STAGING_DIR}" \
    -ov -format UDZO \
    -fs HFS+ \
    "${DMG_NAME}" 2>/dev/null

  rm -rf "${DMG_TEMP}"

  echo ""
  echo "Done! Built ${DMG_NAME}"
}

release() {
  local version="$1"
  shift

  # Parse optional --notes flag
  local notes=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --notes) notes="$2"; shift 2 ;;
      *) echo "Unknown option: $1"; exit 1 ;;
    esac
  done

  # Verify working tree is clean
  if [ -n "$(git status --porcelain)" ]; then
    echo "Error: Working tree has uncommitted changes. Commit or stash them first."
    exit 1
  fi

  # Ensure tag doesn't already exist
  if git rev-parse "$version" >/dev/null 2>&1; then
    echo "Error: Tag $version already exists."
    exit 1
  fi

  build_dmg

  # Build release notes
  if [ -z "$notes" ]; then
    notes_file=$(mktemp)
    cat > "$notes_file" <<- EOF
## Changes

- _Fill in the release highlights here._

## Download

\`${APP_NAME}.dmg\` — drag to Applications.
EOF
    ${EDITOR:-vi} "$notes_file"
    notes=$(cat "$notes_file")
    rm -f "$notes_file"
  fi

  # Create GitHub release and upload DMG
  echo "Creating GitHub release $version..."
  gh release create "$version" "${APP_NAME}.dmg" \
    --title "${APP_NAME} ${version}" \
    --notes "$notes"

  echo ""
  echo "Released! https://github.com/wheevu/${APP_NAME}/releases/tag/${version}"
}

case "${1:-}" in
  release)
    if [ -z "${2:-}" ]; then
      echo "Usage: $0 release <version> [--notes \"...\"]"
      echo ""
      echo "Examples:"
      echo "  $0 release v1.0.0"
      echo "  $0 release v1.0.0 --notes \"First public release\""
      exit 1
    fi
    release "${2}" "${@:3}"
    ;;
  *)
    build_dmg
    ;;
esac
