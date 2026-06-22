"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { AlertTriangle, Filter, Target } from "lucide-react";
import { PageHeader } from "@/components/page-header";
import { getClasses, getRiskStudents, type RiskStudentResponse } from "@/lib/api";

const riskLabels = {
  HIGH: "집중 관리",
  MEDIUM: "관찰 필요",
  LOW: "안정",
} as const;

function formatMinutes(minutes: number) {
  const safe = Math.max(0, Math.round(minutes));
  const h = Math.floor(safe / 60);
  const m = safe % 60;
  return h > 0 ? `${h}h ${m}m` : `${m}m`;
}

export default function RiskStudentsPage() {
  const [items, setItems] = useState<RiskStudentResponse[]>([]);
  const [classes, setClasses] = useState<Array<{ id: string; name: string }>>([]);
  const [classId, setClassId] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    Promise.all([
      getRiskStudents(classId || undefined),
      getClasses().catch(() => []),
    ])
      .then(([risks, classList]) => {
        if (cancelled) return;
        setItems(risks);
        setClasses(classList);
      })
      .catch((err) => {
        if (!cancelled) setError(err instanceof Error ? err.message : "위험 학생을 불러오지 못했습니다.");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [classId]);

  const counts = useMemo(
    () => ({
      high: items.filter((item) => item.riskLevel === "HIGH").length,
      medium: items.filter((item) => item.riskLevel === "MEDIUM").length,
      low: items.filter((item) => item.riskLevel === "LOW").length,
    }),
    [items],
  );

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <PageHeader title="위험 학생" description="출결, 공부 시간, 달성률 기준으로 개입 우선순위를 확인합니다" icon={AlertTriangle} />

      <div className="mb-5 grid grid-cols-3 gap-3">
        <Summary label="집중 관리" value={counts.high} tone="hot" />
        <Summary label="관찰 필요" value={counts.medium} tone="warm" />
        <Summary label="안정" value={counts.low} tone="accent" />
      </div>

      <div className="mb-4 flex items-center gap-2 rounded-2xl border border-card-border bg-white p-3 card-shadow">
        <Filter size={16} className="text-text-tertiary" />
        <select
          value={classId}
          onChange={(event) => {
            setLoading(true);
            setError(null);
            setClassId(event.target.value);
          }}
          className="flex-1 bg-transparent text-sm font-semibold text-text-secondary outline-none"
        >
          <option value="">전체 반</option>
          {classes.map((klass) => (
            <option key={klass.id} value={klass.id}>{klass.name}</option>
          ))}
        </select>
      </div>

      {loading ? (
        <div className="grid gap-3">
          {[1, 2, 3].map((item) => <div key={item} className="skeleton h-32 rounded-2xl" />)}
        </div>
      ) : error ? (
        <div className="rounded-2xl border border-hot-light bg-white p-8 text-center text-hot">{error}</div>
      ) : items.length === 0 ? (
        <div className="rounded-2xl border border-card-border bg-white p-10 text-center text-text-tertiary card-shadow">
          표시할 학생이 없습니다.
        </div>
      ) : (
        <div className="grid gap-3">
          {items.map((student) => (
            <Link
              key={student.studentId}
              href={`/students/${student.studentId}`}
              className="rounded-2xl border border-card-border bg-white p-5 card-shadow transition hover:border-primary/30"
            >
              <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                <div>
                  <div className="mb-2 flex items-center gap-2">
                    <span className={`rounded-full px-2.5 py-1 text-xs font-bold ${badgeClass(student.riskLevel)}`}>
                      {riskLabels[student.riskLevel]}
                    </span>
                    <span className="text-xs text-text-tertiary">{student.className ?? "반 미배정"}</span>
                  </div>
                  <h2 className="text-lg font-extrabold text-text-primary">{student.studentName}</h2>
                  <p className="mt-1 text-sm text-text-tertiary">
                    출석률 {Math.round(student.attendanceRate)}% · 평균 공부 {formatMinutes(student.averageStudyMinutes)} · 평균 달성률 {Math.round(student.averageAchievedRate)}%
                  </p>
                </div>
                <div className="min-w-64 rounded-xl bg-bg p-4">
                  <div className="mb-2 flex items-center gap-2 text-xs font-bold text-primary">
                    <Target size={14} />
                    추천 개입
                  </div>
                  <p className="text-sm font-semibold text-text-primary">
                    {student.recommendedFocusSubjects.slice(0, 2).join(", ")} 중심으로 {formatMinutes(student.recommendedTargetMinutes)} 목표
                  </p>
                </div>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}

function Summary({ label, value, tone }: { label: string; value: number; tone: "hot" | "warm" | "accent" }) {
  const color = tone === "hot" ? "text-hot bg-hot-light" : tone === "warm" ? "text-warm bg-warm-light" : "text-accent bg-accent-light";
  return (
    <div className="rounded-2xl border border-card-border bg-white p-4 card-shadow">
      <p className="text-xs font-semibold text-text-tertiary">{label}</p>
      <p className={`mt-2 inline-flex rounded-xl px-3 py-1 text-2xl font-black tabular-nums ${color}`}>{value}</p>
    </div>
  );
}

function badgeClass(level: RiskStudentResponse["riskLevel"]) {
  if (level === "HIGH") return "bg-hot-light text-hot";
  if (level === "MEDIUM") return "bg-warm-light text-warm";
  return "bg-accent-light text-accent";
}
