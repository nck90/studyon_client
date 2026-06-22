"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import {
  Check,
  Clipboard,
  HeartHandshake,
  ListChecks,
  MessageSquareText,
  RefreshCw,
  Share2,
  X,
} from "lucide-react";
import { PageHeader } from "@/components/page-header";
import {
  createOpsParentFollowUp,
  createOpsParentReport,
  dismissOpsTask,
  generateOpsTasks,
  getOpsOverview,
  getOpsTasks,
  resolveOpsTask,
  sendOpsStudentMessage,
  type OpsOverviewResponse,
  type OpsTaskReasonType,
  type OpsTaskResponse,
  type OpsTaskSeverity,
} from "@/lib/api";

const reasonLabels: Record<OpsTaskReasonType, string> = {
  NOT_CHECKED_IN: "미입실",
  EARLY_LEAVE: "조기퇴실",
  DAILY_MISSION_INCOMPLETE: "데일리 미션",
  TARGET_SHORTFALL: "목표 미달",
  FOCUS_INTERRUPTION: "집중 이탈",
};

const severityLabels: Record<OpsTaskSeverity, string> = {
  LOW: "낮음",
  MEDIUM: "보통",
  HIGH: "높음",
};

export default function OpsPage() {
  const [overview, setOverview] = useState<OpsOverviewResponse | null>(null);
  const [tasks, setTasks] = useState<OpsTaskResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [busyTaskId, setBusyTaskId] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [copiedUrl, setCopiedUrl] = useState<string | null>(null);

  const reload = useCallback(async () => {
    const [nextOverview, nextTasks] = await Promise.all([
      getOpsOverview(),
      getOpsTasks({ status: "OPEN" }),
    ]);
    setOverview(nextOverview);
    setTasks(nextTasks);
  }, []);

  useEffect(() => {
    setLoading(true);
    generateOpsTasks()
      .then((nextTasks) => setTasks(nextTasks))
      .then(() => getOpsOverview())
      .then(setOverview)
      .catch((err) =>
        setMessage(
          err instanceof Error ? err.message : "운영 큐를 불러오지 못했습니다.",
        ),
      )
      .finally(() => setLoading(false));
  }, []);

  const openHigh = useMemo(
    () => tasks.filter((task) => task.severity === "HIGH").length,
    [tasks],
  );

  const refreshQueue = async () => {
    setLoading(true);
    try {
      const nextTasks = await generateOpsTasks();
      setTasks(nextTasks);
      setOverview(await getOpsOverview());
      setMessage("오늘 운영 큐를 갱신했습니다.");
    } finally {
      setLoading(false);
    }
  };

  const runTaskAction = async (
    taskId: string,
    action: () => Promise<unknown>,
    done: string,
  ) => {
    setBusyTaskId(taskId);
    try {
      await action();
      setMessage(done);
      await reload();
    } finally {
      setBusyTaskId(null);
    }
  };

  const createParentLink = async (task: OpsTaskResponse) => {
    setBusyTaskId(task.id);
    try {
      const issued = await createOpsParentReport(task.id, task.message);
      const parentBase =
        process.env.NEXT_PUBLIC_PARENT_WEB_URL ?? window.location.origin;
      const url = `${parentBase.replace(/\/$/, "")}${issued.urlPath}`;
      await navigator.clipboard?.writeText(url);
      setCopiedUrl(url);
      setMessage("학부모 조치 리포트 링크를 생성하고 복사했습니다.");
      await reload();
    } finally {
      setBusyTaskId(null);
    }
  };

  return (
    <div className="mx-auto max-w-7xl p-6 md:p-8">
      <PageHeader
        title="오늘 운영"
        description="미입실, 조기퇴실, 미션 미완료, 목표 미달, 집중 이탈을 한 큐에서 처리합니다"
        icon={ListChecks}
        actions={
          <button
            type="button"
            onClick={refreshQueue}
            className="inline-flex h-10 items-center gap-2 rounded-lg bg-primary px-4 text-sm font-bold text-white shadow-sm disabled:opacity-60"
            disabled={loading}
          >
            <RefreshCw size={16} />
            큐 갱신
          </button>
        }
      />

      <div className="mb-5 grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Kpi label="처리완료율" value={`${overview?.completionRate ?? 0}%`} />
        <Kpi label="열린 항목" value={`${overview?.openCount ?? tasks.length}건`} />
        <Kpi
          label="높은 위험"
          value={`${overview?.highSeverityOpenCount ?? openHigh}건`}
        />
        <Kpi
          label="학부모 링크"
          value={`${overview?.parentReportCount ?? 0}건`}
        />
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

      <section>
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-base font-extrabold text-text-primary">
            열린 운영 항목
          </h2>
          <span className="text-xs font-bold text-text-tertiary">
            {tasks.length}건
          </span>
        </div>

        {loading ? (
          <Empty text="오늘 운영 큐를 불러오는 중입니다." />
        ) : tasks.length === 0 ? (
          <Empty text="열린 운영 항목이 없습니다." />
        ) : (
          <div className="grid gap-3">
            {tasks.map((task) => (
              <article
                key={task.id}
                className="rounded-lg border border-card-border bg-white p-4 card-shadow"
              >
                <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
                  <div className="min-w-0">
                    <div className="mb-2 flex flex-wrap items-center gap-2">
                      <span
                        className={`rounded-full px-2.5 py-1 text-[11px] font-extrabold ${
                          task.severity === "HIGH"
                            ? "bg-hot/10 text-hot"
                            : task.severity === "MEDIUM"
                              ? "bg-amber-100 text-amber-700"
                              : "bg-blue-50 text-blue-700"
                        }`}
                      >
                        {severityLabels[task.severity]}
                      </span>
                      <span className="rounded-full bg-bg px-2.5 py-1 text-[11px] font-bold text-text-secondary">
                        {reasonLabels[task.reasonType]}
                      </span>
                      <span className="text-xs font-bold text-text-tertiary">
                        {task.gradeName ?? "학년 없음"} ·{" "}
                        {task.className ?? "반 없음"}
                      </span>
                    </div>
                    <h3 className="text-base font-extrabold text-text-primary">
                      {task.studentName}
                      <span className="ml-2 text-xs font-bold text-text-tertiary">
                        {task.studentNo}
                      </span>
                    </h3>
                    <p className="mt-1 text-sm font-medium text-text-secondary">
                      {task.message}
                    </p>
                    {task.parentReports[0] && (
                      <p className="mt-2 text-xs font-bold text-primary">
                        최근 학부모 링크 만료{" "}
                        {new Date(
                          task.parentReports[0].expiresAt,
                        ).toLocaleDateString("ko-KR")}
                      </p>
                    )}
                  </div>

                  <div className="grid grid-cols-2 gap-2 sm:flex sm:items-center">
                    <ActionButton
                      label="학생 메시지"
                      icon={MessageSquareText}
                      disabled={busyTaskId === task.id}
                      onClick={() =>
                        runTaskAction(
                          task.id,
                          () => sendOpsStudentMessage(task.id, task.message),
                          "학생에게 메시지를 보냈습니다.",
                        )
                      }
                    />
                    <ActionButton
                      label="학부모 링크"
                      icon={Share2}
                      disabled={busyTaskId === task.id}
                      onClick={() => createParentLink(task)}
                    />
                    <ActionButton
                      label="상담 태스크"
                      icon={HeartHandshake}
                      disabled={busyTaskId === task.id}
                      onClick={() =>
                        runTaskAction(
                          task.id,
                          () => createOpsParentFollowUp(task.id, task.message),
                          "상담 후속 태스크를 만들었습니다.",
                        )
                      }
                    />
                    <ActionButton
                      label="완료"
                      icon={Check}
                      disabled={busyTaskId === task.id}
                      onClick={() =>
                        runTaskAction(
                          task.id,
                          () => resolveOpsTask(task.id),
                          "운영 항목을 완료했습니다.",
                        )
                      }
                    />
                    <ActionButton
                      label="제외"
                      icon={X}
                      tone="muted"
                      disabled={busyTaskId === task.id}
                      onClick={() =>
                        runTaskAction(
                          task.id,
                          () => dismissOpsTask(task.id),
                          "운영 항목을 제외했습니다.",
                        )
                      }
                    />
                  </div>
                </div>
              </article>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}

function Kpi({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg border border-card-border bg-white p-4 card-shadow">
      <p className="text-xs font-bold text-text-tertiary">{label}</p>
      <p className="mt-2 text-2xl font-black text-text-primary">{value}</p>
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

function ActionButton({
  label,
  icon: Icon,
  onClick,
  disabled,
  tone = "default",
}: {
  label: string;
  icon: typeof MessageSquareText;
  onClick: () => void;
  disabled?: boolean;
  tone?: "default" | "muted";
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      className={`inline-flex h-9 items-center justify-center gap-1.5 rounded-lg px-3 text-xs font-extrabold transition disabled:opacity-50 ${
        tone === "muted"
          ? "bg-bg text-text-secondary hover:bg-gray-100"
          : "bg-primary-surface text-primary hover:bg-primary/15"
      }`}
    >
      <Icon size={15} />
      {label}
    </button>
  );
}
