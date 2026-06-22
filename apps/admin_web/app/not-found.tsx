import Link from "next/link";
import { Home } from "lucide-react";

export default function NotFound() {
  return (
    <div className="flex min-h-[60vh] items-center justify-center p-6">
      <div className="w-full max-w-md rounded-2xl border border-card-border bg-white p-6 text-center card-shadow">
        <h1 className="text-lg font-extrabold text-text-primary">
          페이지를 찾을 수 없습니다
        </h1>
        <p className="mt-2 text-sm text-text-tertiary">
          주소가 바뀌었거나 접근할 수 없는 화면입니다.
        </p>
        <Link
          href="/"
          className="mt-5 inline-flex items-center justify-center gap-2 rounded-xl bg-primary px-4 py-2.5 text-sm font-bold text-white transition hover:bg-primary/90"
        >
          <Home size={16} />
          대시보드로 이동
        </Link>
      </div>
    </div>
  );
}
