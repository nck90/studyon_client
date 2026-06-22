"use client";

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

const SECTIONS = [
  { id: 0, label: "HERO" },
  { id: 1, label: "TODAY" },
  { id: 2, label: "INFO" },
  { id: 3, label: "WHY" },
  { id: 4, label: "RESULTS" },
  { id: 5, label: "LIFE" },
];

export function SectionIndex() {
  const [active, setActive] = useState(0);

  useEffect(() => {
    const compute = () => {
      const y = window.scrollY + window.innerHeight / 2;
      const main = document.querySelector("main");
      if (!main) return;
      const sections = Array.from(main.children) as HTMLElement[];
      let found = 0;
      sections.forEach((el, i) => {
        if (el.offsetTop <= y) found = Math.min(i, SECTIONS.length - 1);
      });
      setActive(found);
    };

    compute();
    window.addEventListener("scroll", compute, { passive: true });
    window.addEventListener("resize", compute);
    return () => {
      window.removeEventListener("scroll", compute);
      window.removeEventListener("resize", compute);
    };
  }, []);

  return (
    <div
      aria-hidden="true"
      style={{
        position: "fixed",
        left: 28,
        top: "50%",
        transform: "translateY(-50%)",
        zIndex: 9998,
        pointerEvents: "none",
        display: "flex",
        flexDirection: "column",
        gap: 14,
        fontFamily: "'Prompt', sans-serif",
        mixBlendMode: "difference",
        color: "#fff",
      }}
    >
      {SECTIONS.map((s, i) => (
        <div
          key={s.id}
          style={{
            display: "flex",
            alignItems: "center",
            gap: 12,
            opacity: active === i ? 1 : 0.35,
            transition: "opacity 0.4s ease",
          }}
        >
          <span
            style={{
              width: active === i ? 28 : 10,
              height: 1,
              background: "currentColor",
              transition: "width 0.4s cubic-bezier(0.22, 0.61, 0.36, 1)",
            }}
          />
          <AnimatePresence mode="wait">
            {active === i && (
              <motion.span
                key={s.label}
                initial={{ opacity: 0, x: -4 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -4 }}
                transition={{ duration: 0.25 }}
                style={{
                  fontSize: 10,
                  fontWeight: 700,
                  letterSpacing: "2px",
                  textTransform: "uppercase",
                }}
              >
                {`0${i + 1} · ${s.label}`}
              </motion.span>
            )}
          </AnimatePresence>
        </div>
      ))}
    </div>
  );
}
