"use client";

import { useEffect, useRef, useState } from "react";
import { motion, useMotionValue, useSpring } from "framer-motion";

export function CustomCursor() {
  const x = useMotionValue(-100);
  const y = useMotionValue(-100);
  const sx = useSpring(x, { stiffness: 450, damping: 30, mass: 0.4 });
  const sy = useSpring(y, { stiffness: 450, damping: 30, mass: 0.4 });
  const rx = useSpring(x, { stiffness: 180, damping: 22, mass: 0.6 });
  const ry = useSpring(y, { stiffness: 180, damping: 22, mass: 0.6 });

  const [hovering, setHovering] = useState(false);
  const [mounted, setMounted] = useState(false);
  const [coarse, setCoarse] = useState(false);
  const lastPos = useRef({ x: 0, y: 0 });

  useEffect(() => {
    const frame = window.requestAnimationFrame(() => {
      setMounted(true);
      setCoarse(window.matchMedia("(pointer: coarse)").matches);
    });
    return () => window.cancelAnimationFrame(frame);
  }, []);

  useEffect(() => {
    if (coarse) return;

    const move = (e: MouseEvent) => {
      x.set(e.clientX);
      y.set(e.clientY);
      lastPos.current = { x: e.clientX, y: e.clientY };
    };

    const over = (e: MouseEvent) => {
      const target = e.target as HTMLElement | null;
      if (!target) return;
      const interactive = target.closest(
        'a, button, [role="button"], input, textarea, select, [data-cursor="hover"]'
      );
      setHovering(Boolean(interactive));
    };

    window.addEventListener("mousemove", move);
    window.addEventListener("mouseover", over);
    return () => {
      window.removeEventListener("mousemove", move);
      window.removeEventListener("mouseover", over);
    };
  }, [x, y, coarse]);

  if (!mounted || coarse) return null;

  return (
    <>
      {/* Outer ring — lags behind */}
      <motion.div
        aria-hidden="true"
        style={{
          position: "fixed",
          top: 0,
          left: 0,
          width: 40,
          height: 40,
          borderRadius: "50%",
          border: "1px solid #fff",
          mixBlendMode: "difference",
          pointerEvents: "none",
          zIndex: 99999,
          x: rx,
          y: ry,
          translateX: "-50%",
          translateY: "-50%",
          scale: hovering ? 1.55 : 1,
          transition: "scale 280ms cubic-bezier(0.22, 0.61, 0.36, 1)",
        }}
      />
      {/* Inner dot — snaps to cursor */}
      <motion.div
        aria-hidden="true"
        style={{
          position: "fixed",
          top: 0,
          left: 0,
          width: 6,
          height: 6,
          borderRadius: "50%",
          background: "#fff",
          mixBlendMode: "difference",
          pointerEvents: "none",
          zIndex: 99999,
          x: sx,
          y: sy,
          translateX: "-50%",
          translateY: "-50%",
          scale: hovering ? 0.3 : 1,
          transition: "scale 240ms cubic-bezier(0.22, 0.61, 0.36, 1)",
        }}
      />
    </>
  );
}
