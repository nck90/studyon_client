# 자습ON

학원 자습실 운영 자동화 서비스다. 현재 기준으로 학생 모바일 앱과 NestJS API가 실데이터 기반으로 연결되어 있다.

## 현재 범위

- 학생 앱: `apps/studyon_client`
- 백엔드 API: `apps/api`
- 관리자 웹: `apps/admin_web`
- TV 디스플레이: `apps/tv_display_web`

## 빠른 실행

### 학생 앱 로컬 실행

```bash
flutter pub get
flutter run \
  --dart-define=API_BASE_URL=http://127.0.0.1:3000 \
  --dart-define=APP_ENV=dev \
  --dart-define=ENABLE_LOGGING=true
```

### API 로컬 실행

```bash
cd apps/api
cp .env.example .env
docker compose -f ../../infra/compose/docker-compose.yml up -d postgres redis
pnpm install
pnpm prisma:generate
pnpm prisma:migrate:dev
pnpm prisma:seed
pnpm start:dev
```

## 주요 기능

- 학생 회원가입 / 로그인 / 자동 로그인
- 입실 / 퇴실 / 좌석 변경
- 공부 세션 시작 / 휴식 / 재개 / 종료
- 학습 로그, 주간/월간 기록, 랭킹, 알림
- 프로필 포인트 / 레벨 / 알림 설정

## 배포

운영 배포 절차는 [DEPLOYMENT.md](/Users/bagjun-won/studyon/DEPLOYMENT.md:1)에 정리했다.

빠른 빌드 스크립트:

- API: `./scripts/deploy_api.sh`
- 학생 실기기 테스트 APK: `./scripts/build_student_device_test.sh`
- 학생 release 빌드: `./scripts/build_student_release.sh`
- 웹 standalone 빌드: `./scripts/build_web_release.sh`

## 기술 스택

- Flutter 3.32+ / Dart 3.10+
- Riverpod / GoRouter / Dio
- NestJS / Prisma / PostgreSQL / Redis
