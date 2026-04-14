# STUDYON Backend Final

## 문서 목적

이 문서는 `STUDYON` 프로젝트에서 프론트엔드를 제외한 백엔드 범위의 최종 구현 상태를 정리한다.
대상 범위는 API, 인증, 데이터 모델, 스케줄러, 자동화, 운영 설정, Docker 구동, 테스트, 문서화까지 포함한다.

## 기술 스택

- Framework: NestJS 11
- Database: PostgreSQL 16
- Cache / Session: Redis 7
- ORM: Prisma 6
- API Docs: Swagger
- Logging: Pino
- Validation: class-validator, Zod
- Runtime: Docker, Docker Compose

## 현재 구동 상태

- API: `http://127.0.0.1:3000`
- Health: `http://127.0.0.1:3000/api/v1/health`
- Swagger: `http://127.0.0.1:3000/docs`
- Docker services:
  - `studyon-api`
  - `studyon-postgres`
  - `studyon-redis`

## 구현 완료 범위

### 1. 인증 / 세션

- 학생 번호 + 이름 로그인
- 학생 QR 로그인
- 좌석 태블릿 자동 로그인
- 관리자 이메일 + 비밀번호 로그인
- Access / Refresh JWT 발급
- 중복 로그인 방지
- Redis 기반 refresh token 저장
- 세션 로그아웃
- 활성 세션 검증
- 유휴 세션 자동 만료 스케줄러
- 세션 마지막 활동 시간 자동 갱신

### 2. 학생 기능

- 학생 홈 조회
- 학생 프로필 조회
- 학생 배지 조회
- 오늘 출결 조회
- 출결 이력 조회
- 입실 처리
- 퇴실 처리
- 총 체류 시간 계산
- 지각 / 조기퇴실 플래그 기록
- 오늘 학습 계획 CRUD
- 계획 완료 처리
- 공부 세션 시작 / 일시정지 / 재개 / 종료
- 휴식 시간 분리 기록
- 공부 로그 CRUD
- 일간 / 주간 / 월간 개인 리포트
- 학생 랭킹 조회
- 학생 알림함 조회
- 알림 읽음 처리

### 3. 좌석 관리

- 개인 지정 좌석 조회
- 좌석 맵 조회
- 빈 좌석 조회
- 좌석 변경 요청 생성
- 좌석 변경 요청 내역 조회
- 관리자 좌석 목록 조회
- 좌석 수동 배정
- 좌석 잠금 / 해제
- 좌석 상태 갱신
- 좌석 변경 요청 승인 / 반려
- 지정 좌석 / 사용중 좌석 / 예약 좌석 상태 구분

### 4. 관리자 기능

- 관리자 대시보드
- 학생 목록 조회 / 상세 조회 / 등록 / 수정 / 비활성 삭제
- 학년 / 반 / 그룹 조회 및 생성
- 출결 목록 조회
- 출결 상세 조회
- 출결 통계 조회
- 관리자 출결 수정
- 학습 현황 개요 조회
- 학생별 학습 요약
- 반별 학습 요약
- 랭킹 조회
- 랭킹 정책 기본 관리
- 출결 정책 조회 / 갱신
- TV 디스플레이 설정 조회 / 갱신
- 관리자 알림 생성 / 조회 / 발송

### 5. 원장 기능

- 원장 개요 조회
- 운영 리포트 조회
- 성과 분석 조회

### 6. 학부모 / 분석 확장

- 관리자 발급형 학부모 접근 토큰
- 학부모용 학생 개요 조회 API
- 학부모용 출결 조회 API
- 학부모용 학습 리포트 조회 API
- 위험 학생 탐지 API
- 학생별 분석 API
- 학생 개인 추천 학습 계획 API

### 7. TV / 공용 디스플레이 API

- 현재 화면 설정 조회
- 랭킹 데이터 조회
- 자습실 현황 조회
- 동기부여 데이터 조회
- 화면 제어 API

### 8. 자동화 / 스케줄러

- 유휴 세션 자동 만료
- 정책 기반 자동 퇴실
- 예정 알림 자동 발송
- 미입실 자동 알림
- 휴식 시간 초과 알림
- 목표 미달성 알림
- 일간 / 주간 / 월간 지표 자동 집계
- 랭킹 스냅샷 재계산
- 배지 자동 지급

### 9. 운영 기반

- Prisma schema 및 migration 구성
- 초기 seed 데이터
- Dockerfile
- Docker Compose
- GitHub Actions CI
- Swagger 문서화
- 헬스체크
- ESLint / Jest / e2e 기본 검증
- 관리자 감사 로그
- SSE 실시간 이벤트 스트림

## 핵심 API 그룹

### 인증

- `POST /api/v1/auth/student/login`
- `POST /api/v1/auth/student/qr-login`
- `POST /api/v1/auth/student/auto-login`
- `POST /api/v1/auth/student/qr-token`
- `POST /api/v1/auth/admin/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`
- `GET /api/v1/auth/me`
- `POST /api/v1/auth/devices/register`

### 학생

- `GET /api/v1/student/home`
- `GET /api/v1/student/profile`
- `GET /api/v1/student/badges`

### 출결

- `GET /api/v1/student/attendances/today`
- `GET /api/v1/student/attendances`
- `POST /api/v1/student/attendances/check-in`
- `POST /api/v1/student/attendances/check-out`
- `GET /api/v1/admin/attendances`
- `GET /api/v1/admin/attendances/:attendanceId`
- `PATCH /api/v1/admin/attendances/:attendanceId`
- `GET /api/v1/admin/attendance-stats`

### 좌석

- `GET /api/v1/student/seats/my`
- `GET /api/v1/student/seats/map`
- `GET /api/v1/student/seats/available`
- `POST /api/v1/student/seat-change-requests`
- `GET /api/v1/student/seat-change-requests`
- `GET /api/v1/admin/seats`
- `PATCH /api/v1/admin/seats/:seatId`
- `POST /api/v1/admin/seats/:seatId/assign`
- `POST /api/v1/admin/seats/:seatId/lock`
- `POST /api/v1/admin/seats/:seatId/unlock`
- `GET /api/v1/admin/seat-change-requests`
- `POST /api/v1/admin/seat-change-requests/:requestId/approve`
- `POST /api/v1/admin/seat-change-requests/:requestId/reject`

### 학습

- `GET /api/v1/student/study-plans`
- `POST /api/v1/student/study-plans`
- `PATCH /api/v1/student/study-plans/:planId`
- `DELETE /api/v1/student/study-plans/:planId`
- `POST /api/v1/student/study-plans/:planId/complete`
- `GET /api/v1/student/study-sessions/active`
- `GET /api/v1/student/study-sessions`
- `POST /api/v1/student/study-sessions/start`
- `POST /api/v1/student/study-sessions/:sessionId/pause`
- `POST /api/v1/student/study-sessions/:sessionId/resume`
- `POST /api/v1/student/study-sessions/:sessionId/end`
- `GET /api/v1/student/study-logs`
- `POST /api/v1/student/study-logs`
- `PATCH /api/v1/student/study-logs/:logId`
- `DELETE /api/v1/student/study-logs/:logId`

### 리포트 / 랭킹 / 알림 / 디스플레이

- `GET /api/v1/student/reports/daily`
- `GET /api/v1/student/reports/weekly`
- `GET /api/v1/student/reports/monthly`
- `GET /api/v1/student/rankings`
- `GET /api/v1/admin/rankings`
- `GET /api/v1/student/notifications`
- `POST /api/v1/student/notifications/:notificationId/read`
- `GET /api/v1/admin/notifications`
- `POST /api/v1/admin/notifications`
- `POST /api/v1/admin/notifications/:notificationId/send`
- `GET /api/v1/display/current`
- `GET /api/v1/display/rankings`
- `GET /api/v1/display/status`
- `GET /api/v1/display/motivation`
- `POST /api/v1/display/control`

### 운영 / 실시간

- `GET /api/v1/admin/audit-logs`
- `GET /api/v1/events/public`
- `GET /api/v1/events/me`

### 학부모 / 분석

- `POST /api/v1/admin/parent-access/issue`
- `GET /api/v1/parent/student/overview`
- `GET /api/v1/parent/student/attendance`
- `GET /api/v1/parent/student/study-report`
- `GET /api/v1/admin/insights/students/risks`
- `GET /api/v1/admin/insights/students/:studentId`
- `GET /api/v1/student/insights/recommendation`

## 기본 시드 데이터

- 관리자 계정
  - email: `admin@studyon.local`
  - password: `ChangeMe123!`
- 학생 계정
  - studentNo: `2026001`
  - name: `홍길동`
- 기본 학년 / 반 / 그룹
  - `고2`
  - `A반`
  - `심화반`
- 기본 좌석
  - `A-01`

## 검증 완료 항목

- `pnpm prisma:generate`
- `pnpm build`
- `pnpm lint`
- `pnpm test --runInBand`
- `pnpm test:e2e`
- Docker Compose 재빌드 및 런타임 구동
- 관리자 로그인 실검증
- 학생 로그인 실검증
- 학생 QR 토큰 발급 실검증
- 태블릿 자동 로그인 실검증
- 학생 입실 실검증
- 관리자 출결 조회 실검증
- 디스플레이 상태 반영 실검증
- 감사 로그 생성 실검증
- SSE 실시간 이벤트 수신 실검증
- 학부모 접근 토큰 발급 및 조회 실검증
- 위험 학생 분석 / 학생 추천 API 실검증

## 문서 위치

- 앱 정의: [STUDYON_APP_DEFINITION.md](./STUDYON_APP_DEFINITION.md)
- PRD: [STUDYON_PRD.md](./STUDYON_PRD.md)
- IA: [STUDYON_IA.md](./STUDYON_IA.md)
- 화면 명세: [STUDYON_SCREEN_SPEC.md](./STUDYON_SCREEN_SPEC.md)
- DB 스키마: [DB_SCHEMA.md](./DB_SCHEMA.md)
- API 명세: [API_SPEC.md](./API_SPEC.md)
- ERD: [STUDYON_ERD.md](./STUDYON_ERD.md)
- 백엔드 마스터 플랜: [BACKEND_MASTER_PLAN.md](./BACKEND_MASTER_PLAN.md)

## 프론트엔드 제외 기준에서 남은 항목

백엔드만 기준으로 보면 핵심 운영 영역은 대부분 구현되었지만, 아래는 아직 확장 가능 영역이다.

- 외부 Push, 문자, 카카오, 이메일 채널 연동
- 관리자 감사 로그 상세화
- 배지 자동 지급 규칙 엔진
- 외부 알림 채널 연동
- AI 모델 연동형 분석 API 고도화
- 클라우드 인프라 배포 스크립트 Terraform 수준 자동화
- 운영 모니터링 연동

## 프론트엔드가 필요한 항목

- 학생 앱 / 관리자 웹 / TV 화면 UI
- QR 표시 화면 및 스캔 UX
- 디스플레이 송출 화면
- 실시간 대시보드 시각화

## 결론

프론트엔드를 제외한 백엔드 범위는 현재 로컬 프로덕션 수준으로 구동 가능하다.
인증, 출결, 좌석, 학습, 리포트, 랭킹, 알림, TV API, 자동화, Docker 운영 기반까지 포함해 실제 연결 가능한 상태다.
