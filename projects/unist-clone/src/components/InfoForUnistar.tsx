"use client";

import { useState, useEffect, useRef, useCallback } from "react";
import Image from "next/image";
import { motion, AnimatePresence } from "framer-motion";

const BANNERS = [
  {
    image: "/images/main/banner02.png",
    title: "맞춤형 1:1 학습 플랜으로\n내신 1등급을 향해",
    link: "수업 상담 바로가기",
    href: "#",
  },
  {
    image: "/images/main/sec02-03.png",
    title: "체계적인 커리큘럼으로\n수능 수학 완벽 대비",
    link: "커리큘럼 보기",
    href: "#",
  },
];

const INTERVAL = 5000;

export function InfoForUnistar() {
  const [current, setCurrent] = useState(0);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const [inView, setInView] = useState(false);
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const el = sectionRef.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setInView(true);
          obs.disconnect();
        }
      },
      { threshold: 0.1 }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, []);

  const startTimer = useCallback(() => {
    if (timerRef.current) clearInterval(timerRef.current);
    timerRef.current = setInterval(() => {
      setCurrent((prev) => (prev + 1) % BANNERS.length);
    }, INTERVAL);
  }, []);

  useEffect(() => {
    startTimer();
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [startTimer]);

  const goTo = (i: number) => {
    setCurrent(i);
    startTimer();
  };

  const prev = () => goTo((current - 1 + BANNERS.length) % BANNERS.length);
  const next = () => goTo((current + 1) % BANNERS.length);

  return (
    <section
      ref={sectionRef}
      className="jm-info-section"
      style={{
        background: "#fff",
        padding: "110px 0",
      }}
    >
      <style dangerouslySetInnerHTML={{ __html: `
        @media (max-width: 768px) {
          .jm-info-section { padding: 60px 0 !important; }
          .jm-info-container { padding: 0 16px !important; }
          .jm-info-grid {
            grid-template-columns: 1fr !important;
            min-height: auto !important;
          }
        }
      ` }} />
      <div className="jm-info-container" style={{ maxWidth: 1528, margin: "0 auto", padding: "0 40px", width: "100%" }}>
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-40px" }}
          transition={{ duration: 1.2, ease: [0.16, 1, 0.3, 1] }}
          style={{ textAlign: "center", marginBottom: 50 }}
        >
          <h2
            style={{
              fontFamily: "'Prompt', sans-serif",
              fontWeight: 700,
              fontSize: 28,
              letterSpacing: "0.56px",
              lineHeight: "30.8px",
              color: "#111",
              textTransform: "uppercase",
              margin: "0 0 16px",
            }}
          >
            Information for 진수학
          </h2>
          <span
            style={{
              display: "inline-block",
              width: 40,
              height: 3,
              borderRadius: 999,
              background: "#111",
            }}
          />
        </motion.div>

        {/* Grid: big carousel (2/3) + stacked cards (1/3) */}
        <div
          className="jm-info-grid"
          style={{
            display: "grid",
            gridTemplateColumns: "2fr 1fr",
            gap: 16,
            minHeight: 560,
          }}
        >
          {/* Left: big carousel */}
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true, margin: "-40px" }}
            transition={{ duration: 1.2, ease: [0.16, 1, 0.3, 1] }}
            style={{
              position: "relative",
              borderRadius: 20,
              overflow: "hidden",
              background: "#111",
            }}
          >
            <AnimatePresence mode="wait">
              {BANNERS.map((banner, i) =>
                i === current ? (
                  <motion.div
                    key={i}
                    initial={{ opacity: 0, scale: 1.04 }}
                    animate={{ opacity: 1, scale: 1 }}
                    exit={{ opacity: 0, scale: 1.02 }}
                    transition={{ duration: 0.8, ease: [0.22, 0.61, 0.36, 1] }}
                    style={{ position: "absolute", inset: 0 }}
                  >
                    <Image
                      src={banner.image}
                      alt={banner.title}
                      fill
                      sizes="(max-width: 1024px) 100vw, 66vw"
                      style={{ objectFit: "cover" }}
                      priority={i === 0}
                    />
                    <div
                      style={{
                        position: "absolute",
                        inset: 0,
                        background:
                          "linear-gradient(90deg, rgba(0,0,0,0.78) 0%, rgba(0,0,0,0.42) 45%, rgba(0,0,0,0.1) 100%)",
                      }}
                    />
                  </motion.div>
                ) : null
              )}
            </AnimatePresence>

            <div
              style={{
                position: "absolute",
                bottom: 48,
                left: 52,
                right: 52,
                zIndex: 2,
              }}
            >
              <AnimatePresence mode="wait">
                <motion.div
                  key={current}
                  initial={{ opacity: 0, y: 16 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  transition={{ duration: 0.5, ease: [0.22, 0.61, 0.36, 1] }}
                >
                  <p
                    style={{
                      color: "#fff",
                      fontSize: "clamp(22px, 2.4vw, 30px)",
                      fontWeight: 800,
                      lineHeight: 1.35,
                      letterSpacing: "-0.7px",
                      marginBottom: 22,
                      whiteSpace: "pre-line",
                      maxWidth: 540,
                    }}
                  >
                    {BANNERS[current].title}
                  </p>

                  <motion.a
                    href={BANNERS[current].href}
                    whileHover="hover"
                    initial="rest"
                    animate="rest"
                    style={{
                      display: "inline-flex",
                      alignItems: "center",
                      gap: 10,
                      padding: "13px 22px",
                      borderRadius: 999,
                      border: "1px solid rgba(255,255,255,0.7)",
                      color: "#fff",
                      fontSize: 13,
                      fontWeight: 700,
                      letterSpacing: "0.3px",
                      textDecoration: "none",
                      overflow: "hidden",
                      position: "relative",
                    }}
                  >
                    <motion.span
                      variants={{ rest: { x: "-101%" }, hover: { x: "0%" } }}
                      transition={{ duration: 0.5, ease: [0.22, 0.61, 0.36, 1] }}
                      style={{ position: "absolute", inset: 0, background: "#fff", zIndex: 0 }}
                    />
                    <motion.span
                      variants={{ rest: { color: "#fff" }, hover: { color: "#111" } }}
                      transition={{ duration: 0.4 }}
                      style={{ position: "relative", zIndex: 1 }}
                    >
                      {BANNERS[current].link}
                    </motion.span>
                    <motion.svg
                      variants={{ rest: { color: "#fff", x: 0 }, hover: { color: "#111", x: 3 } }}
                      transition={{ duration: 0.4 }}
                      width="14"
                      height="14"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      style={{ position: "relative", zIndex: 1 }}
                    >
                      <path d="M5 12h14M12 5l7 7-7 7" />
                    </motion.svg>
                  </motion.a>
                </motion.div>
              </AnimatePresence>
            </div>

            {/* Dots */}
            <div
              style={{
                position: "absolute",
                bottom: 28,
                right: 52,
                zIndex: 3,
                display: "flex",
                gap: 8,
                alignItems: "center",
              }}
            >
              {BANNERS.map((_, i) => (
                <button
                  key={i}
                  onClick={() => goTo(i)}
                  aria-label={`슬라이드 ${i + 1}`}
                  style={{
                    width: i === current ? 26 : 6,
                    height: 6,
                    borderRadius: 999,
                    background: i === current ? "#fff" : "rgba(255,255,255,0.45)",
                    border: "none",
                    padding: 0,
                    cursor: "pointer",
                    transition: "width 0.35s ease, background 0.3s ease",
                  }}
                />
              ))}
            </div>

            {/* Arrows */}
            <motion.button
              onClick={prev}
              aria-label="이전"
              whileHover={{ scale: 1.06 }}
              whileTap={{ scale: 0.94 }}
              style={{
                position: "absolute",
                left: 18,
                top: "50%",
                transform: "translateY(-50%)",
                zIndex: 3,
                width: 44,
                height: 44,
                borderRadius: "50%",
                background: "rgba(255,255,255,0.1)",
                border: "1px solid rgba(255,255,255,0.25)",
                backdropFilter: "blur(6px)",
                WebkitBackdropFilter: "blur(6px)",
                cursor: "pointer",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M15 18l-6-6 6-6" />
              </svg>
            </motion.button>
            <motion.button
              onClick={next}
              aria-label="다음"
              whileHover={{ scale: 1.06 }}
              whileTap={{ scale: 0.94 }}
              style={{
                position: "absolute",
                right: 18,
                top: "50%",
                transform: "translateY(-50%)",
                zIndex: 3,
                width: 44,
                height: 44,
                borderRadius: "50%",
                background: "rgba(255,255,255,0.1)",
                border: "1px solid rgba(255,255,255,0.25)",
                backdropFilter: "blur(6px)",
                WebkitBackdropFilter: "blur(6px)",
                cursor: "pointer",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
              }}
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M9 18l6-6-6-6" />
              </svg>
            </motion.button>
          </motion.div>

          {/* Right column: stacked cards */}
          <div
            style={{
              display: "grid",
              gridTemplateRows: "1.25fr 1fr",
              gap: 16,
            }}
          >
            {/* Top right: dark info card */}
            <SideCard
              dark
              delay={0.15}
              title={"진수학\n커리큘럼"}
              desc="내신·수능·경시까지, 학년별 단계식 커리큘럼을 확인하세요."
              href="#"
              Icon={() => (
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                  <rect x="3" y="4" width="18" height="16" rx="2" />
                  <path d="M7 9h10M7 13h10M7 17h7" />
                </svg>
              )}
            />

            {/* Bottom right: 2 smaller cards side by side */}
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16 }}>
              <SideCard
                delay={0.3}
                title="입반 테스트"
                desc="학습 진단"
                href="#"
                Icon={() => (
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M9 11l2 2 4-4" />
                    <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                )}
              />
              <SideCard
                delay={0.4}
                title="한눈에 보기"
                desc="학원 소개"
                href="#"
                Icon={() => (
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M3 10l9-7 9 7v10a2 2 0 01-2 2h-4v-7h-6v7H5a2 2 0 01-2-2V10z" />
                  </svg>
                )}
              />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function SideCard({
  dark = false,
  title,
  desc,
  href,
  delay,
  Icon,
}: {
  dark?: boolean;
  title: string;
  desc: string;
  href: string;
  delay: number;
  Icon: () => React.ReactElement;
}) {
  const bg = dark ? "#111" : "#FAFAFA";
  const fg = dark ? "#fff" : "#111";
  const descColor = dark ? "rgba(255,255,255,0.7)" : "#666";
  const border = dark ? "1px solid #111" : "1px solid #EAEAEA";

  return (
    <motion.a
      href={href}
      initial={{ opacity: 0, y: 30 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-30px" }}
      transition={{ delay, duration: 1.1, ease: [0.16, 1, 0.3, 1] }}
      whileHover={{ y: -4 }}
      style={{
        position: "relative",
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-between",
        padding: "28px 28px 26px",
        background: bg,
        border,
        borderRadius: 20,
        textDecoration: "none",
        cursor: "pointer",
        overflow: "hidden",
        transition: "border-color 0.3s ease",
      }}
    >
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <h3
          style={{
            fontFamily: "Pretendard, sans-serif",
            fontSize: dark ? "clamp(22px, 2vw, 28px)" : 17,
            fontWeight: 800,
            color: fg,
            letterSpacing: "-0.6px",
            lineHeight: 1.15,
            margin: 0,
            whiteSpace: "pre-line",
          }}
        >
          {title}
        </h3>
        <motion.svg
          whileHover={{ x: 2, y: -2 }}
          width="18"
          height="18"
          viewBox="0 0 24 24"
          fill="none"
          stroke={fg}
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
          style={{ flexShrink: 0, marginTop: 4 }}
        >
          <path d="M7 17L17 7M17 7H9M17 7v8" />
        </motion.svg>
      </div>

      <div style={{ display: "flex", alignItems: "flex-end", justifyContent: "space-between", gap: 12, marginTop: dark ? 28 : 16 }}>
        <p
          style={{
            color: descColor,
            fontSize: dark ? 14 : 12,
            fontWeight: 500,
            lineHeight: 1.55,
            letterSpacing: "-0.2px",
            margin: 0,
          }}
        >
          {desc}
        </p>
        <div style={{ color: fg, opacity: 0.9 }}>
          <Icon />
        </div>
      </div>
    </motion.a>
  );
}
