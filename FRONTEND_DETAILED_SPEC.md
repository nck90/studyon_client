# STUDYON Frontend Detailed Specification

## 1. 문서 목적

이 문서는 `STUDYON`의 프론트엔드 구현을 위한 상세 명세서다.
목표는 디자이너 없이도 개발자가 바로 화면, 라우팅, 상태, API 연결, 예외 처리, 권한 분기까지 구현 가능한 수준의 기준을 제공하는 것이다.

이 문서는 다음을 포함한다.

- 채널별 프론트 구조
- 화면 라우팅
- 레이아웃 규칙
- 화면별 상세 요구사항
- 폼 검증 규칙
- 상태 관리 기준
- API 연동 기준
- 인증 / 권한 처리
- 실시간 이벤트 처리 기준
- QA 체크포인트

이 문서는 의도적으로 색상, 타이포, 그래픽 스타일, 브랜딩 규칙 같은 디자인 요소는 다루지 않는다.

## 2. 프론트 대상 채널

STUDYON 프론트는 아래 5개 채널을 기준으로 분리한다.

1. 학생 앱
2. 관리자 웹
3. 원장 웹
4. TV / 공용 디스플레이
5. 학부모 포털

권장 구현 방식은 하나의 모노레포 안에서 채널별 앱을 분리하거나, 공통 컴포넌트와 도메인 로직을 공유하는 멀티 앱 구조다.

예시:

```text
apps/
  student-app/
  admin-web/
  display-web/
  parent-web/
packages/
  ui/
  api-client/
  auth/
  types/
  utils/
```

## 3. 채널별 목적

### 학생 앱

- 출결 처리
- 좌석 확인
- 오늘 계획 관리
- 공부 세션 시작 / 종료
- 학습 기록 작성
- 개인 리포트 확인
- 랭킹 / 알림 확인

### 관리자 웹

- 학생 / 좌석 / 출결 운영
- 학습 현황 관리
- 알림 발송
- 랭킹 관리
- 디스플레이 제어
- 정책 조정

### 원장 웹

- 운영 지표 확인
- 성과 분석 확인
- 정책 변경
- 감사 로그 확인

### TV / 공용 디스플레이

- 랭킹 송출
- 자습실 현황 송출
- 동기부여 메시지 송출

### 학부모 포털

- 학생의 출결 확인
- 학생의 학습 리포트 확인
- 오늘 상태 확인

## 4. 라우팅 구조

## 4-1. 학생 앱 라우트

```text
/login
/login/qr
/home
/attendance
/seats
/plans
/plans/new
/plans/:planId/edit
/study-session
/study-logs/new
/reports/daily
/reports/weekly
/reports/monthly
/rankings
/notifications
/profile
/badges
/insights/recommendation
```

## 4-2. 관리자 웹 라우트

```text
/login
/dashboard
/students
/students/new
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
/settings/tv-display
/settings/ranking-policy
/audit-logs
/insights/risks
/insights/students/:studentId
/parent-access
```

## 4-3. 원장 웹 라우트

```text
/director/overview
/director/reports/operations
/director/analytics/performance
/settings/attendance-policy
/settings/tv-display
/settings/ranking-policy
/audit-logs
```

관리자와 원장을 하나의 웹 앱으로 합치는 경우, 같은 앱 안에서 권한별 메뉴만 분기해도 된다.

## 4-4. TV 라우트

```text
/display/current
/display/rankings
/display/status
/display/motivation
```

실제 구현에서는 `/:screen` 구조보다 단일 디스플레이 앱이 현재 화면 설정 API를 읽고 자체적으로 표시 전환하는 방식이 더 적합하다.

## 4-5. 학부모 포털 라우트

```text
/parent/login-link
/parent/overview
/parent/attendance
/parent/study-report
```

학부모 포털은 로그인 폼 기반이 아니라 `Bearer parent access token` 기반으로 읽기 전용 진입을 전제로 한다.

## 5. 공통 프론트 규칙

## 5-1. 인증 저장 규칙

### 학생 / 관리자 / 원장

- `accessToken`
- `refreshToken`
- `sessionId`
- `role`
- `user summary`

권장 방식:

- access token: 메모리 우선
- refresh token: 보안 저장소 또는 httpOnly cookie 대체 전략
- 앱 재기동 복원 시 `/auth/me` 확인 후 세션 복구

### 학부모 포털

- `parent access token`만 사용
- refresh 없음
- 만료 시 재발급 링크 필요

## 5-2. 인증 실패 처리

- `401`: 로그인 페이지 이동 또는 토큰 재발급 시도
- `403`: 권한 없음 화면 표시
- `409` 또는 도메인 정책 오류: 경고 모달 / 토스트
- 만료된 학부모 토큰: “링크가 만료되었습니다” 상태 페이지

## 5-3. 공통 페이지 상태

모든 화면은 최소 아래 상태를 가져야 한다.

- 초기 로딩
- 데이터 로딩 완료
- 빈 상태
- 부분 실패
- 전체 실패
- 재시도

권장 규칙:

- 첫 진입은 스켈레톤 또는 로더
- 리스트 데이터가 없으면 빈 상태 문구와 CTA 표시
- 저장 실패는 인라인 + 토스트 동시 고려

## 5-4. 공통 액션 피드백

- 저장 성공: 토스트
- 저장 실패: 토스트 + 폼 하단 메시지
- 삭제: 확인 모달
- 정책 변경: 재확인 모달
- 출결 / 퇴실 / 좌석 잠금 같은 운영 액션: 성공 후 즉시 화면 재조회

## 5-5. 날짜 / 시간 표기

- 사용자 표시는 `Asia/Seoul`
- 백엔드 응답은 ISO 기반으로 수신
- 리스트는 `YYYY-MM-DD`, `HH:mm`, `YYYY-MM-DD HH:mm` 포맷을 일관 사용

## 5-6. 숫자 표기

- 시간은 기본적으로 `분` 단위 원천값을 받아 화면에서 `시간 + 분`으로 변환
- 퍼센트는 소수점 0~2자리 노출 정책 유지

## 6. 정보 구조와 내비게이션

## 6-1. 학생 앱 하단 탭

권장 탭:

1. 홈
2. 출결
3. 계획
4. 리포트
5. 내 정보

공부 세션은 탭이 아니라 전역 CTA 또는 플로팅 진입으로 두는 편이 적합하다.

## 6-2. 관리자 웹 좌측 메뉴

권장 그룹:

- 운영
  - 대시보드
  - 학생
  - 좌석
  - 출결
- 학습
  - 학습 현황
  - 랭킹
  - 인사이트
- 커뮤니케이션
  - 알림
  - 학부모 접근
- 송출 / 설정
  - TV 제어
  - 정책 설정
  - 감사 로그

## 6-3. 원장 웹 메뉴

- 통합 현황
- 운영 리포트
- 성과 분석
- 정책
- 감사 로그

## 7. 상태 관리 기준

권장 저장소 분리:

- `auth store`
- `session store`
- `ui store`
- `student domain store`
- `admin domain store`
- `display store`

공통 캐시 기준:

- 조회 데이터: React Query / TanStack Query 류 캐시 권장
- 폼 입력 상태: 페이지 로컬 상태
- 토큰 / 권한: 전역 상태
- 실시간 이벤트 누적 상태: 전역 이벤트 버퍼

## 8. API 클라이언트 기준

## 8-1. 공통 API 래퍼

모든 요청은 공통 클라이언트를 사용한다.

필수 기능:

- base URL 주입
- Authorization header 자동 주입
- 401 시 refresh 처리
- 403 공통 처리
- 서버 에러 메시지 파싱
- SSE 연결 유틸

## 8-2. 도메인별 API 모듈

권장 모듈:

- `authApi`
- `studentApi`
- `attendanceApi`
- `seatApi`
- `planApi`
- `studySessionApi`
- `studyLogApi`
- `reportApi`
- `rankingApi`
- `notificationApi`
- `displayApi`
- `settingsApi`
- `auditApi`
- `insightsApi`
- `parentApi`

## 8-3. 캐시 무효화 기준

예시:

- 입실 성공 후:
  - `student/home`
  - `student/attendances/today`
  - `display/status`
  - `admin/dashboard`
- 계획 생성 후:
  - `student/study-plans`
  - `student/home`
  - `student/reports/daily`
- 좌석 배정 후:
  - `admin/seats`
  - `student/seats/my`
  - `student/home`
- 알림 읽음 처리 후:
  - `student/notifications`
  - `student/home`

## 9. 실시간 이벤트 처리 기준

백엔드는 SSE 엔드포인트를 제공한다.

- `GET /api/v1/events/public`
- `GET /api/v1/events/me`

### public stream 사용 대상

- TV 화면
- 관리자 대시보드의 실시간 현황
- 좌석 현황판

### me stream 사용 대상

- 학생 알림 실시간 수신
- 학생 출결 / 세션 상태 변경 반영

### 이벤트 처리 규칙

- 이벤트 수신 시 전체 페이지 새로고침 금지
- 영향 범위 쿼리만 invalidate
- 연결 끊김 시 지수 백오프 재연결
- 앱 비활성 상태에서 재진입 시 전체 핵심 데이터 재조회

## 10. 학생 앱 상세 명세

## S-01 로그인

### 목적

- 학생 번호 / 이름 기반 로그인
- QR 로그인 진입
- 태블릿 자동 로그인 처리

### 입력 필드

- 학생 번호
- 이름

### 검증 규칙

- 학생 번호: 빈 값 불가
- 이름: 빈 값 불가

### 버튼

- 로그인
- QR 로그인
- 자동 로그인 시도

### API

- `POST /api/v1/auth/student/login`
- `POST /api/v1/auth/student/qr-login`
- `POST /api/v1/auth/student/auto-login`

### 처리 규칙

- 일반 로그인 성공 시 홈 이동
- 자동 로그인은 앱 시작 시 `deviceCode`가 있으면 1회 자동 시도
- 실패해도 로그인 폼은 유지

### 오류 처리

- 인증 실패: 인라인 문구
- 중복 로그인 교체 정책 발생 시 경고 모달 또는 메시지

## S-02 홈

### 목적

- 학생 상태 종합 대시보드

### 표시 데이터

- 오늘 출결 상태
- 내 좌석
- 활성 공부 세션 상태
- 오늘 계획 개수 / 완료 수
- 최근 알림 5개

### API

- `GET /api/v1/student/home`

### 화면 섹션

- 사용자 요약
- 출결 요약
- 좌석 요약
- 공부 상태 요약
- 계획 요약
- 최근 알림
- 빠른 액션

### 빠른 액션

- 입실
- 퇴실
- 공부 시작
- 계획 추가
- 학습 기록 추가

### 상태 분기

- 미입실
- 입실 후 공부 미시작
- 공부 진행 중
- 공부 일시정지
- 퇴실 완료

## S-03 출결

### 목적

- 오늘 출결 처리와 과거 출결 조회

### API

- `GET /api/v1/student/attendances/today`
- `GET /api/v1/student/attendances`
- `POST /api/v1/student/attendances/check-in`
- `POST /api/v1/student/attendances/check-out`

### 주요 표시 항목

- 오늘 상태
- 입실 시간
- 퇴실 시간
- 체류 시간
- 지각 여부
- 조기 퇴실 여부
- 과거 출결 리스트

### 입력 / 액션

- 입실 시 선택 좌석이 필요한 경우 좌석 선택 모달
- 퇴실 시 공부 세션 자동 종료 여부 안내

### 예외

- 이미 입실된 상태에서 재입실 시도
- 입실 기록 없는 퇴실 시도

## S-04 좌석

### 목적

- 내 좌석 확인과 좌석 변경 요청

### API

- `GET /api/v1/student/seats/my`
- `GET /api/v1/student/seats/map`
- `GET /api/v1/student/seats/available`
- `POST /api/v1/student/seat-change-requests`
- `GET /api/v1/student/seat-change-requests`

### 화면 구성

- 내 좌석 요약
- 전체 좌석 맵
- 빈 좌석 리스트
- 좌석 변경 요청 이력

### 상태 분류

- `AVAILABLE`
- `OCCUPIED`
- `RESERVED`
- `LOCKED`

### 요청 생성 규칙

- 이미 대기 중인 요청이 있으면 새 요청 버튼 비활성 또는 경고
- 현재 지정 좌석과 동일한 좌석은 선택 불가
- 사용 중 / 잠금 좌석은 요청 불가

## S-05 계획 목록

### 목적

- 오늘 계획 관리

### API

- `GET /api/v1/student/study-plans`
- `POST /api/v1/student/study-plans`
- `PATCH /api/v1/student/study-plans/:planId`
- `DELETE /api/v1/student/study-plans/:planId`
- `POST /api/v1/student/study-plans/:planId/complete`

### 리스트 항목

- 과목명
- 제목
- 설명
- 목표 시간
- 우선순위
- 상태

### 필터

- 오늘만 기본
- 필요 시 과거 날짜 조회 확장 가능

### 액션

- 등록
- 수정
- 삭제
- 완료 처리

## S-06 계획 등록 / 수정

### 폼 필드

- 과목명
- 제목
- 세부 설명
- 목표 시간
- 우선순위

### 검증

- 과목명 필수
- 제목 필수
- 목표 시간 1분 이상

### 완료 후

- 계획 목록 이동
- 혹은 상세 패널 갱신

## S-07 공부 세션

### 목적

- 공부 시작 / 종료 / 휴식 관리

### API

- `GET /api/v1/student/study-sessions/active`
- `GET /api/v1/student/study-sessions`
- `POST /api/v1/student/study-sessions/start`
- `POST /api/v1/student/study-sessions/:sessionId/pause`
- `POST /api/v1/student/study-sessions/:sessionId/resume`
- `POST /api/v1/student/study-sessions/:sessionId/end`

### 화면 요소

- 현재 세션 상태
- 세션 시작 시각
- 누적 공부 시간
- 누적 휴식 시간
- 연결된 계획
- 최근 세션 이력

### 상태

- 시작 전
- 진행 중
- 일시정지
- 종료 완료

### 처리 규칙

- 동시에 하나의 활성 세션만 허용
- pause 시 휴식 시작
- resume 시 휴식 종료
- end 시 최종 공부 시간 계산 결과 반영

## S-08 학습 기록 등록

### 목적

- 학습량 정리 기록

### API

- `GET /api/v1/student/study-logs`
- `POST /api/v1/student/study-logs`
- `PATCH /api/v1/student/study-logs/:logId`
- `DELETE /api/v1/student/study-logs/:logId`

### 폼 필드

- 과목명
- 페이지 수
- 문제 수
- 진도율
- 완료 여부
- 메모
- 연결 계획
- 연결 세션

### 검증

- 과목명 필수
- 숫자 입력은 0 이상
- 진도율 0~100

## S-09 리포트

### 하위 탭

- 일간
- 주간
- 월간

### API

- `GET /api/v1/student/reports/daily`
- `GET /api/v1/student/reports/weekly`
- `GET /api/v1/student/reports/monthly`

### 주요 표시 값

- 총 공부 시간
- 총 휴식 시간
- 목표 시간
- 달성률
- 과목별 기록
- 페이지 / 문제 풀이량
- 출결 상태

### 비어 있는 경우

- 해당 기간 데이터 없음 상태 노출

## S-10 랭킹

### 목적

- 본인 랭킹과 전체 랭킹 확인

### API

- `GET /api/v1/student/rankings`

### 화면 요소

- 기간 선택: 일간 / 주간 / 월간
- 기준 선택: 공부 시간 / 학습량 / 출석 연속
- 내 순위 강조
- TOP 리스트

## S-11 알림

### API

- `GET /api/v1/student/notifications`
- `POST /api/v1/student/notifications/:notificationId/read`

### 기능

- 알림 리스트
- 읽음 표시
- 읽지 않은 알림 개수 뱃지
- 홈 최근 알림과 연동

## S-12 프로필

### API

- `GET /api/v1/student/profile`
- `GET /api/v1/student/badges`
- `GET /api/v1/student/insights/recommendation`

### 표시 항목

- 이름 / 학번 / 학년 / 반 / 그룹
- 지정 좌석
- 배지 목록
- 추천 목표 시간
- 추천 과목

## 11. 관리자 웹 상세 명세

## A-01 로그인

### API

- `POST /api/v1/auth/admin/login`

### 필드

- 이메일
- 비밀번호

### 검증

- 이메일 형식
- 비밀번호 필수

## A-02 대시보드

### API

- `GET /api/v1/admin/dashboard`
- `GET /api/v1/events/public?channels=display,attendance,seat`

### 표시 값

- 현재 입실 학생 수
- 좌석 점유율
- 빈 좌석 수
- 미입실 학생 수
- 공부 시작 안 한 학생 수
- 비활동 학생 수

### 실시간 반영

- SSE 이벤트 수신 시 재조회 또는 일부 카드 갱신

## A-03 학생 목록

### API

- `GET /api/v1/admin/students`

### 필터

- 검색어
- 학년
- 반
- 그룹
- 상태

### 액션

- 학생 등록
- 학생 상세 이동
- 수정 이동
- 비활성 삭제
- 학부모 접근 토큰 발급 진입

## A-04 학생 상세

### API

- `GET /api/v1/admin/students/:studentId`
- `GET /api/v1/admin/students/:studentId/study-summary`
- `GET /api/v1/admin/insights/students/:studentId`

### 섹션

- 기본 정보
- 출결 이력
- 계획 이력
- 학습 로그
- 최근 학습 지표
- 위험도 분석

## A-05 학생 등록 / 수정

### 생성 API

- `POST /api/v1/admin/students`

### 수정 API

- `PATCH /api/v1/admin/students/:studentId`

### 폼 필드

- 학생 번호
- 이름
- 학년
- 반
- 그룹
- 지정 좌석
- 메모

## A-06 좌석 관리

### API

- `GET /api/v1/admin/seats`
- `PATCH /api/v1/admin/seats/:seatId`
- `POST /api/v1/admin/seats/:seatId/assign`
- `POST /api/v1/admin/seats/:seatId/lock`
- `POST /api/v1/admin/seats/:seatId/unlock`

### 화면 기능

- 좌석 맵
- 좌석 리스트
- 학생별 배정
- 상태 변경
- 잠금 / 해제

### 보조 화면

- 좌석 변경 요청 리스트
- 승인 / 반려

## A-07 출결 관리

### API

- `GET /api/v1/admin/attendances`
- `GET /api/v1/admin/attendances/:attendanceId`
- `PATCH /api/v1/admin/attendances/:attendanceId`
- `GET /api/v1/admin/attendance-stats`

### 기능

- 날짜 기준 조회
- 반 / 그룹 필터
- 상태 필터
- 상세 열람
- 시간 / 상태 / 좌석 수정

### 수정 UI

- 입실 시각
- 퇴실 시각
- 좌석
- 출결 상태
- 지각 / 조퇴 플래그

## A-08 학습 현황

### API

- `GET /api/v1/admin/study-overview`
- `GET /api/v1/admin/classes/:classId/study-summary`

### 기능

- 학생별 학습 시간
- 반별 총 공부 시간
- 날짜 범위 필터
- 반 / 그룹 필터

## A-09 랭킹 관리

### API

- `GET /api/v1/admin/rankings`
- `GET /api/v1/admin/ranking-policies/active`
- `POST /api/v1/admin/ranking-policies`
- `PATCH /api/v1/admin/ranking-policies/:policyId`

### 화면 기능

- 기준 선택
- 기간 선택
- 랭킹 표 조회
- 정책 값 수정

## A-10 알림 관리

### API

- `GET /api/v1/admin/notifications`
- `GET /api/v1/admin/notifications/:notificationId`
- `POST /api/v1/admin/notifications`
- `POST /api/v1/admin/notifications/:notificationId/send`

### 작성 폼

- 유형
- 채널
- 제목
- 내용
- 대상 범위
- 예약 발송 시간

### 상태

- draft
- scheduled
- sent

## A-11 TV 제어

### API

- `GET /api/v1/display/current`
- `POST /api/v1/display/control`
- `GET /api/v1/admin/settings/tv-display`
- `PATCH /api/v1/admin/settings/tv-display`

### 기능

- 현재 송출 화면 보기
- 화면 전환
- 로테이션 여부
- 로테이션 주기

## A-12 정책 / 감사 로그 / 학부모 접근

### 출결 정책

- `GET /api/v1/admin/settings/attendance-policy`
- `PATCH /api/v1/admin/settings/attendance-policy`

### 감사 로그

- `GET /api/v1/admin/audit-logs`

### 학부모 접근 발급

- `POST /api/v1/admin/parent-access/issue`

### 화면 기능

- 자동 퇴실 정책
- 지각 / 조퇴 기준
- 감사 로그 검색
- 학생 선택 후 학부모 접근 토큰 발급

## 12. 원장 웹 상세 명세

## O-01 통합 대시보드

### API

- `GET /api/v1/director/overview`

### 표시 항목

- 출석률
- 좌석 활용률
- 총 공부 시간
- 활성 학생 수

## O-02 운영 리포트

### API

- `GET /api/v1/director/reports/operations`

### 필터

- daily
- weekly
- monthly

### 출력 값

- 기간 키
- 출석률
- 좌석 활용률
- 총 공부 시간
- 평균 일 학습 시간
- 상위 반 목록

## O-03 성과 분석

### API

- `GET /api/v1/director/analytics/performance`

### 기능

- 반별 학생 성과 비교
- 공부 시간 상위 / 하위
- 목표 달성률 비교

## 13. TV / 디스플레이 상세 명세

## T-01 공통 동작

### API

- `GET /api/v1/display/current`
- `GET /api/v1/events/public?channels=display`

### 동작 규칙

- 초기 로드 시 current 조회
- 실시간 이벤트 수신 시 해당 화면 재조회
- rotationEnabled가 true면 화면 자동 전환

## T-02 랭킹 화면

### API

- `GET /api/v1/display/rankings`

### 표시 항목

- 기간
- 기준
- TOP 리스트
- 학생명
- 순위
- 점수

## T-03 자습실 현황 화면

### API

- `GET /api/v1/display/status`

### 표시 항목

- 현재 입실 인원
- 좌석 점유율
- 실시간 공부 시간
- 오늘 누적 공부 시간

## T-04 동기부여 화면

### API

- `GET /api/v1/display/motivation`

### 표시 항목

- 메시지
- 상위 학생
- 챌린지 문구

## 14. 학부모 포털 상세 명세

## P-01 진입 방식

- 관리자 발급 토큰 링크 진입
- 별도 회원가입 없음
- 읽기 전용

## P-02 개요 화면

### API

- `GET /api/v1/parent/student/overview`

### 표시 항목

- 학생 기본 정보
- 오늘 출결 상태
- 오늘 학습 지표
- 오늘 계획

## P-03 출결 화면

### API

- `GET /api/v1/parent/student/attendance`

### 기능

- 최근 30~90일 출결 이력
- 날짜 범위 조회

## P-04 학습 리포트 화면

### API

- `GET /api/v1/parent/student/study-report`

### 표시 항목

- 총 공부 시간
- 평균 달성률
- 총 페이지 수
- 총 문제 수
- 최근 일별 지표
- 최근 학습 로그

## 15. 분석 / 추천 화면 명세

## I-01 위험 학생 목록

### 사용자

- 관리자
- 원장

### API

- `GET /api/v1/admin/insights/students/risks`

### 표시 항목

- 학생명
- 반
- 위험도
- 출석률
- 평균 공부 시간
- 평균 달성률
- 연속 출석

### 정렬

- HIGH 우선
- 같은 위험도 안에서는 위험 원인 지표 낮은 순

## I-02 학생 분석 상세

### API

- `GET /api/v1/admin/insights/students/:studentId`

### 표시 항목

- 위험도
- 최근 2주 출석률
- 최근 2주 평균 공부 시간
- 최근 2주 평균 달성률
- 추천 목표 시간
- 추천 집중 과목
- 추천 계획 템플릿

## I-03 학생 개인 추천 화면

### API

- `GET /api/v1/student/insights/recommendation`

### 목적

- 학생이 오늘 계획을 쉽게 세울 수 있도록 추천 제공

### 표시 항목

- 추천 목표 시간
- 추천 집중 과목
- 추천 계획 템플릿 3개

### 액션

- 추천 계획을 기반으로 바로 계획 작성

## 16. 폼 검증 규칙 모음

## 학생 로그인

- studentNo: 필수
- name: 필수

## 관리자 로그인

- email: 이메일 형식
- password: 필수

## 계획 폼

- subjectName: 필수
- title: 필수
- targetMinutes: 1 이상

## 학습 기록 폼

- subjectName: 필수
- pagesCompleted: 0 이상
- problemsSolved: 0 이상
- progressPercent: 0~100

## 알림 작성 폼

- notificationType: 필수
- channel: 필수
- title: 필수
- body: 필수

## 학부모 접근 발급

- studentId: 필수
- expiresInDays: 선택, 기본값 사용 가능

## 17. 에러 처리 가이드

## 17-1. 학생 앱

- 로그인 실패: 필드 하단 에러
- 입실 중복: 모달 또는 배너
- 좌석 요청 실패: 폼 하단 안내
- 세션 만료: 로그인으로 이동

## 17-2. 관리자 웹

- 권한 부족: 403 전용 화면
- 정책 저장 실패: 상단 에러 배너
- 운영 액션 실패: 테이블 상단 토스트

## 17-3. 학부모 포털

- 토큰 만료: 재발급 안내 페이지
- 데이터 없음: 학생 활동 없음 안내

## 18. 권한 분기 기준

## 학생

- 학생 전용 라우트만 접근
- 관리자 / 원장 라우트 접근 금지

## 관리자

- 운영 화면 접근 가능
- 일부 정책 변경은 원장만 가능하도록 세부 분기

## 원장

- 관리자 권한 + 원장 전용 리포트 / 정책 권한

## TV

- 공개 읽기 API 또는 고정 토큰 기반 읽기 전용

## 학부모

- parent token 기반 읽기 전용
- 쓰기 액션 없음

## 19. 프론트 구현 우선순위

## 1차 구현

- 학생 로그인
- 학생 홈
- 출결
- 계획 CRUD
- 공부 세션
- 학습 기록
- 관리자 로그인
- 관리자 대시보드
- 학생 목록 / 상세
- 좌석 관리
- 출결 관리

## 2차 구현

- 학생 리포트
- 랭킹
- 알림
- TV 화면
- 설정
- 감사 로그

## 3차 구현

- 학부모 포털
- 인사이트
- 추천 계획
- 실시간 이벤트 반영 고도화

## 20. QA 체크리스트

## 학생 앱

- 자동 로그인 성공 / 실패
- 입실 전 / 후 홈 상태 변화
- 세션 pause / resume / end 계산값
- 계획 완료 후 홈 / 리포트 반영
- 알림 읽음 후 배지 감소

## 관리자 웹

- 학생 등록 후 목록 반영
- 좌석 잠금 후 학생 요청 차단
- 출결 수정 후 통계 반영
- TV 화면 제어 후 display current 반영
- 감사 로그 생성 확인

## TV

- current API 기반 초기 화면 일치
- SSE 이벤트 수신 후 갱신
- rotation 설정 반영

## 학부모 포털

- 유효 토큰 접근
- 만료 토큰 접근 차단
- 출결 / 학습 리포트 조회

## 21. 구현 시 주의사항

- 프론트는 백엔드 응답의 `minutes` 원천값을 직접 재계산하지 말고 표시용 변환만 수행한다.
- 출결, 좌석, 세션은 실시간성이 있으므로 optimistic update보다 서버 재조회가 더 안전하다.
- 학생 앱과 관리자 웹은 같은 도메인 모델을 공유하되 라우팅과 권한은 완전히 분리한다.
- 학부모 포털은 쓰기 기능을 절대 넣지 않는다.
- TV 화면은 사용자 입력보다 표시 안정성과 자동 복구를 우선한다.

## 22. 관련 문서

- [STUDYON_PRD.md](./STUDYON_PRD.md)
- [STUDYON_IA.md](./STUDYON_IA.md)
- [STUDYON_SCREEN_SPEC.md](./STUDYON_SCREEN_SPEC.md)
- [API_SPEC.md](./API_SPEC.md)
- [BACKEND_FINAL.md](./BACKEND_FINAL.md)
