"use client";

import { useEffect } from "react";
import { AlertTriangle, RefreshCw } from "lucide-react";

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
    <div className="flex min-h-[60vh] items-center justify-center p-6">
      <div className="w-full max-w-md rounded-2xl border border-card-border bg-white p-6 text-center card-shadow">
        <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-xl bg-hot-light text-hot">
          <AlertTriangle size={22} />
        </div>
        <h1 className="mt-4 text-lg font-extrabold text-text-primary">
          화면을 불러오지 못했습니다
        </h1>
        <p className="mt-2 text-sm text-text-tertiary">
          일시적인 오류일 수 있습니다. 다시 시도해 주세요.
        </p>
        <button
          type="button"
          onClick={reset}
          className="mt-5 inline-flex items-center justify-center gap-2 rounded-xl bg-primary px-4 py-2.5 text-sm font-bold text-white transition hover:bg-primary/90"
        >
          <RefreshCw size={16} />
          다시 시도
        </button>
      </div>
    </div>
  );
}
