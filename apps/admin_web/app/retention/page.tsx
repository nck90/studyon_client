"use client";

/* eslint-disable @next/next/no-img-element */
import { useCallback, useEffect, useMemo, useState } from "react";
import { Check, Focus, Target, X } from "lucide-react";
import { PageHeader } from "@/components/page-header";
import {
  createDailyMissionTemplate,
  generateRetentionInterventions,
  getDailyMissionOverview,
  getDailyMissionTemplates,
  getRetentionInterventions,
  getRetentionGoals,
  getRetentionOverview,
  messageRetentionIntervention,
  recommendRetentionPlan,
  reviewRetentionGoal,
  updateDailyMissionTemplate,
  type DailyMissionOverviewResponse,
  type DailyMissionTemplateResponse,
  type RetentionGoalResponse,
  type RetentionInterventionResponse,
  type RetentionOverviewResponse,
} from "@/lib/api";

function mediaUrl(path?: string | null) {
  if (!path) return "";
  if (path.startsWith("http")) return path;
  const base =
    process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:3000/api/v1";
  return `${base.replace(/\/api\/v1$/, "")}${path}`;
}

export default function RetentionPage() {
  const [overview, setOverview] = useState<RetentionOverviewResponse | null>(
    null,
  );
  const [goals, setGoals] = useState<RetentionGoalResponse[]>([]);
  const [interventions, setInterventions] = useState<
    RetentionInterventionResponse[]
  >([]);
  const [missionOverview, setMissionOverview] =
    useState<DailyMissionOverviewResponse | null>(null);
  const [missionTemplates, setMissionTemplates] = useState<
    DailyMissionTemplateResponse[]
  >([]);
  const [templateForm, setTemplateForm] = useState({
    title: "오늘 핵심 루틴",
    subjectName: "수학",
    targetMinutes: 60,
  });
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState<string | null>(null);

  const reload = useCallback(() => {
    setLoading(true);
    Promise.all([
      getRetentionOverview(),
      getRetentionGoals(),
      getRetentionInterventions(),
      getDailyMissionOverview(),
      getDailyMissionTemplates(),
    ])
      .then(
        ([
          nextOverview,
          nextGoals,
          nextInterventions,
          nextMissionOverview,
          nextMissionTemplates,
        ]) => {
        setOverview(nextOverview);
        setGoals(nextGoals);
        setInterventions(nextInterventions);
        setMissionOverview(nextMissionOverview);
        setMissionTemplates(nextMissionTemplates);
        },
      )
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    queueMicrotask(reload);
  }, [reload]);

  const pending = useMemo(
    () => goals.filter((goal) => goal.tvGoalApprovalStatus === "PENDING"),
    [goals],
  );

  const review = async (studentId: string, status: "APPROVED" | "REJECTED") => {
    await reviewRetentionGoal(studentId, status);
    setMessage(
      status === "APPROVED"
        ? "TV 노출을 승인했습니다."
        : "TV 노출을 반려했습니다.",
    );
    reload();
  };

  const generateQueue = async () => {
    const next = await generateRetentionInterventions();
    setInterventions(next);
    setMessage("개입 큐를 갱신했습니다.");
    reload();
  };

  const resolveIntervention = async (
    interventionId: string,
    action: "message" | "plan",
  ) => {
    if (action === "message") {
      await messageRetentionIntervention(interventionId);
      setMessage("학생에게 메시지를 보냈습니다.");
    } else {
      await recommendRetentionPlan(interventionId);
      setMessage("추천 계획을 보냈습니다.");
    }
    reload();
  };

  const createTemplate = async () => {
    await createDailyMissionTemplate(templateForm);
    setMessage("일일 미션 템플릿을 추가했습니다.");
    reload();
  };

  const toggleTemplate = async (template: DailyMissionTemplateResponse) => {
    await updateDailyMissionTemplate(template.id, {
      isActive: !template.isActive,
    });
    setMessage(
      template.isActive
        ? "일일 미션 템플릿을 비활성화했습니다."
        : "일일 미션 템플릿을 활성화했습니다.",
    );
    reload();
  };

  return (
    <div className="mx-auto max-w-7xl p-6 md:p-8">
      <PageHeader
        title="리텐션"
        description="목표 홈, 주간 활성 공부, 포커스 이탈, TV 목표 월을 운영합니다"
        icon={Target}
      />

      <div className="mb-5 grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Kpi
          label="주간 활성 학생"
          value={`${overview?.weeklyActiveStudents ?? 0}명`}
        />
        <Kpi
          label="계획 달성률"
          value={`${overview?.planAchievedRate ?? 0}%`}
        />
        <Kpi
          label="포커스 이탈"
          value={`${overview?.focusEventCount ?? 0}회`}
        />
        <Kpi
          label="승인 대기"
          value={`${overview?.pendingGoalApprovalCount ?? pending.length}건`}
        />
        <Kpi
          label="개입 큐"
          value={`${overview?.openInterventionCount ?? interventions.length}건`}
        />
        <Kpi
          label="오늘 미션 완료율"
          value={`${missionOverview?.completionRate ?? 0}%`}
        />
      </div>

      {message && (
        <div className="mb-4 rounded-xl bg-primary-surface px-4 py-3 text-sm font-bold text-primary">
          {message}
        </div>
      )}

      <div className="grid gap-5 lg:grid-cols-[1.3fr_0.7fr]">
        <section className="rounded-lg border border-card-border bg-white p-5 card-shadow">
          <div className="mb-4 flex items-center justify-between">
            <div>
              <h2 className="text-lg font-extrabold text-text-primary">
                TV 목표 승인
              </h2>
              <p className="mt-1 text-xs text-text-tertiary">
                학생이 동의한 목표만 검토합니다.
              </p>
            </div>
            <span className="rounded-full bg-bg px-3 py-1 text-xs font-bold text-text-secondary">
              {pending.length}건 대기
            </span>
          </div>

          {loading ? (
            <Empty text="리텐션 데이터를 불러오는 중입니다." />
          ) : pending.length === 0 ? (
            <Empty text="승인 대기 중인 목표가 없습니다." />
          ) : (
            <div className="grid gap-3 md:grid-cols-2">
              {pending.map((goal) => (
                <article
                  key={goal.studentId}
                  className="rounded-lg border border-divider bg-bg p-4"
                >
                  <div className="flex gap-3">
                    <div className="h-16 w-16 overflow-hidden rounded-lg bg-white">
                      {goal.targetUniversityMedia?.publicUrl ? (
                        <img
                          src={mediaUrl(goal.targetUniversityMedia.publicUrl)}
                          alt=""
                          className="h-full w-full object-cover"
                        />
                      ) : (
                        <div className="flex h-full w-full items-center justify-center text-xl font-black text-primary">
                          {goal.targetUniversityName[0]}
                        </div>
                      )}
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="truncate text-base font-extrabold text-text-primary">
                        {goal.targetUniversityName}
                      </p>
                      <p className="mt-1 text-xs font-semibold text-text-tertiary">
                        {goal.studentName} · {goal.className ?? "반 미배정"}
                      </p>
                    </div>
                  </div>
                  <div className="mt-4 flex gap-2">
                    <button
                      onClick={() => review(goal.studentId, "APPROVED")}
                      className="flex flex-1 items-center justify-center gap-1 rounded-lg bg-primary px-3 py-2 text-xs font-bold text-white"
                    >
                      <Check size={14} /> 승인
                    </button>
                    <button
                      onClick={() => review(goal.studentId, "REJECTED")}
                      className="flex flex-1 items-center justify-center gap-1 rounded-lg bg-hot-light px-3 py-2 text-xs font-bold text-hot"
                    >
                      <X size={14} /> 반려
                    </button>
                  </div>
                </article>
              ))}
            </div>
          )}
        </section>

        <section className="rounded-lg border border-card-border bg-white p-5 card-shadow">
          <div className="mb-4 flex items-center gap-2">
            <Focus size={18} className="text-primary" />
            <h2 className="text-lg font-extrabold text-text-primary">
              포커스 이탈 상위
            </h2>
          </div>
          <div className="space-y-3">
            {(overview?.focusRiskStudents ?? []).length === 0 ? (
              <Empty text="이번 주 포커스 이탈 기록이 없습니다." />
            ) : (
              overview?.focusRiskStudents.map((item) => (
                <div key={item.studentId} className="rounded-lg bg-bg p-3">
                  <div className="flex items-center justify-between">
                    <p className="font-bold text-text-primary">
                      {item.studentName}
                    </p>
                    <span className="text-sm font-extrabold text-hot">
                      {item.eventCount}회
                    </span>
                  </div>
                  <p className="mt-1 text-xs text-text-tertiary">
                    {item.className ?? "반 미배정"}
                  </p>
                </div>
              ))
            )}
          </div>
        </section>
      </div>

      <section className="mt-5 rounded-lg border border-card-border bg-white p-5 card-shadow">
        <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
          <div>
            <h2 className="text-lg font-extrabold text-text-primary">
              공용 개입 큐
            </h2>
            <p className="mt-1 text-xs text-text-tertiary">
              연속 기록, 목표 미달, 포커스 이탈, 미션 미수락 기준입니다.
            </p>
          </div>
          <button
            onClick={generateQueue}
            className="rounded-lg bg-primary px-4 py-2 text-xs font-bold text-white"
          >
            큐 갱신
          </button>
        </div>

        {interventions.length === 0 ? (
          <Empty text="열린 개입 항목이 없습니다." />
        ) : (
          <div className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
            {interventions.map((item) => (
              <article
                key={item.id}
                className="rounded-lg border border-divider bg-bg p-4"
              >
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0">
                    <p className="truncate text-base font-extrabold text-text-primary">
                      {item.studentName}
                    </p>
                    <p className="mt-1 text-xs font-semibold text-text-tertiary">
                      {item.className ?? "반 미배정"} ·{" "}
                      {reasonLabel(item.reasonType)}
                    </p>
                  </div>
                  <span className={severityClass(item.severity)}>
                    {item.severity}
                  </span>
                </div>
                <p className="mt-3 line-clamp-2 text-sm font-semibold text-text-secondary">
                  {item.message}
                </p>
                <div className="mt-3 rounded-lg bg-white p-3 text-xs font-semibold text-text-tertiary">
                  <p className="truncate">
                    목표: {item.roadmap?.targetName ?? "미설정"}
                  </p>
                  <p className="mt-1 truncate">
                    미션: {item.currentMission?.title ?? "미생성"}
                  </p>
                </div>
                <div className="mt-4 flex gap-2">
                  <button
                    onClick={() => resolveIntervention(item.id, "message")}
                    className="flex-1 rounded-lg bg-white px-3 py-2 text-xs font-bold text-primary"
                  >
                    메시지
                  </button>
                  <button
                    onClick={() => resolveIntervention(item.id, "plan")}
                    className="flex-1 rounded-lg bg-primary px-3 py-2 text-xs font-bold text-white"
                  >
                    계획 추천
                  </button>
                </div>
              </article>
            ))}
          </div>
        )}
      </section>

      <section className="mt-5 rounded-lg border border-card-border bg-white p-5 card-shadow">
        <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
          <div>
            <h2 className="text-lg font-extrabold text-text-primary">
              일일 미션 운영
            </h2>
            <p className="mt-1 text-xs text-text-tertiary">
              오늘 미션 완료율과 기본 템플릿을 관리합니다.
            </p>
          </div>
          <span className="rounded-full bg-primary-surface px-3 py-1 text-xs font-bold text-primary">
            {missionOverview?.completedCount ?? 0}/
            {missionOverview?.totalAssignedCount ?? 0} 완료
          </span>
        </div>

        <div className="mb-4 grid grid-cols-2 gap-3 lg:grid-cols-4">
          <Kpi
            label="미완료"
            value={`${missionOverview?.incompleteCount ?? 0}명`}
          />
          <Kpi
            label="알림 설정"
            value={`${missionOverview?.reminderEnabledStudentCount ?? 0}명`}
          />
          <Kpi
            label="알림 유입"
            value={`${missionOverview?.notificationOpenCount ?? 0}회`}
          />
          <Kpi label="템플릿" value={`${missionTemplates.length}개`} />
        </div>

        <div className="grid gap-5 lg:grid-cols-[0.8fr_1.2fr]">
          <div className="rounded-lg bg-bg p-4">
            <h3 className="mb-3 text-sm font-extrabold text-text-primary">
              템플릿 추가
            </h3>
            <div className="grid gap-2">
              <input
                value={templateForm.title}
                onChange={(event) =>
                  setTemplateForm((prev) => ({
                    ...prev,
                    title: event.target.value,
                  }))
                }
                className="rounded-lg border border-divider bg-white px-3 py-2 text-sm font-semibold outline-none"
                placeholder="미션 제목"
              />
              <div className="grid grid-cols-[1fr_110px] gap-2">
                <input
                  value={templateForm.subjectName}
                  onChange={(event) =>
                    setTemplateForm((prev) => ({
                      ...prev,
                      subjectName: event.target.value,
                    }))
                  }
                  className="rounded-lg border border-divider bg-white px-3 py-2 text-sm font-semibold outline-none"
                  placeholder="과목"
                />
                <input
                  type="number"
                  value={templateForm.targetMinutes}
                  onChange={(event) =>
                    setTemplateForm((prev) => ({
                      ...prev,
                      targetMinutes: Number(event.target.value),
                    }))
                  }
                  className="rounded-lg border border-divider bg-white px-3 py-2 text-sm font-semibold outline-none"
                />
              </div>
              <button
                onClick={createTemplate}
                className="rounded-lg bg-primary px-4 py-2 text-xs font-bold text-white"
              >
                템플릿 저장
              </button>
            </div>
          </div>

          <div className="grid gap-3 md:grid-cols-2">
            {missionTemplates.length === 0 ? (
              <Empty text="등록된 미션 템플릿이 없습니다." />
            ) : (
              missionTemplates.map((template) => (
                <article
                  key={template.id}
                  className="rounded-lg border border-divider bg-bg p-4"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      <p className="truncate text-sm font-extrabold text-text-primary">
                        {template.title}
                      </p>
                      <p className="mt-1 text-xs font-semibold text-text-tertiary">
                        {template.subjectName} · {template.targetMinutes}분
                      </p>
                    </div>
                    <button
                      onClick={() => toggleTemplate(template)}
                      className="rounded-lg bg-white px-3 py-2 text-xs font-bold text-primary"
                    >
                      {template.isActive ? "활성" : "비활성"}
                    </button>
                  </div>
                </article>
              ))
            )}
          </div>
        </div>
      </section>
    </div>
  );
}

function Kpi({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg border border-card-border bg-white p-4 card-shadow">
      <p className="text-xs font-bold text-text-tertiary">{label}</p>
      <p className="mt-3 text-2xl font-black text-text-primary">{value}</p>
    </div>
  );
}

function Empty({ text }: { text: string }) {
  return (
    <div className="rounded-lg bg-bg p-6 text-center text-sm font-semibold text-text-tertiary">
      {text}
    </div>
  );
}

function reasonLabel(reason: RetentionInterventionResponse["reasonType"]) {
  switch (reason) {
    case "STREAK_BROKEN":
      return "연속 기록 중단";
    case "TARGET_SHORTFALL":
      return "목표 미달";
    case "FOCUS_INTERRUPTION":
      return "포커스 이탈";
    case "MISSION_NOT_ACCEPTED":
      return "미션 미수락";
  }
}

function severityClass(severity: RetentionInterventionResponse["severity"]) {
  const base = "rounded-full px-2 py-1 text-[11px] font-black";
  if (severity === "HIGH") return `${base} bg-hot-light text-hot`;
  if (severity === "MEDIUM") return `${base} bg-yellow-100 text-yellow-700`;
  return `${base} bg-primary-surface text-primary`;
}
