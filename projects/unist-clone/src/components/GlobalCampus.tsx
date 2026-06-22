"use client";

import Image from "next/image";
import { useRef } from "react";
import { motion, useScroll, useTransform } from "framer-motion";

const cards = [
  { label: "교육혁신지원센터", image: "/images/main/experience-01-01.png" },
  { label: "산학협력", image: "/images/main/experience-01-02.png" },
  { label: "학생활동", image: "/images/main/experience-01-03.png" },
  { label: "연구성과", image: "/images/main/experience-01-04.png" },
  { label: "캠퍼스", image: "/images/main/insight05.png" },
];

function CardWithParallax({
  card,
  offset,
}: {
  card: (typeof cards)[0];
  offset: number;
}) {
  const ref = useRef<HTMLAnchorElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"],
  });
  const y = useTransform(scrollYProgress, [0, 1], [30 + offset, -20 - offset]);
  const imgScale = useTransform(scrollYProgress, [0, 0.5, 1], [1.12, 1, 1.04]);

  return (
    <motion.a
      ref={ref}
      href="#"
      style={{ y }}
      className="group relative w-[160px] md:w-[200px] h-[220px] md:h-[280px] rounded-[16px] overflow-hidden shrink-0 snap-center"
    >
      <motion.div style={{ scale: imgScale }} className="absolute inset-0">
        <Image
          src={card.image}
          alt={card.label}
          fill
          sizes="200px"
          className="object-cover"
        />
      </motion.div>
      <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent" />
      <div className="absolute bottom-[16px] left-[16px] right-[16px]">
        <span className="text-white text-[13px] font-semibold">{card.label}</span>
      </div>
    </motion.a>
  );
}

export function GlobalCampus() {
  const sectionRef = useRef<HTMLElement>(null);
  const { scrollYProgress } = useScroll({
    target: sectionRef,
    offset: ["start end", "end start"],
  });
  const headingY = useTransform(scrollYProgress, [0, 1], [60, -40]);
  const headingOpacity = useTransform(scrollYProgress, [0, 0.25, 0.75, 1], [0.3, 1, 1, 0.3]);

  return (
    <section ref={sectionRef} className="relative z-10 bg-white py-[50px] md:py-[80px] overflow-hidden">
      <style dangerouslySetInnerHTML={{ __html: `.hide-scrollbar::-webkit-scrollbar { display: none; } .hide-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }` }} />
      <div className="max-w-[1200px] mx-auto px-[16px] md:px-[40px]">
        {/* Large watermark text */}
        <motion.div
          style={{ y: headingY, opacity: headingOpacity }}
          className="text-center mb-[60px]"
        >
          <h2 className="text-[60px] md:text-[80px] lg:text-[100px] font-black text-[#EFF3F6] leading-[1.05] tracking-[-2px] select-none">
            GLOBAL<br />
            CAMPUS FOR<br />
            FUTURE<br />
            <span className="text-[#D9D9D9]">INNOVATORS</span>
          </h2>
        </motion.div>

        {/* Image cards row */}
        <div className="flex gap-[16px] justify-center overflow-x-auto pb-4 snap-x snap-mandatory md:overflow-visible md:pb-0 hide-scrollbar">
          {cards.map((card, i) => (
            <CardWithParallax
              key={i}
              card={card}
              offset={[0, 12, 6, 18, 10][i]}
            />
          ))}
        </div>
      </div>
    </section>
  );
}
