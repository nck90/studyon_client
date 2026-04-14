# STUDYON Design System

> 레퍼런스: 토스(구조/입력), 말해보카(게이미피케이션/다크학습), ABC Camp(출석/배지), 이화여대(좌석예약)

---

## 1. 디자인 방향

### 한 줄 정의
**"토스처럼 깔끔하고, 공부할 땐 집중되고, 성취는 눈에 보이는 학습 운영 앱"**

### 핵심 원칙

| 원칙 | 설명 | 레퍼런스 |
|------|------|----------|
| **Simple First** | 한 화면에 하나의 목적. 여백 넉넉히. | 토스 입력 화면 |
| **Glanceable** | 숫자/상태를 1초 안에 파악 가능 | 토스 홈, 이화여대 좌석 현황 |
| **Rewarding** | 출석/공부 성과를 시각적으로 보상 | ABC Camp 스탬프, 말해보카 트로피 |
| **Focus Mode** | 공부 중에는 다크톤으로 전환, 방해 최소화 | 말해보카 학습 화면 |

### 톤앤매너
- **라이트 모드**: 순백 배경 + 블루 포인트 (일반 화면)
- **다크 모드**: 딥 네이비 배경 (공부 세션/타이머 전용)
- **소프트 라운드**: 모든 모서리 둥글게 (12~16px), 친근하고 부드러운 느낌
- **대형 타이포**: 제목은 크고 두껍게, 한눈에 읽히도록 (토스 스타일)
- **미니멀 아이콘**: 라인 스타일, 단색, 꼭 필요한 곳에만

---

## 2. 컬러 시스템

### 2-1. Primary

```
primary         #3B82F6   CTA, 활성 탭, 링크, 공부중 상태
primaryLight    #DBEAFE   선택 배경, 하이라이트 tint
primaryDark     #1D4ED8   pressed/hover
primarySurface  #EFF6FF   카드 하이라이트 배경
```

### 2-2. Semantic

```
success         #22C55E   완료, 입실, 달성
successLight    #DCFCE7   성공 배경 tint
warning         #F59E0B   주의, 휴식중, 지각
warningLight    #FEF3C7   경고 배경 tint
error           #EF4444   오류, 미입실, 결석
errorLight      #FEE2E2   에러 배경 tint
info            #8B5CF6   배지, 보상, 특별 이벤트 (보라 — 말해보카 참조)
infoLight       #EDE9FE   보라 배경 tint
```

### 2-3. Neutral

```
background      #F8FAFC   전체 배경 (거의 화이트)
surface         #FFFFFF   카드, 시트, 모달
surfaceVariant  #F1F5F9   입력필드 배경, 비활성 영역
border          #E2E8F0   카드 외곽, 구분선
textPrimary     #0F172A   제목, 핵심 텍스트
textSecondary   #475569   본문, 설명
textTertiary    #94A3B8   힌트, 비활성
textOnPrimary   #FFFFFF   Primary 위의 텍스트
disabled        #CBD5E1   비활성 요소
```

### 2-4. 다크 모드 (공부 세션 전용)

```
darkBackground  #0F172A   타이머/세션 배경
darkSurface     #1E293B   다크 카드
darkBorder      #334155   다크 구분선
darkText        #F1F5F9   다크 모드 텍스트
darkTextSub     #94A3B8   다크 모드 보조 텍스트
```

### 2-5. 출결 상태

```
checkedIn       #22C55E   입실
studying        #3B82F6   공부 중
onBreak         #F59E0B   휴식 중
checkedOut      #64748B   퇴실
notCheckedIn    #EF4444   미입실
late            #F97316   지각
```

### 2-6. 랭킹/보상

```
rankGold        #F59E0B   1위 / 금
rankSilver      #94A3B8   2위 / 은
rankBronze      #D97706   3위 / 동
badgePurple     #8B5CF6   배지/보상 포인트 (말해보카 보라)
```

---

## 3. 타이포그래피

### 폰트
- **Pretendard** (한글+영문+숫자 통합)
- 대체: Apple SD Gothic Neo → Noto Sans KR

### 스케일

| 토큰 | 크기 | 웨이트 | 행간 | 용도 |
|------|------|--------|------|------|
| `displayLarge` | 32px | Bold 700 | 1.2 | 온보딩 대형 타이틀 (토스 스타일) |
| `headlineLarge` | 24px | Bold 700 | 1.3 | 페이지 제목 |
| `headlineMedium` | 20px | SemiBold 600 | 1.3 | KPI 숫자, 타이머 값 |
| `headlineSmall` | 18px | SemiBold 600 | 1.4 | 섹션 헤더 |
| `titleLarge` | 16px | SemiBold 600 | 1.4 | 카드 제목, 리스트 제목 |
| `titleMedium` | 14px | SemiBold 600 | 1.4 | 탭 라벨, 부제목 |
| `bodyLarge` | 16px | Regular 400 | 1.6 | 본문 (토스처럼 넉넉한 행간) |
| `bodyMedium` | 14px | Regular 400 | 1.5 | 일반 본문 |
| `bodySmall` | 12px | Regular 400 | 1.5 | 보조, 캡션 |
| `labelLarge` | 14px | Medium 500 | 1.4 | 버튼 라벨 |
| `labelSmall` | 11px | Medium 500 | 1.4 | 배지, 타임스탬프 |
| `timerDisplay` | 48px | Bold 700 | 1.1 | 공부 타이머 (tabular figures) |

### 규칙
- 제목: **왼쪽 정렬**, 큰 사이즈로 강하게 (토스 패턴)
- 숫자: **tabular figures** (고정폭)
- 시간: `X시간 Y분` 또는 `HH:mm`

---

## 4. 스페이싱

### 기본 단위 (4px 베이스)

```
xs    4px    아이콘-텍스트 간격
sm    8px    요소 내부 간격
md    12px   컴포넌트 간 간격
lg    16px   카드 패딩, 페이지 좌우
xl    24px   섹션 간 간격
xxl   32px   대형 섹션 구분
xxxl  48px   페이지 상단 여백
```

### 레이아웃

```
pagePadding       EdgeInsets.symmetric(horizontal: 20, vertical: 16)
                  ※ 토스 스타일: 좌우 20px로 여유롭게
cardPadding       EdgeInsets.all(16)
sectionGap        24px
```

### 반경 (Border Radius)

```
radiusSm    8px    태그, 배지
radiusMd    12px   버튼, 입력 필드
radiusLg    16px   카드
radiusXl    20px   모달, 바텀시트
radiusFull  9999px 칩, 아바타, 원형 버튼
```

---

## 5. 그림자

```
shadowNone  없음                  플랫 카드 (토스 스타일 — 구분선 대신)
shadowSm    0 1px 3px 0,0,0/0.06  미세 분리
shadowMd    0 4px 12px 0,0,0/0.08 플로팅 요소
shadowLg    0 12px 24px 0,0,0/0.12 모달, 바텀시트
```

> 토스 레퍼런스에서 배운 점: **그림자보다 여백과 배경색 차이**로 구분.
> 카드는 `surface`(흰색) + `background`(#F8FAFC) 대비로 분리.

---

## 6. 컴포넌트

### 6-1. 버튼

#### Primary (토스 스타일 CTA)
```
높이:         52px
반경:         radiusMd (12px)
배경:         primary (#3B82F6)
텍스트:       textOnPrimary, labelLarge
너비:         풀 너비 (stretch) — 토스처럼 하단 고정
pressed:     primaryDark
disabled:    disabled 배경 + textTertiary
loading:     20px 스피너 (white)
```

#### Secondary (Outlined)
```
배경:         transparent
테두리:       border 1.5px
텍스트:       textPrimary
pressed:     surfaceVariant 배경
```

#### Danger
```
배경:         error
텍스트:       textOnPrimary
용도:         삭제, 로그아웃
```

#### Ghost (Text)
```
배경:         transparent
텍스트:       primary
용도:         취소, 보조 액션
```

### 6-2. 입력 필드 (토스 스타일)

#### Underline TextField
```
스타일:       하단 border만 (1.5px)
비포커스:     border 색상
포커스:       primary 색상, 2px
라벨:         bodySmall, textTertiary, 상단 (floating)
값:           bodyLarge, textPrimary
에러:         하단 border error, 에러 메시지 bodySmall
제목:         headlineLarge — 필드 위에 크게
              "이름을 알려주세요" (토스 패턴)
```

#### Filled TextField (대안)
```
배경:         surfaceVariant
반경:         radiusMd
테두리:       없음 → 포커스시 primary 1.5px
```

### 6-3. 카드

#### 기본 카드
```
배경:         surface (#FFFFFF)
반경:         radiusLg (16px)
패딩:         16px
그림자:       shadowNone (배경 대비로 분리)
              또는 border 0.5px (미세 외곽)
```

#### KPI 카드 (토스 홈 섹션 참조)
```
구조:         라벨(bodySmall) + 값(headlineMedium)
              "오늘 공부 시간"
              "3시간 42분"
좌측:         아이콘 (선택)
```

#### 상태 카드 (출결)
```
좌:           상태 정보 (라벨 + 값)
우:           StatusBadge
```

#### 액션 카드
```
기본 카드 + 우측 chevron_right
onTap → 화면 이동
```

### 6-4. 상태 배지 (StatusBadge)

```
패딩:         좌우 10px, 상하 4px
반경:         radiusFull
폰트:         labelSmall (11px, Medium)
배경:         상태색 12% opacity
텍스트:       상태색 100%
```

| 상태 | 컬러 | 라벨 |
|------|------|------|
| 입실 | success | 입실 |
| 공부 중 | primary | 공부 중 |
| 휴식 중 | warning | 휴식 중 |
| 퇴실 | textTertiary | 퇴실 |
| 미입실 | error | 미입실 |
| 완료 | success | 완료 |
| 대기 | textTertiary | 대기 |
| 지각 | #F97316 | 지각 |

### 6-5. 칩 (ChoiceChip)

```
높이:         36px
패딩:         좌우 16px
반경:         radiusFull
비선택:       surfaceVariant 배경, textSecondary
선택:         primary 배경, textOnPrimary
```

### 6-6. 네비게이션

#### BottomNavigationBar (학생)
```
높이:         60px + SafeArea
배경:         surface
상단 구분:    border 0.5px
아이콘:       24px
라벨:         labelSmall
비활성:       textTertiary
활성:         primary (아이콘 + 라벨 모두)
탭 5개:       홈 / 출결 / 계획 / 리포트 / 내 정보
```

#### NavigationRail (관리자 웹)
```
너비:         80px (아이콘만) / 240px (확장)
배경:         surface
우측 구분:    border 1px
활성:         primary + primaryLight 배경 pill
```

### 6-7. AppBar

```
높이:         56px
배경:         surface (토스처럼 순백)
제목:         headlineSmall, 좌측 정렬
              또는 제목 없이 뒤로가기만 (토스 입력 패턴)
하단:         구분선 없음 (토스 스타일) 또는 미세 border
```

### 6-8. 모달 / 다이얼로그 (말해보카 참조)

```
배경:         surface
반경:         radiusXl (20px)
패딩:         24px
제목:         headlineLarge, 중앙 정렬 (말해보카 패턴)
내용:         bodyMedium, 중앙 정렬
CTA:          Primary Button (풀너비)
보조:         Ghost Button
오버레이:     검정 40% opacity
```

### 6-9. 토스트 / 스낵바

```
위치:         하단 20px
배경:         textPrimary (다크)
텍스트:       textOnPrimary
반경:         radiusMd (12px)
자동닫힘:     3초
```

### 6-10. 좌석 배치도 (이화여대 참조)

#### 좌석 목록 (이화여대 스타일)
```
각 행:        공간명 + 잔여/전체 + 프로그레스바
              "일반열람실  24/292  잔여하석 268  05:00~23:59"
프로그레스:   높이 4px, primary 색상
```

#### 좌석 맵 (이화여대 그리드)
```
그리드:       열 6~8개
셀:           40x40px (모바일) / 48x48px (웹)
빈좌석:       surface + border → 탭 가능
사용중:       primaryLight 배경
잠금:         errorLight 배경 + X표시
내좌석:       primary 배경 + textOnPrimary
```

### 6-11. 출석 캘린더 (ABC Camp 참조)

```
레이아웃:     7열 그리드 (월~일)
오늘:         primary 원형 배경
출석일:       success 점 (하단) 또는 체크 아이콘
미출석:       기본 텍스트
선택일:       primaryLight 배경
```

### 6-12. 타이머 (공부 세션)

```
배경:         darkBackground (#0F172A) — 말해보카 다크 참조
타이머 숫자:  timerDisplay (48px), darkText
상태 배지:    중앙, 타이머 아래
순공부/휴식:  2열 통계, darkTextSub
버튼:         Primary (공부 시작) / 보라 info (휴식)
```

### 6-13. 랭킹 리스트

#### TOP 3
```
CircleAvatar:  크기 44px
1위:           rankGold 배경 + 트로피 아이콘 (말해보카 참조)
2위:           rankSilver 배경
3위:           rankBronze 배경
이름:          titleLarge, Bold
점수:          headlineMedium
```

#### 4위 이하
```
CircleAvatar:  border 배경
이름:          bodyMedium
```

### 6-14. 배지/보상 (ABC Camp + 말해보카 참조)

```
배지 카드:     원형 56px 아이콘 + 라벨
미획득:        disabled 색상, 50% opacity
획득:          info (보라) 강조, 100% opacity
등급:          "여행자 → 탐험가 → 수집가" 식 레벨 시스템
```

### 6-15. 프로필 카드

```
구조:          아바타(64px) + 이름(headlineLarge) + 정보
              학생번호, 반, 좌석
QR 버튼:       secondary 버튼 (이화여대 참조)
```

### 6-16. 공지/알림 리스트

```
아이템:        제목(titleMedium) + 날짜(bodySmall)
구분선:        border 0.5px
읽음:          textTertiary
안읽음:        textPrimary + 좌측 primary 점(6px)
```

---

## 7. 화면별 디자인 가이드

### 7-1. 로그인 (토스 패턴 적용)

```
┌─────────────────────────┐
│                         │
│        STUDYON           │  ← headlineLarge, 중앙
│                         │
│  ┌─ 학생 ─┐ ┌─ 관리자 ─┐ │  ← ChoiceChip 2개
│                         │
│  학생 번호를 알려주세요    │  ← displayLarge, 좌측 (토스)
│                         │
│  학생 번호                │  ← Underline TextField
│  ────────────────────    │
│                         │
│  이름                    │  ← Underline TextField
│  ────────────────────    │
│                         │
│  (여백)                  │
│                         │
│  ┌─────────────────────┐│
│  │      로그인          ││  ← Primary Button, 하단 고정
│  └─────────────────────┘│
│  ┌─────────────────────┐│
│  │    QR 로그인         ││  ← Secondary Button
│  └─────────────────────┘│
└─────────────────────────┘
```

### 7-2. 홈 (토스 홈 + ABC Camp 인사)

```
┌─────────────────────────┐
│ STUDYON          🔔(3)  │  ← AppBar
├─────────────────────────┤
│                         │
│ 안녕하세요, 김학생님       │  ← headlineLarge
│ 오늘도 화이팅!            │  ← bodyMedium, textSecondary
│                         │
│ ┌───────────────────┐   │
│ │ 출결    입실 중 ●  │   │  ← 카드 + StatusBadge
│ │ 09:12 입실         │   │
│ │ 3시간 24분 체류    │   │
│ └───────────────────┘   │
│                         │
│ ┌─────────┐ ┌─────────┐ │
│ │오늘 공부 │ │오늘 계획 │ │  ← 2열 KPI 카드
│ │ 2h 30m  │ │ 3/5     │ │
│ └─────────┘ └─────────┘ │
│                         │
│ ┌───────────────────┐   │
│ │ 내 좌석  A-12     >│   │  ← 액션 카드
│ └───────────────────┘   │
│                         │
│ 빠른 액션                │  ← titleMedium
│ ┌─────────┐ ┌─────────┐ │
│ │ 🎯 공부 │ │ 📝 기록 │ │  ← 2열 버튼
│ │  시작   │ │  작성   │ │
│ └─────────┘ └─────────┘ │
│                         │
│ 공지                     │
│ · 이번 주 자습실 운영 안내 │  ← 최근 1~2건
│                         │
├─────────────────────────┤
│ 홈  출결  계획  리포트  MY│  ← BottomNav
└─────────────────────────┘
```

### 7-3. 공부 세션 (다크 모드 — 말해보카 학습 참조)

```
┌─────────────────────────┐
│ ← 공부 세션             │  ← AppBar (다크)
├─────────────────────────┤
│         (다크 배경)       │
│                         │
│       02:34:17          │  ← timerDisplay, white
│                         │
│      [ 공부 중 ]         │  ← StatusBadge (primary)
│                         │
│                         │
│   순공부        휴식      │
│   2시간 15분    19분     │  ← 2열 통계
│                         │
│                         │
│  ┌─────────────────────┐│
│  │     잠시 쉬기   ⏸   ││  ← Secondary (보라 info)
│  └─────────────────────┘│
│  ┌─────────────────────┐│
│  │       종료           ││  ← Danger Button
│  └─────────────────────┘│
└─────────────────────────┘
```

### 7-4. 좌석 (이화여대 직접 참조)

```
┌─────────────────────────┐
│ ← 좌석                  │
├─────────────────────────┤
│ ┌───────────────────┐   │
│ │ 내 좌석  A-12     │   │  ← 내 좌석 카드 (primary tint)
│ │ 상태: 사용 중      │   │
│ └───────────────────┘   │
│                         │
│ 자습실 현황              │
│ ┌───────────────────┐   │
│ │ 1층 자습실         │   │
│ │ ███████░░░ 24/30  │   │  ← 프로그레스바 + 숫자
│ ├───────────────────┤   │
│ │ 2층 자습실         │   │
│ │ ████░░░░░░ 12/30  │   │
│ └───────────────────┘   │
│                         │
│ 좌석 배치도              │
│ ┌──┬──┬──┬──┬──┬──┐    │
│ │01│02│03│04│05│06│    │  ← 그리드 맵
│ ├──┼──┼──┼──┼──┼──┤    │
│ │07│08│■ │10│11│12│    │  ← ■ = 사용중
│ ├──┼──┼──┼──┼──┼──┤    │
│ │13│14│15│16│17│18│    │
│ └──┴──┴──┴──┴──┴──┘    │
│                         │
│ 범례: □빈좌석 ■사용중 ●내자리 ✕잠금│
└─────────────────────────┘
```

### 7-5. 관리자 대시보드 (토스 홈 섹션 패턴)

```
┌──────┬──────────────────────┐
│      │ 운영 현황              │  ← headlineLarge
│ Nav  │                      │
│ Rail │ ┌────┐┌────┐┌────┐┌────┐
│      │ │전체 ││입실 ││공부 ││평균 │ ← 4열 KPI
│      │ │42명 ││28명 ││15명 ││3h  │
│      │ └────┘└────┘└────┘└────┘
│      │                      │
│      │ 주의 학생              │  ← titleLarge + warning tint
│      │ ┌──────────────────┐ │
│      │ │ ⚠ 미입실 3명     │ │
│      │ │ ⚠ 공부미시작 5명  │ │
│      │ │ ⚠ 장시간휴식 2명  │ │
│      │ └──────────────────┘ │
│      │                      │
│      │ 좌석 점유              │
│      │ ████████░░ 28/42     │
│      │                      │
│      │ 빠른 액션              │
│      │ [알림 발송] [좌석 관리] │
└──────┴──────────────────────┘
```

---

## 8. 인터랙션

### 전환
```
페이지:     300ms ease-out 슬라이드
모달:       250ms ease-out 페이드 + 슬라이드업
탭 전환:    200ms 크로스페이드
```

### 피드백
```
버튼 press:  100ms scale(0.97)
카드 tap:    150ms opacity(0.7)
토스트:      300ms 슬라이드업 → 3초 후 200ms 페이드아웃
```

### 데이터
```
스켈레톤:    1.5s shimmer 반복 (surfaceVariant → border)
Pull-to-refresh: 표준 Material
```

### 타이머
```
초 변경:     즉시 (애니메이션 없음)
상태 전환:   200ms 색상 크로스페이드
```

---

## 9. 아이콘

- **Material Icons Rounded** 기본
- 크기: 20px (인라인), 24px (네비/액션), 48px (빈 상태)

| 기능 | 아이콘 |
|------|--------|
| 홈 | `home_rounded` |
| 출결 | `how_to_reg` |
| 입실 | `login` |
| 퇴실 | `logout` |
| 계획 | `checklist` |
| 공부시작 | `play_circle_filled` |
| 일시정지 | `pause_circle_filled` |
| 리포트 | `bar_chart` |
| 랭킹 | `emoji_events` (트로피 — 말해보카) |
| 프로필 | `person` |
| 알림 | `notifications` |
| 좌석 | `event_seat` |
| 설정 | `settings` |
| 배지 | `military_tech` |

---

## 10. 반응형

```
mobile      0~599px     학생 앱, 관리자 모바일
tablet      600~899px   태블릿
desktop     900px+      관리자 웹 (NavigationRail)
```

---

## 11. 접근성

- 최소 터치 타겟: 44x44px
- 색상 대비: WCAG AA (4.5:1)
- 상태는 색상 + 텍스트 라벨 병행
- 포커스 링: primary 2px outline

---

## 12. Flutter 토큰 매핑 요약

```dart
// AppColors 핵심 변경사항
primary         → #3B82F6 (유지)
info            → #8B5CF6 (보라 — 배지/보상용으로 변경)
pagePadding     → EdgeInsets.symmetric(horizontal: 20, vertical: 16)
                  (기존 16 all → 좌우 20으로 토스 스타일 여유)
radiusLg        → 16px (기존 12 → 카드 더 둥글게)
radiusXl        → 20px (신규 — 모달/시트)
buttonHeight    → 52px (기존 48 → 더 넉넉하게)

// 신규 추가
darkBackground  → #0F172A (공부 세션 전용)
darkSurface     → #1E293B
badgePurple     → #8B5CF6
successLight    → #DCFCE7
warningLight    → #FEF3C7
errorLight      → #FEE2E2
infoLight       → #EDE9FE
primarySurface  → #EFF6FF
surfaceVariant  → #F1F5F9
```
