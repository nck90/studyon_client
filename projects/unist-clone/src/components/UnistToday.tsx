"use client";

import { useEffect, useRef, useState } from "react";
import Image from "next/image";
import { motion, useMotionValue, useSpring, useTransform, useScroll } from "framer-motion";
import { TiltCard } from "./TiltCard";

type NewsItem = {
  title: string;
  date: string;
  category: string;
  tone: "dark" | "outline";
  image: string;
};

const NEWS: NewsItem[] = [
  { title: "2026 1학기 중간고사 전략 완벽 가이드",    date: "2026.03.06", category: "공지사항", tone: "dark",    image: "/images/brand/brand-05.jpg" },
  { title: "3월 정규반 대개강 — 초3부터 고3까지",      date: "2026.02.23", category: "공지사항", tone: "outline", image: "/images/brand/brand-06.jpg" },
  { title: "2026 겨울방학 월례고사 실시",             date: "2026.02.23", category: "학사일정", tone: "dark",    image: "/images/brand/brand-07.jpg" },
  { title: "설 연휴 휴강 일정 안내",                   date: "2026.02.09", category: "공지사항", tone: "outline", image: "/images/brand/brand-08.jpg" },
  { title: "자체교재 '쓰는 개념북' 정규반 투입",       date: "2026.01.12", category: "교재",     tone: "dark",    image: "/images/brand/brand-09.jpg" },
  { title: "졸업생 & 새내기 환영 파티 개최",           date: "2026.01.12", category: "행사",     tone: "outline", image: "/images/brand/brand-10.jpg" },
  { title: "익명 고민상담 '마음전달 우체통' 운영 시작", date: "2026.03.17", category: "프로그램", tone: "dark",    image: "/images/brand/brand-02.jpg" },
  { title: "친구 소개 문화상품권 이벤트 선착순 30명",  date: "2026.03.10", category: "이벤트",   tone: "outline", image: "/images/brand/brand-04.jpg" },
];

const ROW1 = [...NEWS, ...NEWS];
const ROW2_BASE = [...NEWS.slice(4), ...NEWS.slice(0, 4)];
const ROW2 = [...ROW2_BASE, ...ROW2_BASE];

const WATERMARK = ["TRUE", "MATH", "ACADEMY", "진수학"];

const CARD_W = 833;
const CARD_H = 259;

function TodayCard({ item, odd }: { item: NewsItem; odd: boolean }) {
  const badgeStyle =
    item.tone === "dark"
      ? { background: "#111", color: "#fff", border: "1px solid #111" }
      : { background: "#fff", color: "#111", border: "1px solid #111" };

  return (
    <TiltCard
      max={7}
      perspective={1000}
      scale={1.015}
      style={{
        width: CARD_W,
        height: CARD_H,
        flexShrink: 0,
        position: "relative",
        marginTop: odd ? 20 : 0,
      }}
    >
      <a href="#" className="today-card">
        <div className="today-card__text">
          <p className="today-card__title">{item.title}</p>
          <p className="today-card__date">{item.date}</p>
          <span className="today-card__badge" style={badgeStyle}>
            {item.category}
          </span>
        </div>
        <div className="today-card__thumb">
          <Image
            src={item.image}
            alt={item.title}
            fill
            sizes="280px"
            style={{ objectFit: "cover" }}
            className="today-card__img"
          />
        </div>
      </a>
    </TiltCard>
  );
}

export function UnistToday() {
  const [phase, setPhase] = useState(0);
  const [paused, setPaused] = useState(false);
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    const el = sectionRef.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          obs.disconnect();
          setPhase(1);
          setTimeout(() => setPhase(2), 400);    // title starts
          setTimeout(() => setPhase(3), 1300);   // rows appear after ~1s of watermark
          setTimeout(() => setPhase(4), 2200);   // marquee begins
        }
      },
      // Fire only when the section is actually 30% into viewport — avoids early trigger
      // while user is still in Hero and hasn't seen the watermark
      { threshold: 0.3, rootMargin: "-15% 0px" }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, []);

  const rowTranslate = ROW1.length * CARD_W / 2; // 2x duplicated → translate 50% for seamless loop
  const watermarkDelays = [0, 0.2, 0.4, 0.6];

  // Magnetic mouse tracking for watermark (normalized -0.5..0.5 around section center)
  const mx = useMotionValue(0);
  const my = useMotionValue(0);
  const smoothMx = useSpring(mx, { stiffness: 60, damping: 18, mass: 0.8 });
  const smoothMy = useSpring(my, { stiffness: 60, damping: 18, mass: 0.8 });

  useEffect(() => {
    const el = sectionRef.current;
    if (!el) return;
    const onMove = (e: MouseEvent) => {
      const rect = el.getBoundingClientRect();
      mx.set((e.clientX - rect.left) / rect.width - 0.5);
      my.set((e.clientY - rect.top) / rect.height - 0.5);
    };
    const onLeave = () => {
      mx.set(0);
      my.set(0);
    };
    el.addEventListener("mousemove", onMove);
    el.addEventListener("mouseleave", onLeave);
    return () => {
      el.removeEventListener("mousemove", onMove);
      el.removeEventListener("mouseleave", onLeave);
    };
  }, [mx, my]);

  // Scroll-linked watermark pulse (scale + letter spacing)
  const { scrollYProgress: sectionProgress } = useScroll({
    target: sectionRef,
    offset: ["start end", "end start"],
  });
  const wmScale = useTransform(sectionProgress, [0, 0.5, 1], [0.92, 1.02, 0.96]);
  const wmGlobalOpacity = useTransform(sectionProgress, [0, 0.2, 0.8, 1], [0, 1, 1, 0.5]);

  // Per-word magnetic displacements — alternating directions create a drifting, animated feel
  const wx0 = useTransform(smoothMx, (v) => v * 80);
  const wy0 = useTransform(smoothMy, (v) => v * 24);
  const wx1 = useTransform(smoothMx, (v) => v * -55);
  const wy1 = useTransform(smoothMy, (v) => v * -18);
  const wx2 = useTransform(smoothMx, (v) => v * 45);
  const wy2 = useTransform(smoothMy, (v) => v * 16);
  const wx3 = useTransform(smoothMx, (v) => v * -38);
  const wy3 = useTransform(smoothMy, (v) => v * -12);
  const wordX = [wx0, wx1, wx2, wx3];
  const wordY = [wy0, wy1, wy2, wy3];

  return (
    <section
      ref={sectionRef}
      data-snap="start"
      className="jm-today-section"
      style={{
        position: "relative",
        background: "#fff",
        padding: "140px 0 50px",
        overflow: "hidden",
      }}
    >
      <style
        dangerouslySetInnerHTML={{
          __html: `
            @keyframes todayMarqueeL {
              0%   { transform: translate3d(0, 0, 0); }
              100% { transform: translate3d(-${rowTranslate}px, 0, 0); }
            }

            .today-card {
              position: absolute;
              inset: 0;
              margin: auto;
              width: 738px;
              height: ${CARD_H}px;
              display: flex;
              align-items: center;
              justify-content: space-between;
              gap: 31px;
              background: #ffffff;
              border: 1px solid #EAEAEA;
              border-radius: 16px;
              padding: 37.5px 30px 37.5px 40px;
              overflow: hidden;
              box-sizing: border-box;
              text-decoration: none;
              color: inherit;
              cursor: pointer;
              will-change: transform;
              transition:
                transform 400ms cubic-bezier(.2,0,0,1),
                border-color 300ms ease,
                box-shadow 400ms ease;
            }
            .today-card:hover {
              transform: translateY(-4px);
              border-color: #111;
              box-shadow: 0 14px 32px rgba(0, 0, 0, 0.08);
            }

            .today-card__text {
              flex: 1;
              text-align: left;
              position: relative;
              z-index: 2;
              display: flex;
              flex-direction: column;
              gap: 10px;
            }
            .today-card__title {
              font-family: Pretendard, sans-serif;
              font-weight: 800;
              font-size: 28px;
              line-height: 38px;
              letter-spacing: -0.84px;
              color: #111;
              margin: 0;
              display: -webkit-box;
              -webkit-line-clamp: 3;
              -webkit-box-orient: vertical;
              overflow: hidden;
            }
            .today-card__date {
              font-weight: 500;
              font-size: 14px;
              line-height: 1;
              color: #888;
              margin: 0;
              font-variant-numeric: tabular-nums;
            }
            .today-card__badge {
              display: inline-flex;
              align-items: center;
              font-weight: 700;
              font-size: 13px;
              line-height: 1;
              letter-spacing: -0.01em;
              padding: 8px 12px;
              border-radius: 999px;
              width: max-content;
              margin-top: 4px;
            }

            .today-card__thumb {
              position: relative;
              width: 280px;
              height: 198px;
              border-radius: 121px;
              overflow: hidden;
              flex-shrink: 0;
              z-index: 1;
              background: #f4f4f4;
            }
            .today-card__thumb img {
              transition: transform 700ms cubic-bezier(.2,0,0,1);
            }
            .today-card:hover .today-card__thumb img {
              transform: scale(1.08);
            }

            .today-marquee-viewport {
              contain: paint;
            }
            .today-marquee-track {
              display: flex;
              width: max-content;
              will-change: transform;
              transform: translateZ(0);
            }
            @media (max-width: 768px) {
              .jm-today-section { padding: 80px 0 30px !important; }
              .jm-today-watermark { top: 120px !important; }
              .jm-today-watermark > div { font-size: 60px !important; }
              .today-card {
                width: calc(100vw - 80px) !important;
                padding: 20px !important;
                flex-direction: column !important;
                height: auto !important;
                gap: 16px !important;
              }
              .today-card__text {
                width: 100% !important;
              }
              .today-card__title {
                font-size: 20px !important;
                line-height: 28px !important;
              }
              .today-card__thumb {
                width: 100% !important;
                height: 160px !important;
                border-radius: 12px !important;
              }
            }
          `,
        }}
      />

      {/* Interactive magnetic watermark — mouse tracks x/y, scroll scales, each word hoverable */}
      <motion.div
        aria-hidden="true"
        className="jm-today-watermark"
        style={{
          position: "absolute",
          top: 220,
          left: 0,
          right: 0,
          textAlign: "center",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          zIndex: 0,
          gap: 18,
          scale: wmScale,
          opacity: wmGlobalOpacity,
          pointerEvents: "auto",
        }}
      >
        {WATERMARK.map((word, i) => {
          const chars = Array.from(word);
          const wordStart = watermarkDelays[i];
          const pulseStart = wordStart + chars.length * 0.045 + 0.6;
          return (
            <motion.div
              key={i}
              whileHover={{ letterSpacing: "6px" }}
              transition={{ letterSpacing: { duration: 0.5, ease: [0.22, 0.61, 0.36, 1] } }}
              style={{
                position: "relative",
                display: "inline-block",
                fontFamily: "'Prompt', sans-serif",
                fontWeight: 900,
                fontSize: 150,
                lineHeight: "81%",
                letterSpacing: "0px",
                textTransform: "uppercase",
                whiteSpace: "nowrap",
                color: "#F0F0F0",
                userSelect: "none",
                margin: 0,
                padding: 0,
                x: wordX[i],
                y: wordY[i],
                cursor: "default",
                willChange: "transform, letter-spacing",
              }}
            >
              {/* Underline bar that draws left → right during reveal */}
              <motion.span
                aria-hidden="true"
                initial={{ scaleX: 0 }}
                animate={phase >= 1 ? { scaleX: [0, 1, 1, 0] } : { scaleX: 0 }}
                transition={{
                  delay: wordStart,
                  duration: 1.6,
                  times: [0, 0.45, 0.85, 1],
                  ease: [0.22, 0.61, 0.36, 1],
                }}
                style={{
                  position: "absolute",
                  left: 0,
                  right: 0,
                  bottom: "-6px",
                  height: 2,
                  background: "#111",
                  transformOrigin: "left center",
                  zIndex: 2,
                }}
              />

              {/* Sweeping light bar — passes left to right across word */}
              <motion.span
                aria-hidden="true"
                initial={{ x: "-20%", opacity: 0 }}
                animate={
                  phase >= 1
                    ? { x: "120%", opacity: [0, 1, 1, 0] }
                    : { x: "-20%", opacity: 0 }
                }
                transition={{
                  delay: wordStart + 0.1,
                  duration: 1.3,
                  times: [0, 0.2, 0.8, 1],
                  ease: [0.22, 0.61, 0.36, 1],
                }}
                style={{
                  position: "absolute",
                  top: "-8%",
                  bottom: "-8%",
                  left: 0,
                  width: 32,
                  background:
                    "linear-gradient(90deg, transparent, rgba(80,80,80,0.55), transparent)",
                  filter: "blur(8px)",
                  pointerEvents: "none",
                  zIndex: 3,
                }}
              />

              {/* Per-character slide-up reveal + post-entry pulse wrapper */}
              <motion.span
                animate={
                  phase >= 1
                    ? { scale: [1, 1.04, 1] }
                    : { scale: 1 }
                }
                transition={{
                  delay: pulseStart,
                  duration: 0.5,
                  ease: [0.22, 0.61, 0.36, 1],
                  times: [0, 0.4, 1],
                }}
                style={{ display: "inline-block" }}
              >
                {chars.map((c, j) => (
                  <span
                    key={j}
                    style={{
                      display: "inline-block",
                      overflow: "hidden",
                      verticalAlign: "bottom",
                      lineHeight: "81%",
                    }}
                  >
                    <motion.span
                      initial={{ y: "110%" }}
                      animate={phase >= 1 ? { y: "0%" } : { y: "110%" }}
                      transition={{
                        delay: wordStart + j * 0.055,
                        duration: 0.9,
                        ease: [0.22, 0.61, 0.36, 1],
                      }}
                      style={{ display: "inline-block" }}
                    >
                      {c === " " ? "\u00A0" : c}
                    </motion.span>
                  </span>
                ))}
              </motion.span>
            </motion.div>
          );
        })}
      </motion.div>

      {/* Section title — UNIST-style restrained */}
      <motion.h2
        initial={{ opacity: 0, y: 16 }}
        animate={phase >= 2 ? { opacity: 1, y: 0 } : { opacity: 0, y: 16 }}
        transition={{ duration: 0.8, ease: [0.22, 0.61, 0.36, 1] }}
        style={{
          position: "relative",
          zIndex: 1,
          textAlign: "center",
          fontFamily: "'Prompt', sans-serif",
          fontWeight: 700,
          fontSize: 28,
          letterSpacing: "0.56px",
          lineHeight: "30.8px",
          color: "#000",
          textTransform: "uppercase",
          margin: "0 0 20px",
          top: 16,
        }}
      >
        진수학 TODAY
      </motion.h2>

      {/* Black accent bar */}
      <div style={{ textAlign: "center", position: "relative", zIndex: 1, top: 16 }}>
        <motion.span
          initial={{ scaleX: 0 }}
          animate={phase >= 2 ? { scaleX: 1 } : { scaleX: 0 }}
          transition={{ delay: 0.35, duration: 0.6, ease: [0.22, 0.61, 0.36, 1] }}
          style={{
            display: "inline-block",
            width: 40,
            height: 3,
            borderRadius: 999,
            background: "#111",
            transformOrigin: "center",
          }}
        />
      </div>

      {/* Row 1 */}
      <div
        className="today-marquee-viewport"
        onMouseEnter={() => setPaused(true)}
        onMouseLeave={() => setPaused(false)}
        style={{
          position: "relative",
          zIndex: 1,
          overflow: "hidden",
          paddingTop: 39,
          paddingBottom: 39,
          opacity: phase >= 3 ? 1 : 0,
          transform: phase >= 3 ? "translateX(0)" : "translateX(60px)",
          transition: "opacity 0.3s ease, transform 1.6s ease",
        }}
      >
        <div
          className="today-marquee-track"
          style={{
            animationName: phase >= 4 ? "todayMarqueeL" : "none",
            animationDuration: "45s",
            animationTimingFunction: "linear",
            animationIterationCount: "infinite",
            animationPlayState: paused ? "paused" : "running",
            // Top row shifted left — visually "more forward" / further along in marquee
            marginLeft: -120,
          }}
        >
          {ROW1.map((item, i) => (
            <TodayCard key={`r1-${i}`} item={item} odd={i % 2 === 1} />
          ))}
        </div>
      </div>

      {/* Row 2 */}
      <div
        className="today-marquee-viewport"
        onMouseEnter={() => setPaused(true)}
        onMouseLeave={() => setPaused(false)}
        style={{
          position: "relative",
          zIndex: 1,
          overflow: "hidden",
          paddingLeft: 34,
          paddingTop: 39,
          paddingBottom: 39,
          top: -39,
          opacity: phase >= 3 ? 1 : 0,
          transform: phase >= 3 ? "translateX(0)" : "translateX(60px)",
          transition: "opacity 0.3s ease, transform 1.8s ease 0.2s",
        }}
      >
        <div
          className="today-marquee-track"
          style={{
            animationName: phase >= 4 ? "todayMarqueeL" : "none",
            animationDuration: "45s",
            animationTimingFunction: "linear",
            animationIterationCount: "infinite",
            animationPlayState: paused ? "paused" : "running",
            // Bottom row shifted right — visually "more backward" / behind the top row
            marginLeft: 160,
          }}
        >
          {ROW2.map((item, i) => (
            <TodayCard key={`r2-${i}`} item={item} odd={i % 2 === 1} />
          ))}
        </div>
      </div>
    </section>
  );
}
