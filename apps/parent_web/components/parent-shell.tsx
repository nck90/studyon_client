"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect } from "react";
import { rememberToken } from "@/lib/api";

const tabs = [
  { href: "/parent/overview", label: "오늘 상태" },
  { href: "/parent/attendance", label: "출결" },
  { href: "/parent/study-report", label: "학습 리포트" },
];

export function ParentShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  useEffect(() => {
    if (pathname === "/parent/action-report") return;
    const token = new URLSearchParams(window.location.search).get("token");
    if (token) rememberToken(token);
  }, [pathname]);

  return (
    <main className="page">
      <div className="shell">
        <section className="hero">
          <p className="label" style={{ color: "rgba(255,255,255,.75)" }}>
            자습ON 학부모 리포트
          </p>
          <h1 style={{ margin: "8px 0 0", fontSize: 30 }}>자녀의 오늘을 확인하세요</h1>
          <p style={{ margin: "10px 0 0", color: "rgba(255,255,255,.82)" }}>
            이 화면은 학원에서 발급한 읽기 전용 링크로만 접근할 수 있습니다.
          </p>
        </section>
        <nav className="tabs">
          {tabs.map((tab) => (
            <Link
              key={tab.href}
              href={tab.href}
              className={`tab ${pathname === tab.href ? "active" : ""}`}
            >
              {tab.label}
            </Link>
          ))}
        </nav>
        {children}
      </div>
    </main>
  );
}
