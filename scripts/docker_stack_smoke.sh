#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${ROOT_DIR}/infra/compose/docker-compose.yml"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/infra/compose/.env}"
COMPOSE_ARGS=(-f "${COMPOSE_FILE}")

if [[ -f "${ENV_FILE}" ]]; then
  COMPOSE_ARGS=(--env-file "${ENV_FILE}" "${COMPOSE_ARGS[@]}")
fi

env_value() {
  local key="$1"
  local default_value="$2"

  if [[ -n "${!key:-}" ]]; then
    printf '%s\n' "${!key}"
    return
  fi

  if [[ -f "${ENV_FILE}" ]]; then
    local line
    line="$(grep -E "^[[:space:]]*${key}=" "${ENV_FILE}" | tail -n 1 || true)"
    if [[ -n "${line}" ]]; then
      line="${line#*=}"
      line="${line%\"}"
      line="${line#\"}"
      line="${line%\'}"
      line="${line#\'}"
      printf '%s\n' "${line}"
      return
    fi
  fi

  printf '%s\n' "${default_value}"
}

wait_for_url() {
  local name="$1"
  local url="$2"
  local attempts="${3:-60}"
  local delay_seconds="${4:-2}"

  printf 'Waiting for %s: %s\n' "${name}" "${url}"

  for ((attempt = 1; attempt <= attempts; attempt += 1)); do
    if curl -fsS "${url}" >/dev/null; then
      printf '%s is ready.\n' "${name}"
      return
    fi

    sleep "${delay_seconds}"
  done

  printf 'Timed out waiting for %s after %s attempts.\n' "${name}" "${attempts}" >&2
  return 1
}

cd "${ROOT_DIR}"

API_PORT="$(env_value API_PORT 3000)"
ADMIN_WEB_PORT="$(env_value ADMIN_WEB_PORT 11111)"
TV_WEB_PORT="$(env_value TV_WEB_PORT 11112)"
PARENT_WEB_PORT="$(env_value PARENT_WEB_PORT 11113)"

echo "[1/5] Validating compose configuration"
docker compose "${COMPOSE_ARGS[@]}" config >/dev/null

echo "[2/5] Building STUDYON images"
docker compose "${COMPOSE_ARGS[@]}" build api admin_web tv_display_web parent_web

echo "[3/5] Starting STUDYON stack"
docker compose "${COMPOSE_ARGS[@]}" up -d

echo "[4/5] Running HTTP smoke checks"
wait_for_url "API health" "http://127.0.0.1:${API_PORT}/api/v1/health"
wait_for_url "Admin web" "http://127.0.0.1:${ADMIN_WEB_PORT}"
wait_for_url "TV web" "http://127.0.0.1:${TV_WEB_PORT}"
wait_for_url "Parent web" "http://127.0.0.1:${PARENT_WEB_PORT}"

echo "[5/5] Current service status"
docker compose "${COMPOSE_ARGS[@]}" ps

echo
echo "STUDYON Docker stack smoke test completed."
