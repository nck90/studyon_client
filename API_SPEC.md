# STUDYON API 명세서 초안

## 1. 문서 개요

- 제품명: `STUDYON`
- 문서명: `API Specification`
- 문서 버전: `v1.0`
- 작성일: `2026-04-14`
- 문서 목적: STUDYON MVP 기준 REST API 엔드포인트, 요청/응답 구조, 권한 범위를 정의한다.

---

## 2. API 설계 원칙

### 원칙 1. 채널별 책임 분리

- 학생 앱용 API
- 관리자/원장 웹용 API
- TV 디스플레이용 API

### 원칙 2. 리소스 중심 설계

- `students`
- `attendances`
- `seats`
- `study-plans`
- `study-sessions`
- `study-logs`
- `reports`
- `rankings`
- `notifications`

### 원칙 3. 실시간성과 집계성 분리

- 실시간 운영 데이터는 원천 리소스 API로 제공
- 리포트/랭킹은 집계 API로 제공

---

## 3. 공통 규칙

## 3-1. Base URL

```text
/api/v1
```

---

## 3-2. 인증 방식

### 학생

- `Bearer Access Token`
- 로그인 후 발급

### 관리자/원장

- `Bearer Access Token`
- 이메일/비밀번호 로그인 후 발급

### TV

- `Display Access Token` 또는 고정 디스플레이 키

---

## 3-3. 공통 헤더

```http
Authorization: Bearer {token}
Content-Type: application/json
X-Device-Code: {device_code}
```

`X-Device-Code`는 좌석 태블릿 또는 TV 환경에서 선택적으로 사용한다.

---

## 3-4. 공통 응답 형식

### 성공 응답

```json
{
  "success": true,
  "data": {},
  "meta": {}
}
```

### 실패 응답

```json
{
  "success": false,
  "error": {
    "code": "INVALID_REQUEST",
    "message": "요청 값이 올바르지 않습니다."
  }
}
```

---

## 3-5. 공통 에러 코드

- `UNAUTHORIZED`
- `FORBIDDEN`
- `INVALID_REQUEST`
- `NOT_FOUND`
- `DUPLICATE_LOGIN`
- `ACTIVE_SESSION_EXISTS`
- `ALREADY_CHECKED_IN`
- `SEAT_NOT_AVAILABLE`
- `POLICY_VIOLATION`
- `INTERNAL_SERVER_ERROR`

---

## 3-6. 페이지네이션 규칙

리스트 API는 아래 쿼리 파라미터를 권장한다.

```text
page=1
limit=20
sort=created_at
order=desc
```

응답 예시:

```json
{
  "success": true,
  "data": [],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 132
  }
}
```

---

## 4. 인증 API

## 4-1. 학생 번호/이름 로그인

### `POST /auth/student/login`

- 권한: 공개
- 목적: 학생 번호/이름 기반 로그인

### Request

```json
{
  "studentNo": "2026001",
  "name": "홍길동",
  "deviceCode": "TAB-01"
}
```

### Response

```json
{
  "success": true,
  "data": {
    "accessToken": "jwt-token",
    "refreshToken": "refresh-token",
    "user": {
      "id": "uuid",
      "role": "student",
      "name": "홍길동"
    },
    "student": {
      "id": "uuid",
      "studentNo": "2026001",
      "className": "고2 A반",
      "assignedSeatNo": "A-12"
    }
  }
}
```

---

## 4-2. 학생 QR 로그인

### `POST /auth/student/qr-login`

- 권한: 공개
- 목적: QR 토큰 기반 학생 로그인

### Request

```json
{
  "qrToken": "qr-token",
  "deviceCode": "TAB-01"
}
```

---

## 4-3. 관리자 로그인

### `POST /auth/admin/login`

- 권한: 공개
- 목적: 관리자/원장 로그인

### Request

```json
{
  "email": "admin@studyon.com",
  "password": "password"
}
```

---

## 4-4. 토큰 갱신

### `POST /auth/refresh`

- 권한: 공개

### Request

```json
{
  "refreshToken": "refresh-token"
}
```

---

## 4-5. 로그아웃

### `POST /auth/logout`

- 권한: 로그인 사용자

### Request

```json
{
  "sessionId": "uuid"
}
```

---

## 4-6. 현재 사용자 조회

### `GET /auth/me`

- 권한: 로그인 사용자
- 목적: 현재 로그인한 사용자 및 권한 정보 조회

---

## 5. 학생 앱 API

## 5-1. 학생 홈 요약

### `GET /student/home`

- 권한: 학생
- 목적: 학생 홈에 필요한 요약 데이터 제공

### Response

```json
{
  "success": true,
  "data": {
    "todayAttendance": {
      "status": "checked_in",
      "checkInAt": "2026-04-14T08:10:00+09:00",
      "checkOutAt": null,
      "stayMinutes": 95
    },
    "seat": {
      "seatId": "uuid",
      "seatNo": "A-12",
      "status": "occupied"
    },
    "study": {
      "sessionStatus": "active",
      "studyMinutes": 70,
      "breakMinutes": 5
    },
    "plans": {
      "totalCount": 2,
      "completedCount": 1,
      "targetMinutes": 240
    },
    "notifications": [
      {
        "id": "uuid",
        "title": "오늘 영어 단어 테스트"
      }
    ]
  }
}
```

---

## 5-2. 출결 API

### `GET /student/attendances/today`

- 권한: 학생
- 목적: 오늘 출결 상태 조회

### `GET /student/attendances`

- 권한: 학생
- 목적: 출결 이력 조회
- 쿼리:
  - `startDate`
  - `endDate`

### `POST /student/attendances/check-in`

- 권한: 학생
- 목적: 입실 처리

### Request

```json
{
  "seatId": "uuid"
}
```

### `POST /student/attendances/check-out`

- 권한: 학생
- 목적: 퇴실 처리

### Request

```json
{
  "forceCloseStudySession": true
}
```

---

## 5-3. 좌석 API

### `GET /student/seats/my`

- 권한: 학생
- 목적: 내 좌석 정보 조회

### `GET /student/seats/map`

- 권한: 학생
- 목적: 좌석 배치도 및 상태 조회
- 쿼리:
  - `zone`

### `GET /student/seats/available`

- 권한: 학생
- 목적: 빈 좌석 목록 조회

### `POST /student/seat-change-requests`

- 권한: 학생
- 목적: 좌석 변경 요청 생성

### Request

```json
{
  "toSeatId": "uuid",
  "reason": "집중이 잘 안돼서 창가 쪽 좌석 요청"
}
```

### `GET /student/seat-change-requests`

- 권한: 학생
- 목적: 내 좌석 변경 요청 이력 조회

---

## 5-4. 학습 계획 API

### `GET /student/study-plans`

- 권한: 학생
- 목적: 오늘 또는 기간별 계획 조회
- 쿼리:
  - `date`

### `POST /student/study-plans`

- 권한: 학생
- 목적: 계획 생성

### Request

```json
{
  "planDate": "2026-04-14",
  "subjectName": "수학",
  "title": "수1 3단원 문제풀이",
  "description": "개념 복습 후 기본문제 30개",
  "targetMinutes": 120,
  "priority": "high"
}
```

### `GET /student/study-plans/{planId}`

- 권한: 학생

### `PATCH /student/study-plans/{planId}`

- 권한: 학생
- 목적: 계획 수정

### `DELETE /student/study-plans/{planId}`

- 권한: 학생

### `POST /student/study-plans/{planId}/complete`

- 권한: 학생
- 목적: 계획 완료 처리

---

## 5-5. 공부 세션 API

### `GET /student/study-sessions/active`

- 권한: 학생
- 목적: 현재 활성 세션 조회

### `POST /student/study-sessions/start`

- 권한: 학생
- 목적: 공부 시작

### Request

```json
{
  "linkedPlanId": "uuid"
}
```

### `POST /student/study-sessions/{sessionId}/pause`

- 권한: 학생
- 목적: 일시정지

### `POST /student/study-sessions/{sessionId}/resume`

- 권한: 학생
- 목적: 재시작

### `POST /student/study-sessions/{sessionId}/end`

- 권한: 학생
- 목적: 공부 종료

### Response

```json
{
  "success": true,
  "data": {
    "sessionId": "uuid",
    "studyMinutes": 95,
    "breakMinutes": 10,
    "status": "completed"
  }
}
```

### `GET /student/study-sessions`

- 권한: 학생
- 목적: 세션 이력 조회
- 쿼리:
  - `startDate`
  - `endDate`

---

## 5-6. 학습량 기록 API

### `POST /student/study-logs`

- 권한: 학생
- 목적: 학습량 기록 생성

### Request

```json
{
  "planId": "uuid",
  "studySessionId": "uuid",
  "logDate": "2026-04-14",
  "subjectName": "영어",
  "pagesCompleted": 12,
  "problemsSolved": 30,
  "progressPercent": 45,
  "isCompleted": true,
  "memo": "단어 100개 암기 완료"
}
```

### `GET /student/study-logs`

- 권한: 학생
- 목적: 학습량 기록 조회
- 쿼리:
  - `date`
  - `startDate`
  - `endDate`

### `PATCH /student/study-logs/{logId}`

- 권한: 학생

### `DELETE /student/study-logs/{logId}`

- 권한: 학생

---

## 5-7. 리포트 API

### `GET /student/reports/daily`

- 권한: 학생
- 쿼리:
  - `date`

### Response

```json
{
  "success": true,
  "data": {
    "date": "2026-04-14",
    "attendanceMinutes": 420,
    "studyMinutes": 310,
    "breakMinutes": 25,
    "targetMinutes": 360,
    "achievedRate": 86.11,
    "attendanceStatus": "checked_out",
    "subjectBreakdown": [
      {
        "subjectName": "수학",
        "studyMinutes": 180
      },
      {
        "subjectName": "영어",
        "studyMinutes": 130
      }
    ]
  }
}
```

### `GET /student/reports/weekly`

- 권한: 학생
- 쿼리:
  - `weekStartDate`

### `GET /student/reports/monthly`

- 권한: 학생
- 쿼리:
  - `month`

---

## 5-8. 랭킹 API

### `GET /student/rankings`

- 권한: 학생
- 목적: 학생용 랭킹 조회
- 쿼리:
  - `periodType=daily|weekly|monthly`
  - `rankingType=study_time|study_volume|attendance_streak`

### Response

```json
{
  "success": true,
  "data": {
    "myRank": {
      "rankNo": 4,
      "score": 310
    },
    "items": [
      {
        "studentId": "uuid",
        "studentName": "김민수",
        "rankNo": 1,
        "score": 420
      }
    ]
  }
}
```

### `GET /student/badges`

- 권한: 학생
- 목적: 내 배지 조회

---

## 5-9. 내 정보 API

### `GET /student/profile`

- 권한: 학생

### `GET /student/notifications`

- 권한: 학생
- 목적: 학생 대상 알림 목록 조회

### `POST /student/notifications/{notificationId}/read`

- 권한: 학생

---

## 6. 관리자 웹 API

## 6-1. 관리자 대시보드

### `GET /admin/dashboard`

- 권한: 관리자, 원장
- 목적: 실시간 자습실 현황 조회
- 쿼리:
  - `date`
  - `classId`
  - `groupId`

### Response

```json
{
  "success": true,
  "data": {
    "checkedInCount": 48,
    "seatOccupancyRate": 80.0,
    "availableSeatCount": 12,
    "notCheckedInStudents": 5,
    "notStartedStudyStudents": 7,
    "inactiveStudents": 3
  }
}
```

---

## 6-2. 학생 관리 API

### `GET /admin/students`

- 권한: 관리자, 원장
- 목적: 학생 목록 조회
- 쿼리:
  - `keyword`
  - `gradeId`
  - `classId`
  - `groupId`
  - `status`
  - `page`
  - `limit`

### `POST /admin/students`

- 권한: 관리자
- 목적: 학생 등록

### Request

```json
{
  "studentNo": "2026001",
  "name": "홍길동",
  "gradeId": "uuid",
  "classId": "uuid",
  "groupId": "uuid",
  "assignedSeatId": "uuid"
}
```

### `GET /admin/students/{studentId}`

- 권한: 관리자, 원장
- 목적: 학생 상세 조회

### `PATCH /admin/students/{studentId}`

- 권한: 관리자
- 목적: 학생 정보 수정

### `DELETE /admin/students/{studentId}`

- 권한: 관리자
- 목적: 학생 비활성 또는 삭제

---

## 6-3. 반/그룹/학년 API

### `GET /admin/grades`

### `POST /admin/grades`

### `GET /admin/classes`

### `POST /admin/classes`

### `GET /admin/groups`

### `POST /admin/groups`

- 권한: 관리자, 원장
- 목적: 기준 정보 관리

---

## 6-4. 좌석 관리 API

### `GET /admin/seats`

- 권한: 관리자, 원장
- 목적: 좌석 목록 및 상태 조회
- 쿼리:
  - `zone`
  - `status`

### `POST /admin/seats`

- 권한: 관리자
- 목적: 좌석 생성

### `PATCH /admin/seats/{seatId}`

- 권한: 관리자
- 목적: 좌석 정보 수정

### `POST /admin/seats/{seatId}/assign`

- 권한: 관리자
- 목적: 특정 학생에게 좌석 배정

### Request

```json
{
  "studentId": "uuid",
  "assignmentType": "fixed"
}
```

### `POST /admin/seats/{seatId}/lock`

- 권한: 관리자

### `POST /admin/seats/{seatId}/unlock`

- 권한: 관리자

### `GET /admin/seat-change-requests`

- 권한: 관리자
- 목적: 좌석 변경 요청 목록 조회

### `POST /admin/seat-change-requests/{requestId}/approve`

- 권한: 관리자

### `POST /admin/seat-change-requests/{requestId}/reject`

- 권한: 관리자

---

## 6-5. 출결 관리 API

### `GET /admin/attendances`

- 권한: 관리자, 원장
- 목적: 일자별 출결 목록 조회
- 쿼리:
  - `date`
  - `gradeId`
  - `classId`
  - `groupId`
  - `attendanceStatus`

### `GET /admin/attendances/{attendanceId}`

- 권한: 관리자, 원장

### `PATCH /admin/attendances/{attendanceId}`

- 권한: 관리자
- 목적: 출결 예외 수정

### `GET /admin/attendance-stats`

- 권한: 관리자, 원장
- 목적: 출결 통계 조회
- 쿼리:
  - `startDate`
  - `endDate`
  - `classId`

### `GET /admin/attendance-stats/export`

- 권한: 관리자, 원장
- 목적: CSV/엑셀 다운로드

---

## 6-6. 학습 현황 API

### `GET /admin/study-overview`

- 권한: 관리자, 원장
- 목적: 학습 현황 대시보드 데이터 조회
- 쿼리:
  - `startDate`
  - `endDate`
  - `classId`
  - `groupId`

### `GET /admin/students/{studentId}/study-summary`

- 권한: 관리자, 원장
- 목적: 특정 학생 학습 요약 조회

### `GET /admin/classes/{classId}/study-summary`

- 권한: 관리자, 원장
- 목적: 반 단위 학습 요약 조회

---

## 6-7. 랭킹 관리 API

### `GET /admin/rankings`

- 권한: 관리자, 원장
- 목적: 랭킹 현황 조회
- 쿼리:
  - `periodType`
  - `rankingType`
  - `periodKey`

### `GET /admin/ranking-policies/active`

- 권한: 관리자, 원장

### `POST /admin/ranking-policies`

- 권한: 원장
- 목적: 랭킹 정책 생성

### `PATCH /admin/ranking-policies/{policyId}`

- 권한: 원장
- 목적: 랭킹 정책 수정

---

## 6-8. 알림 관리 API

### `GET /admin/notifications`

- 권한: 관리자, 원장

### `POST /admin/notifications`

- 권한: 관리자
- 목적: 공지/알림 생성 및 발송

### Request

```json
{
  "notificationType": "notice",
  "channel": "in_app",
  "title": "오늘 10시 영어 테스트",
  "body": "대상 학생은 9시 55분까지 착석 바랍니다.",
  "targetScope": "class",
  "targetClassId": "uuid",
  "scheduledAt": null
}
```

### `GET /admin/notifications/{notificationId}`

- 권한: 관리자, 원장

### `POST /admin/notifications/{notificationId}/send`

- 권한: 관리자

---

## 6-9. 설정 API

### `GET /admin/settings/attendance-policy`

- 권한: 관리자, 원장

### `PATCH /admin/settings/attendance-policy`

- 권한: 원장

### `GET /admin/settings/ranking-policy`

- 권한: 관리자, 원장

### `PATCH /admin/settings/ranking-policy`

- 권한: 원장

### `GET /admin/settings/tv-display`

- 권한: 관리자, 원장

### `PATCH /admin/settings/tv-display`

- 권한: 관리자, 원장

---

## 7. 원장 웹 API

원장 기능은 대부분 관리자 API를 상속하며, 아래 상위 집계 API를 추가로 권장한다.

## 7-1. 통합 대시보드

### `GET /director/overview`

- 권한: 원장
- 목적: 전체 운영 지표 조회
- 쿼리:
  - `startDate`
  - `endDate`

### Response

```json
{
  "success": true,
  "data": {
    "attendanceRate": 91.4,
    "seatUtilizationRate": 83.2,
    "totalStudyMinutes": 15420,
    "activeStudentCount": 87
  }
}
```

---

## 7-2. 운영 리포트

### `GET /director/reports/operations`

- 권한: 원장
- 목적: 운영 리포트 조회
- 쿼리:
  - `periodType=daily|weekly|monthly`
  - `periodKey`

### `GET /director/reports/operations/export`

- 권한: 원장

---

## 7-3. 성과 분석

### `GET /director/analytics/performance`

- 권한: 원장
- 목적: 학생/반/과목 성과 분석
- 쿼리:
  - `startDate`
  - `endDate`
  - `classId`

### `GET /director/analytics/risk-students`

- 권한: 원장
- 목적: 향후 위험 학생 분석 확장용

---

## 8. TV API

## 8-1. TV 현재 송출 정보

### `GET /display/current`

- 권한: TV, 관리자
- 목적: 현재 송출 화면 정보 조회

### Response

```json
{
  "success": true,
  "data": {
    "activeScreen": "ranking",
    "rotationEnabled": true,
    "rotationIntervalSeconds": 30
  }
}
```

---

## 8-2. 랭킹 화면 데이터

### `GET /display/rankings`

- 권한: TV, 관리자
- 목적: TV 랭킹 화면 데이터 조회
- 쿼리:
  - `periodType`
  - `rankingType`

---

## 8-3. 자습실 현황 화면 데이터

### `GET /display/status`

- 권한: TV, 관리자
- 목적: TV 자습실 현황 데이터 조회

### Response

```json
{
  "success": true,
  "data": {
    "checkedInCount": 48,
    "seatOccupancyRate": 80,
    "liveStudyMinutes": 2140,
    "todayTotalStudyMinutes": 9140
  }
}
```

---

## 8-4. 동기부여 화면 데이터

### `GET /display/motivation`

- 권한: TV, 관리자
- 목적: TV 동기부여 화면 데이터 조회

---

## 8-5. TV 화면 전환 제어

### `POST /display/control`

- 권한: 관리자, 원장
- 목적: TV 송출 화면 변경

### Request

```json
{
  "activeScreen": "status"
}
```

---

## 9. 공통 마스터 데이터 API

## 9-1. 과목 목록

### `GET /common/subjects`

- 권한: 학생, 관리자, 원장
- 목적: 과목 선택 리스트 제공

---

## 9-2. 상태 코드 목록

### `GET /common/codes`

- 권한: 학생, 관리자, 원장
- 목적: 프론트엔드용 공통 코드값 제공
- 쿼리:
  - `type=attendance_status|seat_status|ranking_type`

---

## 10. 웹소켓 / 실시간 이벤트 권장

실시간 운영성을 위해 아래 이벤트 채널을 권장한다.

## 10-1. 관리자 대시보드 이벤트

### 채널

```text
ws://.../realtime/admin-dashboard
```

### 이벤트 예시

- `attendance.updated`
- `seat.updated`
- `study_session.updated`
- `notification.created`

---

## 10-2. 학생 홈 이벤트

### 채널

```text
ws://.../realtime/student-home
```

### 이벤트 예시

- `study_session.ticked`
- `notification.received`
- `attendance.updated`

---

## 10-3. TV 화면 이벤트

### 채널

```text
ws://.../realtime/display
```

### 이벤트 예시

- `display.screen_changed`
- `ranking.updated`
- `room_status.updated`

---

## 11. 권한 매트릭스 요약

| API 영역 | 학생 | 관리자 | 원장 | TV |
| --- | --- | --- | --- | --- |
| 학생 홈/출결/계획/세션 | O | X | X | X |
| 학생 개인 리포트 | O | X | X | X |
| 학생 관리 | X | O | O | X |
| 좌석 관리 | X | O | O | X |
| 출결 통계 | X | O | O | X |
| 학습 현황 | X | O | O | X |
| 랭킹 조회 | O | O | O | O |
| 랭킹 정책 수정 | X | 일부 | O | X |
| 알림 발송 | X | O | O | X |
| TV 제어 | X | O | O | 일부 조회 |

---

## 12. MVP 우선 엔드포인트

MVP에서 먼저 구현할 API는 아래와 같다.

### 인증

- `POST /auth/student/login`
- `POST /auth/admin/login`
- `POST /auth/logout`
- `GET /auth/me`

### 학생

- `GET /student/home`
- `GET /student/attendances/today`
- `POST /student/attendances/check-in`
- `POST /student/attendances/check-out`
- `GET /student/seats/my`
- `GET /student/study-plans`
- `POST /student/study-plans`
- `PATCH /student/study-plans/{planId}`
- `POST /student/study-sessions/start`
- `POST /student/study-sessions/{sessionId}/pause`
- `POST /student/study-sessions/{sessionId}/resume`
- `POST /student/study-sessions/{sessionId}/end`
- `POST /student/study-logs`
- `GET /student/reports/daily`
- `GET /student/rankings`

### 관리자

- `GET /admin/dashboard`
- `GET /admin/students`
- `POST /admin/students`
- `GET /admin/students/{studentId}`
- `PATCH /admin/students/{studentId}`
- `GET /admin/seats`
- `POST /admin/seats/{seatId}/assign`
- `GET /admin/attendances`
- `GET /admin/study-overview`
- `POST /admin/notifications`
- `GET /admin/settings/tv-display`
- `PATCH /admin/settings/tv-display`

### TV

- `GET /display/current`
- `GET /display/rankings`
- `GET /display/status`

---

## 13. 오픈 이슈

- 학생 로그인에서 이름 검증만으로 충분한지 추가 검증 수단이 필요한지 확정 필요
- QR 로그인 토큰 수명 정책 확정 필요
- 관리자 수정 가능한 출결 범위 확정 필요
- 좌석 변경 요청 승인 프로세스의 자동/수동 여부 확정 필요
- TV 공개 범위에서 학생 실명 노출 정책 확정 필요
- 푸시/문자/카카오 등 외부 알림 채널 포함 여부 확정 필요

---

## 14. 최종 정의

STUDYON API는 학생의 하루 학습 흐름과 관리자의 실시간 운영 흐름을 모두 지원해야 한다.  
따라서 학생용 API는 `행동 트리거 중심`, 관리자용 API는 `조회/통제 중심`, TV API는 `읽기 전용 집계 중심`으로 설계하는 것이 적합하다.

이 문서를 기준으로 다음 단계인 `Swagger/OpenAPI`, `백엔드 폴더 구조`, `Prisma schema`, `ERD` 작성으로 이어갈 수 있다.

