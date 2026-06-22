"use client";

import { useEffect, useState } from "react";
import { getOverview, type ParentOverview } from "@/lib/api";
import { ParentShell } from "@/components/parent-shell";

function formatMinutes(minutes: number) {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return h > 0 ? `${h}시간 ${m}분` : `${m}분`;
}

export default function OverviewPage() {
  const [data, setData] = useState<ParentOverview | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    getOverview().then(setData).catch((err) => setError(err instanceof Error ? err.message : "리포트를 불러오지 못했습니다."));
  }, []);

  if (error) return <ParentShell><div className="error">{error}</div></ParentShell>;
  if (!data) return <ParentShell><div className="card">불러오는 중...</div></ParentShell>;

  const metric = data.todayMetric;
  const attendance = data.todayAttendance;
  const student = data.student;

  return (
    <ParentShell>
      <div className="grid">
        <div className="card">
          <p className="label">학생</p>
          <p className="value">{student?.user.name ?? "학생"}</p>
          <p className="label">{[student?.grade?.name, student?.class?.name, student?.assignedSeat?.seatNo && `${student.assignedSeat.seatNo}번 좌석`].filter(Boolean).join(" · ") || "소속 정보 없음"}</p>
        </div>
        <div className="card">
          <p className="label">오늘 출결</p>
          <p className="value">{attendance?.attendanceStatus ?? "미입실"}</p>
          <p className="label">체류 {formatMinutes(attendance?.stayMinutes ?? 0)}</p>
        </div>
        <div className="card">
          <p className="label">오늘 공부</p>
          <p className="value">{formatMinutes(metric?.studyMinutes ?? 0)}</p>
          <p className="label">목표 {formatMinutes(metric?.targetMinutes ?? 0)}</p>
        </div>
        <div className="card">
          <p className="label">달성률</p>
          <p className="value">{Math.round(Number(metric?.achievedRate ?? 0))}%</p>
          <p className="label">{metric?.pagesCompleted ?? 0}p · {metric?.problemsSolved ?? 0}문제</p>
        </div>
      </div>
      <section className="card" style={{ marginTop: 12 }}>
        <p className="label">오늘 계획</p>
        <div className="list" style={{ marginTop: 12 }}>
          {data.todayPlans.length === 0 ? (
            <p className="label">오늘 등록된 계획이 없습니다.</p>
          ) : data.todayPlans.map((plan) => (
            <div key={plan.id} className="row">
              <div>
                <strong>{plan.subjectName}</strong>
                <p className="label" style={{ margin: "4px 0 0" }}>{plan.title}</p>
              </div>
              <span className="pill">{Math.round(Number(plan.progressRate))}%</span>
            </div>
          ))}
        </div>
      </section>
    </ParentShell>
  );
}
