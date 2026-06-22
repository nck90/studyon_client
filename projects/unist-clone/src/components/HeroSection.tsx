"use client";

import { useEffect, useRef } from "react";
import { motion, useMotionValue, useScroll, useSpring, useTransform, MotionValue } from "framer-motion";
import { MagneticLink } from "./MagneticLink";

const MATH_SYMBOLS = [
  { symbol: "∑", top: "15%", left: "8%",  size: 88, dur: 7,   delay: 0 },
  { symbol: "∫", top: "25%", right: "10%", size: 96, dur: 9,   delay: 1 },
  { symbol: "π", top: "60%", left: "5%",   size: 76, dur: 8,   delay: 2 },
  { symbol: "√", top: "70%", right: "8%",  size: 80, dur: 10,  delay: 0.5 },
  { symbol: "∞", top: "10%", right: "25%", size: 70, dur: 6,   delay: 3 },
  { symbol: "θ", top: "80%", left: "25%",  size: 64, dur: 7.5, delay: 1.5 },
  { symbol: "Δ", top: "40%", left: "3%",   size: 60, dur: 11,  delay: 2.5 },
  { symbol: "≈", top: "20%", left: "40%",  size: 54, dur: 8.5, delay: 4 },
];

const headline = "수학의 본질을";
const emphasis = "꿰뚫는 힘";

const charVariants = {
  hidden: { y: "110%", opacity: 0 },
  show: (i: number) => ({
    y: 0,
    opacity: 1,
    transition: {
      delay: 0.4 + i * 0.045,
      duration: 0.85,
      ease: [0.22, 0.61, 0.36, 1] as const,
    },
  }),
};

export function HeroSection() {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start start", "end start"],
  });

  const rawY = useTransform(scrollYProgress, [0, 1], [0, 180]);
  const y = useSpring(rawY, { stiffness: 120, damping: 28, mass: 0.5 });
  const fade = useTransform(scrollYProgress, [0, 0.7], [1, 0]);
  const blur = useTransform(scrollYProgress, [0, 1], [0, 8]);
  const filter = useTransform(blur, (v) => `blur(${v}px)`);

  // Hero content dramatically grows + drifts up as user scrolls (cinema feel)
  const contentScale = useTransform(scrollYProgress, [0, 0.6], [1, 1.18]);
  const contentY = useTransform(scrollYProgress, [0, 0.6], [0, -60]);

  // Mouse-tracking spotlight
  const spotX = useMotionValue(0.5);
  const spotY = useMotionValue(0.5);
  const sx = useSpring(spotX, { stiffness: 90, damping: 20, mass: 0.6 });
  const sy = useSpring(spotY, { stiffness: 90, damping: 20, mass: 0.6 });
  const spotBg = useTransform(
    [sx, sy] as [MotionValue<number>, MotionValue<number>],
    ([x, y]) =>
      `radial-gradient(620px circle at ${(x as number) * 100}% ${(y as number) * 100}%, rgba(255,255,255,0.1), transparent 60%)`
  );

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const onMove = (e: MouseEvent) => {
      const rect = el.getBoundingClientRect();
      spotX.set((e.clientX - rect.left) / rect.width);
      spotY.set((e.clientY - rect.top) / rect.height);
    };
    const onLeave = () => {
      spotX.set(0.5);
      spotY.set(0.5);
    };
    el.addEventListener("mousemove", onMove);
    el.addEventListener("mouseleave", onLeave);
    return () => {
      el.removeEventListener("mousemove", onMove);
      el.removeEventListener("mouseleave", onLeave);
    };
  }, [spotX, spotY]);

  return (
    <div
      ref={ref}
      data-snap="start"
      style={{
        position: "relative",
        width: "100%",
        height: "100vh",
        overflow: "hidden",
        background: "#000",
        zIndex: 1,
      }}
    >
      <style
        dangerouslySetInnerHTML={{
          __html: `
            @keyframes heroGridDrift {
              0%   { transform: translate3d(0, 0, 0); }
              100% { transform: translate3d(-80px, -80px, 0); }
            }
            @keyframes heroSymbolFloat {
              0%, 100% { transform: translate3d(0, 0, 0) rotate(0deg); }
              50%      { transform: translate3d(0, -28px, 0) rotate(8deg); }
            }
            @keyframes heroRingPulse {
              0%, 100% { opacity: 0.06; transform: translate(-50%, -50%) scale(1); }
              50%      { opacity: 0.16; transform: translate(-50%, -50%) scale(1.06); }
            }
            @keyframes heroScrollLine {
              0%   { transform: scaleY(0); }
              40%  { transform: scaleY(1); }
              100% { transform: scaleY(0); }
            }
            @keyframes heroTicker {
              0%   { transform: translate3d(0, 0, 0); }
              100% { transform: translate3d(-50%, 0, 0); }
            }
            @media (max-width: 768px) {
              .jm-hero-side-label { display: none !important; }
              .jm-hero-corner { display: none !important; }
              .jm-hero-ticker { bottom: 100px !important; }
              .jm-hero-scroll { padding-bottom: 24px !important; }
            }
          `,
        }}
      />

      {/* Grid background (drifting) */}
      <motion.div
        aria-hidden="true"
        style={{
          position: "absolute",
          inset: -80,
          backgroundImage: `
            linear-gradient(rgba(255,255,255,0.05) 1px, transparent 1px),
            linear-gradient(90deg, rgba(255,255,255,0.05) 1px, transparent 1px)
          `,
          backgroundSize: "80px 80px",
          zIndex: 1,
          animation: "heroGridDrift 28s linear infinite",
          y,
          opacity: fade,
        }}
      />

      {/* Concentric rings */}
      <div
        aria-hidden="true"
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          width: "90vh",
          height: "90vh",
          borderRadius: "50%",
          border: "1px solid rgba(255,255,255,0.12)",
          zIndex: 1,
          animation: "heroRingPulse 6s ease-in-out infinite",
        }}
      />
      <div
        aria-hidden="true"
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          width: "70vh",
          height: "70vh",
          borderRadius: "50%",
          border: "1px solid rgba(255,255,255,0.08)",
          zIndex: 1,
          animation: "heroRingPulse 8s ease-in-out infinite 1s",
        }}
      />

      {/* Floating math symbols */}
      {MATH_SYMBOLS.map((s, i) => (
        <motion.div
          key={i}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6 + i * 0.08, duration: 1.2 }}
          style={{
            position: "absolute",
            top: s.top,
            left: s.left,
            right: s.right,
            fontSize: s.size,
            fontWeight: 900,
            color: "rgba(255,255,255,0.09)",
            fontFamily: "'Prompt', serif",
            zIndex: 1,
            pointerEvents: "none",
            userSelect: "none",
            animation: `heroSymbolFloat ${s.dur}s ease-in-out infinite ${s.delay}s`,
          }}
        >
          {s.symbol}
        </motion.div>
      ))}

      {/* Vignette */}
      <motion.div
        aria-hidden="true"
        style={{
          position: "absolute",
          inset: 0,
          background: "radial-gradient(ellipse at center, transparent 20%, rgba(0,0,0,0.8) 100%)",
          zIndex: 2,
          opacity: fade,
        }}
      />

      {/* Mouse-following spotlight */}
      <motion.div
        aria-hidden="true"
        style={{
          position: "absolute",
          inset: 0,
          background: spotBg,
          zIndex: 3,
          pointerEvents: "none",
          mixBlendMode: "screen",
        }}
      />

      {/* Rotated side label — left */}
      <div
        aria-hidden="true"
        className="jm-hero-side-label"
        style={{
          position: "absolute",
          left: 28,
          top: "50%",
          transform: "translateY(-50%) rotate(-90deg)",
          transformOrigin: "left center",
          zIndex: 5,
          fontFamily: "'Prompt', sans-serif",
          fontSize: 10,
          fontWeight: 700,
          letterSpacing: "5px",
          color: "rgba(255,255,255,0.45)",
          textTransform: "uppercase",
          whiteSpace: "nowrap",
          display: "flex",
          alignItems: "center",
          gap: 12,
        }}
      >
        <span style={{ width: 30, height: 1, background: "rgba(255,255,255,0.3)" }} />
        Scholastic Mathematics · Seoul
      </div>

      {/* Rotated side label — right */}
      <div
        aria-hidden="true"
        className="jm-hero-side-label"
        style={{
          position: "absolute",
          right: 28,
          top: "50%",
          transform: "translateY(-50%) rotate(90deg)",
          transformOrigin: "right center",
          zIndex: 5,
          fontFamily: "'Prompt', sans-serif",
          fontSize: 10,
          fontWeight: 700,
          letterSpacing: "5px",
          color: "rgba(255,255,255,0.45)",
          textTransform: "uppercase",
          whiteSpace: "nowrap",
          display: "flex",
          alignItems: "center",
          gap: 12,
        }}
      >
        Est MMX · V 1.0 · Live
        <span style={{ width: 30, height: 1, background: "rgba(255,255,255,0.3)" }} />
      </div>

      {/* Hero content */}
      <motion.div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          translateX: "-50%",
          translateY: "-50%",
          zIndex: 5,
          textAlign: "center",
          width: "100%",
          padding: "0 24px",
          opacity: fade,
          filter,
          scale: contentScale,
          y: contentY,
        }}
      >
        {/* Eyebrow */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.25, duration: 0.8, ease: [0.22, 0.61, 0.36, 1] }}
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 10,
            padding: "7px 20px",
            borderRadius: 999,
            border: "1px solid rgba(255,255,255,0.25)",
            background: "rgba(255,255,255,0.04)",
            backdropFilter: "blur(12px)",
            WebkitBackdropFilter: "blur(12px)",
            marginBottom: 32,
          }}
        >
          <motion.span
            animate={{ opacity: [1, 0.3, 1] }}
            transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            style={{
              width: 6,
              height: 6,
              borderRadius: "50%",
              background: "#fff",
              display: "inline-block",
            }}
          />
          <span
            style={{
              color: "#fff",
              fontSize: 12,
              fontWeight: 600,
              letterSpacing: "3px",
              textTransform: "uppercase",
            }}
          >
            Premium Math Academy
          </span>
        </motion.div>

        {/* Headline with character-by-character reveal */}
        <h1
          style={{
            fontFamily: "Pretendard, sans-serif",
            fontWeight: 900,
            fontSize: "clamp(48px, 8vw, 112px)",
            lineHeight: 1.03,
            letterSpacing: "-3.5px",
            color: "#fff",
            marginBottom: 28,
          }}
        >
          <span style={{ display: "block", overflow: "hidden", paddingBottom: 8 }}>
            {headline.split("").map((c, i) => (
              <motion.span
                key={`h1-${i}`}
                custom={i}
                variants={charVariants}
                initial="hidden"
                animate="show"
                style={{ display: "inline-block", whiteSpace: "pre" }}
              >
                {c}
              </motion.span>
            ))}
          </span>
          <span style={{ display: "inline-block", overflow: "hidden", paddingBottom: 10, position: "relative" }}>
            {emphasis.split("").map((c, i) => (
              <motion.span
                key={`h2-${i}`}
                custom={i + headline.length}
                variants={charVariants}
                initial="hidden"
                animate="show"
                style={{ display: "inline-block", whiteSpace: "pre", color: "#fff" }}
              >
                {c}
              </motion.span>
            ))}
            <motion.span
              initial={{ scaleX: 0 }}
              animate={{ scaleX: 1 }}
              transition={{
                delay: 0.4 + (headline.length + emphasis.length) * 0.045 + 0.4,
                duration: 1.1,
                ease: [0.22, 0.61, 0.36, 1],
              }}
              style={{
                position: "absolute",
                left: 0,
                right: 0,
                bottom: 0,
                height: 2,
                background: "#fff",
                transformOrigin: "left center",
              }}
            />
          </span>
        </h1>

        {/* Subtitle */}
        <motion.p
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1.2, duration: 0.7, ease: [0.22, 0.61, 0.36, 1] }}
          style={{
            color: "rgba(255,255,255,0.55)",
            fontSize: "clamp(15px, 1.5vw, 19px)",
            fontWeight: 400,
            letterSpacing: "1.5px",
            marginBottom: 48,
          }}
        >
          진수학전문학원 &nbsp;·&nbsp; 내신 · 수능 · 경시대회
        </motion.p>

        {/* CTA */}
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1.45, duration: 0.7, ease: [0.22, 0.61, 0.36, 1] }}
          style={{ display: "flex", gap: 14, justifyContent: "center", flexWrap: "wrap" }}
        >
          <MagneticCta primary>상담 신청하기</MagneticCta>
          <MagneticCta>커리큘럼 보기</MagneticCta>
        </motion.div>
      </motion.div>

      {/* Corner signature — top left */}
      <motion.div
        className="jm-hero-corner"
        initial={{ opacity: 0, x: -8 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ delay: 0.9, duration: 0.8 }}
        style={{
          position: "absolute",
          top: 32,
          left: 40,
          zIndex: 5,
          color: "rgba(255,255,255,0.5)",
          fontFamily: "'Prompt', sans-serif",
          fontSize: 11,
          fontWeight: 700,
          letterSpacing: "3px",
          textTransform: "uppercase",
          display: "flex",
          alignItems: "center",
          gap: 10,
          opacity: fade,
        }}
      >
        <span style={{ width: 24, height: 1, background: "rgba(255,255,255,0.4)" }} />
        EST. 2010 · TRUE MATH
      </motion.div>

      {/* Corner marker — top right index */}
      <motion.div
        className="jm-hero-corner"
        initial={{ opacity: 0, x: 8 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ delay: 0.9, duration: 0.8 }}
        style={{
          position: "absolute",
          top: 32,
          right: 40,
          zIndex: 5,
          color: "rgba(255,255,255,0.5)",
          fontFamily: "'Prompt', sans-serif",
          fontSize: 11,
          fontWeight: 700,
          letterSpacing: "3px",
          textTransform: "uppercase",
          display: "flex",
          alignItems: "center",
          gap: 10,
          opacity: fade,
        }}
      >
        00 / 06 · HERO
        <span style={{ width: 24, height: 1, background: "rgba(255,255,255,0.4)" }} />
      </motion.div>

      {/* Bottom ticker marquee */}
      <motion.div
        className="jm-hero-ticker"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.8, duration: 0.8 }}
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          bottom: 140,
          zIndex: 4,
          overflow: "hidden",
          opacity: fade,
          borderTop: "1px solid rgba(255,255,255,0.15)",
          borderBottom: "1px solid rgba(255,255,255,0.15)",
          padding: "14px 0",
        }}
      >
        <div
          style={{
            display: "flex",
            gap: 60,
            width: "max-content",
            animation: "heroTicker 38s linear infinite",
            willChange: "transform",
          }}
        >
          {Array.from({ length: 10 }).map((_, i) => (
            <span
              key={i}
              style={{
                display: "inline-flex",
                alignItems: "center",
                gap: 60,
                fontFamily: "'Prompt', sans-serif",
                fontSize: 13,
                fontWeight: 700,
                letterSpacing: "3px",
                color: "rgba(255,255,255,0.6)",
                textTransform: "uppercase",
                whiteSpace: "nowrap",
              }}
            >
              <span>진수학</span>
              <span style={{ opacity: 0.4 }}>✦</span>
              <span>TRUE MATH ACADEMY</span>
              <span style={{ opacity: 0.4 }}>✦</span>
              <span>EST. 2010</span>
              <span style={{ opacity: 0.4 }}>✦</span>
              <span>내신 · 수능 · 경시</span>
              <span style={{ opacity: 0.4 }}>✦</span>
            </span>
          ))}
        </div>
      </motion.div>

      {/* Scroll indicator — bottom */}
      <motion.div
        className="jm-hero-scroll"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.8, duration: 0.8 }}
        style={{
          position: "absolute",
          bottom: 0,
          left: 0,
          right: 0,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          paddingBottom: 48,
          zIndex: 5,
          opacity: fade,
        }}
      >
        <span
          style={{
            color: "rgba(255,255,255,0.55)",
            fontFamily: "'Prompt', sans-serif",
            fontSize: 10,
            letterSpacing: 4,
            fontWeight: 700,
            marginBottom: 14,
          }}
        >
          SCROLL
        </span>
        <div
          style={{
            position: "relative",
            width: 1,
            height: 56,
            background: "rgba(255,255,255,0.2)",
            overflow: "hidden",
          }}
        >
          <div
            style={{
              position: "absolute",
              inset: 0,
              background: "#fff",
              transformOrigin: "top",
              animation: "heroScrollLine 2.4s ease-in-out infinite",
            }}
          />
        </div>
      </motion.div>
    </div>
  );
}

function MagneticCta({ children, primary = false }: { children: React.ReactNode; primary?: boolean }) {
  return (
    <MagneticLink
      href="#"
      strength={0.3}
      style={{
        display: "inline-flex",
        alignItems: "center",
        gap: 10,
        padding: "17px 34px",
        borderRadius: 999,
        background: primary ? "#fff" : "transparent",
        color: primary ? "#111" : "#fff",
        border: primary ? "1px solid #fff" : "1px solid rgba(255,255,255,0.35)",
        fontSize: 14,
        fontWeight: 700,
        letterSpacing: "0.8px",
        textDecoration: "none",
        overflow: "hidden",
        position: "relative",
      }}
    >
      <span style={{ position: "relative", zIndex: 2 }}>{children}</span>
      <motion.span
        style={{ display: "inline-flex", position: "relative", zIndex: 2 }}
        animate={{ x: [0, 4, 0] }}
        transition={{ duration: 1.8, repeat: Infinity, ease: "easeInOut" }}
      >
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M5 12h14M12 5l7 7-7 7" />
        </svg>
      </motion.span>
    </MagneticLink>
  );
}
