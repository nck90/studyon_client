"use client";

import Image from "next/image";
import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";
import { TiltCard } from "./TiltCard";

const LIFE_CARDS = [
  {
    tag: "강의실",
    title: "1:1 맞춤 수업",
    subtitle: "소수정예 프리미엄 강의로 학생 한 명 한 명의 실력을 끌어올립니다.",
    image: "/images/main/insight01.png",
    href: "#",
    no: "01",
  },
  {
    tag: "자습실",
    title: "24시간 자습 공간",
    subtitle: "언제든 몰입할 수 있는 쾌적한 학습 환경을 제공합니다.",
    image: "/images/main/insight02.png",
    href: "#",
    no: "02",
  },
  {
    tag: "상담실",
    title: "학부모 상담",
    subtitle: "매월 정기 학습 상담으로 성장 과정을 투명하게 공유합니다.",
    image: "/images/main/insight03.png",
    href: "#",
    no: "03",
  },
  {
    tag: "라운지",
    title: "학생 휴게공간",
    subtitle: "집중과 휴식의 균형을 돕는 편안한 쉼터.",
    image: "/images/main/insight04.png",
    href: "#",
    no: "04",
  },
  {
    tag: "프리미엄관",
    title: "하이퍼 스터디룸",
    subtitle: "소음 차단 개별 부스와 스튜디오 급 책상.",
    image: "/images/main/insight05.png",
    href: "#",
    no: "05",
  },
];

// Distribute into 2 columns, varying heights for masonry rhythm.
// `floatSpeed` controls how much each card drifts upward as the page scrolls —
// higher speed = card rises faster than the surrounding content (layered parallax).
const LEFT_COL = [
  { card: LIFE_CARDS[0], height: 540, floatSpeed: 0.9 },
  { card: LIFE_CARDS[2], height: 600, floatSpeed: 1.25 },
  { card: LIFE_CARDS[4], height: 480, floatSpeed: 0.8 },
];
const RIGHT_COL = [
  { card: LIFE_CARDS[1], height: 620, floatSpeed: 1.1 },
  { card: LIFE_CARDS[3], height: 460, floatSpeed: 1.35 },
];

export function LifeAtUnist() {
  const sectionRef = useRef<HTMLElement>(null);

  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ["start end", "end start"],
  });
  const wmX = useTransform(scrollYProgress, [0, 1], ["8%", "-12%"]);
  const wmOpacity = useTransform(scrollYProgress, [0, 0.2, 0.8, 1], [0, 1, 1, 0.5]);

  return (
    <section
      ref={sectionRef}
      className="jm-life-section"
      style={{
        position: "relative",
        background: "#F7F7F7",
        padding: "140px 0 180px",
        overflow: "hidden",
      }}
    >
      <style dangerouslySetInnerHTML={{ __html: `
        @media (max-width: 768px) {
          .jm-life-section { padding: 80px 0 100px !important; }
          .jm-life-grid {
            grid-template-columns: 1fr !important;
            padding: 0 16px !important;
            gap: 20px !important;
          }
          .jm-life-col-right { margin-top: 0 !important; }
        }
      ` }} />
      {/* Giant background watermark */}
      <motion.div
        aria-hidden="true"
        style={{
          position: "absolute",
          top: "30%",
          left: 0,
          right: 0,
          textAlign: "center",
          fontFamily: "'Prompt', sans-serif",
          fontWeight: 900,
          fontSize: "clamp(160px, 22vw, 340px)",
          color: "transparent",
          WebkitTextStroke: "1.4px rgba(0,0,0,0.08)",
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
        LIFE
      </motion.div>

      {/* Title block */}
      <motion.div
        initial={{ opacity: 0, y: 24 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: "-100px" }}
        transition={{ duration: 0.8, ease: [0.22, 0.61, 0.36, 1] }}
        style={{
          position: "relative",
          zIndex: 1,
          textAlign: "center",
          marginBottom: 72,
        }}
      >
        <p
          style={{
            fontFamily: "'Prompt', sans-serif",
            fontSize: 11,
            fontWeight: 700,
            letterSpacing: "3px",
            color: "#666",
            textTransform: "uppercase",
            marginBottom: 14,
          }}
        >
          06 · Life at 진수학
        </p>
        <h2
          style={{
            fontFamily: "'Prompt', sans-serif",
            fontWeight: 700,
            fontSize: 28,
            letterSpacing: "0.56px",
            lineHeight: "30.8px",
            color: "#111",
            textTransform: "uppercase",
            margin: "0 0 18px",
          }}
        >
          Scenes from the studio
        </h2>
        <motion.span
          initial={{ scaleX: 0 }}
          whileInView={{ scaleX: 1 }}
          viewport={{ once: true, margin: "-80px" }}
          transition={{ delay: 0.25, duration: 0.6 }}
          style={{
            display: "inline-block",
            width: 40,
            height: 3,
            borderRadius: 999,
            background: "#111",
            transformOrigin: "center",
          }}
        />
      </motion.div>

      {/* 2-column staggered grid */}
      <div
        className="jm-life-grid"
        style={{
          position: "relative",
          zIndex: 1,
          maxWidth: 1280,
          margin: "0 auto",
          padding: "0 60px",
          display: "grid",
          gridTemplateColumns: "1fr 1fr",
          gap: 32,
          alignItems: "start",
        }}
      >
        {/* Left column */}
        <div style={{ display: "flex", flexDirection: "column", gap: 32 }}>
          {LEFT_COL.map(({ card, height, floatSpeed }) => (
            <MasonryCard key={card.no} card={card} height={height} floatSpeed={floatSpeed} />
          ))}
        </div>

        {/* Right column — offset down for stagger */}
        <div className="jm-life-col-right" style={{ display: "flex", flexDirection: "column", gap: 32, marginTop: 120 }}>
          {RIGHT_COL.map(({ card, height, floatSpeed }) => (
            <MasonryCard key={card.no} card={card} height={height} floatSpeed={floatSpeed} />
          ))}
        </div>
      </div>
    </section>
  );
}

type LifeCardData = typeof LIFE_CARDS[0];

function MasonryCard({
  card,
  height,
  floatSpeed,
}: {
  card: LifeCardData;
  height: number;
  floatSpeed: number;
}) {
  const cardRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: cardRef,
    offset: ["start end", "end start"],
  });
  // Scroll-linked rise: card drifts upward as user scrolls past it (layered parallax).
  // Cards are visible from the start — no fade-in.
  const lift = useTransform(
    scrollYProgress,
    [0, 1],
    [80 * floatSpeed, -100 * floatSpeed],
  );
  // Image parallax within card — opposite direction for depth
  const imgY = useTransform(scrollYProgress, [0, 1], ["-12%", "12%"]);

  return (
    <motion.div
      ref={cardRef}
      style={{ y: lift, willChange: "transform" }}
    >
      <TiltCard
        max={7}
        perspective={1100}
        scale={1.02}
        style={{ width: "100%", height, willChange: "transform" }}
      >
        <motion.a
          href={card.href}
          whileHover="hover"
          animate="rest"
          variants={{ rest: {}, hover: {} }}
          style={{
            position: "relative",
            display: "block",
            width: "100%",
            height: "100%",
            borderRadius: 20,
            overflow: "hidden",
            background: "#111",
            textDecoration: "none",
            cursor: "pointer",
          }}
        >
          <motion.div
            variants={{ rest: { scale: 1 }, hover: { scale: 1.08 } }}
            transition={{ duration: 1.0, ease: [0.22, 0.61, 0.36, 1] }}
            style={{ position: "absolute", inset: "-12% 0" }}
          >
            <motion.div style={{ position: "absolute", inset: 0, y: imgY }}>
              <Image
                src={card.image}
                alt={card.title}
                fill
                sizes="(max-width: 1024px) 100vw, 50vw"
                style={{ objectFit: "cover" }}
              />
            </motion.div>
          </motion.div>

          <motion.div
            variants={{ rest: { opacity: 0.8 }, hover: { opacity: 1 } }}
            transition={{ duration: 0.5 }}
            style={{
              position: "absolute",
              inset: 0,
              background:
                "linear-gradient(0deg, rgba(0,0,0,0.92) 0%, rgba(0,0,0,0.25) 55%, rgba(0,0,0,0.1) 100%)",
              zIndex: 1,
            }}
          />

          <div
            style={{
              position: "absolute",
              top: 28,
              left: 32,
              zIndex: 2,
              color: "rgba(255,255,255,0.85)",
              fontFamily: "'Prompt', sans-serif",
              fontWeight: 700,
              fontSize: 13,
              letterSpacing: "2.5px",
            }}
          >
            {card.no}
          </div>

          <motion.div
            variants={{ rest: { scaleX: 0 }, hover: { scaleX: 1 } }}
            transition={{ duration: 0.6, ease: [0.22, 0.61, 0.36, 1] }}
            style={{
              position: "absolute",
              top: 0,
              left: 0,
              right: 0,
              height: 2,
              background: "#fff",
              zIndex: 3,
              transformOrigin: "left center",
            }}
          />

          <div
            style={{
              position: "absolute",
              bottom: 0,
              left: 0,
              right: 0,
              padding: "34px 30px",
              zIndex: 2,
            }}
          >
            <span
              style={{
                display: "inline-block",
                fontSize: 11,
                fontWeight: 700,
                color: "#fff",
                padding: "5px 13px",
                borderRadius: 999,
                border: "1px solid rgba(255,255,255,0.5)",
                marginBottom: 14,
                letterSpacing: "0.5px",
              }}
            >
              {card.tag}
            </span>
            <h3
              style={{
                color: "#fff",
                fontSize: 26,
                fontWeight: 800,
                marginBottom: 10,
                letterSpacing: "-0.5px",
                lineHeight: 1.2,
              }}
            >
              {card.title}
            </h3>
            <motion.p
              variants={{ rest: { opacity: 0, y: 10 }, hover: { opacity: 1, y: 0 } }}
              transition={{ duration: 0.4, ease: "easeOut" }}
              style={{
                color: "rgba(255,255,255,0.75)",
                fontSize: 13,
                lineHeight: 1.6,
              }}
            >
              {card.subtitle}
            </motion.p>
          </div>

          <motion.div
            variants={{
              rest: { opacity: 0, scale: 0.7, rotate: -20 },
              hover: { opacity: 1, scale: 1, rotate: 0 },
            }}
            transition={{ duration: 0.45, ease: [0.22, 0.61, 0.36, 1] }}
            style={{
              position: "absolute",
              top: 26,
              right: 26,
              zIndex: 2,
              width: 42,
              height: 42,
              borderRadius: "50%",
              background: "#fff",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#111" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M7 17L17 7M17 7H9M17 7v8" />
            </svg>
          </motion.div>
        </motion.a>
      </TiltCard>
    </motion.div>
  );
}
