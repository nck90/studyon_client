#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/apps/studyon_client"
ARCHIVE_PATH="${ARCHIVE_PATH:-$APP_DIR/build/ios/archive/Runner.xcarchive}"
EXPORT_PATH="${EXPORT_PATH:-$APP_DIR/build/ios/ipa}"
EXPORT_OPTIONS_PLIST="${EXPORT_OPTIONS_PLIST:-$APP_DIR/ios/ExportOptions/TestFlight.plist}"

cd "$APP_DIR"

flutter pub get
flutter build ios --release --no-codesign

xcodebuild \
  -workspace ios/Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  archive

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
  -exportPath "$EXPORT_PATH"

echo
echo "Archive: $ARCHIVE_PATH"
echo "Export:  $EXPORT_PATH"
