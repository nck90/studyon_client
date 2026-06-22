"use client";

import { useEffect, useState } from "react";
import { AnimatePresence, motion } from "framer-motion";

export function PageLoader() {
  const [visible, setVisible] = useState(true);
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    const total = 400;
    const start = performance.now();
    let raf = 0;
    const step = (t: number) => {
      const elapsed = t - start;
      const p = Math.min((elapsed / total) * 100, 100);
      setProgress(p);
      if (elapsed < total) raf = requestAnimationFrame(step);
      else setTimeout(() => setVisible(false), 100);
    };
    raf = requestAnimationFrame(step);
    return () => cancelAnimationFrame(raf);
  }, []);

  return (
    <AnimatePresence>
      {visible && (
        <motion.div
          exit={{ y: "-100%" }}
          transition={{ duration: 0.9, ease: [0.7, 0, 0.3, 1] }}
          style={{
            position: "fixed",
            inset: 0,
            background: "#000",
            color: "#fff",
            zIndex: 100000,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          {/* Corner marks */}
          <div
            aria-hidden="true"
            style={{
              position: "absolute",
              top: 32,
              left: 40,
              fontFamily: "'Prompt', sans-serif",
              fontSize: 10,
              fontWeight: 700,
              letterSpacing: "2.5px",
              color: "rgba(255,255,255,0.5)",
              display: "flex",
              alignItems: "center",
              gap: 10,
            }}
          >
            <span style={{ width: 24, height: 1, background: "rgba(255,255,255,0.3)" }} />
            JINSUHAK · TRUE MATH ACADEMY
          </div>
          <div
            aria-hidden="true"
            style={{
              position: "absolute",
              top: 32,
              right: 40,
              fontFamily: "'Prompt', sans-serif",
              fontSize: 10,
              fontWeight: 700,
              letterSpacing: "2.5px",
              color: "rgba(255,255,255,0.5)",
              display: "flex",
              alignItems: "center",
              gap: 10,
            }}
          >
            V 1.0.0 · EST. 2010
            <span style={{ width: 24, height: 1, background: "rgba(255,255,255,0.3)" }} />
          </div>

          {/* Monogram */}
          <motion.div
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, ease: [0.22, 0.61, 0.36, 1] }}
            style={{
              fontFamily: "Pretendard, sans-serif",
              fontWeight: 900,
              fontSize: 56,
              letterSpacing: "-1.6px",
              marginBottom: 40,
              color: "#fff",
            }}
          >
            진수학
          </motion.div>

          {/* Progress track */}
          <div
            style={{
              width: 280,
              height: 1,
              background: "rgba(255,255,255,0.12)",
              position: "relative",
              overflow: "hidden",
            }}
          >
            <div
              style={{
                position: "absolute",
                top: 0,
                left: 0,
                height: "100%",
                background: "#fff",
                width: `${progress}%`,
                transition: "width 80ms linear",
              }}
            />
          </div>

          {/* Label */}
          <div
            style={{
              marginTop: 20,
              display: "flex",
              alignItems: "center",
              gap: 14,
              fontFamily: "'Prompt', sans-serif",
              fontSize: 11,
              fontWeight: 700,
              letterSpacing: "2px",
              color: "rgba(255,255,255,0.55)",
            }}
          >
            <span>LOADING</span>
            <span style={{ color: "#fff", fontVariantNumeric: "tabular-nums" }}>
              {String(Math.round(progress)).padStart(3, "0")}
            </span>
          </div>

          {/* Bottom legend */}
          <div
            aria-hidden="true"
            style={{
              position: "absolute",
              bottom: 32,
              left: 0,
              right: 0,
              textAlign: "center",
              fontFamily: "'Prompt', sans-serif",
              fontSize: 10,
              fontWeight: 600,
              letterSpacing: "3px",
              color: "rgba(255,255,255,0.3)",
            }}
          >
            PREPARING THE EXPERIENCE
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
