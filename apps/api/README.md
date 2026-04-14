# STUDYON API

Production-grade NestJS backend for STUDYON using PostgreSQL, Redis, Prisma, Swagger, and Docker.

## Stack

- NestJS
- PostgreSQL
- Redis
- Prisma
- Swagger
- Pino
- Docker / Docker Compose

## Run locally

1. Copy `.env.example` to `.env`.
2. Start infrastructure:

```bash
docker compose -f ../../infra/compose/docker-compose.yml up -d postgres redis
```

3. Install dependencies and generate Prisma client:

```bash
pnpm install
pnpm prisma:generate
```

4. Run migrations and seed:

```bash
pnpm prisma:migrate:dev
pnpm prisma:seed
```

5. Start the server:

```bash
pnpm start:dev
```

## Important endpoints

- `GET /api/v1/health`
- `GET /docs`
- `POST /api/v1/auth/student/login`
- `POST /api/v1/auth/student/auto-login`
- `POST /api/v1/auth/student/qr-token`
- `POST /api/v1/auth/admin/login`
- `GET /api/v1/student/home`
- `GET /api/v1/admin/dashboard`
- `GET /api/v1/display/current`

## Production automation

- Idle sessions are expired automatically based on `SESSION_IDLE_TIMEOUT_MINUTES`.
- Attendance can be auto-checked-out when the active attendance policy enables it.
- Scheduled notifications, absence alerts, break-over alerts, and goal shortfall alerts run on cron.

## Default seed credentials

- Email: `admin@studyon.local`
- Password: `ChangeMe123!`
- Student no: `2026001`
- Student name: `홍길동`
