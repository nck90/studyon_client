# STUDYON Student Client

학생용 Flutter 앱이다. 현재 학생 핵심 플로우는 모두 실제 API와 연결되어 있다.

## Local run

```bash
flutter pub get
flutter run
```

기본값은 운영 API `https://studyon-server.hyphen.it.com` 이다.
로컬 백엔드에 붙이고 싶을 때만 `API_BASE_URL`를 덮어쓴다.

```bash
flutter run \
  --dart-define=API_BASE_URL=http://127.0.0.1:3000 \
  --dart-define=APP_ENV=dev \
  --dart-define=ENABLE_LOGGING=true \
  --dart-define=DEVICE_CODE=studyon_client_local
```

## Release build

Android APK:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.example.com \
  --dart-define=APP_ENV=prod \
  --dart-define=ENABLE_LOGGING=false \
  --dart-define=DEVICE_CODE=studyon_client_release
```

iOS without codesign:

```bash
flutter build ios --release --no-codesign \
  --dart-define=API_BASE_URL=https://api.example.com \
  --dart-define=APP_ENV=prod \
  --dart-define=ENABLE_LOGGING=false \
  --dart-define=DEVICE_CODE=studyon_client_release
```

## Runtime configuration

- `API_BASE_URL`: backend base URL
- `APP_ENV`: `dev`, `staging`, `prod`
- `ENABLE_LOGGING`: `true`, `false`
- `DEVICE_CODE`: device identifier used in auth/session flows

## Notes

- Android release signing is not configured in repo.
- iOS App Store signing is not configured in repo.
- Full deployment checklist is in the repo root `DEPLOYMENT.md`.
