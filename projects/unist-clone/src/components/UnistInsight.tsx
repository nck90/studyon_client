"use client";

import Image from "next/image";

const insights = [
  {
    image: "/images/main/experience-01-01.png",
    icon: "/images/main/experience-ico-01.png",
    title: "에너지 혁신",
    desc: "차세대 에너지 기술 연구의 글로벌 허브",
  },
  {
    image: "/images/main/experience-01-02.png",
    icon: "/images/main/experience-ico-02.png",
    title: "AI · 반도체",
    desc: "인공지능과 반도체 융합 연구의 선두주자",
  },
  {
    image: "/images/main/experience-01-03.png",
    icon: "/images/main/experience-ico-03.png",
    title: "바이오 · 헬스",
    desc: "생명과학과 의공학의 혁신적 융합 연구",
  },
  {
    image: "/images/main/experience-01-04.png",
    icon: "/images/main/experience-ico-04.png",
    title: "기후 · 환경",
    desc: "탄소중립과 지속가능한 미래를 위한 연구",
  },
];

export function UnistInsight() {
  return (
    <section className="py-20 md:py-28 bg-[#F5F7F9]">
      <div className="max-w-[1200px] mx-auto px-6">
        <div className="text-center mb-14">
          <p className="text-[#004BAE] text-[13px] font-semibold tracking-[3px] uppercase mb-2">
            UNIST INSIGHT
          </p>
          <h2 className="text-[28px] md:text-[36px] font-bold text-[#000E2D]">
            UNIST <span className="text-[#004BAE]">Experience</span>
          </h2>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {insights.map((item, i) => (
            <a
              key={i}
              href="#"
              className="group relative rounded-2xl overflow-hidden h-[320px] md:h-[380px]"
            >
              <Image
                src={item.image}
                alt={item.title}
                fill
                className="object-cover group-hover:scale-110 transition-transform duration-700"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-[#000E2D]/80 via-[#000E2D]/20 to-transparent group-hover:from-[#001A54]/90 transition-all duration-300" />
              <div className="absolute bottom-0 left-0 right-0 p-6">
                <div className="w-12 h-12 rounded-xl bg-white/20 backdrop-blur-sm flex items-center justify-center mb-4 group-hover:bg-[#43C1C3]/30 transition-colors">
                  <Image src={item.icon} alt="" width={28} height={28} />
                </div>
                <h3 className="text-white text-[18px] font-bold mb-1">{item.title}</h3>
                <p className="text-white/60 text-[13px] group-hover:text-white/80 transition-colors">
                  {item.desc}
                </p>
              </div>
            </a>
          ))}
        </div>
      </div>
    </section>
  );
}
