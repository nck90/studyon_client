"use client";

import { useEffect } from "react";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <main className="flex min-h-screen items-center justify-center bg-[#080b10] px-8 text-center text-white">
      <section className="max-w-2xl">
        <p className="text-sm font-black tracking-[0.35em] text-cyan-300">
          STUDYON LIVE
        </p>
        <h1 className="mt-6 text-5xl font-black tracking-normal">
          화면을 불러오지 못했습니다
        </h1>
        <p className="mt-5 text-xl font-semibold text-slate-300">
          네트워크 또는 일시적인 표시 오류입니다.
        </p>
        <button
          type="button"
          onClick={reset}
          className="mt-8 rounded-2xl bg-cyan-300 px-7 py-4 text-lg font-black text-slate-950"
        >
          다시 연결
        </button>
      </section>
    </main>
  );
}
