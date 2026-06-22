"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import {
  Armchair,
  Clock,
  ExternalLink,
  MessageSquare,
  RefreshCw,
  Save,
  Target,
  Trophy,
  Tv,
} from "lucide-react";
import { PageHeader } from "@/components/page-header";
import {
  getTvDisplaySettings,
  updateTvDisplaySettings,
  type TvDisplaySettingsResponse,
  type TvScreen,
} from "@/lib/api";

const screens: {
  key: TvScreen;
  label: string;
  desc: string;
  icon: typeof Trophy;
}[] = [
  { key: "RANKING", label: "랭킹", desc: "오늘의 공부 랭킹", icon: Trophy },
  {
    key: "SEAT_MAP",
    label: "좌석 현황",
    desc: "실시간 좌석 배치도",
    icon: Armchair,
  },
  {
    key: "MESSAGE",
    label: "메시지",
    desc: "학원 공지와 동기부여 문구",
    icon: MessageSquare,
  },
  { key: "CLOCK", label: "시계", desc: "현재 시각과 날짜", icon: Clock },
  {
    key: "GOAL_WALL",
    label: "목표 월",
    desc: "승인된 목표와 달성자",
    icon: Target,
  },
];

const screenAliases: Record<string, TvScreen> = {
  RANKING: "RANKING",
  STATUS: "SEAT_MAP",
  SEAT_MAP: "SEAT_MAP",
  MOTIVATION: "MESSAGE",
  MESSAGE: "MESSAGE",
  CLOCK: "CLOCK",
  GOAL_WALL: "GOAL_WALL",
};

const tvDisplayUrl =
  process.env.NEXT_PUBLIC_TV_DISPLAY_URL ?? "http://localhost:11112";

function normalizeScreen(value: string | undefined): TvScreen {
  return value ? (screenAliases[value] ?? "RANKING") : "RANKING";
}

function normalizeSettings(settings: TvDisplaySettingsResponse | null) {
  const displayOptions = settings?.displayOptions ?? {};
  const enabledScreens =
    displayOptions.enabledScreens
      ?.map((screen) => normalizeScreen(screen))
      .filter((screen, index, list) => list.indexOf(screen) === index) ?? [];

  return {
    activeScreen: normalizeScreen(settings?.activeScreen),
    rotationEnabled: settings?.rotationEnabled ?? true,
    rotationIntervalSeconds: settings?.rotationIntervalSeconds ?? 30,
    enabledScreens:
      enabledScreens.length > 0
        ? enabledScreens
        : ([
            "RANKING",
            "SEAT_MAP",
            "MESSAGE",
            "CLOCK",
            "GOAL_WALL",
          ] as TvScreen[]),
    message: displayOptions.message ?? "오늘도 목표를 끝까지 완수하세요.",
    rankingType: displayOptions.rankingType ?? "STUDY_TIME",
    periodType: displayOptions.periodType ?? "DAILY",
  };
}

export default function TvPage() {
  const [activeScreen, setActiveScreen] = useState<TvScreen>("RANKING");
  const [enabledScreens, setEnabledScreens] = useState<TvScreen[]>([
    "RANKING",
    "SEAT_MAP",
    "MESSAGE",
    "CLOCK",
    "GOAL_WALL",
  ]);
  const [rotationEnabled, setRotationEnabled] = useState(true);
  const [rotationIntervalSeconds, setRotationIntervalSeconds] = useState(30);
  const [message, setMessage] = useState("오늘도 목표를 끝까지 완수하세요.");
  const [rankingType, setRankingType] = useState("STUDY_TIME");
  const [periodType, setPeriodType] = useState("DAILY");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [savedAt, setSavedAt] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      const next = normalizeSettings(await getTvDisplaySettings());
      setActiveScreen(next.activeScreen);
      setEnabledScreens(next.enabledScreens);
      setRotationEnabled(next.rotationEnabled);
      setRotationIntervalSeconds(next.rotationIntervalSeconds);
      setMessage(next.message);
      setRankingType(next.rankingType);
      setPeriodType(next.periodType);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  const activeScreenMeta = useMemo(
    () => screens.find((screen) => screen.key === activeScreen) ?? screens[0],
    [activeScreen],
  );

  const toggleScreen = (screen: TvScreen) => {
    setEnabledScreens((current) => {
      if (current.includes(screen)) {
        const next = current.filter((item) => item !== screen);
        return next.length === 0 ? current : next;
      }
      return [...current, screen];
    });
  };

  const saveSettings = async () => {
    setSaving(true);
    try {
      await updateTvDisplaySettings({
        activeScreen,
        rotationEnabled,
        rotationIntervalSeconds,
        displayOptions: {
          enabledScreens,
          message,
          rankingType,
          periodType,
        },
      });
      setSavedAt(
        new Date().toLocaleTimeString("ko-KR", {
          hour: "2-digit",
          minute: "2-digit",
        }),
      );
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <PageHeader
        title="TV 제어"
        description="학원 TV 운영 화면을 관리합니다"
        icon={Tv}
      />

      <div className="grid grid-cols-1 lg:grid-cols-[1fr_420px] gap-6">
        <div className="space-y-4">
          <section className="bg-white rounded-2xl p-5 border border-card-border card-shadow">
            <div className="flex items-center justify-between gap-3 mb-4">
              <p className="text-[11px] font-bold text-text-tertiary tracking-wide uppercase">
                현재 표시 화면
              </p>
              {loading && (
                <span className="text-[11px] text-text-tertiary">
                  불러오는 중...
                </span>
              )}
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
              {screens.map((screen) => {
                const Icon = screen.icon;
                const selected = activeScreen === screen.key;
                return (
                  <button
                    key={screen.key}
                    onClick={() => setActiveScreen(screen.key)}
                    className={`p-4 rounded-xl text-left transition-all border ${
                      selected
                        ? "bg-primary-surface border-primary/20"
                        : "bg-bg border-transparent hover:border-card-border"
                    }`}
                  >
                    <div className="flex items-center gap-2 mb-1">
                      <Icon
                        size={15}
                        className={
                          selected ? "text-primary" : "text-text-tertiary"
                        }
                      />
                      <p
                        className={`font-semibold text-sm ${selected ? "text-primary" : "text-text-primary"}`}
                      >
                        {screen.label}
                      </p>
                    </div>
                    <p className="text-[11px] text-text-tertiary">
                      {screen.desc}
                    </p>
                  </button>
                );
              })}
            </div>
          </section>

          <section className="bg-white rounded-2xl p-5 border border-card-border card-shadow">
            <p className="text-[11px] font-bold text-text-tertiary mb-4 tracking-wide uppercase">
              자동 순환
            </p>
            <div className="flex flex-col gap-4">
              <label className="flex items-center justify-between gap-3">
                <span>
                  <span className="block text-sm font-semibold text-text-primary">
                    순환 사용
                  </span>
                  <span className="block text-[11px] text-text-tertiary">
                    TV가 선택된 화면들을 자동으로 넘깁니다.
                  </span>
                </span>
                <input
                  type="checkbox"
                  checked={rotationEnabled}
                  onChange={(event) => setRotationEnabled(event.target.checked)}
                  className="h-5 w-5 accent-primary"
                />
              </label>
              <label className="block">
                <span className="text-[11px] font-bold text-text-tertiary tracking-wide uppercase">
                  순환 간격
                </span>
                <input
                  type="number"
                  min={10}
                  max={300}
                  value={rotationIntervalSeconds}
                  onChange={(event) =>
                    setRotationIntervalSeconds(Number(event.target.value))
                  }
                  className="mt-2 w-full rounded-xl bg-bg border border-card-border px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/30"
                />
              </label>
              <div className="grid grid-cols-2 gap-2">
                {screens.map((screen) => (
                  <label
                    key={screen.key}
                    className="flex items-center gap-2 rounded-xl bg-bg border border-card-border px-3 py-2 text-sm font-semibold text-text-secondary"
                  >
                    <input
                      type="checkbox"
                      checked={enabledScreens.includes(screen.key)}
                      onChange={() => toggleScreen(screen.key)}
                      className="accent-primary"
                    />
                    {screen.label}
                  </label>
                ))}
              </div>
            </div>
          </section>

          <section className="bg-white rounded-2xl p-5 border border-card-border card-shadow">
            <p className="text-[11px] font-bold text-text-tertiary mb-4 tracking-wide uppercase">
              콘텐츠 옵션
            </p>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <label className="block">
                <span className="text-[11px] font-bold text-text-tertiary">
                  랭킹 기간
                </span>
                <select
                  value={periodType}
                  onChange={(event) => setPeriodType(event.target.value)}
                  className="mt-2 w-full rounded-xl bg-bg border border-card-border px-4 py-3 text-sm"
                >
                  <option value="DAILY">오늘</option>
                  <option value="WEEKLY">이번 주</option>
                  <option value="MONTHLY">이번 달</option>
                </select>
              </label>
              <label className="block">
                <span className="text-[11px] font-bold text-text-tertiary">
                  랭킹 기준
                </span>
                <select
                  value={rankingType}
                  onChange={(event) => setRankingType(event.target.value)}
                  className="mt-2 w-full rounded-xl bg-bg border border-card-border px-4 py-3 text-sm"
                >
                  <option value="STUDY_TIME">공부 시간</option>
                  <option value="STUDY_VOLUME">학습량</option>
                  <option value="ATTENDANCE_STREAK">연속 출석</option>
                </select>
              </label>
            </div>
            <label className="block mt-4">
              <span className="text-[11px] font-bold text-text-tertiary tracking-wide uppercase">
                메시지
              </span>
              <textarea
                value={message}
                onChange={(event) => setMessage(event.target.value)}
                placeholder="TV에 표시할 메시지를 입력하세요"
                rows={3}
                className="mt-2 w-full rounded-xl bg-bg border border-card-border px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/30 placeholder:text-text-tertiary resize-none"
              />
            </label>
          </section>

          <div className="flex flex-col sm:flex-row gap-2">
            <button
              onClick={load}
              className="h-11 px-4 bg-bg text-text-secondary rounded-xl text-sm font-semibold hover:bg-gray-200 transition-colors flex items-center justify-center gap-1.5 border border-card-border"
            >
              <RefreshCw size={15} />
              다시 불러오기
            </button>
            <button
              onClick={saveSettings}
              disabled={saving}
              className="h-11 px-5 gradient-primary text-white rounded-xl text-sm font-semibold hover:opacity-90 transition-opacity flex items-center justify-center gap-1.5 disabled:opacity-60"
            >
              <Save size={15} />
              {saving ? "저장 중..." : "저장"}
            </button>
            <a
              href={tvDisplayUrl}
              target="_blank"
              rel="noreferrer"
              className="h-11 px-4 bg-gray-950 text-white rounded-xl text-sm font-semibold hover:bg-gray-800 transition-colors flex items-center justify-center gap-1.5"
            >
              <ExternalLink size={15} />
              TV 열기
            </a>
          </div>
        </div>

        <aside>
          <div className="flex items-center gap-2 mb-3">
            <span className="w-2 h-2 rounded-full bg-accent animate-pulse-dot" />
            <p className="text-[11px] font-bold text-text-tertiary tracking-wide uppercase">
              미리보기 - {activeScreenMeta.label}
            </p>
            {savedAt && (
              <span className="text-[10px] text-text-tertiary ml-auto">
                {savedAt} 저장
              </span>
            )}
          </div>
          <div className="bg-gray-950 rounded-2xl overflow-hidden aspect-video p-6 border border-gray-800 text-white">
            <p className="text-yellow-300 text-[10px] font-bold mb-4 tracking-[0.2em] uppercase">
              STUDYON TV
            </p>
            {activeScreen === "RANKING" && (
              <p className="text-2xl font-extrabold">오늘의 공부 랭킹</p>
            )}
            {activeScreen === "SEAT_MAP" && (
              <p className="text-2xl font-extrabold">실시간 좌석 현황</p>
            )}
            {activeScreen === "MESSAGE" && (
              <p className="text-2xl font-extrabold leading-relaxed">
                {message}
              </p>
            )}
            {activeScreen === "CLOCK" && (
              <p className="text-5xl font-extrabold tabular-nums">
                {new Date().toLocaleTimeString("ko-KR", {
                  hour: "2-digit",
                  minute: "2-digit",
                })}
              </p>
            )}
            {activeScreen === "GOAL_WALL" && (
              <p className="text-2xl font-extrabold">목표 월 · 오늘의 달성자</p>
            )}
            <p className="mt-5 text-xs text-white/40">
              {rotationEnabled
                ? `${enabledScreens.length}개 화면을 ${rotationIntervalSeconds}초마다 순환`
                : "선택 화면 고정 표시"}
            </p>
          </div>
          <p className="text-[11px] text-text-tertiary mt-2.5 text-center font-medium">
            TV web은 공개 화면이므로 학생 이름은 마스킹되어 표시됩니다.
          </p>
        </aside>
      </div>
    </div>
  );
}
