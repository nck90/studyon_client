#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[1/9] API install"
cd "${ROOT_DIR}/apps/api"
pnpm install --frozen-lockfile

echo "[2/9] API lint"
pnpm lint

echo "[3/9] API build"
pnpm build

echo "[4/9] API tests"
pnpm test --runInBand

echo "[5/9] Admin web lint and build"
cd "${ROOT_DIR}/apps/admin_web"
npm ci
npm run lint -- --max-warnings=0
npm run build

echo "[6/9] TV web lint and build"
cd "${ROOT_DIR}/apps/tv_display_web"
npm ci
npm run lint -- --max-warnings=0
npm run build

echo "[7/10] Parent web lint and build"
cd "${ROOT_DIR}/apps/parent_web"
npm ci
npm run lint -- --max-warnings=0
npm run build

echo "[8/10] Flutter dependencies"
cd "${ROOT_DIR}"
flutter pub get

echo "[9/10] Flutter analyze and tests"
flutter analyze apps/studyon_client packages/api_client packages/core
cd "${ROOT_DIR}/apps/studyon_client"
flutter test

echo "[10/10] Flutter Android debug build"
flutter build apk --debug

echo
echo "Release preflight completed."
