'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

const TABS = [
  { href: '/', label: '홈' },
  { href: '/students', label: '학생' },
  { href: '/seats', label: '좌석' },
  { href: '/attendance', label: '출결' },
  { href: '/settings', label: '설정' },
];

export function MobileNav() {
  const pathname = usePathname();
  return (
    <nav className="md:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-gray-100 z-40 safe-bottom">
      <ul className="flex">
        {TABS.map(({ href, label }) => {
          const active = pathname === href || (href !== '/' && pathname.startsWith(href));
          return (
            <li key={href} className="flex-1">
              <Link
                href={href}
                className={`flex items-center justify-center py-3 text-xs font-medium transition-colors ${
                  active ? 'text-gray-900 font-semibold' : 'text-gray-400'
                }`}
              >
                {label}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
