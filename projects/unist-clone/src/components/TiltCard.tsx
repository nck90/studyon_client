"use client";

import { motion, useMotionValue, useSpring, useTransform } from "framer-motion";
import { useRef, CSSProperties, ReactNode } from "react";

/**
 * Wraps children with a 3D tilt that follows the mouse position within the element.
 */
export function TiltCard({
  children,
  max = 10,
  perspective = 900,
  scale = 1.02,
  style,
  className,
}: {
  children: ReactNode;
  max?: number;
  perspective?: number;
  scale?: number;
  style?: CSSProperties;
  className?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const mx = useMotionValue(0); // -0.5..0.5
  const my = useMotionValue(0);
  const smoothX = useSpring(mx, { stiffness: 200, damping: 20, mass: 0.5 });
  const smoothY = useSpring(my, { stiffness: 200, damping: 20, mass: 0.5 });

  const rotateY = useTransform(smoothX, (v) => v * max * 2);
  const rotateX = useTransform(smoothY, (v) => -v * max * 2);
  const scaleV = useMotionValue(1);
  const smoothScale = useSpring(scaleV, { stiffness: 200, damping: 22, mass: 0.4 });

  const onMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const el = ref.current;
    if (!el) return;
    const rect = el.getBoundingClientRect();
    mx.set((e.clientX - rect.left) / rect.width - 0.5);
    my.set((e.clientY - rect.top) / rect.height - 0.5);
  };

  const onEnter = () => scaleV.set(scale);
  const onLeave = () => {
    mx.set(0);
    my.set(0);
    scaleV.set(1);
  };

  return (
    <motion.div
      ref={ref}
      onMouseMove={onMove}
      onMouseEnter={onEnter}
      onMouseLeave={onLeave}
      className={className}
      style={{
        ...style,
        perspective,
        rotateX,
        rotateY,
        scale: smoothScale,
        transformStyle: "preserve-3d",
        willChange: "transform",
      }}
    >
      {children}
    </motion.div>
  );
}
