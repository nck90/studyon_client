"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Building2, CalendarCheck, Clock, ShieldAlert, Users } from "lucide-react";
import { PageHeader } from "@/components/page-header";
import { getDirectorOverview, getRiskStudents, getStudyOverview, type DirectorOverviewResponse, type RiskStudentResponse, type StudyMetric } from "@/lib/api";

function formatMinutes(minutes: number) {
  const safe = Math.max(0, Math.round(minutes));
  const h = Math.floor(safe / 60);
  const m = safe % 60;
  return h > 0 ? `${h}h ${m}m` : `${m}m`;
}

export default function DirectorOverviewPage() {
  const [overview, setOverview] = useState<DirectorOverviewResponse | null>(null);
  const [risks, setRisks] = useState<RiskStudentResponse[]>([]);
  const [metrics, setMetrics] = useState<StudyMetric[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const endDate = new Date().toISOString().slice(0, 10);
    const start = new Date();
    start.setDate(start.getDate() - 7);
    const startDate = start.toISOString().slice(0, 10);

    Promise.all([
      getDirectorOverview().catch(() => null),
      getRiskStudents().catch(() => []),
      getStudyOverview({ startDate, endDate }).catch(() => []),
    ]).then(([nextOverview, nextRisks, nextMetrics]) => {
      setOverview(nextOverview);
      setRisks(nextRisks);
      setMetrics(nextMetrics);
      setLoading(false);
    });
  }, []);

  const highRiskCount = risks.filter((item) => item.riskLevel === "HIGH").length;
  const classMap = new Map<string, { name: string; minutes: number; count: number }>();
  for (const metric of metrics) {
    const key = metric.student.class?.name ?? "미배정";
    const current = classMap.get(key) ?? { name: metric.student.class?.name ?? "미배정", minutes: 0, count: 0 };
    current.minutes += metric.studyMinutes;
    current.count += 1;
    classMap.set(key, current);
  }
  const classes = [...classMap.values()].sort((a, b) => b.minutes - a.minutes).slice(0, 5);

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <PageHeader title="원장 대시보드" description="출석, 좌석, 학습, 위험 학생을 한 화면에서 확인합니다" icon={Building2} />

      {loading ? (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {[1, 2, 3, 4].map((item) => <div key={item} className="skeleton h-28 rounded-2xl" />)}
        </div>
      ) : (
        <>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
            <Kpi icon={CalendarCheck} label="출석률" value={`${Math.round(overview?.attendanceRate ?? 0)}%`} />
            <Kpi icon={Users} label="활성 학생" value={`${overview?.activeStudentCount ?? 0}명`} />
            <Kpi icon={Clock} label="총 공부시간" value={formatMinutes(overview?.totalStudyMinutes ?? 0)} />
            <Kpi icon={ShieldAlert} label="집중 관리" value={`${highRiskCount}명`} hot />
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-[1.2fr_0.8fr] gap-5">
            <section className="rounded-2xl border border-card-border bg-white p-6 card-shadow">
              <div className="mb-5 flex items-center justify-between">
                <h2 className="text-sm font-bold text-text-primary">반별 공부시간</h2>
                <Link href="/analytics" className="text-xs font-bold text-primary">상세 분석</Link>
              </div>
              {classes.length === 0 ? (
                <p className="py-10 text-center text-sm text-text-tertiary">집계 데이터가 없습니다.</p>
              ) : (
                <div className="space-y-4">
                  {classes.map((klass) => {
                    const max = Math.max(...classes.map((item) => item.minutes), 1);
                    return (
                      <div key={klass.name}>
                        <div className="mb-1 flex items-center justify-between text-sm">
                          <span className="font-semibold text-text-primary">{klass.name}</span>
                          <span className="font-bold text-primary">{formatMinutes(klass.minutes)}</span>
                        </div>
                        <div className="h-2 overflow-hidden rounded-full bg-bg">
                          <div className="h-full rounded-full bg-primary" style={{ width: `${Math.max(4, (klass.minutes / max) * 100)}%` }} />
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </section>

            <section className="rounded-2xl border border-card-border bg-white p-6 card-shadow">
              <div className="mb-5 flex items-center justify-between">
                <h2 className="text-sm font-bold text-text-primary">개입 우선순위</h2>
                <Link href="/insights/risks" className="text-xs font-bold text-primary">전체 보기</Link>
              </div>
              <div className="space-y-3">
                {risks.slice(0, 5).map((student) => (
                  <Link key={student.studentId} href={`/students/${student.studentId}`} className="block rounded-xl bg-bg p-4">
                    <div className="flex items-center justify-between">
                      <span className="font-bold text-text-primary">{student.studentName}</span>
                      <span className={`rounded-full px-2 py-0.5 text-[11px] font-bold ${student.riskLevel === "HIGH" ? "bg-hot-light text-hot" : student.riskLevel === "MEDIUM" ? "bg-warm-light text-warm" : "bg-accent-light text-accent"}`}>
                        {student.riskLevel}
                      </span>
                    </div>
                    <p className="mt-1 text-xs text-text-tertiary">출석 {Math.round(student.attendanceRate)}% · 달성 {Math.round(student.averageAchievedRate)}%</p>
                  </Link>
                ))}
              </div>
            </section>
          </div>
        </>
      )}
    </div>
  );
}

function Kpi({ icon: Icon, label, value, hot = false }: { icon: typeof CalendarCheck; label: string; value: string; hot?: boolean }) {
  return (
    <div className="rounded-2xl border border-card-border bg-white p-5 card-shadow">
      <div className="mb-3 flex items-center justify-between">
        <span className="text-xs font-semibold text-text-tertiary">{label}</span>
        <div className={`flex h-8 w-8 items-center justify-center rounded-lg ${hot ? "bg-hot-light text-hot" : "bg-primary-surface text-primary"}`}>
          <Icon size={16} />
        </div>
      </div>
      <p className="text-2xl font-black text-text-primary tabular-nums">{value}</p>
    </div>
  );
}
