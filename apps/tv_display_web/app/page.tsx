"use client";

/* eslint-disable @next/next/no-img-element */
import { useCallback, useEffect, useState } from "react";
import {
  getGoals,
  getMotivation,
  getRankings,
  getSeats,
  getSettings,
  getStatus,
  type DisplaySeat,
  type DisplayStatus,
  type GoalWall,
  type Motivation,
  type RankingItem,
  type Rankings,
  type TvScreen,
  type TvSettings,
} from "@/lib/api";

const defaultSettings: TvSettings = {
  activeScreen: "RANKING",
  rotationEnabled: true,
  rotationIntervalSeconds: 30,
  enabledScreens: ["RANKING", "SEAT_MAP", "MESSAGE", "CLOCK"],
  message: "오늘도 목표를 끝까지 완수하세요.",
  rankingType: "STUDY_TIME",
  periodType: "DAILY",
  updatedAt: null,
};

const screenLabels: Record<TvScreen, string> = {
  RANKING: "오늘의 랭킹",
  SEAT_MAP: "좌석 현황",
  MESSAGE: "오늘의 메시지",
  CLOCK: "현재 시각",
  GOAL_WALL: "목표 월",
};

export default function Home() {
  const [settings, setSettings] = useState<TvSettings>(defaultSettings);
  const [status, setStatus] = useState<DisplayStatus | null>(null);
  const [rankings, setRankings] = useState<Rankings | null>(null);
  const [seats, setSeats] = useState<DisplaySeat[]>([]);
  const [motivation, setMotivation] = useState<Motivation | null>(null);
  const [goalWall, setGoalWall] = useState<GoalWall | null>(null);
  const [screenIndex, setScreenIndex] = useState(0);
  const [now, setNow] = useState(() => new Date());
  const [lastUpdatedAt, setLastUpdatedAt] = useState<Date | null>(null);
  const [lastErrorAt, setLastErrorAt] = useState<Date | null>(null);
  const [connectionState, setConnectionState] = useState<
    "live" | "polling" | "retrying"
  >("polling");

  const refresh = useCallback(async () => {
    try {
      const nextSettings = await getSettings();
      const [nextStatus, nextRankings, nextSeats, nextMotivation, nextGoals] =
        await Promise.all([
          getStatus(),
          getRankings(nextSettings.periodType, nextSettings.rankingType),
          getSeats(),
          getMotivation(),
          getGoals(),
        ]);
      setSettings(nextSettings);
      setStatus(nextStatus);
      setRankings(nextRankings);
      setSeats(nextSeats);
      setMotivation(nextMotivation);
      setGoalWall(nextGoals);
      setLastUpdatedAt(new Date());
      setLastErrorAt(null);
      setConnectionState((state) => (state === "live" ? "live" : "polling"));
    } catch {
      setLastErrorAt(new Date());
      setConnectionState("retrying");
    }
  }, []);

  useEffect(() => {
    queueMicrotask(() => {
      void refresh();
    });
    const poll = window.setInterval(() => {
      void refresh();
    }, 15_000);
    const clock = window.setInterval(() => setNow(new Date()), 1_000);
    return () => {
      window.clearInterval(poll);
      window.clearInterval(clock);
    };
  }, [refresh]);

  useEffect(() => {
    const source = new EventSource(
      "/api/v1/events/public?channels=display,attendance,seat",
    );
    const handleRefresh = () => {
      setConnectionState("live");
      void refresh();
    };
    source.onopen = () => setConnectionState("live");
    source.onerror = () => setConnectionState("retrying");
    source.onmessage = handleRefresh;
    source.addEventListener("display.updated", handleRefresh);
    source.addEventListener("display.refresh", handleRefresh);
    source.addEventListener("seat.updated", handleRefresh);
    source.addEventListener("seat.assigned", handleRefresh);
    source.addEventListener("student.checked_in", handleRefresh);
    source.addEventListener("student.checked_out", handleRefresh);
    return () => source.close();
  }, [refresh]);

  useEffect(() => {
    if (!settings.rotationEnabled || settings.enabledScreens.length <= 1)
      return;
    const interval = window.setInterval(
      () =>
        setScreenIndex((index) => (index + 1) % settings.enabledScreens.length),
      Math.max(10, settings.rotationIntervalSeconds) * 1000,
    );
    return () => window.clearInterval(interval);
  }, [
    settings.enabledScreens.length,
    settings.rotationEnabled,
    settings.rotationIntervalSeconds,
  ]);

  const visibleScreens =
    settings.enabledScreens.length > 0
      ? settings.enabledScreens
      : [settings.activeScreen];
  const visibleScreenIndex =
    visibleScreens.length > 0 ? screenIndex % visibleScreens.length : 0;
  const visibleScreen = settings.rotationEnabled
    ? (visibleScreens[visibleScreenIndex] ?? settings.activeScreen)
    : settings.activeScreen;
  const occupiedCount = seats.filter(
    (seat) => seat.uiStatus === "occupied",
  ).length;
  const totalSeats = seats.length;

  return (
    <main className="min-h-screen overflow-hidden bg-[#080b10] text-white">
      <div className="flex min-h-screen flex-col px-10 py-8">
        <header className="flex items-start justify-between gap-8">
          <div>
            <p className="text-sm font-bold tracking-[0.35em] text-cyan-300">
              STUDYON LIVE
            </p>
            <h1 className="mt-3 text-5xl font-black tracking-normal">
              자습실 실시간 현황
            </h1>
          </div>
          <div className="text-right">
            <p className="text-5xl font-black tabular-nums">
              {formatTime(now)}
            </p>
            <p className="mt-2 text-lg font-semibold text-slate-300">
              {formatDate(now)}
            </p>
          </div>
        </header>

        <section className="mt-8 grid grid-cols-4 gap-4">
          <Metric
            label="입실 인원"
            value={`${status?.checkedInCount ?? 0}명`}
          />
          <Metric
            label="좌석 사용률"
            value={`${Math.round(status?.seatOccupancyRate ?? 0)}%`}
          />
          <Metric
            label="실시간 순공부"
            value={formatMinutes(status?.liveStudyMinutes ?? 0)}
          />
          <Metric
            label="오늘 누적 공부"
            value={formatMinutes(status?.todayTotalStudyMinutes ?? 0)}
          />
        </section>

        <section className="relative mt-8 flex-1 rounded-[28px] border border-white/10 bg-white/[0.06] p-8 shadow-2xl">
          <div className="mb-6 flex items-center justify-between">
            <div>
              <p className="text-sm font-bold tracking-[0.25em] text-cyan-300">
                {screenLabels[visibleScreen]}
              </p>
              <p className="mt-1 text-slate-300">
                {settings.rotationEnabled
                  ? `${visibleScreens.length}개 화면 자동 순환`
                  : "관리자 선택 화면 고정"}
              </p>
            </div>
            <ScreenDots screens={visibleScreens} active={visibleScreen} />
          </div>

          {visibleScreen === "RANKING" && (
            <RankingScreen items={rankings?.items ?? []} />
          )}
          {visibleScreen === "SEAT_MAP" && (
            <SeatMapScreen
              seats={seats}
              occupiedCount={occupiedCount}
              totalSeats={totalSeats}
            />
          )}
          {visibleScreen === "MESSAGE" && (
            <MessageScreen message={settings.message} motivation={motivation} />
          )}
          {visibleScreen === "CLOCK" && <ClockScreen now={now} />}
          {visibleScreen === "GOAL_WALL" && <GoalWallScreen data={goalWall} />}
        </section>

        <footer className="mt-5 flex items-center justify-between text-sm text-slate-400">
          <span>
            {connectionState === "retrying"
              ? lastUpdatedAt
                ? "연결 재시도 중 · 마지막 데이터 유지"
                : "연결 재시도 중 · 데이터 대기"
              : connectionState === "live"
                ? "실시간 연결됨"
                : "자동 갱신 중"}
          </span>
          <span>
            {lastErrorAt
              ? `${formatTime(lastErrorAt)} 연결 실패`
              : lastUpdatedAt
                ? `${formatTime(lastUpdatedAt)} 업데이트`
                : "데이터 준비 중"}
          </span>
        </footer>
      </div>
    </main>
  );
}

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-2xl border border-white/10 bg-white/[0.07] px-6 py-5">
      <p className="text-sm font-semibold text-slate-400">{label}</p>
      <p className="mt-3 text-4xl font-black tabular-nums">{value}</p>
    </div>
  );
}

function ScreenDots({
  screens,
  active,
}: {
  screens: TvScreen[];
  active: TvScreen;
}) {
  return (
    <div className="flex gap-2">
      {screens.map((screen) => (
        <span
          key={screen}
          className={`h-2.5 w-10 rounded-full ${screen === active ? "bg-cyan-300" : "bg-white/20"}`}
        />
      ))}
    </div>
  );
}

function RankingScreen({ items }: { items: RankingItem[] }) {
  const topItems = items.slice(0, 5);
  if (topItems.length === 0) {
    return (
      <EmptyState
        title="아직 랭킹 데이터가 없습니다"
        subtitle="학생들이 공부를 시작하면 이곳에 순위가 표시됩니다."
      />
    );
  }
  return (
    <div className="grid h-full grid-cols-[380px_1fr] gap-8">
      <div className="flex flex-col justify-center rounded-3xl bg-cyan-300 p-8 text-slate-950">
        <p className="text-sm font-black tracking-[0.25em]">TOP RANK</p>
        <p className="mt-8 text-8xl font-black tabular-nums">1</p>
        <p className="mt-4 text-5xl font-black">{displayName(topItems[0])}</p>
        <p className="mt-4 text-2xl font-bold tabular-nums">
          {Number(topItems[0].score).toLocaleString()}점
        </p>
      </div>
      <div className="space-y-4">
        {topItems.map((item) => (
          <div
            key={item.id}
            className="flex items-center rounded-2xl bg-white/[0.08] px-6 py-5"
          >
            <span className="w-16 text-4xl font-black tabular-nums text-cyan-200">
              {item.rankNo}
            </span>
            <span className="flex-1 text-3xl font-extrabold">
              {displayName(item)}
            </span>
            <span className="text-2xl font-black tabular-nums text-slate-300">
              {Number(item.score).toLocaleString()}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}

function SeatMapScreen({
  seats,
  occupiedCount,
  totalSeats,
}: {
  seats: DisplaySeat[];
  occupiedCount: number;
  totalSeats: number;
}) {
  if (seats.length === 0) {
    return (
      <EmptyState
        title="등록된 좌석이 없습니다"
        subtitle="관리자 좌석 메뉴에서 좌석을 먼저 등록하세요."
      />
    );
  }
  return (
    <div className="grid h-full grid-cols-[1fr_300px] gap-8">
      <div className="grid auto-rows-fr grid-cols-6 gap-3">
        {seats.map((seat) => (
          <div
            key={seat.id}
            className={`flex min-h-24 flex-col justify-between rounded-2xl border px-4 py-3 ${seatColor(seat.uiStatus)}`}
          >
            <span className="text-2xl font-black">{seat.seatNo}</span>
            <span className="text-sm font-bold text-white/75">
              {seat.currentStudent?.displayName ?? statusLabel(seat.uiStatus)}
            </span>
          </div>
        ))}
      </div>
      <div className="flex flex-col justify-center rounded-3xl bg-white/[0.08] p-8">
        <p className="text-sm font-bold tracking-[0.25em] text-cyan-300">
          SEATS
        </p>
        <p className="mt-8 text-7xl font-black tabular-nums">
          {occupiedCount}
          <span className="text-3xl text-slate-400">/{totalSeats}</span>
        </p>
        <p className="mt-3 text-2xl font-bold text-slate-300">현재 사용 중</p>
      </div>
    </div>
  );
}

function MessageScreen({
  message,
  motivation,
}: {
  message: string;
  motivation: Motivation | null;
}) {
  return (
    <div className="flex h-full flex-col items-center justify-center text-center">
      <p className="max-w-5xl text-7xl font-black leading-tight">{message}</p>
      <p className="mt-10 text-3xl font-bold text-cyan-200">
        {motivation?.challenge ?? "오늘의 목표를 끝까지 완수하세요."}
      </p>
      {motivation?.topStudent && (
        <p className="mt-5 text-xl text-slate-300">
          현재 1위{" "}
          {motivation.topStudent.displayName ?? motivation.topStudent.name}
        </p>
      )}
    </div>
  );
}

function ClockScreen({ now }: { now: Date }) {
  return (
    <div className="flex h-full flex-col items-center justify-center text-center">
      <p className="text-[160px] font-black leading-none tabular-nums">
        {formatTime(now)}
      </p>
      <p className="mt-8 text-5xl font-extrabold text-slate-200">
        {formatDate(now)}
      </p>
    </div>
  );
}

function GoalWallScreen({ data }: { data: GoalWall | null }) {
  const goals = data?.goals ?? [];
  const achievers = data?.achievers ?? [];
  if (goals.length === 0 && achievers.length === 0) {
    return (
      <EmptyState
        title="승인된 목표가 없습니다"
        subtitle="학생 동의와 관리자 승인이 완료되면 목표 월에 표시됩니다."
      />
    );
  }
  return (
    <div className="grid h-full grid-cols-[1fr_360px] gap-8">
      <div className="grid grid-cols-3 gap-4">
        {goals.slice(0, 6).map((goal) => (
          <div
            key={goal.studentId}
            className="flex flex-col justify-between overflow-hidden rounded-3xl border border-white/10 bg-white/[0.08] p-6"
          >
            <div className="flex items-center gap-4">
              <div className="flex h-20 w-20 shrink-0 items-center justify-center overflow-hidden rounded-2xl bg-cyan-300 text-3xl font-black text-slate-950">
                {goal.targetUniversityMedia?.publicUrl ? (
                  <img
                    src={goal.targetUniversityMedia.publicUrl}
                    alt=""
                    className="h-full w-full object-cover"
                  />
                ) : (
                  goal.targetUniversityName[0]
                )}
              </div>
              <div className="min-w-0">
                <p className="truncate text-3xl font-black">
                  {goal.targetUniversityName}
                </p>
                <p className="mt-1 text-lg font-bold text-slate-300">
                  {goal.displayName}
                </p>
              </div>
            </div>
            <p className="mt-8 text-xl font-bold text-cyan-200">
              오늘 목표를 향해 한 칸 더 전진
            </p>
          </div>
        ))}
      </div>
      <div className="rounded-3xl bg-cyan-300 p-8 text-slate-950">
        <p className="text-sm font-black tracking-[0.25em]">TODAY ACHIEVERS</p>
        <div className="mt-8 space-y-4">
          {achievers.length === 0 ? (
            <p className="text-2xl font-black">오늘 달성자를 기다리는 중</p>
          ) : (
            achievers.slice(0, 5).map((item) => (
              <div key={`${item.displayName}-${item.studyMinutes}`}>
                <p className="text-3xl font-black">{item.displayName}</p>
                <p className="mt-1 text-lg font-bold">
                  달성률 {Math.round(item.achievedRate)}% ·{" "}
                  {formatMinutes(item.studyMinutes)}
                </p>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}

function EmptyState({ title, subtitle }: { title: string; subtitle: string }) {
  return (
    <div className="flex h-full flex-col items-center justify-center text-center">
      <p className="text-5xl font-black">{title}</p>
      <p className="mt-4 text-2xl font-semibold text-slate-400">{subtitle}</p>
    </div>
  );
}

function displayName(item: RankingItem) {
  return item.displayName ?? item.student.user.name;
}

function seatColor(status: DisplaySeat["uiStatus"]) {
  if (status === "occupied") return "border-cyan-300/60 bg-cyan-400/25";
  if (status === "reserved") return "border-amber-300/60 bg-amber-400/20";
  if (status === "locked") return "border-rose-300/60 bg-rose-400/20";
  return "border-white/10 bg-white/[0.06]";
}

function statusLabel(status: DisplaySeat["uiStatus"]) {
  if (status === "occupied") return "사용 중";
  if (status === "reserved") return "예약";
  if (status === "locked") return "잠김";
  return "비어 있음";
}

function formatTime(date: Date) {
  return date.toLocaleTimeString("ko-KR", {
    hour: "2-digit",
    minute: "2-digit",
  });
}

function formatDate(date: Date) {
  return date.toLocaleDateString("ko-KR", {
    year: "numeric",
    month: "long",
    day: "numeric",
    weekday: "long",
  });
}

function formatMinutes(minutes: number) {
  const safe = Math.max(0, Math.round(minutes));
  const hours = Math.floor(safe / 60);
  const mins = safe % 60;
  return hours > 0 ? `${hours}시간 ${mins}분` : `${mins}분`;
}
