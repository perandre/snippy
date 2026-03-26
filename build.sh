#!/bin/bash
set -e

APP_NAME="Snippy"
BUILD_DIR=".build/app"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "Building $APP_NAME..."
swift build -c release 2>&1

echo "Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy binary
cp "$(swift build -c release --show-bin-path)/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"

# Copy Info.plist
cp Info.plist "$APP_BUNDLE/Contents/"

# Create PkgInfo
echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

# Install to Applications
pkill -f "Snippy.app" 2>/dev/null || true
sleep 0.3
rm -rf "/Applications/$APP_NAME.app"
cp -r "$APP_BUNDLE" /Applications/

echo ""
echo "✓ Built and installed to /Applications/$APP_NAME.app"
echo "  Run:  open /Applications/$APP_NAME.app"
echo ""
echo "Shortcuts:"
echo "  ⌥+⌘+V     — Toggle Snippy popover"
echo "  ⌘+N        — Add new snippet"
echo "  ↑/↓        — Navigate snippets"
echo "  ↵           — Copy selected snippet"
echo "  Esc         — Dismiss"
