"use client";

import { useEffect, useMemo, useState } from "react";
import { ParentShell } from "@/components/parent-shell";
import {
  getConsultationReport,
  type ParentConsultationReport,
} from "@/lib/api";

function formatMinutes(minutes: number) {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return h > 0 ? `${h}시간 ${m}분` : `${m}분`;
}

export default function ConsultationReportPage() {
  const [report, setReport] = useState<ParentConsultationReport | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    const token = new URLSearchParams(window.location.search).get("token") ?? "";
    if (!token) {
      queueMicrotask(() => setError("상담 리포트 링크가 올바르지 않습니다."));
      return;
    }
    getConsultationReport(token)
      .then(setReport)
      .catch((err) =>
        setError(
          err instanceof Error
            ? err.message
            : "상담 리포트를 불러오지 못했습니다.",
        ),
      );
  }, []);

  const averageRate = useMemo(() => {
    if (!report?.recentMetrics.length) return 0;
    const sum = report.recentMetrics.reduce(
      (total, metric) => total + Number(metric.achievedRate),
      0,
    );
    return Math.round(sum / report.recentMetrics.length);
  }, [report]);

  return (
    <ParentShell>
      {error ? (
        <div className="error">{error}</div>
      ) : !report ? (
        <div className="card">불러오는 중...</div>
      ) : (
        <>
          <section className="card">
            <p className="label">상담 공유 리포트</p>
            <p className="value" style={{ fontSize: 22 }}>
              {report.student.name}
            </p>
            <p className="label" style={{ marginTop: 6 }}>
              {[report.student.gradeName, report.student.className]
                .filter(Boolean)
                .join(" · ") || "소속 정보 없음"}
            </p>
            <p className="label" style={{ marginTop: 14 }}>
              {report.report.message}
            </p>
          </section>

          <section className="card" style={{ marginTop: 12 }}>
            <p className="label">상담 요약</p>
            <p className="value" style={{ fontSize: 21 }}>
              {report.consultation.summary}
            </p>
            {report.guardian && (
              <p className="label" style={{ marginTop: 6 }}>
                보호자 {report.guardian.name}
              </p>
            )}
            {report.consultation.detail && (
              <p style={{ marginTop: 14, lineHeight: 1.7 }}>
                {report.consultation.detail}
              </p>
            )}
            {report.consultation.promisedAction && (
              <div className="row" style={{ marginTop: 14 }}>
                <strong>약속한 조치</strong>
                <span className="pill">{report.consultation.promisedAction}</span>
              </div>
            )}
          </section>

          <div className="grid" style={{ marginTop: 12 }}>
            <div className="card">
              <p className="label">최근 7일 평균 달성률</p>
              <p className="value">{averageRate}%</p>
            </div>
            <div className="card">
              <p className="label">오늘 미션</p>
              <p className="value" style={{ fontSize: 20 }}>
                {report.todayMission?.status ?? "없음"}
              </p>
              <p className="label">
                {report.todayMission
                  ? `${report.todayMission.subjectName} · ${report.todayMission.title}`
                  : "오늘 등록된 미션이 없습니다."}
              </p>
            </div>
            <div className="card">
              <p className="label">집중 흐름</p>
              <p className="value">
                {report.focusSummary?.eventCount ?? 0}회
              </p>
              <p className="label">
                평균 복귀 {report.focusSummary?.averageReturnSeconds ?? 0}초
              </p>
            </div>
          </div>

          <section className="card" style={{ marginTop: 12 }}>
            <p className="label">최근 7일 학습 흐름</p>
            <div className="list" style={{ marginTop: 14 }}>
              {report.recentMetrics.length === 0 ? (
                <p className="label">최근 학습 기록이 없습니다.</p>
              ) : (
                report.recentMetrics.map((metric) => (
                  <div key={metric.id} className="row">
                    <div>
                      <strong>
                        {new Date(metric.metricDate).toLocaleDateString(
                          "ko-KR",
                          { month: "short", day: "numeric" },
                        )}
                      </strong>
                      <p className="label" style={{ margin: "4px 0 0" }}>
                        {formatMinutes(metric.studyMinutes)} / 목표{" "}
                        {formatMinutes(metric.targetMinutes)}
                      </p>
                    </div>
                    <span className="pill">
                      {Math.round(Number(metric.achievedRate))}%
                    </span>
                  </div>
                ))
              )}
            </div>
          </section>
        </>
      )}
    </ParentShell>
  );
}
