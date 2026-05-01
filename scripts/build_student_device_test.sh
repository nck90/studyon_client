#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLIENT_DIR="${ROOT_DIR}/apps/studyon_client"

export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:3000}"
APP_ENV="${APP_ENV:-staging}"
ENABLE_LOGGING="${ENABLE_LOGGING:-true}"
DEVICE_CODE="${DEVICE_CODE:-studyon_client_device_test}"

cd "${CLIENT_DIR}"

echo "[1/2] Fetching Flutter dependencies"
flutter pub get

echo "[2/2] Building Android debug APK for real-device smoke testing"
flutter build apk --debug \
  --dart-define=API_BASE_URL="${API_BASE_URL}" \
  --dart-define=APP_ENV="${APP_ENV}" \
  --dart-define=ENABLE_LOGGING="${ENABLE_LOGGING}" \
  --dart-define=DEVICE_CODE="${DEVICE_CODE}"

echo
echo "Device test APK completed."
echo "APK: ${CLIENT_DIR}/build/app/outputs/flutter-apk/app-debug.apk"
echo "Install example: adb install -r ${CLIENT_DIR}/build/app/outputs/flutter-apk/app-debug.apk"
