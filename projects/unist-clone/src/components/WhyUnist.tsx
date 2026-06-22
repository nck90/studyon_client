"use client";

import Image from "next/image";
import { useRef, useState } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import { TiltCard } from "./TiltCard";

type CardIcon = () => React.ReactElement;

const IconCrown: CardIcon = () => (
  <svg width="42" height="42" viewBox="0 0 48 48" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round">
    <path d="M6 36L4 16l10 8 10-16 10 16 10-8-2 20z" />
    <path d="M6 36h36" />
  </svg>
);

const IconMentor: CardIcon = () => (
  <svg width="42" height="42" viewBox="0 0 48 48" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round">
    <circle cx="16" cy="18" r="6" />
    <circle cx="32" cy="18" r="6" />
    <path d="M6 40c0-6 5-10 10-10s10 4 10 10" />
    <path d="M22 40c0-6 5-10 10-10s10 4 10 10" />
  </svg>
);

const IconTrophy: CardIcon = () => (
  <svg width="42" height="42" viewBox="0 0 48 48" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round">
    <path d="M14 6h20v10a10 10 0 01-20 0V6z" />
    <path d="M14 10H8a4 4 0 004 4h2M34 10h6a4 4 0 01-4 4h-2" />
    <path d="M20 32h8v6h-8zM16 42h16" />
  </svg>
);

const IconBuilding: CardIcon = () => (
  <svg width="42" height="42" viewBox="0 0 48 48" fill="none" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round">
    <path d="M10 42V10l14-4v36M24 42V16l14 4v22" />
    <path d="M6 42h36" />
    <path d="M14 16h4M14 22h4M14 28h4M14 34h4M30 24h4M30 30h4M30 36h4" />
  </svg>
);

const CARDS = [
  { tag: "명품 강사진",  title: "TOP\nFACULTY",       subtitle: "SKY 출신 수학 전문 강사진",   image: "/images/main/experience-01-01.png", Icon: IconCrown },
  { tag: "맞춤 관리",    title: "PERSONAL\nMENTORING", subtitle: "학생별 수준 맞춤 학습",       image: "/images/main/experience-01-02.png", Icon: IconMentor },
  { tag: "검증된 실적",  title: "PROVEN\nRESULTS",     subtitle: "매년 수능 만점자 배출",       image: "/images/main/experience-01-03.png", Icon: IconTrophy },
  { tag: "학습 환경",    title: "STUDY\nSPACE",        subtitle: "하이퍼관 프리미엄 공간",      image: "/images/main/experience-01-04.png", Icon: IconBuilding },
];

export function WhyUnist() {
  const sectionRef = useRef<HTMLElement>(null);
  const [hovered, setHovered] = useState<number | null>(null);

  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ["start end", "end start"],
  });

  // Giant background word: drifts horizontally as user scrolls through the section
  const wmX = useTransform(scrollYProgress, [0, 1], ["-6%", "6%"]);
  const wmOpacity = useTransform(scrollYProgress, [0, 0.2, 0.8, 1], [0, 1, 1, 0.4]);

  return (
    <section
      ref={sectionRef}
      className="jm-why-section"
      style={{
        position: "relative",
        background: "#fff",
        padding: "150px 0 170px",
        overflow: "hidden",
      }}
    >
      <style dangerouslySetInnerHTML={{ __html: `
        @media (max-width: 768px) {
          .jm-why-section { padding: 80px 0 100px !important; }
          .jm-why-container { padding: 0 16px !important; }
          .jm-why-cards {
            flex-direction: column !important;
            gap: 16px !important;
            align-items: stretch !important;
          }
          .jm-why-card {
            height: 360px !important;
            width: 100% !important;
            margin-top: 0 !important;
            flex: none !important;
            /* Force-visible on mobile — whileInView + initial:opacity-0 can stay hidden if observer misses */
            opacity: 1 !important;
            transform: none !important;
            filter: none !important;
          }
        }
      ` }} />
      {/* Eyebrow label */}
      <motion.div
        initial={{ opacity: 0, y: 16 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: "-100px" }}
        transition={{ duration: 0.7, ease: [0.22, 0.61, 0.36, 1] }}
        style={{ textAlign: "center", marginBottom: 18 }}
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
            margin: 0,
          }}
        >
          WHY 진수학
        </h2>
      </motion.div>

      <motion.div
        initial={{ scale: 0, rotate: -45, opacity: 0 }}
        whileInView={{ scale: 1, rotate: 0, opacity: 1 }}
        viewport={{ once: true, margin: "-100px" }}
        transition={{ delay: 0.25, duration: 0.7, ease: [0.22, 0.61, 0.36, 1] }}
        style={{ display: "flex", justifyContent: "center", marginBottom: 40 }}
      >
        <svg width="14" height="14" viewBox="0 0 20 20" fill="#111">
          <path d="M10 0L12.5 7.5L20 10L12.5 12.5L10 20L7.5 12.5L0 10L7.5 7.5L10 0Z" />
        </svg>
      </motion.div>

      {/* Giant parallax watermark — sits behind cards */}
      <motion.div
        aria-hidden="true"
        style={{
          position: "absolute",
          top: "44%",
          left: 0,
          right: 0,
          textAlign: "center",
          fontFamily: "'Prompt', sans-serif",
          fontWeight: 900,
          fontSize: "clamp(160px, 20vw, 320px)",
          color: "transparent",
          WebkitTextStroke: "1.2px #E8E8E8",
          letterSpacing: "-8px",
          userSelect: "none",
          pointerEvents: "none",
          zIndex: 0,
          x: wmX,
          opacity: wmOpacity,
          lineHeight: 0.9,
          whiteSpace: "nowrap",
        }}
      >
        TRUE MATH
      </motion.div>

      {/* 4 portrait cards — zigzag heights, horizontal expand on hover */}
      <div
        className="jm-why-container"
        style={{
          position: "relative",
          zIndex: 1,
          maxWidth: 1528,
          margin: "0 auto",
          padding: "0 40px",
        }}
      >
        <div
          className="jm-why-cards"
          style={{
            display: "flex",
            gap: 16,
            alignItems: "flex-start",
          }}
        >
          {CARDS.map((card, i) => {
            const isOdd = i % 2 === 1;
            // All cards same size; gentle zigzag position only
            const height = 540;
            const offset = isOdd ? 40 : 0;
            const flex =
              hovered === null
                ? 1
                : hovered === i
                ? 2.6
                : 0.72;
            return (
              <ZigzagCard
                key={i}
                card={card}
                index={i}
                height={height}
                offset={offset}
                flex={flex}
                onEnter={() => setHovered(i)}
                onLeave={() => setHovered(null)}
                active={hovered === i}
              />
            );
          })}
        </div>
      </div>
    </section>
  );
}

type CardData = typeof CARDS[0];

function ZigzagCard({
  card,
  index,
  height,
  offset,
  flex,
  active,
  onEnter,
  onLeave,
}: {
  card: CardData;
  index: number;
  height: number;
  offset: number;
  flex: number;
  active: boolean;
  onEnter: () => void;
  onLeave: () => void;
}) {
  return (
    <motion.a
      href="#"
      className="jm-why-card"
      onMouseEnter={onEnter}
      onMouseLeave={onLeave}
      initial={{ opacity: 0, y: 100, filter: "blur(8px)" }}
      whileInView={{ opacity: 1, y: 0, filter: "blur(0px)" }}
      viewport={{ once: true, margin: "-80px" }}
      animate={{ flex }}
      transition={{
        opacity:     { delay: index * 0.12, duration: 1.0, ease: [0.22, 0.61, 0.36, 1] },
        y:           { delay: index * 0.12, duration: 1.0, ease: [0.22, 0.61, 0.36, 1] },
        filter:      { delay: index * 0.12, duration: 1.0, ease: [0.22, 0.61, 0.36, 1] },
        flex:        { duration: 0.7, ease: [0.22, 0.61, 0.36, 1] },
      }}
      style={{
        position: "relative",
        display: "block",
        height,
        marginTop: offset,
        borderRadius: 20,
        overflow: "hidden",
        background: "#111",
        textDecoration: "none",
        cursor: "pointer",
        flexBasis: 0,
        flexGrow: flex,
        flexShrink: 0,
        transformStyle: "preserve-3d",
        perspective: 1200,
      }}
    >
      {/* Background image with scale on hover */}
      <motion.div
        animate={{ scale: active ? 1.1 : 1 }}
        transition={{ duration: 0.9, ease: [0.22, 0.61, 0.36, 1] }}
        style={{ position: "absolute", inset: 0 }}
      >
        <Image
          src={card.image}
          alt={card.subtitle}
          fill
          sizes="(max-width: 1024px) 50vw, 25vw"
          style={{ objectFit: "cover" }}
        />
      </motion.div>

      {/* Dark gradient overlay */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          background:
            "linear-gradient(180deg, rgba(0,0,0,0.1) 0%, rgba(0,0,0,0.05) 30%, rgba(0,0,0,0.5) 65%, rgba(0,0,0,0.95) 100%)",
          zIndex: 1,
        }}
      />

      {/* Tag pill — top center */}
      <div
        style={{
          position: "absolute",
          top: 24,
          left: "50%",
          transform: "translateX(-50%)",
          zIndex: 3,
          whiteSpace: "nowrap",
        }}
      >
        <motion.span
          animate={{ background: active ? "#fff" : "#fff", scale: active ? 1.04 : 1 }}
          transition={{ duration: 0.4 }}
          style={{
            display: "inline-flex",
            alignItems: "center",
            padding: "7px 16px",
            borderRadius: 999,
            color: "#111",
            fontSize: 12,
            fontWeight: 700,
            letterSpacing: "-0.2px",
          }}
        >
          {card.tag}
        </motion.span>
      </div>

      {/* Number index — top right corner */}
      <div
        style={{
          position: "absolute",
          top: 22,
          right: 22,
          zIndex: 3,
          fontFamily: "'Prompt', sans-serif",
          fontWeight: 700,
          fontSize: 12,
          letterSpacing: "2.5px",
          color: "rgba(255,255,255,0.7)",
        }}
      >
        0{index + 1}
      </div>

      {/* Top progress stroke on hover */}
      <motion.div
        animate={{ scaleX: active ? 1 : 0 }}
        transition={{ duration: 0.55, ease: [0.22, 0.61, 0.36, 1] }}
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: 3,
          background: "#fff",
          zIndex: 4,
          transformOrigin: "left center",
        }}
      />

      {/* Bottom content */}
      <div
        style={{
          position: "absolute",
          left: 0,
          right: 0,
          bottom: 0,
          padding: "32px 26px 34px",
          zIndex: 2,
          color: "#fff",
        }}
      >
        <motion.div
          animate={{ y: active ? -4 : 0, opacity: active ? 1 : 0.92 }}
          transition={{ duration: 0.4, ease: [0.22, 0.61, 0.36, 1] }}
          style={{ marginBottom: 16 }}
        >
          <card.Icon />
        </motion.div>

        <h3
          style={{
            fontFamily: "'Prompt', sans-serif",
            fontSize: "clamp(22px, 2vw, 32px)",
            fontWeight: 800,
            lineHeight: 1.02,
            letterSpacing: "-1px",
            whiteSpace: "pre-line",
            margin: "0 0 10px",
            textTransform: "uppercase",
          }}
        >
          {card.title}
        </h3>

        <motion.p
          animate={{ opacity: active ? 1 : 0.75, y: active ? 0 : 2 }}
          transition={{ duration: 0.35 }}
          style={{
            fontSize: 13,
            fontWeight: 500,
            lineHeight: 1.5,
            letterSpacing: "-0.2px",
            margin: 0,
          }}
        >
          {card.subtitle}
        </motion.p>

        {/* Arrow — appears on hover */}
        <motion.div
          animate={{ opacity: active ? 1 : 0, x: active ? 0 : -6 }}
          transition={{ duration: 0.4 }}
          style={{
            marginTop: 18,
            display: "inline-flex",
            alignItems: "center",
            gap: 8,
            color: "#fff",
            fontSize: 11,
            fontWeight: 700,
            letterSpacing: "1.5px",
            textTransform: "uppercase",
          }}
        >
          Read More
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M5 12h14M12 5l7 7-7 7" />
          </svg>
        </motion.div>
      </div>
    </motion.a>
  );
}
