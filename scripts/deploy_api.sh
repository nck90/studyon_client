#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="${ROOT_DIR}/infra/compose/docker-compose.yml"
API_DIR="${ROOT_DIR}/apps/api"
ENV_FILE="${API_DIR}/.env"
FALLBACK_ENV_FILE="${API_DIR}/.env.example"
ACTIVE_ENV_FILE=""

cd "${ROOT_DIR}"

echo "[1/5] Starting postgres and redis"
docker compose -f "${COMPOSE_FILE}" up -d postgres redis

echo "[2/5] Installing API dependencies"
cd "${API_DIR}"
pnpm install --frozen-lockfile

if [[ -f "${ENV_FILE}" ]]; then
  ACTIVE_ENV_FILE="${ENV_FILE}"
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
docker compose -f "${COMPOSE_FILE}" up -d --build api

echo
echo "API deployment completed."
echo "Health check: http://127.0.0.1:3000/api/v1/health"
