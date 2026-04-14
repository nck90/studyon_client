# 자습ON

학원 자습실 운영 자동화 앱

## 구조

```
studyon/
├── apps/
│   ├── studyon_client/     # Flutter iPad 앱 (학생 + 관리자)
│   └── tv_display_web/     # Next.js TV 디스플레이
├── packages/
│   ├── design_system/      # 디자인 시스템 (테마, 컬러, 위젯)
│   ├── core/               # 유틸리티, 환경 설정
│   ├── models/             # 데이터 모델 (Freezed)
│   ├── api_client/         # API 클라이언트 (Dio)
│   ├── auth/               # 인증 관리
│   └── realtime/           # SSE 실시간 이벤트
└── reference/              # 디자인 레퍼런스
```

## 실행

```bash
# 루트에서 의존성 설치
cd studyon
flutter pub get

# iPad 시뮬레이터에서 실행
flutter run -d <device-id>

# TV 디스플레이 (Next.js)
cd apps/tv_display_web
npm install
npm run dev
```

## 학생 화면
- 스플래시 → 로그인 → 입실 → 홈 대시보드
- 공부 타이머 (다크 모드, 목표 선택, 휴식 카운트)
- 기록 (주간 차트, 과목 분포, 출석 캘린더)
- 랭킹 (포디움, 리더보드, 순위 추이)
- 프로필 (학생 카드, 배지, 주간 리포트, 설정)
- 학습 계획 (CRUD, 스와이프 삭제, 드래그 정렬)

## 관리자 화면
- 대시보드 (KPI, 좌석맵, 랭킹, 시간대 차트)
- 학생 관리 (리스트, 상세, 등록/수정/삭제, 메시지)
- 좌석 관리 (상태, 편집, 강제 퇴실)
- 출결 관리 (일간/주간/월간, 캘린더)
- 학습 현황 (반별 필터, 과목 분석)
- 랭킹 관리 (시상 기능)
- 알림 / TV 제어 / 설정

## 기술 스택
- Flutter 3.32+ (Dart 3.10+)
- Riverpod (상태 관리)
- GoRouter (라우팅)
- Next.js 15 (TV 디스플레이)
