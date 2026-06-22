"use client";

import { useEffect, useState } from "react";
import { getStudyReport, type ParentStudyReport } from "@/lib/api";
import { ParentShell } from "@/components/parent-shell";

function formatMinutes(minutes: number) {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return h > 0 ? `${h}시간 ${m}분` : `${m}분`;
}

export default function StudyReportPage() {
  const [report, setReport] = useState<ParentStudyReport | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    getStudyReport().then(setReport).catch((err) => setError(err instanceof Error ? err.message : "학습 리포트를 불러오지 못했습니다."));
  }, []);

  return (
    <ParentShell>
      {error ? <div className="error">{error}</div> : !report ? <div className="card">불러오는 중...</div> : (
        <>
          <div className="grid">
            <div className="card"><p className="label">총 공부시간</p><p className="value">{formatMinutes(report.totalStudyMinutes)}</p></div>
            <div className="card"><p className="label">평균 달성률</p><p className="value">{Math.round(report.averageAchievedRate)}%</p></div>
            <div className="card"><p className="label">완료 페이지</p><p className="value">{report.totalPagesCompleted}p</p></div>
            <div className="card"><p className="label">풀이 문제</p><p className="value">{report.totalProblemsSolved}문제</p></div>
          </div>
          <section className="card" style={{ marginTop: 12 }}>
            <p className="label">최근 학습 로그</p>
            <div className="list" style={{ marginTop: 12 }}>
              {report.recentLogs.length === 0 ? <p className="label">학습 로그가 없습니다.</p> : report.recentLogs.slice(0, 20).map((log) => (
                <div key={log.id} className="row">
                  <div>
                    <strong>{log.subjectName}</strong>
                    <p className="label" style={{ margin: "4px 0 0" }}>{log.title}</p>
                  </div>
                  <span className="pill">{formatMinutes(log.studyMinutes)}</span>
                </div>
              ))}
            </div>
          </section>
        </>
      )}
    </ParentShell>
  );
}
