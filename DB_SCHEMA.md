# STUDYON DB 스키마 초안

## 1. 문서 개요

- 제품명: `STUDYON`
- 문서명: `Database Schema Draft`
- 문서 버전: `v1.0`
- 작성일: `2026-04-14`
- 문서 목적: STUDYON MVP 및 확장 기능을 위한 핵심 데이터 모델, 테이블 구조, 관계, 인덱스 전략을 정의한다.

---

## 2. 설계 목표

STUDYON의 데이터베이스는 아래 요구를 만족해야 한다.

- 학생의 `출결`, `좌석`, `학습 계획`, `공부 세션`, `학습량`, `리포트`, `랭킹` 데이터를 통합 저장한다.
- 관리자가 실시간으로 자습실 상태를 조회할 수 있어야 한다.
- 학생의 당일 행동 흐름을 시간 순서대로 추적할 수 있어야 한다.
- 향후 `AI 분석`, `학부모 연동`, `운영 리포트`로 확장 가능해야 한다.

---

## 3. 설계 원칙

### 원칙 1. 운영 데이터와 집계 데이터를 분리

- 원천 이벤트성 데이터는 정규화 저장한다.
- 리포트/랭킹용 집계는 별도 집계 테이블 또는 뷰로 관리한다.

### 원칙 2. 학생 하루 흐름 중심 설계

학생의 하루 기준 주요 흐름은 아래와 같다.

1. 로그인
2. 입실
3. 좌석 사용
4. 계획 작성
5. 공부 세션 시작/일시정지/종료
6. 학습량 기록
7. 퇴실

따라서 날짜 단위와 세션 단위가 모두 중요하다.

### 원칙 3. 정책 변경 가능성 고려

- 지각 기준 시각
- 조퇴 기준 시각
- 자동 로그아웃 기준
- 랭킹 가중치

위 항목은 코드 하드코딩보다 설정 테이블 기반이 적합하다.

---

## 4. DB 구성 개요

```text
기준 정보
├─ users
├─ students
├─ admin_users
├─ grades
├─ classes
├─ groups
├─ seats
└─ devices

운영 데이터
├─ auth_sessions
├─ qr_login_tokens
├─ attendances
├─ seat_assignments
├─ seat_change_requests
├─ study_plans
├─ study_sessions
├─ study_breaks
├─ study_logs
├─ notifications
├─ notification_receipts
└─ admin_audit_logs

집계/동기부여 데이터
├─ daily_student_metrics
├─ weekly_student_metrics
├─ monthly_student_metrics
├─ ranking_snapshots
├─ ranking_snapshot_items
├─ badges
└─ student_badges

설정 데이터
├─ app_settings
├─ attendance_policies
├─ ranking_policies
└─ tv_display_settings
```

---

## 5. 핵심 ER 구조

```text
users 1:1 students
users 1:1 admin_users

grades 1:N classes
classes 1:N groups
classes 1:N students
groups 1:N students

students 1:N auth_sessions
students 1:N attendances
students 1:N study_plans
students 1:N study_sessions
students 1:N study_logs
students 1:N seat_assignments
students 1:N seat_change_requests
students 1:N student_badges

seats 1:N seat_assignments
seats 1:N seat_change_requests

study_sessions 1:N study_breaks
study_plans 1:N study_logs
study_sessions 1:N study_logs

ranking_snapshots 1:N ranking_snapshot_items
badges 1:N student_badges
notifications 1:N notification_receipts
```

---

## 6. 테이블 상세 정의

## 6-1. users

모든 계정의 공통 인증 주체 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 사용자 ID |
| role | varchar(20) | `student`, `admin`, `director`, `display` |
| status | varchar(20) | `active`, `inactive`, `deleted` |
| name | varchar(100) | 이름 |
| phone | varchar(30) null | 연락처 |
| last_login_at | timestamptz null | 최근 로그인 시각 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

### 인덱스

- `idx_users_role`
- `idx_users_status`

---

## 6-2. students

학생 전용 프로필 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 학생 ID |
| user_id | uuid FK -> users.id | 사용자 참조 |
| student_no | varchar(50) unique | 학생 번호 |
| grade_id | uuid FK -> grades.id null | 학년 |
| class_id | uuid FK -> classes.id null | 반 |
| group_id | uuid FK -> groups.id null | 그룹 |
| assigned_seat_id | uuid FK -> seats.id null | 현재 지정 좌석 |
| enrollment_status | varchar(20) | `active`, `leave`, `graduated` |
| joined_at | date null | 등록일 |
| memo | text null | 관리자 메모 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

### 인덱스

- `uq_students_student_no`
- `idx_students_class_id`
- `idx_students_group_id`
- `idx_students_assigned_seat_id`

---

## 6-3. admin_users

관리자/원장 계정 전용 프로필이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 관리자 프로필 ID |
| user_id | uuid FK -> users.id | 사용자 참조 |
| admin_type | varchar(20) | `admin`, `director` |
| email | varchar(255) unique | 로그인 이메일 |
| password_hash | varchar(255) | 비밀번호 해시 |
| last_password_changed_at | timestamptz null | 비밀번호 변경 시각 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

---

## 6-4. grades

학년 기준 정보다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 학년 ID |
| name | varchar(50) | 예: 중1, 고2 |
| sort_order | int | 정렬 순서 |
| created_at | timestamptz | 생성 시각 |

---

## 6-5. classes

반 기준 정보다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 반 ID |
| grade_id | uuid FK -> grades.id null | 학년 |
| name | varchar(100) | 반 이름 |
| sort_order | int | 정렬 순서 |
| created_at | timestamptz | 생성 시각 |

### 인덱스

- `idx_classes_grade_id`

---

## 6-6. groups

운영상 필요한 별도 그룹 단위다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 그룹 ID |
| class_id | uuid FK -> classes.id null | 소속 반 |
| name | varchar(100) | 그룹명 |
| sort_order | int | 정렬 순서 |
| created_at | timestamptz | 생성 시각 |

### 인덱스

- `idx_groups_class_id`

---

## 6-7. seats

자습실 좌석 기준 정보다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 좌석 ID |
| seat_no | varchar(30) unique | 좌석 번호 |
| zone | varchar(50) null | 구역 |
| status | varchar(20) | `available`, `occupied`, `reserved`, `locked` |
| is_active | boolean | 사용 가능 여부 |
| current_student_id | uuid FK -> students.id null | 현재 점유 학생 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

### 인덱스

- `uq_seats_seat_no`
- `idx_seats_status`
- `idx_seats_current_student_id`

---

## 6-8. devices

좌석 태블릿 또는 공용 디바이스 식별용 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 디바이스 ID |
| device_code | varchar(100) unique | 기기 식별 코드 |
| device_type | varchar(20) | `tablet`, `mobile`, `web`, `tv` |
| seat_id | uuid FK -> seats.id null | 좌석 태블릿이면 좌석 연결 |
| status | varchar(20) | `active`, `inactive` |
| last_seen_at | timestamptz null | 마지막 접속 시각 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

---

## 6-9. auth_sessions

로그인 세션 관리 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 세션 ID |
| user_id | uuid FK -> users.id | 사용자 |
| student_id | uuid FK -> students.id null | 학생 세션이면 학생 참조 |
| device_id | uuid FK -> devices.id null | 디바이스 |
| login_method | varchar(20) | `student_no_name`, `qr`, `auto`, `admin_password` |
| session_status | varchar(20) | `active`, `expired`, `logged_out`, `revoked` |
| duplicate_replaced | boolean | 중복 로그인 대체 여부 |
| started_at | timestamptz | 시작 시각 |
| last_activity_at | timestamptz | 마지막 활동 시각 |
| ended_at | timestamptz null | 종료 시각 |
| created_at | timestamptz | 생성 시각 |

### 인덱스

- `idx_auth_sessions_user_id`
- `idx_auth_sessions_student_id`
- `idx_auth_sessions_status`
- `idx_auth_sessions_last_activity_at`

---

## 6-10. qr_login_tokens

QR 로그인용 단기 토큰 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 토큰 ID |
| student_id | uuid FK -> students.id null | 학생 연결 |
| device_id | uuid FK -> devices.id null | 디바이스 연결 |
| token | varchar(255) unique | QR 토큰 |
| token_type | varchar(20) | `student_login`, `seat_login` |
| expires_at | timestamptz | 만료 시각 |
| used_at | timestamptz null | 사용 시각 |
| created_at | timestamptz | 생성 시각 |

---

## 6-11. attendances

학생의 일자별 출결 기록이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 출결 ID |
| student_id | uuid FK -> students.id | 학생 |
| attendance_date | date | 출결 기준 일자 |
| check_in_at | timestamptz null | 입실 시각 |
| check_out_at | timestamptz null | 퇴실 시각 |
| stay_minutes | int default 0 | 총 체류 시간(분) |
| late_status | varchar(20) | `none`, `late` |
| early_leave_status | varchar(20) | `none`, `early_leave` |
| attendance_status | varchar(20) | `not_checked_in`, `checked_in`, `checked_out`, `absent` |
| seat_id | uuid FK -> seats.id null | 당일 입실 좌석 |
| created_by | uuid FK -> users.id null | 수동 생성자 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

### 제약

- `unique(student_id, attendance_date)`

### 인덱스

- `idx_attendances_attendance_date`
- `idx_attendances_student_status`
- `idx_attendances_seat_id`

---

## 6-12. seat_assignments

좌석 배정 이력이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 배정 ID |
| student_id | uuid FK -> students.id | 학생 |
| seat_id | uuid FK -> seats.id | 좌석 |
| assignment_type | varchar(20) | `fixed`, `temporary`, `daily` |
| assigned_by | uuid FK -> users.id null | 배정자 |
| started_at | timestamptz | 시작 시각 |
| ended_at | timestamptz null | 종료 시각 |
| is_current | boolean | 현재 배정 여부 |
| created_at | timestamptz | 생성 시각 |

### 인덱스

- `idx_seat_assignments_student_id`
- `idx_seat_assignments_seat_id`
- `idx_seat_assignments_is_current`

---

## 6-13. seat_change_requests

학생의 좌석 변경 요청 관리 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 요청 ID |
| student_id | uuid FK -> students.id | 학생 |
| from_seat_id | uuid FK -> seats.id null | 기존 좌석 |
| to_seat_id | uuid FK -> seats.id | 요청 좌석 |
| request_status | varchar(20) | `pending`, `approved`, `rejected`, `cancelled` |
| requested_reason | text null | 요청 사유 |
| reviewed_by | uuid FK -> users.id null | 검토자 |
| reviewed_at | timestamptz null | 검토 시각 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

---

## 6-14. study_plans

학생의 당일 학습 계획 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 계획 ID |
| student_id | uuid FK -> students.id | 학생 |
| plan_date | date | 계획 일자 |
| subject_name | varchar(100) | 과목 |
| title | varchar(255) | 목표 제목 |
| description | text null | 세부 학습 내용 |
| target_minutes | int default 0 | 목표 공부 시간 |
| priority | varchar(20) | `high`, `medium`, `low` |
| status | varchar(20) | `planned`, `in_progress`, `completed`, `cancelled` |
| completed_at | timestamptz null | 완료 시각 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

### 인덱스

- `idx_study_plans_student_date`
- `idx_study_plans_plan_date`
- `idx_study_plans_status`

---

## 6-15. study_sessions

실제 공부 세션 기록이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 세션 ID |
| student_id | uuid FK -> students.id | 학생 |
| attendance_id | uuid FK -> attendances.id null | 당일 출결 연결 |
| linked_plan_id | uuid FK -> study_plans.id null | 연결 계획 |
| session_date | date | 세션 기준 일자 |
| status | varchar(20) | `ready`, `active`, `paused`, `completed`, `auto_closed` |
| started_at | timestamptz null | 시작 시각 |
| ended_at | timestamptz null | 종료 시각 |
| study_minutes | int default 0 | 순공부 시간 |
| break_minutes | int default 0 | 휴식 시간 |
| auto_closed_reason | varchar(50) null | 자동 종료 사유 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

### 인덱스

- `idx_study_sessions_student_date`
- `idx_study_sessions_attendance_id`
- `idx_study_sessions_status`
- `idx_study_sessions_linked_plan_id`

---

## 6-16. study_breaks

세션 내부 휴식 기록이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 휴식 ID |
| study_session_id | uuid FK -> study_sessions.id | 세션 |
| started_at | timestamptz | 휴식 시작 |
| ended_at | timestamptz null | 휴식 종료 |
| break_minutes | int default 0 | 휴식 시간 |
| created_at | timestamptz | 생성 시각 |

### 인덱스

- `idx_study_breaks_session_id`

---

## 6-17. study_logs

학습량 기록 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 기록 ID |
| student_id | uuid FK -> students.id | 학생 |
| plan_id | uuid FK -> study_plans.id null | 연결 계획 |
| study_session_id | uuid FK -> study_sessions.id null | 연결 세션 |
| log_date | date | 기록 일자 |
| subject_name | varchar(100) | 과목 |
| pages_completed | int default 0 | 페이지 수 |
| problems_solved | int default 0 | 문제 수 |
| progress_percent | numeric(5,2) default 0 | 진도율 |
| is_completed | boolean default false | 완료 여부 |
| memo | text null | 메모 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

### 인덱스

- `idx_study_logs_student_date`
- `idx_study_logs_plan_id`
- `idx_study_logs_session_id`

---

## 6-18. notifications

알림/공지의 원본 메시지 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 알림 ID |
| notification_type | varchar(30) | `notice`, `absence`, `leave_time`, `break_over`, `goal_shortfall` |
| channel | varchar(20) | `in_app`, `push`, `tv` |
| title | varchar(255) | 제목 |
| body | text | 내용 |
| target_scope | varchar(20) | `student`, `class`, `group`, `all`, `admin` |
| created_by | uuid FK -> users.id null | 작성자 |
| scheduled_at | timestamptz null | 예약 시각 |
| sent_at | timestamptz null | 발송 시각 |
| status | varchar(20) | `draft`, `scheduled`, `sent`, `cancelled` |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

### 인덱스

- `idx_notifications_type`
- `idx_notifications_status`
- `idx_notifications_scheduled_at`

---

## 6-19. notification_receipts

개별 수신자 단위 발송 이력이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 수신 이력 ID |
| notification_id | uuid FK -> notifications.id | 알림 |
| user_id | uuid FK -> users.id | 수신자 |
| delivery_status | varchar(20) | `pending`, `sent`, `failed`, `read` |
| delivered_at | timestamptz null | 전달 시각 |
| read_at | timestamptz null | 읽음 시각 |
| created_at | timestamptz | 생성 시각 |

### 인덱스

- `idx_notification_receipts_notification_id`
- `idx_notification_receipts_user_id`
- `idx_notification_receipts_delivery_status`

---

## 6-20. admin_audit_logs

관리자 조작 이력 저장용 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 로그 ID |
| actor_user_id | uuid FK -> users.id | 수행자 |
| action_type | varchar(50) | 예: `student_update`, `seat_assign`, `policy_update` |
| target_type | varchar(50) | 대상 타입 |
| target_id | uuid null | 대상 ID |
| before_data | jsonb null | 변경 전 |
| after_data | jsonb null | 변경 후 |
| created_at | timestamptz | 생성 시각 |

### 인덱스

- `idx_admin_audit_logs_actor_user_id`
- `idx_admin_audit_logs_action_type`
- `idx_admin_audit_logs_target_type_target_id`

---

## 6-21. daily_student_metrics

학생 일간 집계 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 집계 ID |
| student_id | uuid FK -> students.id | 학생 |
| metric_date | date | 집계 일자 |
| attendance_minutes | int default 0 | 체류 시간 |
| study_minutes | int default 0 | 순공부 시간 |
| break_minutes | int default 0 | 휴식 시간 |
| target_minutes | int default 0 | 목표 시간 |
| achieved_rate | numeric(5,2) default 0 | 달성률 |
| pages_completed | int default 0 | 페이지 수 |
| problems_solved | int default 0 | 문제 수 |
| study_session_count | int default 0 | 세션 수 |
| attendance_status | varchar(20) | 출결 상태 |
| streak_days | int default 0 | 연속 출석 일수 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

### 제약

- `unique(student_id, metric_date)`

### 인덱스

- `idx_daily_student_metrics_metric_date`
- `idx_daily_student_metrics_student_id`

---

## 6-22. weekly_student_metrics

학생 주간 집계 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 집계 ID |
| student_id | uuid FK -> students.id | 학생 |
| week_start_date | date | 주 시작일 |
| study_minutes | int default 0 | 주간 공부 시간 |
| attendance_days | int default 0 | 출석 일수 |
| target_minutes | int default 0 | 목표 시간 |
| achieved_rate | numeric(5,2) default 0 | 달성률 |
| pages_completed | int default 0 | 페이지 수 |
| problems_solved | int default 0 | 문제 수 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

### 제약

- `unique(student_id, week_start_date)`

---

## 6-23. monthly_student_metrics

학생 월간 집계 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 집계 ID |
| student_id | uuid FK -> students.id | 학생 |
| month_key | varchar(7) | `YYYY-MM` |
| study_minutes | int default 0 | 월간 공부 시간 |
| attendance_days | int default 0 | 출석 일수 |
| target_minutes | int default 0 | 목표 시간 |
| achieved_rate | numeric(5,2) default 0 | 달성률 |
| pages_completed | int default 0 | 페이지 수 |
| problems_solved | int default 0 | 문제 수 |
| created_at | timestamptz | 생성 시각 |
| updated_at | timestamptz | 수정 시각 |

### 제약

- `unique(student_id, month_key)`

---

## 6-24. ranking_snapshots

랭킹 산출 단위의 메타 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 스냅샷 ID |
| ranking_type | varchar(30) | `study_time`, `study_volume`, `attendance_streak` |
| period_type | varchar(20) | `daily`, `weekly`, `monthly` |
| period_key | varchar(20) | 예: `2026-04-14`, `2026-W16`, `2026-04` |
| generated_at | timestamptz | 생성 시각 |
| created_at | timestamptz | 생성 시각 |

### 인덱스

- `idx_ranking_snapshots_type_period`

---

## 6-25. ranking_snapshot_items

랭킹별 개별 학생 점수다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 아이템 ID |
| ranking_snapshot_id | uuid FK -> ranking_snapshots.id | 스냅샷 |
| student_id | uuid FK -> students.id | 학생 |
| rank_no | int | 순위 |
| score | numeric(12,2) | 점수 |
| sub_score_1 | numeric(12,2) default 0 | 보조 점수 |
| sub_score_2 | numeric(12,2) default 0 | 보조 점수 |
| created_at | timestamptz | 생성 시각 |

### 제약

- `unique(ranking_snapshot_id, student_id)`
- `unique(ranking_snapshot_id, rank_no)`

### 인덱스

- `idx_ranking_snapshot_items_student_id`
- `idx_ranking_snapshot_items_rank_no`

---

## 6-26. badges

배지 기준 정보다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 배지 ID |
| code | varchar(50) unique | 내부 코드 |
| name | varchar(100) | 배지명 |
| description | text null | 설명 |
| badge_type | varchar(30) | `attendance`, `study_time`, `achievement`, `event` |
| icon_url | text null | 아이콘 |
| is_active | boolean | 사용 여부 |
| created_at | timestamptz | 생성 시각 |

---

## 6-27. student_badges

학생 배지 지급 이력이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 지급 ID |
| student_id | uuid FK -> students.id | 학생 |
| badge_id | uuid FK -> badges.id | 배지 |
| awarded_at | timestamptz | 지급 시각 |
| reason | text null | 지급 사유 |
| created_at | timestamptz | 생성 시각 |

### 인덱스

- `idx_student_badges_student_id`
- `idx_student_badges_badge_id`

---

## 6-28. app_settings

단순 키-값 전역 설정 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 설정 ID |
| setting_key | varchar(100) unique | 설정 키 |
| setting_value | jsonb | 설정 값 |
| updated_by | uuid FK -> users.id null | 수정자 |
| updated_at | timestamptz | 수정 시각 |
| created_at | timestamptz | 생성 시각 |

---

## 6-29. attendance_policies

출결 정책 버전 관리용 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 정책 ID |
| policy_name | varchar(100) | 정책명 |
| late_cutoff_time | time | 지각 기준 |
| early_leave_cutoff_time | time | 조퇴 기준 |
| auto_checkout_enabled | boolean | 자동 퇴실 여부 |
| auto_checkout_after_minutes | int null | 자동 퇴실 분 |
| is_active | boolean | 활성 정책 |
| created_by | uuid FK -> users.id null | 생성자 |
| created_at | timestamptz | 생성 시각 |

---

## 6-30. ranking_policies

랭킹 계산 정책 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 정책 ID |
| policy_name | varchar(100) | 정책명 |
| study_time_weight | numeric(8,2) | 공부 시간 가중치 |
| study_volume_weight | numeric(8,2) | 학습량 가중치 |
| attendance_weight | numeric(8,2) | 출석 가중치 |
| tie_breaker_rule | jsonb | 동점 처리 규칙 |
| is_active | boolean | 활성 여부 |
| created_by | uuid FK -> users.id null | 생성자 |
| created_at | timestamptz | 생성 시각 |

---

## 6-31. tv_display_settings

TV 송출 설정 테이블이다.

| 컬럼명 | 타입 | 설명 |
| --- | --- | --- |
| id | uuid PK | 설정 ID |
| active_screen | varchar(30) | `ranking`, `status`, `motivation` |
| rotation_enabled | boolean | 자동 회전 여부 |
| rotation_interval_seconds | int default 30 | 전환 간격 |
| display_options | jsonb | 화면별 옵션 |
| updated_by | uuid FK -> users.id null | 수정자 |
| updated_at | timestamptz | 수정 시각 |
| created_at | timestamptz | 생성 시각 |

---

## 7. 파생 뷰 제안

실시간 조회 성능과 화면 단순화를 위해 아래 뷰를 권장한다.

### v_current_attendance_status

- 학생별 오늘 출결 상태
- 입실/퇴실 시각
- 체류 시간

### v_current_seat_status

- 좌석 상태
- 현재 점유 학생
- 예약/잠금 여부

### v_student_today_summary

- 학생 오늘 계획 수
- 공부 시간
- 체류 시간
- 달성률

### v_class_daily_summary

- 반별 일간 출석률
- 반별 총 공부 시간
- 평균 공부 시간

### v_live_room_dashboard

- 현재 입실 학생 수
- 좌석 점유율
- 공부 미시작 학생 수
- 비활동 학생 수

---

## 8. 상태값 Enum 제안

### users.role

- `student`
- `admin`
- `director`
- `display`

### attendances.attendance_status

- `not_checked_in`
- `checked_in`
- `checked_out`
- `absent`

### seats.status

- `available`
- `occupied`
- `reserved`
- `locked`

### study_plans.status

- `planned`
- `in_progress`
- `completed`
- `cancelled`

### study_sessions.status

- `ready`
- `active`
- `paused`
- `completed`
- `auto_closed`

### notifications.status

- `draft`
- `scheduled`
- `sent`
- `cancelled`

---

## 9. 주요 제약 조건

### 출결 제약

- 학생은 같은 날짜에 하나의 출결 레코드만 가진다.
- 퇴실 전 상태에서 중복 입실은 불가하다.

### 세션 제약

- 학생은 동시에 하나의 활성 공부 세션만 가진다.
- 세션 종료 전까지 동일 학생의 신규 세션 생성은 제한한다.

### 좌석 제약

- 하나의 좌석은 동시에 한 명만 `occupied` 상태가 가능하다.
- `locked` 좌석은 학생이 직접 요청할 수 없다.

### 랭킹 제약

- 동일 스냅샷 내 같은 학생은 한 번만 등장한다.
- 동일 스냅샷 내 동일 순위 번호는 한 번만 존재한다.

---

## 10. 집계 전략

### 실시간 계산

아래 항목은 실시간 또는 준실시간 조회가 필요하다.

- 현재 입실 학생 수
- 좌석 점유율
- 활성 공부 세션 수
- 현재 공부 시간 누적

### 배치 집계

아래 항목은 배치 또는 이벤트 기반 집계가 적합하다.

- 일간 학생 리포트
- 주간/월간 리포트
- 랭킹 스냅샷
- 연속 출석 일수
- 배지 지급 조건 계산

---

## 11. 기술적 권장 사항

### 권장 DB

- `PostgreSQL`

선택 이유는 아래와 같다.

- `jsonb`로 정책/설정 유연성 확보 가능
- 집계 쿼리와 인덱스 전략이 안정적
- 트랜잭션 기반 운영 데이터 처리에 적합

### 권장 공통 컬럼

모든 주요 테이블에 아래 컬럼 패턴을 권장한다.

- `id`
- `created_at`
- `updated_at`
- 필요 시 `deleted_at`

### 소프트 삭제 권장 대상

- 학생
- 관리자 계정
- 좌석
- 공지

운영 히스토리 보존이 중요하기 때문이다.

---

## 12. MVP 최소 테이블

MVP에서 우선 구현해야 할 테이블은 아래와 같다.

- `users`
- `students`
- `admin_users`
- `grades`
- `classes`
- `groups`
- `seats`
- `auth_sessions`
- `attendances`
- `seat_assignments`
- `study_plans`
- `study_sessions`
- `study_breaks`
- `study_logs`
- `daily_student_metrics`
- `ranking_snapshots`
- `ranking_snapshot_items`
- `notifications`
- `admin_audit_logs`
- `attendance_policies`
- `ranking_policies`
- `tv_display_settings`

---

## 13. 확장 테이블

향후 확장 단계에서 추가 또는 강화할 수 있는 구조다.

- `parents`
- `parent_student_links`
- `ai_risk_scores`
- `recommendation_histories`
- `focus_events`
- `device_heartbeats`
- `push_tokens`

---

## 14. 최종 정의

STUDYON의 데이터 모델은 `학생 하루 흐름`과 `운영 실시간성`을 동시에 지원해야 한다.  
따라서 원천 이벤트 테이블인 `출결`, `좌석`, `계획`, `세션`, `학습 기록`을 중심으로 설계하고,  
그 위에 `일간/주간/월간 집계`, `랭킹 스냅샷`, `설정 정책`을 분리해 쌓는 구조가 가장 적합하다.

이 문서를 기준으로 다음 단계인 `ERD`, `Prisma/TypeORM 스키마`, `API 명세서` 작성으로 이어갈 수 있다.

