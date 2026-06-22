"use client";

import { useEffect, useRef, useState } from "react";
import Image from "next/image";
import { motion, useInView, useScroll, useTransform } from "framer-motion";

const RESEARCH_NEWS = [
  {
    image: "/images/main/insight01.png",
    category: "수능 만점",
    title: "2026 수능 수학 영역 만점자 12명 배출",
    desc: "진수학전문학원이 2026학년도 수능 수학 영역에서 만점자 12명을 배출하며 역대 최고 성과를 달성했습니다.",
    date: "2026.04.16",
    stat: "12",
    statLabel: "수능 만점",
  },
  {
    image: "/images/main/insight02.png",
    category: "서울대 합격",
    title: "서울대 23명 합격, 역대 최다 기록 달성",
    desc: "체계적인 입시 지도의 결실",
    date: "2026.04.15",
    stat: "23",
    statLabel: "서울대 합격",
  },
  {
    image: "/images/main/insight03.png",
    category: "의대 합격",
    title: "의대·치대·한의대 15명 합격",
    desc: "의과계열 특화 수학 커리큘럼의 성과",
    date: "2026.04.14",
    stat: "15",
    statLabel: "의치한 합격",
  },
];

const STATS = [
  { value: "98.7", unit: "%", label: "학부모 만족도" },
  { value: "12", unit: "명", label: "수능 만점자" },
  { value: "23", unit: "명", label: "서울대 합격" },
  { value: "67", unit: "%", label: "내신 1등급 비율" },
];

export function ResearchImpact() {
  const sectionRef = useRef<HTMLElement>(null);
  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ["start end", "end start"],
  });
  const bgY = useTransform(scrollYProgress, [0, 1], ["0%", "30%"]);
  const bgScale = useTransform(scrollYProgress, [0, 1], [1.1, 1]);
  const bigNumberOpacity = useTransform(scrollYProgress, [0.1, 0.4], [0, 0.06]);

  return (
    <section
      ref={sectionRef}
      className="jm-research-section"
      style={{
        position: "relative",
        padding: "180px 0 150px",
        overflow: "hidden",
        background: "#000",
        color: "#fff",
      }}
    >
      <style dangerouslySetInnerHTML={{ __html: `
        @media (max-width: 768px) {
          .jm-research-section { padding: 100px 0 80px !important; }
          .jm-research-inner { padding: 0 16px !important; }
          .jm-research-stats { grid-template-columns: repeat(2, 1fr) !important; margin-bottom: 40px !important; }
          .jm-research-grid { grid-template-columns: 1fr !important; gap: 16px !important; }
        }
      ` }} />
      {/* Parallax background image */}
      <motion.div
        aria-hidden="true"
        style={{
          position: "absolute",
          inset: 0,
          y: bgY,
          scale: bgScale,
        }}
      >
        <div style={{ position: "absolute", inset: 0, filter: "brightness(0.4) contrast(1.05)" }}>
          <Image
            src="/images/main/sec02-bg.jpg"
            alt=""
            fill
            sizes="100vw"
            style={{ objectFit: "cover" }}
            quality={60}
            priority
          />
        </div>
        <div
          style={{
            position: "absolute",
            inset: 0,
            background:
              "linear-gradient(180deg, rgba(0,0,0,0.6) 0%, rgba(0,0,0,0.85) 50%, rgba(0,0,0,0.95) 100%)",
          }}
        />
      </motion.div>

      {/* Giant bg number */}
      <motion.div
        aria-hidden="true"
        style={{
          position: "absolute",
          top: 80,
          left: "50%",
          transform: "translateX(-50%)",
          fontFamily: "'Prompt', sans-serif",
          fontSize: "clamp(200px, 26vw, 420px)",
          fontWeight: 900,
          color: "#fff",
          opacity: bigNumberOpacity,
          whiteSpace: "nowrap",
          letterSpacing: "-10px",
          userSelect: "none",
          pointerEvents: "none",
          zIndex: 0,
        }}
      >
        2026
      </motion.div>

      {/* Top divider line */}
      <motion.div
        initial={{ scaleX: 0 }}
        whileInView={{ scaleX: 1 }}
        viewport={{ once: true, margin: "-100px" }}
        transition={{ duration: 1.4, ease: [0.22, 0.61, 0.36, 1] }}
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: 1,
          background: "rgba(255,255,255,0.18)",
          transformOrigin: "left center",
        }}
      />

      <div
        className="jm-research-inner"
        style={{
          maxWidth: 1528,
          margin: "0 auto",
          padding: "0 40px",
          position: "relative",
          zIndex: 1,
        }}
      >
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-40px" }}
          transition={{ duration: 1.2, ease: [0.16, 1, 0.3, 1] }}
          style={{ textAlign: "center", marginBottom: 72 }}
        >
          <h2
            style={{
              fontFamily: "'Prompt', sans-serif",
              fontWeight: 700,
              fontSize: 28,
              letterSpacing: "0.56px",
              lineHeight: "30.8px",
              color: "#fff",
              textTransform: "uppercase",
              margin: "0 0 16px",
            }}
          >
            Admission Results
          </h2>
          <span
            style={{
              display: "inline-block",
              width: 40,
              height: 3,
              borderRadius: 999,
              background: "#fff",
            }}
          />
        </motion.div>

        {/* Stats row */}
        <div
          className="jm-research-stats"
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(4, 1fr)",
            gap: 1,
            background: "rgba(255,255,255,0.12)",
            marginBottom: 80,
            border: "1px solid rgba(255,255,255,0.12)",
          }}
        >
          {STATS.map((s, i) => (
            <motion.div
              key={s.label}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-30px" }}
              transition={{ delay: i * 0.06, duration: 1.0, ease: [0.16, 1, 0.3, 1] }}
              style={{
                background: "#000",
                padding: "40px 28px",
                display: "flex",
                flexDirection: "column",
                alignItems: "flex-start",
              }}
            >
              <div
                style={{
                  display: "flex",
                  alignItems: "baseline",
                  gap: 4,
                  fontFamily: "'Prompt', sans-serif",
                  marginBottom: 8,
                }}
              >
                <CountUp value={s.value} />
                <span style={{ color: "#fff", fontSize: 22, fontWeight: 700 }}>{s.unit}</span>
              </div>
              <p
                style={{
                  color: "rgba(255,255,255,0.5)",
                  fontSize: 13,
                  fontWeight: 500,
                  letterSpacing: "0.5px",
                }}
              >
                {s.label}
              </p>
            </motion.div>
          ))}
        </div>

        {/* Feature grid */}
        <div className="jm-research-grid" style={{ display: "grid", gridTemplateColumns: "1.7fr 1fr", gap: 20 }}>
          <ResearchCard item={RESEARCH_NEWS[0]} large delay={0.1} />
          <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
            {RESEARCH_NEWS.slice(1).map((item, i) => (
              <ResearchCard key={i} item={item} large={false} delay={0.25 + i * 0.1} />
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}

function CountUp({ value }: { value: string }) {
  const ref = useRef<HTMLSpanElement>(null);
  const inView = useInView(ref, { once: true, margin: "-80px" });
  const hasDecimal = value.includes(".");
  const target = parseFloat(value);
  const [display, setDisplay] = useState(hasDecimal ? "0.0" : "0");

  useEffect(() => {
    if (!inView || isNaN(target)) return;
    const duration = 1800;
    const start = performance.now();
    let raf = 0;
    const step = (t: number) => {
      const elapsed = t - start;
      const p = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - p, 3);
      const v = target * eased;
      setDisplay(hasDecimal ? v.toFixed(1) : Math.round(v).toString());
      if (p < 1) raf = requestAnimationFrame(step);
    };
    raf = requestAnimationFrame(step);
    return () => cancelAnimationFrame(raf);
  }, [inView, target, hasDecimal]);

  return (
    <motion.span
      ref={ref}
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.9, ease: [0.22, 0.61, 0.36, 1] }}
      style={{
        fontFamily: "'Prompt', sans-serif",
        fontSize: "clamp(44px, 5vw, 68px)",
        fontWeight: 800,
        color: "#fff",
        letterSpacing: "-2px",
        lineHeight: 1,
        fontVariantNumeric: "tabular-nums",
      }}
    >
      {display}
    </motion.span>
  );
}

type ResearchItem = typeof RESEARCH_NEWS[0];

function ResearchCard({
  item,
  large,
  delay,
}: {
  item: ResearchItem;
  large: boolean;
  delay: number;
}) {
  return (
    <motion.a
      href="#"
      initial={{ opacity: 0, y: 30 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-30px" }}
      transition={{ delay, duration: 1.1, ease: [0.16, 1, 0.3, 1] }}
      whileHover={{ y: -6 }}
      style={{
        position: "relative",
        display: "block",
        borderRadius: 4,
        overflow: "hidden",
        height: large ? 500 : 240,
        textDecoration: "none",
        cursor: "pointer",
        border: "1px solid rgba(255,255,255,0.12)",
      }}
    >
      <motion.div
        whileHover={{ scale: 1.07 }}
        transition={{ duration: 0.9, ease: [0.22, 0.61, 0.36, 1] }}
        style={{ position: "absolute", inset: 0 }}
      >
        <Image
          src={item.image}
          alt={item.title}
          fill
          sizes={large ? "(max-width: 1024px) 100vw, 60vw" : "(max-width: 1024px) 100vw, 40vw"}
          style={{ objectFit: "cover" }}
        />
      </motion.div>

      <div
        style={{
          position: "absolute",
          inset: 0,
          background: large
            ? "linear-gradient(0deg, rgba(0,0,0,0.96) 0%, rgba(0,0,0,0.4) 55%, rgba(0,0,0,0.1) 100%)"
            : "linear-gradient(0deg, rgba(0,0,0,0.92) 0%, rgba(0,0,0,0.25) 65%, transparent 100%)",
          zIndex: 1,
        }}
      />

      {large && (
        <div
          aria-hidden="true"
          style={{
            position: "absolute",
            top: 28,
            right: 32,
            zIndex: 2,
            fontFamily: "'Prompt', sans-serif",
            fontWeight: 900,
            fontSize: "clamp(80px, 10vw, 180px)",
            color: "rgba(255,255,255,0.12)",
            lineHeight: 0.9,
            letterSpacing: "-6px",
            userSelect: "none",
          }}
        >
          {item.stat}
        </div>
      )}

      <div
        style={{
          position: "absolute",
          bottom: 0,
          left: 0,
          right: 0,
          padding: large ? "36px 40px" : "22px 24px",
          zIndex: 2,
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: large ? 18 : 10 }}>
          <span
            style={{
              display: "inline-flex",
              fontSize: 11,
              fontWeight: 700,
              color: "#fff",
              padding: "5px 12px",
              borderRadius: 999,
              border: "1px solid rgba(255,255,255,0.4)",
              letterSpacing: "0.5px",
            }}
          >
            {item.category}
          </span>
          <span style={{ color: "rgba(255,255,255,0.5)", fontSize: 12, fontWeight: 500, fontVariantNumeric: "tabular-nums" }}>
            {item.date}
          </span>
        </div>
        <h3
          style={{
            color: "#fff",
            fontWeight: 800,
            fontSize: large ? 28 : 16,
            lineHeight: 1.35,
            marginBottom: large ? 12 : 0,
            letterSpacing: "-0.5px",
            display: "-webkit-box",
            WebkitLineClamp: large ? 3 : 2,
            WebkitBoxOrient: "vertical",
            overflow: "hidden",
          }}
        >
          {item.title}
        </h3>
        {large && (
          <p
            style={{
              color: "rgba(255,255,255,0.7)",
              fontSize: 15,
              lineHeight: 1.65,
              display: "-webkit-box",
              WebkitLineClamp: 2,
              WebkitBoxOrient: "vertical",
              overflow: "hidden",
              maxWidth: "70%",
            }}
          >
            {item.desc}
          </p>
        )}

        <motion.div
          whileHover={{ x: 4 }}
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 8,
            marginTop: large ? 22 : 8,
            color: "#fff",
            fontSize: 12,
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
