"use client";

import { motion, useScroll, useSpring, useTransform } from "framer-motion";

export function ScrollProgress() {
  const { scrollYProgress } = useScroll();
  const smoothY = useSpring(scrollYProgress, { stiffness: 140, damping: 22, mass: 0.4 });
  const labelY = useTransform(smoothY, [0, 1], ["0%", "calc(100% - 18px)"]);
  const percent = useTransform(smoothY, (v) => `${Math.round(v * 100).toString().padStart(2, "0")}`);

  return (
    <div
      aria-hidden="true"
      style={{
        position: "fixed",
        right: 28,
        top: 140,
        bottom: 140,
        width: 16,
        zIndex: 9999,
        pointerEvents: "none",
        display: "flex",
        flexDirection: "column",
        alignItems: "flex-end",
      }}
    >
      {/* Track */}
      <div
        style={{
          position: "absolute",
          top: 0,
          bottom: 0,
          right: 6,
          width: 1,
          background: "rgba(0,0,0,0.1)",
        }}
      />
      {/* Fill */}
      <motion.div
        style={{
          position: "absolute",
          top: 0,
          right: 6,
          width: 1,
          height: "100%",
          background: "#111",
          transformOrigin: "top",
          scaleY: smoothY,
        }}
      />
      {/* Percentage label that slides */}
      <motion.div
        style={{
          position: "absolute",
          right: 14,
          top: 0,
          y: labelY,
          fontFamily: "'Prompt', sans-serif",
          fontSize: 10,
          fontWeight: 700,
          letterSpacing: "1.5px",
          color: "#111",
          background: "#fff",
          padding: "3px 6px",
          borderRadius: 4,
          mixBlendMode: "difference",
        }}
      >
        <motion.span>{percent}</motion.span>
      </motion.div>
    </div>
  );
}
