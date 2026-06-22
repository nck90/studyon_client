"use client";

import { motion } from "framer-motion";
import { CSSProperties } from "react";

type Props = {
  text: string;
  delay?: number;
  stagger?: number;
  duration?: number;
  by?: "word" | "char";
  className?: string;
  style?: CSSProperties;
  as?: "h1" | "h2" | "h3" | "p" | "span" | "div";
  viewportAmount?: number;
};

export function SplitText({
  text,
  delay = 0,
  stagger = 0.06,
  duration = 0.8,
  by = "word",
  className,
  style,
  as = "span",
  viewportAmount = 0.3,
}: Props) {
  const parts = by === "word" ? text.split(" ") : text.split("");
  const Tag = motion[as];

  return (
    <Tag
      className={className}
      style={style}
      initial="hidden"
      whileInView="show"
      viewport={{ once: true, amount: viewportAmount }}
    >
      {parts.map((p, i) => (
        <span
          key={i}
          style={{
            display: "inline-block",
            overflow: "hidden",
            verticalAlign: "bottom",
            whiteSpace: "pre",
          }}
        >
          <motion.span
            variants={{
              hidden: { y: "110%", opacity: 0 },
              show: {
                y: 0,
                opacity: 1,
                transition: {
                  delay: delay + i * stagger,
                  duration,
                  ease: [0.22, 0.61, 0.36, 1],
                },
              },
            }}
            style={{ display: "inline-block", whiteSpace: "pre" }}
          >
            {p}
            {by === "word" && i !== parts.length - 1 ? " " : ""}
          </motion.span>
        </span>
      ))}
    </Tag>
  );
}
