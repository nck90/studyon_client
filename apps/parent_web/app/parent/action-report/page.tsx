"use client";

import { useEffect, useMemo, useState } from "react";
import { ParentShell } from "@/components/parent-shell";
import { getActionReport, type ParentActionReport } from "@/lib/api";

const reasonLabels: Record<string, string> = {
  NOT_CHECKED_IN: "미입실",
  EARLY_LEAVE: "조기퇴실",
  DAILY_MISSION_INCOMPLETE: "데일리 미션 미완료",
  TARGET_SHORTFALL: "목표 달성률 미달",
  FOCUS_INTERRUPTION: "집중 이탈",
};

function formatMinutes(minutes: number) {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return h > 0 ? `${h}시간 ${m}분` : `${m}분`;
}

export default function ActionReportPage() {
  const [report, setReport] = useState<ParentActionReport | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    const token = new URLSearchParams(window.location.search).get("token") ?? "";
    if (!token) {
      queueMicrotask(() => setError("조치 리포트 링크가 올바르지 않습니다."));
      return;
    }
    getActionReport(token)
      .then(setReport)
      .catch((err) =>
        setError(
          err instanceof Error
            ? err.message
            : "조치 리포트를 불러오지 못했습니다.",
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
            <p className="label">학원 조치 요청</p>
            <p className="value" style={{ fontSize: 22 }}>
              {report.student.name}
            </p>
            <p className="label" style={{ marginTop: 6 }}>
              {[report.student.gradeName, report.student.className]
                .filter(Boolean)
                .join(" · ") || "소속 정보 없음"}
            </p>
            <div className="row" style={{ marginTop: 16 }}>
              <div>
                <strong>
                  {reasonLabels[report.task.reasonType] ?? report.task.reasonType}
                </strong>
                <p className="label" style={{ margin: "6px 0 0" }}>
                  {report.report.message}
                </p>
              </div>
              <span className="pill">{report.task.severity}</span>
            </div>
          </section>

          <div className="grid" style={{ marginTop: 12 }}>
            <div className="card">
              <p className="label">오늘 출결</p>
              <p className="value">
                {report.todayAttendance?.attendanceStatus ?? "미입실"}
              </p>
              <p className="label">
                체류 {formatMinutes(report.todayAttendance?.stayMinutes ?? 0)}
              </p>
            </div>
            <div className="card">
              <p className="label">오늘 공부</p>
              <p className="value">
                {formatMinutes(report.todayMetric?.studyMinutes ?? 0)}
              </p>
              <p className="label">
                목표 {formatMinutes(report.todayMetric?.targetMinutes ?? 0)}
              </p>
            </div>
            <div className="card">
              <p className="label">오늘 달성률</p>
              <p className="value">
                {Math.round(Number(report.todayMetric?.achievedRate ?? 0))}%
              </p>
              <p className="label">
                {report.todayMetric?.pagesCompleted ?? 0}p ·{" "}
                {report.todayMetric?.problemsSolved ?? 0}문제
              </p>
            </div>
            <div className="card">
              <p className="label">데일리 미션</p>
              <p className="value" style={{ fontSize: 20 }}>
                {report.todayMission?.status ?? "없음"}
              </p>
              <p className="label">
                {report.todayMission
                  ? `${report.todayMission.subjectName} · ${report.todayMission.title}`
                  : "오늘 등록된 미션이 없습니다."}
              </p>
            </div>
          </div>

          {report.focusSummary && (
            <section className="card" style={{ marginTop: 12 }}>
              <p className="label">집중 흐름</p>
              <p className="value" style={{ fontSize: 22 }}>
                앱 이탈 {report.focusSummary.eventCount}회
              </p>
              <p className="label" style={{ marginTop: 6 }}>
                평균 복귀 {report.focusSummary.averageReturnSeconds}초 · 최장{" "}
                {report.focusSummary.longestAwaySeconds}초
              </p>
            </section>
          )}

          <section className="card" style={{ marginTop: 12 }}>
            <p className="label">최근 7일 학습 흐름</p>
            <p className="value" style={{ fontSize: 22 }}>
              평균 달성률 {averageRate}%
            </p>
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
