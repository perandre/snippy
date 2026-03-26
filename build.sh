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

echo ""
echo "✓ Built: $APP_BUNDLE"
echo ""
echo "To install:  cp -r $APP_BUNDLE /Applications/"
echo "To run:      open $APP_BUNDLE"
echo ""
echo "Shortcuts:"
echo "  ⌥+⌘+V     — Toggle Snippy popover"
echo "  ⌘+N        — Add new snippet"
echo "  ↑/↓        — Navigate snippets"
echo "  ↵           — Copy selected snippet"
echo "  Esc         — Dismiss"
