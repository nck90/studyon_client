"use client";

import { useEffect, useState } from "react";

function format(d: Date): string {
  return d.toLocaleTimeString("ko-KR", {
    hour12: false,
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  });
}

export function LiveClock() {
  const [time, setTime] = useState(() => format(new Date()));

  useEffect(() => {
    const id = setInterval(() => setTime(format(new Date())), 1000);
    return () => clearInterval(id);
  }, []);

  return (
    <div
      aria-hidden="true"
      style={{
        position: "fixed",
        bottom: 24,
        left: 28,
        zIndex: 9998,
        fontFamily: "'Prompt', sans-serif",
        fontSize: 10,
        fontWeight: 700,
        letterSpacing: "2px",
        color: "#fff",
        mixBlendMode: "difference",
        pointerEvents: "none",
        display: "flex",
        alignItems: "center",
        gap: 10,
        fontVariantNumeric: "tabular-nums",
      }}
    >
      <span style={{ width: 14, height: 1, background: "currentColor" }} />
      SEOUL · KST · {time}
    </div>
  );
}
