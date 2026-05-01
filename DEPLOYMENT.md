# STUDYON Deployment

학생 앱, 백엔드 API, 관리자 웹, TV 웹을 운영 환경으로 올릴 때 기준이 되는 문서다.

## 1. Current deployment scope

- Backend API: NestJS + Prisma + PostgreSQL + Redis
- Student client: Flutter mobile app
- Admin web: Next.js standalone server
- TV display web: Next.js standalone server

## 2. Required environment

### API

`apps/api/.env` 또는 배포 플랫폼 secret에 아래 값을 넣는다.

```env
NODE_ENV=production
PORT=3000
APP_NAME=STUDYON API
APP_URL=https://api.example.com
CORS_ORIGIN=https://student.example.com,https://admin.example.com,https://tv.example.com

DATABASE_URL=postgresql://USER:PASSWORD@HOST:5432/studyon?schema=public
REDIS_URL=redis://HOST:6379

JWT_ACCESS_SECRET=replace-with-strong-access-secret
JWT_REFRESH_SECRET=replace-with-strong-refresh-secret
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=30d

SWAGGER_ENABLED=false
LOG_LEVEL=info
RATE_LIMIT_TTL=60000
RATE_LIMIT_LIMIT=100
AUTO_LOGOUT_ENABLED=true
SESSION_IDLE_TIMEOUT_MINUTES=120
PARENT_PORTAL_SECRET=replace-with-strong-parent-secret
DEFAULT_ADMIN_EMAIL=admin@studyon.local
DEFAULT_ADMIN_PASSWORD=replace-with-strong-admin-password
```

### Student app

Flutter release 빌드 시 아래 `dart-define` 값을 사용한다.

```text
API_BASE_URL=https://api.example.com
APP_ENV=prod
ENABLE_LOGGING=false
DEVICE_CODE=studyon_client_release
```

### Admin web

`apps/admin_web/.env.example` 기준:

```env
API_URL=https://api.example.com
PORT=11111
HOSTNAME=0.0.0.0
```

### TV display web

`apps/tv_display_web/.env.example` 기준:

```env
PORT=11112
HOSTNAME=0.0.0.0
```

## 3. Backend deployment

로컬 또는 단일 서버 기준 기본 절차:

```bash
chmod +x scripts/deploy_api.sh
./scripts/deploy_api.sh
```

이 스크립트가 하는 일:

1. PostgreSQL/Redis 컨테이너 기동
2. API 의존성 설치
3. Prisma generate / migrate deploy
4. API build
5. production API 컨테이너 재배포

배포 후 확인:

```bash
curl http://127.0.0.1:3000/api/v1/health
```

## 4. Student app release build

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

## 4-1. iOS TestFlight archive

현재 iOS 프로젝트 설정:

- Bundle ID: `com.studyon.studyonClient`
- Display name: `자습ON`
- Team ID: `2PHB3Z8AV5`

서명과 프로비저닝이 Xcode에 정상 연결되어 있다면 아래 스크립트로 아카이브와 export를 진행할 수 있다.

```bash
chmod +x scripts/build_ios_testflight.sh
./scripts/build_ios_testflight.sh
```

기본 export 옵션 템플릿:

- `apps/studyon_client/ios/ExportOptions/TestFlight.plist`

출력물:

- Archive: `apps/studyon_client/build/ios/archive/Runner.xcarchive`
- Export: `apps/studyon_client/build/ios/ipa`

이후 업로드:

1. Xcode Organizer에서 archive 선택
2. `Distribute App`
3. `App Store Connect`
4. `Upload`
5. App Store Connect `TestFlight` 탭에서 테스터 초대

## 5. Student device-test APK

실기기 스모크 테스트용 APK:

```bash
chmod +x scripts/build_student_device_test.sh
API_BASE_URL=https://api.example.com ./scripts/build_student_device_test.sh
```

출력물:

- Android debug APK: `apps/studyon_client/build/app/outputs/flutter-apk/app-debug.apk`

이 APK는 release keystore 없이도 실기기 테스트용으로 바로 설치할 수 있다.

## 6. Admin web build and deploy

```bash
chmod +x scripts/build_web_release.sh
API_URL=https://api.example.com ./scripts/build_web_release.sh
```

관리자 웹 산출물:

- Standalone server: `apps/admin_web/.next/standalone`
- Static assets copied: `apps/admin_web/.next/standalone/public`, `apps/admin_web/.next/standalone/.next/static`

실행 예시:

```bash
cd apps/admin_web
PORT=11111 HOSTNAME=0.0.0.0 node .next/standalone/server.js
```

컨테이너 배포 예시:

```bash
docker build -t studyon-admin-web ./apps/admin_web
docker run -p 11111:11111 --env API_URL=https://api.example.com studyon-admin-web
```

## 7. TV display web build and deploy

```bash
chmod +x scripts/build_web_release.sh
./scripts/build_web_release.sh
```

TV 웹 산출물:

- Standalone server: `apps/tv_display_web/.next/standalone`
- Static assets copied: `apps/tv_display_web/.next/standalone/public`, `apps/tv_display_web/.next/standalone/.next/static`

실행 예시:

```bash
cd apps/tv_display_web
PORT=11112 HOSTNAME=0.0.0.0 node .next/standalone/server.js
```

컨테이너 배포 예시:

```bash
docker build -t studyon-tv-web ./apps/tv_display_web
docker run -p 11112:11112 studyon-tv-web
```

## 8. Launch checklist

- API production env injected
- PostgreSQL backup policy enabled
- Redis persistence enabled
- Prisma migrations applied
- Seed admin password changed
- Student app built with production `API_BASE_URL`
- Student device-test APK installed and smoke-tested
- Admin web standalone build completed
- TV web standalone build completed
- CORS set to production client origin only
- Swagger disabled in production unless required

## 9. Known deployment blockers

- Android release signing keystore is not configured in repo.
- iOS signing and App Store Connect metadata are not configured in repo.
- Public production domain and TLS termination are not configured in repo.
- `apps/tv_display_web`는 아직 기본 템플릿 수준이라 실제 운영 화면/데이터 연동 구현은 별도 작업이 필요하다.

이 항목들은 코드 문제가 아니라 운영 자산 또는 별도 제품 작업이 필요해서 여기서 자동 완료할 수 없다.
