#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${ROOT_DIR}/infra/compose/docker-compose.yml"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/infra/compose/.env}"
COMPOSE_ARGS=(-f "${COMPOSE_FILE}")

if [[ -f "${ENV_FILE}" ]]; then
  COMPOSE_ARGS=(--env-file "${ENV_FILE}" "${COMPOSE_ARGS[@]}")
fi

cd "${ROOT_DIR}"

echo "[1/3] Validating compose configuration"
docker compose "${COMPOSE_ARGS[@]}" config >/dev/null

echo "[2/3] Building and starting STUDYON stack"
docker compose "${COMPOSE_ARGS[@]}" up -d --build

echo "[3/3] Current service status"
docker compose "${COMPOSE_ARGS[@]}" ps

echo
echo "STUDYON stack deployment completed."
echo "API health: http://127.0.0.1:${API_PORT:-3000}/api/v1/health"
echo "Admin web:  http://127.0.0.1:${ADMIN_WEB_PORT:-11111}"
echo "TV web:     http://127.0.0.1:${TV_WEB_PORT:-11112}"
echo "Parent web: http://127.0.0.1:${PARENT_WEB_PORT:-11113}"
