import type { Metadata, Viewport } from 'next';
import './globals.css';
import { SiteHeader } from '@/components/site-header';
import { SiteFooter } from '@/components/site-footer';

export const metadata: Metadata = {
  metadataBase: new URL('https://studyon-landing.hyphen.it.com'),
  title: {
    default: '자습ON — 자습실 집중 관리 앱',
    template: '%s · 자습ON',
  },
  description:
    '자습ON은 iOS 앱에서 공부 시간, 좌석, 랭킹과 성장을 관리하는 자습실 집중 앱입니다.',
  applicationName: '자습ON',
  keywords: ['자습ON', '자습실 관리', '학원 앱', '공부 시간 기록', '집중 타이머', '학습 RPG', '공부 퀘스트'],
  authors: [{ name: 'hyphen' }],
  openGraph: {
    type: 'website',
    locale: 'ko_KR',
    url: 'https://studyon-landing.hyphen.it.com',
    title: '자습ON — 자습실 집중 관리 앱',
    description:
      '실제 iOS 앱 화면으로 보는 공부 시간, 좌석, 랭킹과 성장 관리.',
    siteName: '자습ON',
  },
  twitter: {
    card: 'summary_large_image',
    title: '자습ON — 자습실 집중 관리 앱',
    description:
      '실제 iOS 앱 화면으로 보는 공부 시간, 좌석, 랭킹과 성장 관리.',
  },
  formatDetection: { telephone: false },
};

export const viewport: Viewport = {
  themeColor: '#dff3ff',
  width: 'device-width',
  initialScale: 1,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <head>
        <link
          rel="preconnect"
          href="https://cdn.jsdelivr.net"
          crossOrigin="anonymous"
        />
        <link
          rel="stylesheet"
          href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css"
        />
      </head>
      <body className="min-h-screen antialiased">
        <SiteHeader />
        <main>{children}</main>
        <SiteFooter />
      </body>
    </html>
  );
}
