"use client";

import { useEffect, useState } from "react";
import { getAttendance, type ParentAttendance } from "@/lib/api";
import { ParentShell } from "@/components/parent-shell";

function formatDate(value: string) {
  return new Date(value).toLocaleDateString("ko-KR", { month: "long", day: "numeric", weekday: "short" });
}

export default function AttendancePage() {
  const [items, setItems] = useState<ParentAttendance[]>([]);
  const [error, setError] = useState("");

  useEffect(() => {
    getAttendance().then(setItems).catch((err) => setError(err instanceof Error ? err.message : "출결을 불러오지 못했습니다."));
  }, []);

  return (
    <ParentShell>
      {error ? <div className="error">{error}</div> : (
        <div className="list">
          {items.length === 0 ? <div className="card">출결 기록이 없습니다.</div> : items.slice(0, 90).map((item) => (
            <div key={item.id} className="row">
              <div>
                <strong>{formatDate(item.attendanceDate)}</strong>
                <p className="label" style={{ margin: "4px 0 0" }}>
                  입실 {item.checkInAt ? new Date(item.checkInAt).toLocaleTimeString("ko-KR", { hour: "2-digit", minute: "2-digit" }) : "-"} · 퇴실 {item.checkOutAt ? new Date(item.checkOutAt).toLocaleTimeString("ko-KR", { hour: "2-digit", minute: "2-digit" }) : "-"}
                </p>
              </div>
              <span className="pill">{item.attendanceStatus}</span>
            </div>
          ))}
        </div>
      )}
    </ParentShell>
  );
}
