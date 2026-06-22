import Link from 'next/link';

export function SiteFooter() {
  return (
    <footer className="border-t border-[#e7edf2] bg-white">
      <div className="mx-auto flex max-w-[1180px] flex-col gap-6 px-5 py-10 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-2">
          <span className="brand-mark !h-7 !w-7 !text-[12px]" aria-hidden>ON</span>
          <span className="text-[14px] font-extrabold text-[#202833]">
            자습ON
          </span>
        </div>
        <nav className="flex flex-wrap items-center gap-x-5 gap-y-2 text-[13px] font-semibold text-[#6f7b87]">
          <Link href="/support" className="hover:text-[#202833]">고객 지원</Link>
          <Link href="/privacy" className="hover:text-[#202833]">개인정보 처리방침</Link>
          <a href="mailto:hyphendev2025@gmail.com" className="hover:text-[#202833]">hyphendev2025@gmail.com</a>
        </nav>
        <p className="text-[12px] text-[#6f7b87]">© 2026 hyphen. All rights reserved.</p>
      </div>
    </footer>
  );
}
