# STUDYON Flutter Frontend Detailed Specification

## 1. 문서 목적

이 문서는 `STUDYON`을 Flutter로 구현할 때 필요한 프론트엔드 상세 명세서다.
목표는 디자인 요소 없이도 개발자가 앱 구조, 화면, 상태, API 연결, 권한, 디바이스 분기, 예외 처리까지 바로 구현할 수 있도록 기준을 제공하는 것이다.

이 문서는 다음 범위를 포함한다.

- Flutter 앱 구성 방식
- 스마트폰 앱과 좌석 태블릿 앱 분리 기준
- 관리자 / 원장 / TV / 학부모 채널의 Flutter 구현 기준
- 라우팅 구조
- 화면별 데이터 요구사항
- 상태 관리 구조
- API 연동 규칙
- 실시간 이벤트 처리 기준
- 디바이스별 동작 차이
- QA 체크리스트

이 문서는 의도적으로 아래는 포함하지 않는다.

- 색상 체계
- 브랜드 스타일
- 타이포그래피
- 일러스트 / 아이콘 스타일
- 레이아웃의 시각적 분위기

## 2. Flutter 채널 구성

Flutter 기준으로 STUDYON은 아래 5개 앱 또는 5개 실행 타겟으로 정의한다.

1. 학생 스마트폰 앱
2. 좌석 태블릿 앱
3. 관리자 / 원장 운영 앱
4. TV / 디스플레이 앱
5. 학부모 포털 앱

권장 방식은 하나의 Flutter 모노레포에서 flavor 또는 target으로 분리하는 구조다.

예시:

```text
studyon/
  apps/
    student_app/
    tablet_app/
    admin_app/
    display_app/
    parent_app/
  packages/
    core/
    api/
    auth/
    models/
    design_system/
    realtime/
```

실무적으로는 아래 2가지 방식 중 하나를 권장한다.

### 방식 A. 앱 5개 분리

- 장점: 권한/배포/스토어/기기별 제약이 명확함
- 단점: 설정 중복 가능

### 방식 B. 앱 3개 분리

- 학생 계열: 학생 스마트폰 앱 + 좌석 태블릿 flavor
- 운영 계열: 관리자 + 원장 앱
- 디스플레이 / 학부모 별도 앱

현재 요구 기준으로는 `방식 B`가 가장 현실적이다.

## 3. 권장 Flutter 기술 스택

- Flutter stable
- 상태 관리: `Riverpod` 권장
- 라우팅: `go_router`
- API: `dio`
- 모델 생성: `freezed`, `json_serializable`
- 로깅: `logger`
- 로컬 저장소:
  - 민감 정보: `flutter_secure_storage`
  - 일반 캐시: `shared_preferences` 또는 `hive`
- 실시간 SSE:
  - `http` 기반 stream 또는 SSE 패키지
  - 별도 wrapper repository 필수
- 폼 검증:
  - `formz` 또는 커스텀 validator

## 4. 앱별 역할 정의

## 4-1. 학생 스마트폰 앱

### 대상 사용자

- 학생 개인

### 핵심 목적

- 출결 처리
- 오늘 계획 관리
- 공부 세션 관리
- 학습 기록 입력
- 개인 리포트 확인
- 랭킹 / 배지 / 알림 확인
- 개인 추천 계획 확인

### 사용 환경

- iPhone / Android phone
- 세로 화면 중심

## 4-2. 좌석 태블릿 앱

### 대상 사용자

- 좌석에 비치된 공용 태블릿

### 핵심 목적

- 태블릿 자동 로그인
- QR 기반 학생 로그인
- 입실 / 퇴실 빠른 처리
- 현재 좌석 / 현재 학생 상태 표시
- 공부 시작 / 일시정지 / 종료 빠른 처리

### 사용 환경

- 고정 태블릿
- 가로 또는 세로 가능
- 특정 `deviceCode`와 `seatId`가 연결됨

### 중요한 차이점

- 개인 앱이 아니라 공용 기기
- 세션 종료 규칙이 학생 앱보다 엄격해야 함
- 화면 이동 깊이를 최소화해야 함

## 4-3. 관리자 / 원장 운영 앱

### 대상 사용자

- 관리자
- 원장

### 핵심 목적

- 학생 관리
- 출결 / 좌석 / 학습 현황 운영
- 알림 발송
- 랭킹 관리
- 디스플레이 제어
- 정책 변경
- 감사 로그 조회
- 위험 학생 분석
- 학부모 접근 토큰 발급

### 사용 환경

- 태블릿 / 데스크톱 / 웹
- Flutter Web 우선 고려

## 4-4. TV / 디스플레이 앱

### 대상 사용자

- 사용자 직접 조작 없음

### 핵심 목적

- 랭킹 화면 송출
- 자습실 현황 화면 송출
- 동기부여 화면 송출

### 사용 환경

- TV 브라우저 또는 셋탑 / 태블릿 미러링
- 장시간 자동 실행

## 4-5. 학부모 포털 앱

### 대상 사용자

- 학부모

### 핵심 목적

- 학생의 출결 현황 확인
- 학생의 공부 시간 및 리포트 확인
- 오늘 상태 확인

### 사용 환경

- 모바일 웹 또는 Flutter Web / 모바일 앱
- 읽기 전용

## 5. Flutter 아키텍처

권장 아키텍처:

```text
presentation
  screens
  widgets
  controllers
application
  usecases
  coordinators
domain
  entities
  repositories
data
  dto
  datasource
  repository_impl
core
  constants
  errors
  env
  utils
```

## 5-1. 레이어 역할

### presentation

- 화면
- 위젯
- 입력 처리
- 로컬 뷰 상태

### application

- 화면 사이의 플로우 제어
- 저장 성공 후 이동 규칙
- 복합 시나리오

### domain

- 순수 모델
- 비즈니스 규칙 이름화
- repository contract

### data

- API DTO
- local storage
- token storage
- SSE client

## 6. 환경 / Flavor 정의

최소 3개 flavor 권장:

- `dev`
- `staging`
- `prod`

공통 환경 변수:

- `API_BASE_URL`
- `APP_ENV`
- `ENABLE_LOGGING`
- `DISPLAY_DEVICE_CODE`
- `TABLET_DEVICE_CODE`

학생 앱과 태블릿 앱은 flavor 또는 compile-time define으로 구분 가능하다.

예시:

```text
--dart-define=APP_MODE=student
--dart-define=APP_MODE=tablet
--dart-define=APP_MODE=admin
--dart-define=APP_MODE=display
--dart-define=APP_MODE=parent
```

## 7. 인증 / 세션 전략

## 7-1. 학생 스마트폰 앱

저장 정보:

- accessToken
- refreshToken
- sessionId
- role
- student summary

저장 위치:

- `flutter_secure_storage`

복구 규칙:

- 앱 시작 시 refreshToken이 있으면 `/auth/me` 또는 refresh 후 세션 복원
- 실패 시 로그인 화면 이동

## 7-2. 좌석 태블릿 앱

저장 정보:

- deviceCode
- 마지막 학생 세션 정보
- accessToken
- refreshToken
- sessionId

규칙:

- 앱 시작 시 `deviceCode`가 있으면 `/auth/student/auto-login` 자동 시도
- 실패하면 QR 또는 학생 번호/이름 로그인 모드 표시
- 학생 퇴실 시 즉시 로그아웃할지, 태블릿 대기 화면으로 둘지 정책으로 분기

## 7-3. 운영 앱

저장 정보:

- 관리자 access / refresh token
- role
- 사용자 요약

권한 규칙:

- admin, director 메뉴 분리
- 원장만 접근 가능한 메뉴는 라우터 레벨에서 차단

## 7-4. 학부모 포털

저장 정보:

- parent access token

규칙:

- refresh 없음
- 만료되면 자동 로그아웃이 아니라 “만료 링크” 상태 페이지 표시

## 8. Flutter 라우팅 구조

## 8-1. 학생 스마트폰 앱

```text
/splash
/login
/login/qr
/home
/attendance
/seats
/plans
/plans/create
/plans/:planId/edit
/study-session
/study-logs
/study-logs/create
/study-logs/:logId/edit
/reports
/reports/daily
/reports/weekly
/reports/monthly
/rankings
/notifications
/profile
/badges
/recommendation
```

## 8-2. 좌석 태블릿 앱

```text
/tablet/splash
/tablet/auto-login
/tablet/login
/tablet/login/qr
/tablet/home
/tablet/attendance
/tablet/study-session
/tablet/logout
```

## 8-3. 운영 앱

```text
/login
/dashboard
/students
/students/create
/students/:studentId
/students/:studentId/edit
/seats
/seat-change-requests
/attendances
/attendances/:attendanceId
/study-overview
/rankings
/notifications
/display-control
/settings/attendance-policy
/settings/ranking-policy
/settings/tv-display
/audit-logs
/insights/risks
/insights/students/:studentId
/parent-access
/director/overview
/director/reports/operations
/director/analytics/performance
```

## 8-4. 디스플레이 앱

```text
/display/splash
/display/current
/display/rankings
/display/status
/display/motivation
```

## 8-5. 학부모 포털

```text
/parent/entry
/parent/overview
/parent/attendance
/parent/study-report
```

## 9. 공통 UI 상태 규칙

모든 화면은 최소 아래 상태를 지원해야 한다.

- initial
- loading
- refreshing
- success
- empty
- partialError
- error

권장 구현:

- `AsyncValue` 또는 `sealed class UiState<T>`

예시:

```dart
sealed class ScreenState<T> {
  const ScreenState();
}

class Loading<T> extends ScreenState<T> {}
class Success<T> extends ScreenState<T> {
  final T data;
  const Success(this.data);
}
class Empty<T> extends ScreenState<T> {}
class Failure<T> extends ScreenState<T> {
  final String message;
  const Failure(this.message);
}
```

## 10. 상태 관리 모듈 구조

권장 provider 그룹:

- authProvider
- sessionProvider
- deviceProvider
- studentHomeProvider
- attendanceProvider
- seatProvider
- planProvider
- studySessionProvider
- studyLogProvider
- reportProvider
- rankingProvider
- notificationProvider
- settingsProvider
- displayProvider
- auditLogProvider
- insightsProvider
- parentProvider
- sseProvider

## 11. API 클라이언트 구조

## 11-1. 공통 Dio 설정

필수 기능:

- Base URL 공통화
- Authorization header 자동 주입
- refresh 처리 interceptor
- 공통 에러 파서
- timeout 설정
- 재시도 정책

필수 인터셉터:

- AuthInterceptor
- RefreshInterceptor
- ErrorMappingInterceptor
- LoggingInterceptor

## 11-2. API 모듈 분리

```text
auth_api.dart
student_api.dart
attendance_api.dart
seat_api.dart
plan_api.dart
study_session_api.dart
study_log_api.dart
report_api.dart
ranking_api.dart
notification_api.dart
settings_api.dart
display_api.dart
audit_api.dart
insights_api.dart
parent_api.dart
events_api.dart
```

## 11-3. DTO / Entity 분리

권장:

- DTO는 API 응답 기준
- Entity는 화면 / 도메인 기준
- 변환 mapper 별도 유지

## 12. 실시간 이벤트 처리

백엔드 제공 엔드포인트:

- `GET /api/v1/events/public`
- `GET /api/v1/events/me`

### 학생 스마트폰 앱

- `events/me`
- 알림 도착
- 출결 상태 변경
- 세션 상태 변경

### 좌석 태블릿 앱

- `events/me`
- 현재 학생 세션 변경
- 출결 변경

### 운영 앱

- `events/public`
- 좌석 상태
- 출결 상태
- 디스플레이 상태
- 알림 발송 결과

### 디스플레이 앱

- `events/public?channels=display`
- 화면 변경
- 회전 정책 변경

### 처리 원칙

- 이벤트 수신 시 전체 화면 새로고침 금지
- 관련 Provider invalidate
- 연결 끊김 시 재연결
- 앱이 background였다면 foreground 복귀 시 핵심 데이터 재조회

## 13. 학생 스마트폰 앱 상세 명세

## S-01 스플래시

### 목적

- 토큰 복구
- 자동 로그인 여부 판단

### 처리 순서

1. secure storage 읽기
2. refresh token 여부 확인
3. 유효하면 refresh 또는 me 호출
4. 성공 시 홈 이동
5. 실패 시 로그인 이동

## S-02 로그인

### API

- `POST /api/v1/auth/student/login`

### 필드

- studentNo
- name

### 검증

- studentNo 필수
- name 필수

### 상태

- 입력 전
- 제출 가능
- 로그인 진행 중
- 실패

### 성공 후

- student summary 저장
- 홈 이동

## S-03 QR 로그인

### API

- `POST /api/v1/auth/student/qr-login`

### 기능

- 카메라 스캔
- QR 토큰 추출
- 로그인 요청

### 예외

- 카메라 권한 거부
- 잘못된 QR
- 만료된 QR

## S-04 홈

### API

- `GET /api/v1/student/home`

### 표시 영역

- 학생 기본 정보
- 오늘 출결 상태
- 좌석 요약
- 활성 공부 상태
- 오늘 계획 요약
- 최근 알림
- 빠른 액션

### 빠른 액션

- 입실
- 퇴실
- 공부 시작
- 계획 추가
- 학습 기록 추가

## S-05 출결

### API

- `GET /api/v1/student/attendances/today`
- `GET /api/v1/student/attendances`
- `POST /api/v1/student/attendances/check-in`
- `POST /api/v1/student/attendances/check-out`

### 화면 요소

- 오늘 상태 카드
- 입실 시간
- 퇴실 시간
- 체류 시간
- 지각 / 조퇴 라벨
- 과거 이력 탭 또는 리스트

### 액션 규칙

- 미입실이면 입실 버튼 활성
- 입실 상태면 퇴실 버튼 활성
- 퇴실 완료면 모든 버튼 비활성

## S-06 좌석

### API

- `GET /api/v1/student/seats/my`
- `GET /api/v1/student/seats/map`
- `GET /api/v1/student/seats/available`
- `POST /api/v1/student/seat-change-requests`
- `GET /api/v1/student/seat-change-requests`

### 화면 구조

- 내 좌석 카드
- 좌석 맵 탭
- 빈 좌석 리스트 탭
- 변경 요청 이력 섹션

### 동작 규칙

- 잠금 / 사용중 좌석 선택 불가
- 이미 대기 중인 요청이 있으면 새 요청 차단

## S-07 계획 목록

### API

- `GET /api/v1/student/study-plans`

### 항목

- subjectName
- title
- description
- targetMinutes
- priority
- status

### 액션

- 생성
- 수정
- 삭제
- 완료

## S-08 계획 생성 / 수정

### API

- `POST /api/v1/student/study-plans`
- `PATCH /api/v1/student/study-plans/:planId`

### 필드

- subjectName
- title
- description
- targetMinutes
- priority

### 검증

- 과목명 필수
- 제목 필수
- 목표 시간 1 이상

## S-09 공부 세션

### API

- `GET /api/v1/student/study-sessions/active`
- `GET /api/v1/student/study-sessions`
- `POST /api/v1/student/study-sessions/start`
- `POST /api/v1/student/study-sessions/:sessionId/pause`
- `POST /api/v1/student/study-sessions/:sessionId/resume`
- `POST /api/v1/student/study-sessions/:sessionId/end`

### 화면 요소

- 현재 세션 상태
- 경과 시간
- 휴식 시간
- 연결된 계획
- 세션 이력

### 동작 규칙

- 활성 세션은 1개만 허용
- pause 중에는 resume, end만 가능

## S-10 학습 기록

### API

- `GET /api/v1/student/study-logs`
- `POST /api/v1/student/study-logs`
- `PATCH /api/v1/student/study-logs/:logId`
- `DELETE /api/v1/student/study-logs/:logId`

### 필드

- subjectName
- pagesCompleted
- problemsSolved
- progressPercent
- isCompleted
- memo

## S-11 리포트

### 탭

- 일간
- 주간
- 월간

### API

- `GET /api/v1/student/reports/daily`
- `GET /api/v1/student/reports/weekly`
- `GET /api/v1/student/reports/monthly`

### 표시 값

- 총 공부 시간
- 총 휴식 시간
- 목표 시간
- 달성률
- 과목별 집계

## S-12 랭킹

### API

- `GET /api/v1/student/rankings`

### 필터

- periodType
- rankingType

### 표시

- 내 순위
- 상위 랭킹 리스트

## S-13 알림

### API

- `GET /api/v1/student/notifications`
- `POST /api/v1/student/notifications/:notificationId/read`

## S-14 프로필 / 배지 / 추천

### API

- `GET /api/v1/student/profile`
- `GET /api/v1/student/badges`
- `GET /api/v1/student/insights/recommendation`

### 하위 섹션

- 기본 정보
- 배지
- 추천 목표 시간
- 추천 과목
- 추천 계획 템플릿

## 14. 좌석 태블릿 앱 상세 명세

## T-01 태블릿 스플래시

### 목적

- deviceCode 확인
- 자동 로그인 시도

### 처리 규칙

1. `deviceCode` 존재 확인
2. `/auth/student/auto-login` 호출
3. 성공 시 태블릿 홈 이동
4. 실패 시 태블릿 로그인 화면 이동

## T-02 태블릿 로그인

### 목적

- 자동 로그인 실패 시 대체 로그인

### 모드

- 학생 번호/이름 로그인
- QR 로그인

### API

- `POST /api/v1/auth/student/login`
- `POST /api/v1/auth/student/qr-login`

### 특수 규칙

- `deviceCode`를 반드시 함께 전송
- 로그인 성공 후 태블릿 홈으로 즉시 이동

## T-03 태블릿 홈

### 목적

- 현재 좌석과 학생 상태를 한 화면에서 제공

### 표시 영역

- 좌석 번호
- 현재 학생 이름 / 학번
- 출결 상태
- 공부 상태
- 오늘 공부 시간
- 빠른 액션

### 빠른 액션

- 입실
- 퇴실
- 공부 시작
- 일시정지
- 재개
- 종료
- 로그아웃

## T-04 태블릿 출결

### 목적

- 빠른 입퇴실 처리

### API

- 학생 앱과 동일

### 차이점

- 좌석은 device에 연결된 seat 기준으로 기본 고정
- 입실 버튼 누를 때 좌석 선택 과정 없음

## T-05 태블릿 공부 세션

### 목적

- 학생이 태블릿에서 바로 공부를 시작 / 종료

### API

- 학생 앱과 동일

### 차이점

- 최소 클릭 수 지향
- 현재 상태 CTA만 크게 제공

## T-06 태블릿 로그아웃 / 대기 화면

### 목적

- 학생 퇴실 후 공용 기기 상태 초기화

### 처리 규칙

- 퇴실 성공 시:
  - 옵션 A: 즉시 로그아웃
  - 옵션 B: 일정 시간 후 자동 로그아웃

권장:

- 태블릿은 퇴실 성공 후 대기 화면으로 전환

## 15. 운영 앱 상세 명세

## A-01 로그인

### API

- `POST /api/v1/auth/admin/login`

### 필드

- email
- password

## A-02 대시보드

### API

- `GET /api/v1/admin/dashboard`
- `GET /api/v1/events/public`

### 카드 영역

- 현재 입실 학생 수
- 좌석 점유율
- 빈 좌석 수
- 미입실 학생 수
- 공부 시작 안 한 학생 수
- 비활동 학생 수

## A-03 학생 목록

### API

- `GET /api/v1/admin/students`

### 필터

- keyword
- gradeId
- classId
- groupId
- status

### 액션

- 상세
- 수정
- 삭제
- 학부모 접근 발급

## A-04 학생 상세

### API

- `GET /api/v1/admin/students/:studentId`
- `GET /api/v1/admin/students/:studentId/study-summary`
- `GET /api/v1/admin/insights/students/:studentId`

### 탭

- 기본 정보
- 출결
- 계획
- 학습 로그
- 최근 지표
- 분석

## A-05 학생 생성 / 수정

### 생성 API

- `POST /api/v1/admin/students`

### 수정 API

- `PATCH /api/v1/admin/students/:studentId`

### 필드

- studentNo
- name
- gradeId
- classId
- groupId
- assignedSeatId
- memo

## A-06 좌석 관리

### API

- `GET /api/v1/admin/seats`
- `PATCH /api/v1/admin/seats/:seatId`
- `POST /api/v1/admin/seats/:seatId/assign`
- `POST /api/v1/admin/seats/:seatId/lock`
- `POST /api/v1/admin/seats/:seatId/unlock`
- `GET /api/v1/admin/seat-change-requests`
- `POST /api/v1/admin/seat-change-requests/:requestId/approve`
- `POST /api/v1/admin/seat-change-requests/:requestId/reject`

### 화면 구성

- 좌석 맵
- 좌석 리스트
- 요청 리스트

## A-07 출결 관리

### API

- `GET /api/v1/admin/attendances`
- `GET /api/v1/admin/attendances/:attendanceId`
- `PATCH /api/v1/admin/attendances/:attendanceId`
- `GET /api/v1/admin/attendance-stats`

### 수정 필드

- attendanceStatus
- checkInAt
- checkOutAt
- seatId
- lateStatus
- earlyLeaveStatus

## A-08 학습 현황

### API

- `GET /api/v1/admin/study-overview`
- `GET /api/v1/admin/classes/:classId/study-summary`

## A-09 랭킹 관리

### API

- `GET /api/v1/admin/rankings`
- `GET /api/v1/admin/ranking-policies/active`
- `POST /api/v1/admin/ranking-policies`
- `PATCH /api/v1/admin/ranking-policies/:policyId`

## A-10 알림 관리

### API

- `GET /api/v1/admin/notifications`
- `GET /api/v1/admin/notifications/:notificationId`
- `POST /api/v1/admin/notifications`
- `POST /api/v1/admin/notifications/:notificationId/send`

### 작성 필드

- notificationType
- channel
- title
- body
- targetScope
- scheduledAt

## A-11 TV 제어

### API

- `GET /api/v1/display/current`
- `POST /api/v1/display/control`
- `GET /api/v1/admin/settings/tv-display`
- `PATCH /api/v1/admin/settings/tv-display`

## A-12 정책

### API

- `GET /api/v1/admin/settings/attendance-policy`
- `PATCH /api/v1/admin/settings/attendance-policy`
- `GET /api/v1/admin/settings/ranking-policy`

## A-13 감사 로그

### API

- `GET /api/v1/admin/audit-logs`

### 필터

- actionType
- targetType

## A-14 인사이트

### API

- `GET /api/v1/admin/insights/students/risks`
- `GET /api/v1/admin/insights/students/:studentId`

### 화면 구성

- 위험 학생 리스트
- 학생별 분석 상세
- 추천 계획 템플릿 확인

## A-15 학부모 접근 발급

### API

- `POST /api/v1/admin/parent-access/issue`

### 화면 기능

- 학생 선택
- 만료 일수 입력
- 토큰 / 링크 발급
- 복사 기능

## 16. 원장 전용 화면 상세 명세

## O-01 개요

### API

- `GET /api/v1/director/overview`

## O-02 운영 리포트

### API

- `GET /api/v1/director/reports/operations`

### 필터

- periodType: daily / weekly / monthly
- periodKey

## O-03 성과 분석

### API

- `GET /api/v1/director/analytics/performance`

### 필터

- startDate
- endDate
- classId

## 17. 디스플레이 앱 상세 명세

## D-01 스플래시

### 목적

- current 설정 조회
- 첫 화면 결정

## D-02 메인 컨트롤러

### API

- `GET /api/v1/display/current`
- `GET /api/v1/events/public?channels=display`

### 역할

- activeScreen 결정
- rotationEnabled 반영
- rotationIntervalSeconds 타이머 제어

## D-03 랭킹 화면

### API

- `GET /api/v1/display/rankings`

### 파라미터

- periodType
- rankingType

## D-04 현황 화면

### API

- `GET /api/v1/display/status`

### 표시 값

- checkedInCount
- seatOccupancyRate
- liveStudyMinutes
- todayTotalStudyMinutes

## D-05 동기부여 화면

### API

- `GET /api/v1/display/motivation`

### 표시 값

- message
- topStudent
- challenge

## 18. 학부모 포털 상세 명세

## P-01 엔트리

### 목적

- Authorization token 유효성 확인

### 처리 흐름

1. 링크 또는 토큰 저장 확인
2. overview 호출
3. 성공 시 overview 진입
4. 실패 시 만료 상태 페이지

## P-02 학생 개요

### API

- `GET /api/v1/parent/student/overview`

### 표시 값

- 학생 정보
- 오늘 출결
- 오늘 지표
- 오늘 계획

## P-03 출결

### API

- `GET /api/v1/parent/student/attendance`

### 필터

- startDate
- endDate

## P-04 학습 리포트

### API

- `GET /api/v1/parent/student/study-report`

### 표시 값

- totalStudyMinutes
- averageAchievedRate
- totalPagesCompleted
- totalProblemsSolved
- recentMetrics
- recentLogs

## 19. 분석 / 추천 화면 상세

## I-01 위험 학생 목록

### 사용자

- 관리자
- 원장

### API

- `GET /api/v1/admin/insights/students/risks`

### 표시 컬럼

- 학생명
- 반
- 위험도
- 출석률
- 평균 공부 시간
- 평균 달성률
- 연속 출석

## I-02 학생 분석 상세

### API

- `GET /api/v1/admin/insights/students/:studentId`

### 표시 값

- riskLevel
- attendanceRate
- averageStudyMinutes
- averageAchievedRate
- streakDays
- recommendedTargetMinutes
- recommendedFocusSubjects
- recommendedPlanTemplate

## I-03 학생 개인 추천

### API

- `GET /api/v1/student/insights/recommendation`

### 화면 목적

- 학생이 오늘 계획을 빠르게 세울 수 있도록 추천 제안

## 20. 디바이스 분기 규칙

## 20-1. 스마트폰 앱

- 하단 탭 네비게이션 사용
- 세로 화면 중심
- 입력 폼 단일 컬럼

## 20-2. 태블릿 앱

- 빠른 액션 중심
- 현재 상태 카드 고정
- 좌우 2컬럼 또는 상하 분리 가능

## 20-3. 운영 앱

- 데스크톱 폭에서 좌측 내비 + 우측 콘텐츠
- 태블릿에서는 rail 또는 drawer

## 20-4. 디스플레이 앱

- 상호작용 최소
- 포커스 가능한 입력 요소 없음

## 21. 로컬 저장 규칙

## secure storage

- accessToken
- refreshToken
- parentToken
- deviceCode

## shared preferences

- 마지막 선택 탭
- 필터 값
- 디스플레이 로컬 설정 캐시

## 22. 폼 검증 규칙

## 학생 로그인

- studentNo 필수
- name 필수

## 관리자 로그인

- email 형식 필수
- password 필수

## 계획 생성 / 수정

- subjectName 필수
- title 필수
- targetMinutes > 0

## 학습 로그

- subjectName 필수
- pagesCompleted >= 0
- problemsSolved >= 0
- progressPercent 0~100

## 출결 수정

- checkOutAt >= checkInAt
- 출결 상태와 시간 관계 일치

## 알림 작성

- title 필수
- body 필수
- channel 필수
- notificationType 필수

## 학부모 접근 발급

- studentId 필수
- expiresInDays는 양수

## 23. 에러 처리 기준

## 학생 앱

- 로그인 실패: 필드 하단 에러
- 입실 중복: 배너 또는 다이얼로그
- 세션 만료: 로그인 재진입

## 태블릿 앱

- 자동 로그인 실패: 로그인 선택 화면 전환
- deviceCode 누락: 디바이스 등록 필요 화면
- 학생 퇴실 후 세션 만료: 대기 화면 전환

## 운영 앱

- 403: 권한 없음 화면
- 저장 실패: 상단 알림 + 폼 에러
- 정책 반영 실패: 재시도 버튼

## 학부모 포털

- 토큰 만료: 재발급 안내 페이지

## 24. 캐시 무효화 기준

## 학생 앱

- 로그인 후:
  - home
  - profile
  - notifications
- 입실 후:
  - attendance today
  - home
  - reports daily
- 계획 생성 후:
  - plans
  - home
  - recommendation

## 운영 앱

- 학생 생성 / 수정 후:
  - students
  - student detail
- 좌석 변경 후:
  - seats
  - dashboard
- 출결 수정 후:
  - attendances
  - attendance stats
  - dashboard
- display 설정 변경 후:
  - display current
  - events public로도 실시간 반영

## 25. 테스트 기준

## 단위 테스트

- provider 상태 전이
- validator
- mapper
- token parser

## 위젯 테스트

- 로그인 폼
- 출결 카드
- 계획 작성 폼
- 알림 리스트
- 운영 테이블 필터

## 통합 테스트

- 로그인 -> 홈 -> 입실 -> 공부 시작 흐름
- 태블릿 자동 로그인 흐름
- 관리자 좌석 잠금 -> 학생 요청 차단 흐름
- 학부모 토큰 -> overview 조회 흐름

## 26. 구현 우선순위

## 1차

- 학생 스마트폰 앱
  - 로그인
  - 홈
  - 출결
  - 계획
  - 공부 세션
- 좌석 태블릿 앱
  - 자동 로그인
  - 홈
  - 출결
  - 공부 세션
- 운영 앱
  - 로그인
  - 대시보드
  - 학생 목록
  - 좌석 관리
  - 출결 관리

## 2차

- 학생 리포트
- 학생 랭킹 / 알림 / 배지 / 추천
- 운영 앱의 랭킹 / 알림 / 설정 / TV 제어
- 디스플레이 앱

## 3차

- 학부모 포털
- 위험 학생 인사이트
- 감사 로그
- 실시간 이벤트 고도화

## 27. QA 체크리스트

## 학생 스마트폰 앱

- 로그인 성공 / 실패
- 자동 세션 복원
- 입실 / 퇴실 후 홈 상태 변화
- 공부 세션 pause / resume 시간 반영
- 알림 읽음 후 배지 감소

## 좌석 태블릿 앱

- 자동 로그인 성공
- 자동 로그인 실패 시 로그인 화면 이동
- 퇴실 후 대기 화면 전환
- deviceCode 변경 시 재등록 흐름

## 운영 앱

- 학생 생성 / 수정 / 삭제
- 좌석 잠금 / 해제
- 출결 수정
- 감사 로그 생성
- 디스플레이 화면 제어

## 디스플레이 앱

- current 설정 읽기
- SSE 이벤트 수신 후 화면 전환
- rotation 작동

## 학부모 포털

- 유효 토큰 접근
- 만료 토큰 차단
- 출결 / 리포트 조회

## 28. 구현 시 주의사항

- 학생 스마트폰 앱과 좌석 태블릿 앱은 화면과 플로우가 다르므로 같은 위젯을 무리하게 공유하지 않는다.
- 공통은 API, 모델, 인증, 유틸, 일부 도메인 위젯만 공유한다.
- 태블릿 앱은 공용기기라는 점 때문에 로그아웃 / 대기화면 플로우를 학생 앱보다 우선 설계한다.
- 디스플레이 앱은 입력보다 안정성과 복구가 우선이다.
- 학부모 포털은 읽기 전용으로 제한한다.

## 29. 관련 문서

- [STUDYON_PRD.md](./STUDYON_PRD.md)
- [STUDYON_IA.md](./STUDYON_IA.md)
- [STUDYON_SCREEN_SPEC.md](./STUDYON_SCREEN_SPEC.md)
- [API_SPEC.md](./API_SPEC.md)
- [BACKEND_FINAL.md](./BACKEND_FINAL.md)
