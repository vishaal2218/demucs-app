#!/bin/zsh
# Builds Demucs Splitter.app from the AppleScript source and installs it into /Applications.
# Usage: ./build.sh
set -euo pipefail

HERE="${0:A:h}"
APP_NAME="Demucs Splitter"
BUNDLE_ID="com.vishal.demucs-splitter"
VERSION="1.0"
BUILD_DIR="$HERE/build"
APP="$BUILD_DIR/$APP_NAME.app"
INSTALLED="/Applications/$APP_NAME.app"

echo "Building icon..."
ICONSET="$BUILD_DIR/AppIcon.iconset"
rm -rf "$BUILD_DIR" && mkdir -p "$ICONSET"
swift "$HERE/icon/make-icon.swift" "$BUILD_DIR/icon-1024.png" >/dev/null
for s in 16 32 128 256 512; do
  sips -z $s $s "$BUILD_DIR/icon-1024.png" --out "$ICONSET/icon_${s}x${s}.png" >/dev/null
  sips -z $((s*2)) $((s*2)) "$BUILD_DIR/icon-1024.png" --out "$ICONSET/icon_${s}x${s}@2x.png" >/dev/null
done
iconutil -c icns "$ICONSET" -o "$BUILD_DIR/AppIcon.icns"

echo "Compiling app..."
osacompile -o "$APP" "$HERE/$APP_NAME.applescript"

# Swap the default script icon for ours (Assets.car would override it, so remove it).
rm -f "$APP/Contents/Resources/Assets.car" "$APP/Contents/Resources/droplet.icns"
cp "$BUILD_DIR/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"

PLIST="$APP/Contents/Info.plist"
setkey() { /usr/libexec/PlistBuddy -c "Delete :$1" "$PLIST" 2>/dev/null || true; /usr/libexec/PlistBuddy -c "Add :$1 string $2" "$PLIST"; }
/usr/libexec/PlistBuddy -c "Delete :CFBundleIconName" "$PLIST" 2>/dev/null || true
setkey CFBundleIconFile "AppIcon"
setkey CFBundleIdentifier "$BUNDLE_ID"
setkey CFBundleName "$APP_NAME"
setkey CFBundleDisplayName "$APP_NAME"
setkey CFBundleShortVersionString "$VERSION"
setkey CFBundleVersion "$VERSION"
setkey LSApplicationCategoryType "public.app-category.music"
setkey NSHumanReadableCopyright "Splits songs into stems with Demucs."

codesign --force --deep -s - "$APP"

echo "Installing to /Applications..."
pkill -f "$APP_NAME.app/Contents/MacOS/droplet" 2>/dev/null || true
rm -rf "$INSTALLED"
ditto "$APP" "$INSTALLED"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$INSTALLED"
touch "$INSTALLED"

echo "Done: $INSTALLED"
