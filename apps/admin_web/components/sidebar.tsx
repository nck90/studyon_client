'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

const NAV = [
  { href: '/', label: '대시보드' },
  { href: '/students', label: '학생 관리' },
  { href: '/seats', label: '좌석 현황' },
  { href: '/attendance', label: '출결 관리' },
  { href: '/analytics', label: '분석' },
  { href: '/rankings', label: '랭킹' },
  { href: '/notifications', label: '알림' },
  { href: '/tv', label: 'TV 제어' },
  { href: '/settings', label: '설정' },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="hidden md:flex w-56 flex-col bg-white border-r border-gray-100 shrink-0">
      {/* Brand */}
      <div className="px-5 py-6">
        <p className="text-lg font-extrabold text-gray-900 tracking-tight">자습ON</p>
        <p className="text-xs text-gray-400 mt-0.5">관리자</p>
      </div>

      {/* Nav */}
      <nav className="flex-1 px-3">
        <ul className="space-y-0.5">
          {NAV.map(({ href, label }) => {
            const active = pathname === href || (href !== '/' && pathname.startsWith(href));
            return (
              <li key={href}>
                <Link
                  href={href}
                  className={`block px-3 py-2 rounded-lg text-[13px] font-medium transition-colors ${
                    active
                      ? 'bg-gray-900 text-white'
                      : 'text-gray-500 hover:text-gray-900 hover:bg-gray-50'
                  }`}
                >
                  {label}
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>

      {/* Admin info */}
      <div className="px-5 py-4 border-t border-gray-100">
        <p className="text-sm font-semibold text-gray-800">김원장</p>
        <p className="text-xs text-gray-400">원장</p>
      </div>
    </aside>
  );
}
