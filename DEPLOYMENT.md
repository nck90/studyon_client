# STUDYON Deployment

학생 앱, 백엔드 API, 관리자 웹, TV 웹을 운영 환경으로 올릴 때 기준이 되는 문서다.

## 1. Current deployment scope

- Backend API: NestJS + Prisma + PostgreSQL + Redis
- Student client: Flutter mobile app
- Admin web: Next.js standalone server
- TV display web: Next.js standalone server
- Parent web: Next.js standalone read-only parent report portal
- Default server model: one Linux host running Docker Compose

## 2. Single-server Docker stack

기본 배포 단위는 `infra/compose/docker-compose.yml`이다. 이 스택은 PostgreSQL, Redis, API, Admin web, TV display web, 학생 이미지 업로드 볼륨을 함께 띄운다.

1. 서버에 Docker와 Docker Compose v2를 설치한다.
2. env 템플릿을 복사하고 운영 값을 채운다.

```bash
cp infra/compose/.env.example infra/compose/.env
vi infra/compose/.env
```

3. 전체 스택을 빌드하고 실행한다.

```bash
chmod +x scripts/deploy_stack.sh
./scripts/deploy_stack.sh
```

4. 배포 후 확인한다.

```bash
curl http://127.0.0.1:3000/api/v1/health
curl -I http://127.0.0.1:11111
curl -I http://127.0.0.1:11112
```

빌드, 실행, HTTP 확인을 한 번에 검증하려면 smoke 스크립트를 사용한다.

```bash
chmod +x scripts/docker_stack_smoke.sh
./scripts/docker_stack_smoke.sh
```

운영 서버에서는 `API_PORT`, `ADMIN_WEB_PORT`, `TV_WEB_PORT`를 방화벽과 reverse proxy 정책에 맞춰 열고, public TLS termination은 Nginx/Caddy/로드밸런서에서 처리한다.

## 3. Required environment

### Compose env

`infra/compose/.env.example` 기준:

```env
POSTGRES_USER=studyon
POSTGRES_PASSWORD=replace-with-strong-postgres-password
POSTGRES_DB=studyon
POSTGRES_PORT=5432
REDIS_PORT=6379
API_PORT=3000
ADMIN_WEB_PORT=11111
TV_WEB_PORT=11112
PARENT_WEB_PORT=11113

APP_URL=https://api.example.com
CORS_ORIGIN=https://admin.example.com,https://tv.example.com,https://parent.example.com
JWT_ACCESS_SECRET=replace-with-strong-access-secret
JWT_REFRESH_SECRET=replace-with-strong-refresh-secret
PARENT_PORTAL_SECRET=replace-with-strong-parent-secret
DEFAULT_ADMIN_EMAIL=admin@studyon.local
DEFAULT_ADMIN_PASSWORD=replace-with-strong-admin-password
SWAGGER_ENABLED=false
LOG_LEVEL=info
ADMIN_API_URL=http://api:3000
TV_API_URL=http://api:3000
PARENT_API_URL=http://api:3000
PARENT_WEB_PUBLIC_URL=https://parent.example.com
```

### API-only env

`apps/api/.env`로 API만 로컬 또는 별도 서버에서 실행할 때는 아래 값을 사용한다.

```env
NODE_ENV=production
PORT=3000
APP_NAME=STUDYON API
APP_URL=https://api.example.com
CORS_ORIGIN=https://admin.example.com,https://tv.example.com
DATABASE_URL=postgresql://USER:PASSWORD@HOST:5432/studyon?schema=public
REDIS_URL=redis://HOST:6379
JWT_ACCESS_SECRET=replace-with-strong-access-secret
JWT_REFRESH_SECRET=replace-with-strong-refresh-secret
SWAGGER_ENABLED=false
LOG_LEVEL=info
PARENT_PORTAL_SECRET=replace-with-strong-parent-secret
DEFAULT_ADMIN_EMAIL=admin@studyon.local
DEFAULT_ADMIN_PASSWORD=replace-with-strong-admin-password
MEDIA_UPLOAD_DIR=/var/lib/studyon/student-media
```

### Student app

Flutter release 빌드 시 아래 `dart-define` 값을 사용한다.

```text
API_BASE_URL=https://api.example.com
APP_ENV=prod
ENABLE_LOGGING=false
DEVICE_CODE=studyon_client_release
```

## 4. Release preflight

코드 변경 후 릴리즈 후보는 아래 스크립트로 검증한다.

```bash
chmod +x scripts/preflight_release.sh
./scripts/preflight_release.sh
```

이 스크립트는 API lint/build/test, Admin web lint/build, TV web lint/build, Flutter analyze/test/debug APK build를 실행한다.

개별 명령이 필요하면 아래 기준을 사용한다.

```bash
cd apps/api && pnpm lint && pnpm build && pnpm test --runInBand
cd apps/admin_web && npm run lint -- --max-warnings=0 && npm run build
cd apps/tv_display_web && npm run lint -- --max-warnings=0 && npm run build
cd apps/parent_web && npm run lint -- --max-warnings=0 && npm run build
flutter analyze apps/studyon_client packages/api_client packages/core
cd apps/studyon_client && flutter test && flutter build apk --debug
```

Docker 배포 후보까지 확인할 때는 release preflight 후 아래 smoke test를 이어서 실행한다.

```bash
./scripts/docker_stack_smoke.sh
```

## 5. Student app release build

```bash
chmod +x scripts/build_student_release.sh
API_BASE_URL=https://api.example.com ./scripts/build_student_release.sh
```

출력물:

- Android APK: `apps/studyon_client/build/app/outputs/flutter-apk/app-release.apk`
- iOS release build: `apps/studyon_client/build/ios/iphoneos`

주의:

- Android는 현재 release signing 설정이 없다. 실제 배포 전 keystore를 넣고 `android/app/build.gradle.kts`에 signing config를 추가해야 한다.
- iOS는 `--no-codesign`으로 빌드한다. 실제 TestFlight/App Store 배포는 Xcode 서명 설정이 필요하다.

## 6. iOS TestFlight archive

현재 iOS 프로젝트 설정:

- Bundle ID: `com.studyon.studyonClient`
- Display name: `자습ON`
- Team ID: `2PHB3Z8AV5`

서명과 프로비저닝이 Xcode에 정상 연결되어 있다면 아래 스크립트로 아카이브와 export를 진행할 수 있다.

```bash
chmod +x scripts/build_ios_testflight.sh
./scripts/build_ios_testflight.sh
```

출력물:

- Archive: `apps/studyon_client/build/ios/archive/Runner.xcarchive`
- Export: `apps/studyon_client/build/ios/ipa`

## 7. Launch checklist

- `infra/compose/.env`에 운영 secret과 domain 값을 주입했다.
- PostgreSQL named volume과 백업 정책을 확인했다.
- Redis AOF persistence와 백업/복구 정책을 확인했다.
- `studyon-media-data` volume이 유지되고 백업 대상에 포함된다.
- `/api/v1/health`에서 `postgres`, `redis`, `media` 상태가 정상이다.
- Prisma migrations가 컨테이너 시작 시 적용된다.
- Seed admin password를 운영 값으로 교체했다.
- Student app을 production `API_BASE_URL`로 빌드했다.
- Student device-test APK를 실기기에 설치해 로그인, 체크인, 공부 시작, 목표 이미지 표시를 smoke-test했다.
- `./scripts/docker_stack_smoke.sh`로 compose build/up과 API/Admin/TV HTTP 응답을 확인했다.
- Admin web과 TV web이 reverse proxy 뒤에서 접근되고, 두 web의 `/api/*` rewrite가 API 컨테이너로 연결된다.
- Parent web이 reverse proxy 뒤에서 접근되고, 관리자 웹의 학부모 공유 링크 `PARENT_WEB_PUBLIC_URL`이 실제 parent domain을 가리킨다.
- CORS는 운영 web origin만 허용한다.
- Swagger는 운영에서 비활성화했다.

## 8. Docker build troubleshooting

Docker Desktop 또는 BuildKit에서 아래와 같은 오류가 나면 애플리케이션 코드보다 Docker 내부 content store 또는 디스크 여유 공간 문제일 가능성이 높다.

```text
write /var/lib/docker/buildkit/containerd-overlayfs/metadata_v2.db: input/output error
failed to retrieve image list ... input/output error
```

먼저 디스크와 Docker 상태를 확인한다.

```bash
df -h /System/Volumes/Data /
docker system df
```

운영 데이터 보존이 필요하면 named volume은 지우지 말고, 보수적으로 빌더 캐시와 dangling image만 정리한다.

```bash
docker builder prune -f
docker image prune -f
```

그 후 Docker Desktop을 재시작하고 다시 실행한다.

```bash
./scripts/docker_stack_smoke.sh
```

주의:

- `docker system prune --volumes`는 PostgreSQL, Redis, 학생 미디어 named volume까지 지울 수 있으므로 운영 서버에서 사용하지 않는다.
- `docker volume rm studyon-postgres-data studyon-redis-data studyon-media-data`는 DB와 업로드 파일 삭제가 의도된 경우에만 실행한다.
- Admin web과 TV web은 `.dockerignore`로 `node_modules`, `.next` 등을 빌드 컨텍스트에서 제외한다. 컨텍스트 전송 크기가 과도하게 크면 `.dockerignore` 누락 여부를 먼저 확인한다.

## 9. Known deployment blockers

- Android release signing keystore is not configured in repo.
- iOS signing and App Store Connect metadata are not configured in repo.
- Public production domain and TLS termination are not configured in repo.
- 학생 목표대학/배경 이미지는 API 로컬 디스크의 `MEDIA_UPLOAD_DIR` 또는 compose의 `studyon-media-data` volume에 저장된다. 컨테이너 재배포 때 사라지지 않도록 persistent volume을 유지하고 백업 대상에 포함해야 한다.
- 학생 앱의 이미지 표시를 위해 미디어 content URL은 UUID 기반 공개 URL로 제공된다. 민감한 개인정보/문서는 이 업로드 경로에 올리지 않는 운영 정책이 필요하다.
- 집중모드의 강한 차단은 Android Device Owner 배포 또는 iOS Screen Time entitlement가 있어야 실효성이 생긴다. 일반 설치 환경은 소프트락 안내 수준으로 동작한다.

이 항목들은 코드 문제가 아니라 운영 자산 또는 별도 제품 작업이 필요해서 여기서 자동 완료할 수 없다.
