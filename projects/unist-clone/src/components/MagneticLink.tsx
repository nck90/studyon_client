"use client";

import { motion, useMotionValue, useSpring, MotionProps } from "framer-motion";
import { useRef, CSSProperties, ReactNode } from "react";

type Props = {
  children: ReactNode;
  href?: string;
  className?: string;
  style?: CSSProperties;
  strength?: number;
  onClick?: () => void;
} & Omit<MotionProps, "children" | "style">;

export function MagneticLink({
  children,
  href = "#",
  className,
  style,
  strength = 0.35,
  onClick,
  ...rest
}: Props) {
  const ref = useRef<HTMLAnchorElement>(null);
  const x = useMotionValue(0);
  const y = useMotionValue(0);
  const sx = useSpring(x, { stiffness: 220, damping: 14, mass: 0.5 });
  const sy = useSpring(y, { stiffness: 220, damping: 14, mass: 0.5 });

  const handleMove = (e: React.MouseEvent<HTMLAnchorElement>) => {
    const rect = ref.current?.getBoundingClientRect();
    if (!rect) return;
    const dx = e.clientX - rect.left - rect.width / 2;
    const dy = e.clientY - rect.top - rect.height / 2;
    x.set(dx * strength);
    y.set(dy * strength);
  };

  const handleLeave = () => {
    x.set(0);
    y.set(0);
  };

  return (
    <motion.a
      ref={ref}
      href={href}
      className={className}
      onMouseMove={handleMove}
      onMouseLeave={handleLeave}
      onClick={onClick}
      style={{ ...style, x: sx, y: sy }}
      {...rest}
    >
      {children}
    </motion.a>
  );
}
