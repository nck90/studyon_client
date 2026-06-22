"use client";

import type React from "react";
import { useCallback, useEffect, useMemo, useState } from "react";
import {
  AlertTriangle,
  CheckCircle2,
  Clipboard,
  Focus,
  MessageSquareText,
  RefreshCw,
  Share2,
} from "lucide-react";
import { PageHeader } from "@/components/page-header";
import {
  createOpsParentReport,
  generateOpsTasks,
  getFocusEvents,
  getFocusOverview,
  getFocusStudents,
  sendOpsStudentMessage,
  type FocusEventResponse,
  type FocusOverviewResponse,
  type FocusStudentResponse,
  type FocusStudentStatus,
  type OpsTaskResponse,
} from "@/lib/api";

const statusLabels: Record<FocusStudentStatus, string> = {
  FOCUSING: "집중 중",
  BREAK: "휴식",
  NEEDS_ATTENTION: "관찰",
  HIGH_RISK: "조치 필요",
  IDLE: "대기",
};

const eventLabels: Record<string, string> = {
  FOCUS_STARTED: "집중 시작",
  APP_EXIT: "앱 이탈",
  APP_RETURN: "복귀",
  FOCUS_PAUSED: "휴식",
  FOCUS_RESUMED: "재개",
  FOCUS_ENDED: "집중 종료",
};

export default function FocusPage() {
  const [overview, setOverview] = useState<FocusOverviewResponse | null>(null);
  const [students, setStudents] = useState<FocusStudentResponse[]>([]);
  const [events, setEvents] = useState<FocusEventResponse[]>([]);
  const [status, setStatus] = useState<FocusStudentStatus | "ALL">("ALL");
  const [loading, setLoading] = useState(true);
  const [busyStudentId, setBusyStudentId] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [copiedUrl, setCopiedUrl] = useState<string | null>(null);
  const [liveState, setLiveState] = useState<"live" | "retrying">("live");

  const reload = useCallback(async () => {
    const [nextOverview, nextStudents, nextEvents] = await Promise.all([
      getFocusOverview(),
      getFocusStudents({ status }),
      getFocusEvents(),
    ]);
    setOverview(nextOverview);
    setStudents(nextStudents);
    setEvents(nextEvents);
  }, [status]);

  useEffect(() => {
    setLoading(true);
    reload()
      .catch((error) =>
        setMessage(
          error instanceof Error
            ? error.message
            : "집중 관제 데이터를 불러오지 못했습니다.",
        ),
      )
      .finally(() => setLoading(false));
  }, [reload]);

  useEffect(() => {
    const poll = window.setInterval(() => {
      void reload();
    }, 15_000);
    const source = new EventSource("/api/v1/events/public?channels=focus");
    const refresh = () => {
      setLiveState("live");
      void reload();
    };
    source.onopen = () => setLiveState("live");
    source.onerror = () => setLiveState("retrying");
    source.onmessage = refresh;
    source.addEventListener("focus.changed", refresh);
    return () => {
      window.clearInterval(poll);
      source.close();
    };
  }, [reload]);

  const highRiskCount = useMemo(
    () => students.filter((student) => student.status === "HIGH_RISK").length,
    [students],
  );

  const ensureFocusTask = async (student: FocusStudentResponse) => {
    const tasks = await generateOpsTasks();
    const task = tasks.find(
      (item) =>
        item.studentId === student.studentId &&
        item.reasonType === "FOCUS_INTERRUPTION" &&
        item.status === "OPEN",
    );
    if (!task) {
      throw new Error("운영 큐 기준에 도달한 집중 이탈 항목이 없습니다.");
    }
    return task;
  };

  const runStudentMessage = async (student: FocusStudentResponse) => {
    setBusyStudentId(student.studentId);
    try {
      const task = await ensureFocusTask(student);
      await sendOpsStudentMessage(
        task.id,
        `${student.studentName} 학생, 잠깐 새어 나간 집중을 다시 이어가 봅시다.`,
      );
      setMessage("학생에게 복귀 메시지를 보냈습니다.");
      await reload();
    } finally {
      setBusyStudentId(null);
    }
  };

  const runParentReport = async (student: FocusStudentResponse) => {
    setBusyStudentId(student.studentId);
    try {
      const task: OpsTaskResponse = await ensureFocusTask(student);
      const issued = await createOpsParentReport(task.id, task.message);
      const parentBase =
        process.env.NEXT_PUBLIC_PARENT_WEB_URL ?? window.location.origin;
      const url = `${parentBase.replace(/\/$/, "")}${issued.urlPath}`;
      await navigator.clipboard?.writeText(url);
      setCopiedUrl(url);
      setMessage("학부모 공유 링크를 생성하고 복사했습니다.");
      await reload();
    } finally {
      setBusyStudentId(null);
    }
  };

  return (
    <div className="mx-auto max-w-7xl p-6 md:p-8">
      <PageHeader
        title="집중 관제"
        description="공부 중 앱 이탈, 복귀 흐름, 운영 조치 대상을 실시간으로 확인합니다"
        icon={Focus}
        actions={
          <button
            type="button"
            onClick={() => void reload()}
            className="inline-flex h-10 items-center gap-2 rounded-lg bg-primary px-4 text-sm font-bold text-white shadow-sm"
          >
            <RefreshCw size={16} />
            새로고침
          </button>
        }
      />

      <div className="mb-5 grid grid-cols-2 gap-3 lg:grid-cols-5">
        <Kpi label="집중 보호율" value={`${overview?.protectionRate ?? 100}%`} />
        <Kpi label="집중 중" value={`${overview?.totalStudyingCount ?? 0}명`} />
        <Kpi label="이탈 학생" value={`${overview?.exitStudentCount ?? 0}명`} />
        <Kpi label="고위험" value={`${overview?.highRiskStudentCount ?? highRiskCount}명`} />
        <Kpi label="평균 복귀" value={`${overview?.averageReturnSeconds ?? 0}초`} />
      </div>

      <div className="mb-4 flex flex-wrap items-center gap-2">
        {(["ALL", "FOCUSING", "BREAK", "NEEDS_ATTENTION", "HIGH_RISK", "IDLE"] as const).map((item) => (
          <button
            key={item}
            type="button"
            onClick={() => setStatus(item)}
            className={`h-9 rounded-lg px-3 text-xs font-extrabold ${
              status === item
                ? "bg-primary text-white"
                : "border border-card-border bg-white text-text-secondary"
            }`}
          >
            {item === "ALL" ? "전체" : statusLabels[item]}
          </button>
        ))}
        <span className="ml-auto inline-flex items-center gap-1.5 rounded-full bg-white px-3 py-1.5 text-xs font-bold text-text-tertiary">
          <span className={`h-2 w-2 rounded-full ${liveState === "live" ? "bg-accent" : "bg-warm"}`} />
          {liveState === "live" ? "실시간" : "재연결 중"}
        </span>
      </div>

      {message && (
        <div className="mb-4 rounded-lg bg-primary-surface px-4 py-3 text-sm font-bold text-primary">
          {message}
        </div>
      )}

      {copiedUrl && (
        <div className="mb-4 flex items-center gap-2 rounded-lg border border-card-border bg-white px-4 py-3 text-xs text-text-secondary">
          <Clipboard size={15} className="text-primary" />
          <span className="truncate">{copiedUrl}</span>
        </div>
      )}

      <div className="grid gap-4 lg:grid-cols-[minmax(0,1fr)_360px]">
        <section>
          <div className="mb-3 flex items-center justify-between">
            <h2 className="text-base font-extrabold text-text-primary">
              학생 집중 상태
            </h2>
            <span className="text-xs font-bold text-text-tertiary">
              {students.length}명
            </span>
          </div>
          {loading ? (
            <Empty text="집중 상태를 불러오는 중입니다." />
          ) : students.length === 0 ? (
            <Empty text="표시할 학생이 없습니다." />
          ) : (
            <div className="grid gap-3">
              {students.map((student) => (
                <article
                  key={student.studentId}
                  className="rounded-lg border border-card-border bg-white p-4 card-shadow"
                >
                  <div className="flex flex-col gap-4 xl:flex-row xl:items-center xl:justify-between">
                    <div className="min-w-0">
                      <div className="mb-2 flex flex-wrap items-center gap-2">
                        <StatusPill status={student.status} />
                        <span className="text-xs font-bold text-text-tertiary">
                          {student.gradeName ?? "학년 없음"} · {student.className ?? "반 없음"}
                        </span>
                      </div>
                      <h3 className="text-base font-extrabold text-text-primary">
                        {student.studentName}
                        <span className="ml-2 text-xs font-bold text-text-tertiary">
                          {student.studentNo}
                        </span>
                      </h3>
                      <p className="mt-1 text-sm font-medium text-text-secondary">
                        이탈 {student.eventCount}회 · 복귀 {student.returnCount}회 · 평균 복귀 {student.averageReturnSeconds}초
                      </p>
                    </div>
                    <div className="grid grid-cols-2 gap-2 sm:flex">
                      <ActionButton
                        label="메시지"
                        icon={MessageSquareText}
                        disabled={busyStudentId === student.studentId}
                        onClick={() => void runStudentMessage(student)}
                      />
                      <ActionButton
                        label="학부모 링크"
                        icon={Share2}
                        disabled={busyStudentId === student.studentId}
                        onClick={() => void runParentReport(student)}
                      />
                    </div>
                  </div>
                </article>
              ))}
            </div>
          )}
        </section>

        <aside>
          <h2 className="mb-3 text-base font-extrabold text-text-primary">
            이탈 활동
          </h2>
          <div className="grid gap-2">
            {events.length === 0 ? (
              <Empty text="오늘 기록된 집중 이벤트가 없습니다." />
            ) : (
              events.map((event) => (
                <div
                  key={event.id}
                  className="rounded-lg border border-card-border bg-white p-3"
                >
                  <div className="flex items-start gap-2">
                    {event.eventType === "APP_EXIT" ? (
                      <AlertTriangle size={16} className="mt-0.5 text-hot" />
                    ) : (
                      <CheckCircle2 size={16} className="mt-0.5 text-accent" />
                    )}
                    <div className="min-w-0">
                      <p className="text-sm font-extrabold text-text-primary">
                        {event.studentName}
                      </p>
                      <p className="text-xs font-bold text-text-tertiary">
                        {eventLabels[event.eventType] ?? event.eventType}
                        {event.durationSeconds != null
                          ? ` · ${event.durationSeconds}초`
                          : ""}
                      </p>
                      <p className="mt-1 text-[11px] font-medium text-text-tertiary">
                        {new Date(event.occurredAt).toLocaleTimeString("ko-KR")}
                      </p>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>
        </aside>
      </div>
    </div>
  );
}

function Kpi({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg border border-card-border bg-white p-4 card-shadow">
      <p className="text-xs font-bold text-text-tertiary">{label}</p>
      <p className="mt-2 text-2xl font-extrabold text-text-primary">{value}</p>
    </div>
  );
}

function Empty({ text }: { text: string }) {
  return (
    <div className="rounded-lg border border-dashed border-card-border bg-white p-8 text-center text-sm font-bold text-text-tertiary">
      {text}
    </div>
  );
}

function StatusPill({ status }: { status: FocusStudentStatus }) {
  const className =
    status === "HIGH_RISK"
      ? "bg-hot/10 text-hot"
      : status === "NEEDS_ATTENTION"
        ? "bg-amber-100 text-amber-700"
        : status === "FOCUSING"
          ? "bg-accent/10 text-accent"
          : "bg-bg text-text-secondary";
  return (
    <span className={`rounded-full px-2.5 py-1 text-[11px] font-extrabold ${className}`}>
      {statusLabels[status]}
    </span>
  );
}

function ActionButton({
  label,
  icon: Icon,
  disabled,
  onClick,
}: {
  label: string;
  icon: React.ComponentType<{ size?: number }>;
  disabled?: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      className="inline-flex h-9 items-center justify-center gap-1.5 rounded-lg border border-card-border bg-white px-3 text-xs font-extrabold text-text-secondary transition hover:border-primary/40 hover:text-primary disabled:opacity-50"
    >
      <Icon size={14} />
      {label}
    </button>
  );
}
