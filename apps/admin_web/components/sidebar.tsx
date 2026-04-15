'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';

const NAV_ITEMS = [
  { href: '/', label: '대시보드', icon: '📊' },
  { href: '/students', label: '학생 관리', icon: '👥' },
  { href: '/seats', label: '좌석 현황', icon: '🪑' },
  { href: '/attendance', label: '출결 관리', icon: '📋' },
  { href: '/analytics', label: '분석', icon: '📈' },
  { href: '/rankings', label: '랭킹', icon: '🏆' },
  { href: '/notifications', label: '알림', icon: '🔔' },
  { href: '/tv', label: 'TV 디스플레이', icon: '📺' },
  { href: '/settings', label: '설정', icon: '⚙️' },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="hidden md:flex w-60 flex-col bg-white border-r border-gray-200 shrink-0">
      {/* Brand */}
      <div className="flex items-center gap-2 px-5 py-5 border-b border-gray-100">
        <div className="w-8 h-8 rounded-lg flex items-center justify-center text-white text-sm font-bold"
          style={{ backgroundColor: '#6C5CE7' }}>
          자
        </div>
        <div>
          <p className="text-sm font-bold text-gray-900">자습ON</p>
          <p className="text-xs text-gray-500">관리자</p>
        </div>
      </div>

      {/* Nav */}
      <nav className="flex-1 px-3 py-4 overflow-y-auto">
        <ul className="space-y-0.5">
          {NAV_ITEMS.map((item) => {
            const isActive =
              item.href === '/'
                ? pathname === '/'
                : pathname.startsWith(item.href);

            return (
              <li key={item.href}>
                <Link
                  href={item.href}
                  className={[
                    'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors',
                    isActive
                      ? 'bg-primary-surface text-primary font-semibold'
                      : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900',
                  ].join(' ')}
                >
                  <span className="text-base leading-none">{item.icon}</span>
                  <span>{item.label}</span>
                  {isActive && (
                    <span className="ml-auto w-1.5 h-1.5 rounded-full bg-primary" />
                  )}
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>

      {/* Admin info */}
      <div className="px-4 py-4 border-t border-gray-100">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center text-sm text-gray-600 font-medium">
            관
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-gray-900 truncate">관리자</p>
            <p className="text-xs text-gray-500 truncate">admin@studyon.kr</p>
          </div>
        </div>
      </div>
    </aside>
  );
}
