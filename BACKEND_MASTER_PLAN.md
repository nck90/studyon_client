# STUDYON 백엔드 마스터 개발 계획

## 1. 문서 개요

- 제품명: `STUDYON`
- 문서명: `Backend Master Plan`
- 버전: `v1.0`
- 작성일: `2026-04-14`
- 목적: NestJS + PostgreSQL + Redis 기반으로 STUDYON 백엔드를 처음부터 프로덕션 수준으로 구축하기 위한 실행 계획을 정의한다.

---

## 2. 현재 상태

현재 워크스페이스에는 백엔드 코드가 없고, 아래 기획 산출물만 존재한다.

- [STUDYON_APP_DEFINITION.md](/Users/bagjun-won/studyon/STUDYON_APP_DEFINITION.md)
- [STUDYON_PRD.md](/Users/bagjun-won/studyon/STUDYON_PRD.md)
- [STUDYON_IA.md](/Users/bagjun-won/studyon/STUDYON_IA.md)
- [STUDYON_SCREEN_SPEC.md](/Users/bagjun-won/studyon/STUDYON_SCREEN_SPEC.md)
- [DB_SCHEMA.md](/Users/bagjun-won/studyon/DB_SCHEMA.md)
- [STUDYON_ERD.md](/Users/bagjun-won/studyon/STUDYON_ERD.md)
- [API_SPEC.md](/Users/bagjun-won/studyon/API_SPEC.md)

즉, 지금부터 해야 할 일은 `기획 문서 -> 실제 백엔드 시스템`으로 전환하는 것이다.

---

## 3. 목표

이번 백엔드 개발의 목표는 단순 MVP 서버가 아니라, 아래 조건을 만족하는 프로덕션 기준 시스템을 만드는 것이다.

- NestJS 기반의 명확한 모듈 구조
- PostgreSQL 기반의 안정적인 관계형 데이터 저장
- Redis 기반의 세션/캐시/실시간 보조 구조
- JWT 인증 및 권한 분리
- Swagger/OpenAPI 문서화
- 검증 가능한 테스트 체계
- Docker 기반 로컬/운영 실행 환경
- 프로덕션 배포 가능한 CI/CD 및 운영 설정
- 장애 대응 가능한 로깅/헬스체크/마이그레이션 구조

---

## 4. 기술 스택 결정

## 백엔드 런타임

- `Node.js 22 LTS`
- `NestJS`
- `TypeScript`
- `pnpm` 또는 `npm`

권장:

- `pnpm` 사용
- 이유: 설치 속도, lockfile 안정성, monorepo 확장성

## 데이터베이스

- `PostgreSQL 16`

## 캐시/세션/실시간 보조

- `Redis 7`

## ORM

- `Prisma`

선정 이유:

- 스키마 관리와 마이그레이션 일관성
- Type-safe 쿼리
- NestJS와 통합이 단순함
- 문서화와 유지보수성이 좋음

## 인증

- `JWT access token + refresh token`
- 학생/관리자/원장/TV 디스플레이 권한 분리

## 문서화

- `Swagger / OpenAPI`

## 테스트

- `Vitest` 또는 `Jest`
- NestJS 기본 호환성 때문에 초기에는 `Jest`가 더 무난
- e2e 테스트는 `Supertest`

## 인프라

- 로컬: `Docker Compose`
- 운영: `Docker` 컨테이너 배포
- Reverse proxy: `Nginx` 또는 `AWS ALB`
- CI/CD: `GitHub Actions`

## 관측성

- 로깅: `Pino`
- 헬스체크: `@nestjs/terminus`
- 에러 추적: `Sentry` 권장

---

## 5. 프로덕션 아키텍처

```text
Client Apps
├─ Student App
├─ Admin Web
├─ Director Web
└─ TV Display
        |
        v
API Gateway / Reverse Proxy
        |
        v
NestJS Backend
├─ Auth / RBAC
├─ Student Domain
├─ Attendance Domain
├─ Seat Domain
├─ Study Plan Domain
├─ Study Session Domain
├─ Study Log Domain
├─ Report / Ranking Domain
├─ Notification Domain
└─ Admin / Settings Domain
        |
        +--> PostgreSQL
        |
        +--> Redis
        |
        +--> Object Storage (optional future)
        |
        +--> Sentry / Logs / Monitoring
```

### Redis 사용 용도

- 로그인 세션 보조 저장
- refresh token blacklist / revoke 관리
- rate limiting
- 실시간 대시보드 캐시
- TV 송출 데이터 캐시
- 랭킹/집계 단기 캐시

---

## 6. 권장 저장소 구조

```text
studyon/
├─ apps/
│  └─ api/
│     ├─ src/
│     │  ├─ main.ts
│     │  ├─ app.module.ts
│     │  ├─ common/
│     │  ├─ config/
│     │  ├─ database/
│     │  ├─ auth/
│     │  ├─ users/
│     │  ├─ students/
│     │  ├─ seats/
│     │  ├─ attendances/
│     │  ├─ study-plans/
│     │  ├─ study-sessions/
│     │  ├─ study-logs/
│     │  ├─ reports/
│     │  ├─ rankings/
│     │  ├─ notifications/
│     │  ├─ settings/
│     │  ├─ display/
│     │  └─ admin/
│     ├─ test/
│     ├─ prisma/
│     ├─ package.json
│     └─ tsconfig.json
├─ infra/
│  ├─ docker/
│  ├─ compose/
│  └─ nginx/
├─ docs/
├─ .github/workflows/
└─ README.md
```

초기에는 단일 앱으로 시작하고, 이후 필요하면 worker나 scheduler를 분리한다.

---

## 7. NestJS 모듈 설계

## 코어 모듈

- `AppModule`
- `ConfigModule`
- `PrismaModule`
- `RedisModule`
- `HealthModule`
- `LoggingModule`

## 인증/권한

- `AuthModule`
- `UsersModule`
- `RolesGuard`
- `JwtAuthGuard`

## 학생 도메인

- `StudentsModule`
- `SeatsModule`
- `AttendancesModule`
- `StudyPlansModule`
- `StudySessionsModule`
- `StudyLogsModule`

## 집계/운영 도메인

- `ReportsModule`
- `RankingsModule`
- `NotificationsModule`
- `SettingsModule`
- `DisplayModule`
- `AdminModule`

## 백그라운드/배치

- `SchedulerModule`

예상 역할:

- 일간 집계 생성
- 주간/월간 집계 생성
- 랭킹 스냅샷 생성
- 미입실/비활동 알림 트리거

---

## 8. 구현 전략

한 번에 끝내기 위해서도 실제 구현은 계층적으로 가야 한다.  
순서는 `기반 공사 -> 핵심 학생 흐름 -> 관리자 운영 흐름 -> 집계/랭킹 -> 실시간/운영 -> 배포`가 맞다.

---

## 9. 단계별 실행 계획

## Phase 0. 초기 부트스트랩

### 목표

프로젝트 뼈대를 만들고 운영에 필요한 기반을 먼저 세운다.

### 작업 항목

- NestJS 프로젝트 생성
- TypeScript strict 설정
- ESLint + Prettier + import 정리
- 환경변수 관리 구조 구축
- Prisma 초기 설정
- PostgreSQL 연결
- Redis 연결
- Dockerfile 작성
- docker-compose 작성
- Swagger 기본 설정
- 글로벌 ValidationPipe, ExceptionFilter, Interceptor 설정
- Pino 로깅 설정
- 헬스체크 엔드포인트 생성

### 산출물

- 실행 가능한 API 서버
- `/health`
- `/docs`
- Prisma migration 초기 상태

### 완료 기준

- 로컬 Docker 환경에서 API/Postgres/Redis가 모두 뜬다.
- Swagger 문서가 열린다.
- 헬스체크가 DB/Redis 상태를 반환한다.

---

## Phase 1. 인증/권한/기준 데이터

### 목표

학생/관리자/원장/TV 권한 체계를 안정적으로 만든다.

### 작업 항목

- `users`, `students`, `admin_users`, `grades`, `classes`, `groups`, `seats`, `devices` 스키마 구현
- JWT access/refresh 토큰 발급
- 학생 번호/이름 로그인
- 관리자 이메일/비밀번호 로그인
- 현재 사용자 조회
- 로그아웃 / 세션 종료
- 중복 로그인 정책 구현
- Guard / Role decorator 구현
- 시드 데이터 구조 작성

### 산출물

- `POST /auth/student/login`
- `POST /auth/admin/login`
- `POST /auth/logout`
- `GET /auth/me`
- 기준 데이터 CRUD 일부

### 완료 기준

- 학생과 관리자 로그인 흐름이 모두 동작한다.
- 권한 없는 엔드포인트 접근 시 403이 일관되게 반환된다.

---

## Phase 2. 학생 핵심 루프

### 목표

학생의 하루 행동 흐름을 완결한다.

### 작업 항목

- 출결 도메인 구현
- 좌석 조회/배정/점유 상태 연동
- 오늘의 계획 CRUD
- 공부 세션 시작/일시정지/재시작/종료
- 휴식 시간 기록
- 학습량 기록
- 학생 홈 요약 API

### 우선 엔드포인트

- `GET /student/home`
- `GET /student/attendances/today`
- `POST /student/attendances/check-in`
- `POST /student/attendances/check-out`
- `GET /student/seats/my`
- `GET /student/seats/map`
- `GET /student/study-plans`
- `POST /student/study-plans`
- `PATCH /student/study-plans/{planId}`
- `POST /student/study-sessions/start`
- `POST /student/study-sessions/{sessionId}/pause`
- `POST /student/study-sessions/{sessionId}/resume`
- `POST /student/study-sessions/{sessionId}/end`
- `POST /student/study-logs`

### 완료 기준

- 학생이 입실부터 계획 작성, 공부 시작, 종료, 기록, 퇴실까지 한 사이클을 API만으로 완결할 수 있다.

---

## Phase 3. 관리자 운영 흐름

### 목표

관리자가 학생과 자습실을 실시간 운영할 수 있게 한다.

### 작업 항목

- 학생 목록/상세/등록/수정/삭제
- 좌석 관리 및 좌석 변경 요청 승인
- 일별 출결 조회
- 관리자 대시보드 요약
- 관리자 공지/알림 발송
- 감사 로그 기록

### 우선 엔드포인트

- `GET /admin/dashboard`
- `GET /admin/students`
- `POST /admin/students`
- `GET /admin/students/{studentId}`
- `PATCH /admin/students/{studentId}`
- `GET /admin/seats`
- `POST /admin/seats/{seatId}/assign`
- `GET /admin/attendances`
- `POST /admin/notifications`

### 완료 기준

- 관리자가 학생 상태와 좌석 상태를 조회하고 조작할 수 있다.
- 관리자 행위가 audit log로 남는다.

---

## Phase 4. 리포트/랭킹/TV

### 목표

학생 리포트, 관리자 학습 현황, 랭킹, TV 송출까지 운영 시각화를 완성한다.

### 작업 항목

- 일간/주간/월간 집계 로직
- 학생 리포트 API
- 관리자 학습 현황 API
- 랭킹 정책/스냅샷 생성
- TV 상태/랭킹/동기부여 API
- Redis 캐시 전략 적용

### 우선 엔드포인트

- `GET /student/reports/daily`
- `GET /student/reports/weekly`
- `GET /student/reports/monthly`
- `GET /student/rankings`
- `GET /admin/study-overview`
- `GET /admin/rankings`
- `GET /display/current`
- `GET /display/rankings`
- `GET /display/status`

### 완료 기준

- 학생은 개인 리포트를 볼 수 있고, 관리자와 TV는 집계 데이터를 안정적으로 조회할 수 있다.

---

## Phase 5. 실시간/배치/운영 안정화

### 목표

프로덕션 운영에 필요한 자동화와 안정성을 마무리한다.

### 작업 항목

- Nest scheduler 또는 queue 기반 배치 작업
- Redis 기반 rate limit
- WebSocket 또는 SSE 기반 실시간 갱신
- 비활동 감지 로직
- 자동 퇴실/세션 정리 정책
- 에러 핸들링 고도화
- 캐시 TTL 정책
- 장애 대응용 로그 컨텍스트 강화

### 완료 기준

- 대시보드/TV 데이터가 실시간 또는 준실시간으로 갱신된다.
- 정책성 자동 작업이 백그라운드에서 안정적으로 처리된다.

---

## Phase 6. 배포/운영/보안 마감

### 목표

실서비스 투입이 가능한 수준으로 마무리한다.

### 작업 항목

- 멀티스테이지 Dockerfile 최적화
- GitHub Actions CI
- 테스트, 린트, 빌드 파이프라인
- production 환경변수 템플릿
- migration 배포 전략
- 시드 전략 분리
- HTTPS/프록시 설정
- Sentry 연동
- 운영 로그 전략
- 백업/복구 전략 문서화

### 완료 기준

- 운영 환경에 배포 가능
- migration 포함 자동 배포 가능
- 장애 시 기본 원인 추적이 가능

---

## 10. Prisma 스키마 구현 계획

Prisma는 아래 순서로 작성하는 것이 좋다.

1. 기준 테이블
2. 인증/세션 테이블
3. 출결/좌석 테이블
4. 계획/세션/학습 기록 테이블
5. 집계/랭킹 테이블
6. 알림/정책 테이블

### Prisma 산출물

- `schema.prisma`
- 초기 migration
- seed script

### 주의점

- enum 남용보다 PostgreSQL enum 또는 Prisma enum을 명확히 통제
- soft delete 필요 테이블은 `deletedAt` 추가 고려
- snapshot/metrics 테이블은 집계 성능 위주 인덱스 설계

---

## 11. Redis 설계

## 필수 사용처

- refresh token revoke / blacklist
- 로그인 세션 상태 보조 캐시
- rate limiting
- 관리자 대시보드 캐시
- TV 랭킹 캐시

## 선택 사용처

- 실시간 타이머 tick 보조 상태
- 일간 집계 중복 실행 방지 lock

### 키 설계 예시

```text
auth:refresh:blacklist:{tokenId}
auth:session:{sessionId}
dashboard:summary:{date}:{classId}
display:ranking:{periodType}:{rankingType}
lock:daily-metrics:{date}
```

---

## 12. 보안 계획

## 인증/인가

- access token 짧게
- refresh token rotation 적용 권장
- role 기반 접근 제어
- 관리자/원장 API 분리

## 입력 검증

- class-validator 기반 DTO 검증
- whitelist, forbidNonWhitelisted 활성화

## 민감 정보

- password는 bcrypt/argon2 해시
- env는 vault 또는 배포 시 secret 주입
- PII 마스킹 로깅 고려

## 남용 방지

- 로그인 rate limit
- QR 토큰 만료
- 관리자 인증 실패 횟수 제한

---

## 13. 테스트 전략

## 단위 테스트

- 서비스 로직
- 정책 계산
- 랭킹 계산
- 집계 계산

## 통합 테스트

- Prisma + PostgreSQL 실제 연결
- Redis 연결
- 인증/권한 흐름

## E2E 테스트

- 학생 로그인 -> 입실 -> 계획 -> 공부 세션 -> 학습 기록 -> 퇴실
- 관리자 로그인 -> 학생 생성 -> 좌석 배정 -> 대시보드 조회
- TV 데이터 조회

## 최소 커버리지 목표

- 서비스 레이어 80% 이상
- 핵심 정책/집계 로직 90% 이상

---

## 14. 배포 전략

## 권장 환경

- `dev`
- `staging`
- `production`

## 권장 구성

- App 1~2 replicas
- PostgreSQL managed service 권장
- Redis managed service 권장
- object storage는 추후 도입

## 배포 흐름

1. PR 생성
2. CI: lint + test + build
3. staging 배포
4. smoke test
5. production 배포
6. migration 실행
7. health check 검증

## 롤백 전략

- Docker image tag rollback
- migration은 backward-safe하게 설계
- destructive migration은 분리 배포

---

## 15. 환경변수 설계

예상 `.env` 항목:

```text
NODE_ENV=
PORT=
APP_NAME=
APP_URL=

DATABASE_URL=
REDIS_URL=

JWT_ACCESS_SECRET=
JWT_REFRESH_SECRET=
JWT_ACCESS_EXPIRES_IN=
JWT_REFRESH_EXPIRES_IN=

SWAGGER_ENABLED=
LOG_LEVEL=
SENTRY_DSN=

CORS_ORIGIN=
RATE_LIMIT_TTL=
RATE_LIMIT_LIMIT=
```

운영에서는 `.env` 파일 커밋 금지, secret 주입 방식 사용.

---

## 16. 품질 기준

이번 백엔드 구현은 아래 기준을 만족해야 한다.

- DTO, Entity, Service, Controller 역할 분리
- 비즈니스 로직은 Controller에 두지 않음
- Prisma 접근은 Repository 또는 Service 경계에서 통제
- 모든 공개 API는 Swagger 문서 포함
- 모든 주요 도메인은 e2e 시나리오 보유
- migration 없는 스키마 변경 금지
- 환경변수 검증 없는 부팅 금지

---

## 17. 예상 개발 순서

실제 구현 순서는 아래가 가장 안정적이다.

1. 프로젝트 초기화
2. 공통 인프라 구축
3. Prisma schema 작성
4. 인증/권한 구현
5. 학생 핵심 루프 구현
6. 관리자 핵심 운영 구현
7. 집계/랭킹 구현
8. TV/API 캐시 구현
9. 테스트 보강
10. Docker/CI/CD/배포 구성
11. 운영 문서화

---

## 18. 리스크와 대응

## 리스크 1. 범위 과대

도메인이 많아서 한 번에 다 만들려다 구조가 무너질 수 있다.

대응:

- 초기부터 모듈 경계를 강하게 나눈다.
- 핵심 플로우 우선 구현 후 집계/실시간은 뒤로 둔다.

## 리스크 2. 집계/랭킹 정확도 문제

출결, 세션, 학습 기록 간 정합성이 흔들리면 리포트가 틀어진다.

대응:

- 원천 데이터 정합성 검증 테스트 작성
- 집계 로직은 독립 서비스/테스트로 분리

## 리스크 3. 실시간 상태 불일치

좌석 상태, 입실 상태, 세션 상태가 서로 어긋날 수 있다.

대응:

- 상태 전이 규칙 명확화
- 단일 트랜잭션 처리 우선
- Redis는 보조 캐시로만 사용

## 리스크 4. 운영 배포 초기에 장애 대응 미흡

대응:

- 헬스체크
- 구조화 로깅
- Sentry
- staging smoke test 필수

---

## 19. 이 계획으로 바로 개발할 때의 실행 원칙

이 계획 승인 후 구현은 아래 원칙으로 진행하는 것이 맞다.

- 먼저 프로젝트 부트스트랩과 인프라 파일부터 생성
- 다음으로 Prisma schema와 migration 작성
- 인증부터 학생 루프까지 end-to-end로 닫기
- 매 단계마다 테스트와 Swagger를 함께 작성
- 마지막에 배포를 붙이는 방식이 아니라, 초반부터 Docker/CI 구조를 같이 만든다

즉, `기능 개발 후 배포`가 아니라 `배포 가능한 구조 위에서 기능 개발`로 간다.

---

## 20. 최종 제안

이 프로젝트는 현재 문서화 수준이 충분하므로, 추가 기획 없이 바로 구현에 들어갈 수 있다.  
권장 실행 방식은 아래와 같다.

1. `NestJS 프로젝트 초기화 + Prisma + Redis + Docker`부터 생성
2. `Auth + Student Core Flow`를 첫 번째 완성 단위로 묶어 구현
3. 이후 `Admin Dashboard + Reporting + Ranking + Display` 순서로 확장
4. 동시에 `Swagger, Test, CI/CD, Production Config`를 병행 구축

이 계획을 기준으로 다음 턴부터는 실제 백엔드 프로젝트를 생성하고 구현을 시작하면 된다.

