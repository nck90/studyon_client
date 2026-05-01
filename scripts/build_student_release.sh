#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLIENT_DIR="${ROOT_DIR}/apps/studyon_client"

export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:3000}"
APP_ENV="${APP_ENV:-prod}"
ENABLE_LOGGING="${ENABLE_LOGGING:-false}"
DEVICE_CODE="${DEVICE_CODE:-studyon_client_release}"

cd "${CLIENT_DIR}"

echo "[1/3] Fetching Flutter dependencies"
flutter pub get

echo "[2/3] Building Android release APK"
flutter build apk --release \
  --dart-define=API_BASE_URL="${API_BASE_URL}" \
  --dart-define=APP_ENV="${APP_ENV}" \
  --dart-define=ENABLE_LOGGING="${ENABLE_LOGGING}" \
  --dart-define=DEVICE_CODE="${DEVICE_CODE}"

echo "[3/3] Building iOS without codesign"
flutter build ios --release --no-codesign \
  --dart-define=API_BASE_URL="${API_BASE_URL}" \
  --dart-define=APP_ENV="${APP_ENV}" \
  --dart-define=ENABLE_LOGGING="${ENABLE_LOGGING}" \
  --dart-define=DEVICE_CODE="${DEVICE_CODE}"

echo
echo "Student release builds completed."
echo "APK: ${CLIENT_DIR}/build/app/outputs/flutter-apk/app-release.apk"
echo "iOS archive assets: ${CLIENT_DIR}/build/ios/iphoneos"
