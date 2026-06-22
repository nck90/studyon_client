#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${ROOT_DIR}/infra/compose/docker-compose.yml"
COMPOSE_ENV_FILE="${COMPOSE_ENV_FILE:-${ROOT_DIR}/infra/compose/.env}"
API_DIR="${ROOT_DIR}/apps/api"
API_ENV_FILE="${API_DIR}/.env"
FALLBACK_ENV_FILE="${API_DIR}/.env.example"
ACTIVE_ENV_FILE=""
COMPOSE_ARGS=(-f "${COMPOSE_FILE}")

if [[ -f "${COMPOSE_ENV_FILE}" ]]; then
  COMPOSE_ARGS=(--env-file "${COMPOSE_ENV_FILE}" "${COMPOSE_ARGS[@]}")
fi

cd "${ROOT_DIR}"

echo "[1/5] Starting postgres and redis"
docker compose "${COMPOSE_ARGS[@]}" up -d postgres redis

echo "[2/5] Installing API dependencies"
cd "${API_DIR}"
pnpm install --frozen-lockfile

if [[ -f "${API_ENV_FILE}" ]]; then
  ACTIVE_ENV_FILE="${API_ENV_FILE}"
elif [[ -f "${FALLBACK_ENV_FILE}" ]]; then
  ACTIVE_ENV_FILE="${FALLBACK_ENV_FILE}"
fi

if [[ -n "${ACTIVE_ENV_FILE}" ]]; then
  export DATABASE_URL="$(grep '^DATABASE_URL=' "${ACTIVE_ENV_FILE}" | cut -d= -f2-)"
  export REDIS_URL="$(grep '^REDIS_URL=' "${ACTIVE_ENV_FILE}" | cut -d= -f2-)"
fi

echo "[3/5] Running Prisma generate and migrations"
pnpm prisma:generate
pnpm prisma:migrate:deploy

echo "[4/5] Building API"
pnpm build

echo "[5/5] Starting production API container"
cd "${ROOT_DIR}"
docker compose "${COMPOSE_ARGS[@]}" up -d --build api

echo
echo "API deployment completed."
echo "Health check: http://127.0.0.1:3000/api/v1/health"
