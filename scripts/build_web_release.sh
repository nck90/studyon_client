#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADMIN_DIR="${ROOT_DIR}/apps/admin_web"
TV_DIR="${ROOT_DIR}/apps/tv_display_web"

build_next_app() {
  local app_dir="$1"
  local app_name="$2"

  cd "${app_dir}"

  if [[ -f package-lock.json ]]; then
    echo "[${app_name}] Installing dependencies with npm ci"
    npm ci
  else
    echo "[${app_name}] Installing dependencies with npm install"
    npm install
  fi

  echo "[${app_name}] Building standalone bundle"
  npm run build

  if [[ -d public ]]; then
    mkdir -p .next/standalone/public
    cp -R public/. .next/standalone/public/
  fi

  if [[ -d .next/static ]]; then
    mkdir -p .next/standalone/.next/static
    cp -R .next/static/. .next/standalone/.next/static/
  fi

  echo "[${app_name}] Standalone output ready: ${app_dir}/.next/standalone"
}

build_next_app "${ADMIN_DIR}" "admin_web"
build_next_app "${TV_DIR}" "tv_display_web"

echo
echo "Web release builds completed."
echo "Admin standalone: ${ADMIN_DIR}/.next/standalone"
echo "TV standalone: ${TV_DIR}/.next/standalone"
