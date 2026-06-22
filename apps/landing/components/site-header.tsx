import Link from 'next/link';

export function SiteHeader() {
  return (
    <header className="site-shell sticky top-0 z-40">
      <div className="mx-auto flex h-14 max-w-[1180px] items-center justify-between px-5">
        <Link href="/" className="flex items-center gap-2">
          <span className="brand-mark" aria-hidden>ON</span>
          <span className="text-[15px] font-extrabold text-[#202833]">
            자습ON
          </span>
        </Link>
        <nav className="flex items-center gap-5 text-[13px] font-bold text-[#6f7b87]">
          <Link href="/#preview" className="hover:text-[#202833]">미리보기</Link>
          <Link href="/support" className="hover:text-[#202833]">고객 지원</Link>
          <Link href="/privacy" className="hidden hover:text-[#202833] sm:inline">개인정보</Link>
        </nav>
      </div>
    </header>
  );
}
