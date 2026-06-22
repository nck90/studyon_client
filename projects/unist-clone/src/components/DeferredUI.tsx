"use client";

import dynamic from "next/dynamic";

const CustomCursor = dynamic(
  () => import("@/components/CustomCursor").then((m) => ({ default: m.CustomCursor })),
  { ssr: false }
);
const SectionIndex = dynamic(
  () => import("@/components/SectionIndex").then((m) => ({ default: m.SectionIndex })),
  { ssr: false }
);
const LiveClock = dynamic(
  () => import("@/components/LiveClock").then((m) => ({ default: m.LiveClock })),
  { ssr: false }
);
const PageLoader = dynamic(
  () => import("@/components/PageLoader").then((m) => ({ default: m.PageLoader })),
  { ssr: false }
);

export function DeferredUI() {
  return (
    <>
      <PageLoader />
      <CustomCursor />
      <SectionIndex />
      <LiveClock />
    </>
  );
}
