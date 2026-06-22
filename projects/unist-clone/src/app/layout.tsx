import type { Metadata } from "next";
import "./globals.css";
import "lenis/dist/lenis.css";
import { SmoothScroll } from "@/components/SmoothScroll";
import { ScrollProgress } from "@/components/ScrollProgress";
import { DeferredUI } from "@/components/DeferredUI";

export const metadata: Metadata = {
  title: "진수학전문학원 | TRUE MATH",
  description: "진수학전문학원 - 내신 · 수능 · 경시대회 수학 전문 학원. 수학의 본질을 꿰뚫는 힘.",
  icons: {
    icon: "/seo/favicon.ico",
  },
  openGraph: {
    type: "website",
    locale: "ko",
    siteName: "진수학전문학원",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko" className="h-full antialiased">
      <head>
        <link rel="preconnect" href="https://cdn.jsdelivr.net" crossOrigin="anonymous" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css"
          rel="stylesheet"
        />
        <link
          href="https://fonts.googleapis.com/css2?family=Prompt:wght@700;900&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="min-h-full flex flex-col" style={{ fontFamily: "Pretendard, -apple-system, BlinkMacSystemFont, system-ui, sans-serif" }}>
        <DeferredUI />
        <SmoothScroll />
        <ScrollProgress />
        {children}
      </body>
    </html>
  );
}
