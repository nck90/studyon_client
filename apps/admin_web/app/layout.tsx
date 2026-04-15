import type { Metadata, Viewport } from 'next';
import './globals.css';
import { Sidebar } from '@/components/sidebar';
import { MobileNav } from '@/components/mobile-nav';

export const metadata: Metadata = {
  title: '자습ON 관리자',
  description: '자습실 관리 시스템',
  manifest: '/manifest.json',
};

export const viewport: Viewport = {
  themeColor: '#6C5CE7',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <body className="bg-bg text-gray-900 antialiased">
        <div className="flex h-screen">
          {/* Desktop sidebar */}
          <Sidebar />
          {/* Main content */}
          <main className="flex-1 overflow-auto pb-20 md:pb-0">
            {children}
          </main>
        </div>
        {/* Mobile bottom nav */}
        <MobileNav />
      </body>
    </html>
  );
}
