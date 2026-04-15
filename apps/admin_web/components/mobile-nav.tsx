'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

const PRIMARY_NAV = [
  { href: '/', label: '홈', icon: '🏠' },
  { href: '/students', label: '학생', icon: '👥' },
  { href: '/seats', label: '좌석', icon: '🪑' },
  { href: '/attendance', label: '출결', icon: '📋' },
];

const MORE_NAV = [
  { href: '/analytics', label: '분석', icon: '📈' },
  { href: '/rankings', label: '랭킹', icon: '🏆' },
  { href: '/notifications', label: '알림', icon: '🔔' },
  { href: '/tv', label: 'TV 디스플레이', icon: '📺' },
  { href: '/settings', label: '설정', icon: '⚙️' },
];

export function MobileNav() {
  const pathname = usePathname();
  const [moreOpen, setMoreOpen] = useState(false);

  const isMoreActive = MORE_NAV.some((item) => pathname.startsWith(item.href));

  return (
    <>
      {/* Bottom nav bar */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-40">
        <ul className="flex items-center">
          {PRIMARY_NAV.map((item) => {
            const isActive =
              item.href === '/'
                ? pathname === '/'
                : pathname.startsWith(item.href);

            return (
              <li key={item.href} className="flex-1">
                <Link
                  href={item.href}
                  className={[
                    'flex flex-col items-center justify-center py-2.5 gap-0.5 text-center transition-colors',
                    isActive ? 'text-primary' : 'text-gray-500',
                  ].join(' ')}
                >
                  <span className="text-xl leading-none">{item.icon}</span>
                  <span className="text-[10px] font-medium">{item.label}</span>
                </Link>
              </li>
            );
          })}

          {/* More button */}
          <li className="flex-1">
            <button
              onClick={() => setMoreOpen(true)}
              className={[
                'w-full flex flex-col items-center justify-center py-2.5 gap-0.5 transition-colors',
                isMoreActive ? 'text-primary' : 'text-gray-500',
              ].join(' ')}
            >
              <span className="text-xl leading-none">⋯</span>
              <span className="text-[10px] font-medium">더보기</span>
            </button>
          </li>
        </ul>
      </nav>

      {/* Bottom sheet overlay */}
      {moreOpen && (
        <>
          <div
            className="md:hidden fixed inset-0 bg-black/40 z-50"
            onClick={() => setMoreOpen(false)}
          />
          <div className="md:hidden fixed bottom-0 left-0 right-0 bg-white rounded-t-2xl z-50 pb-safe">
            <div className="flex items-center justify-between px-5 pt-4 pb-3 border-b border-gray-100">
              <span className="text-sm font-semibold text-gray-900">더보기</span>
              <button
                onClick={() => setMoreOpen(false)}
                className="w-7 h-7 rounded-full bg-gray-100 flex items-center justify-center text-gray-500 text-sm"
              >
                ✕
              </button>
            </div>
            <ul className="px-4 py-3 space-y-1">
              {MORE_NAV.map((item) => {
                const isActive = pathname.startsWith(item.href);
                return (
                  <li key={item.href}>
                    <Link
                      href={item.href}
                      onClick={() => setMoreOpen(false)}
                      className={[
                        'flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-colors',
                        isActive
                          ? 'bg-primary-surface text-primary'
                          : 'text-gray-700 hover:bg-gray-50',
                      ].join(' ')}
                    >
                      <span className="text-lg leading-none">{item.icon}</span>
                      <span>{item.label}</span>
                    </Link>
                  </li>
                );
              })}
            </ul>
            <div className="h-6" />
          </div>
        </>
      )}
    </>
  );
}
