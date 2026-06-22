"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";

const COURSES = [
  "초등 수학", "중등 수학", "고1 수학", "고2 수학",
  "고3 수능반", "재수 수능반", "수학올림피아드", "의대 특강반",
];

const RELATED_SITES = [
  "학원 블로그", "수학 자료실", "입시정보센터", "EBS 수능",
  "수능 기출문제", "대학별 입시요강",
];

const FOOTER_LINKS_1 = [
  "학원소개", "강사소개", "수업안내", "합격실적", "공지사항", "상담신청",
];

const FOOTER_LINKS_2 = [
  "이용약관", "개인정보처리방침", "이메일무단수집거부", "저작권보호",
];

export function Footer() {
  const [courseOpen, setCourseOpen] = useState(false);
  const [siteOpen, setSiteOpen] = useState(false);

  return (
    <footer style={{ background: "#000", color: "#fff", position: "relative", zIndex: 10, overflow: "hidden" }}>
      <style
        dangerouslySetInnerHTML={{
          __html: `
            .jm-footer-link {
              position: relative;
              display: inline-block;
              padding-bottom: 2px;
              text-decoration: none;
              transition: color 0.3s ease;
            }
            .jm-footer-link::after {
              content: "";
              position: absolute;
              left: 0;
              bottom: 0;
              width: 100%;
              height: 1px;
              background: currentColor;
              transform: scaleX(0);
              transform-origin: left center;
              transition: transform 420ms cubic-bezier(0.22, 0.61, 0.36, 1);
            }
            .jm-footer-link:hover {
              color: #fff !important;
            }
            .jm-footer-link:hover::after {
              transform: scaleX(1);
            }
            @media (max-width: 768px) {
              .jm-footer-accordion-row { flex-direction: column !important; }
              .jm-footer-body { padding: 40px 16px 24px !important; }
              .jm-accordion-btn { padding: 18px 16px !important; font-size: 14px !important; }
            }
          `,
        }}
      />

      {/* Top accordion row */}
      <div style={{ borderBottom: "1px solid rgba(255,255,255,0.1)", borderTop: "1px solid rgba(255,255,255,0.1)" }}>
        <div className="jm-footer-accordion-row" style={{ maxWidth: 1400, margin: "0 auto", display: "flex" }}>
          <AccordionRow
            label="과정별 안내 바로가기"
            open={courseOpen}
            onToggle={() => setCourseOpen((v) => !v)}
            items={COURSES}
            hasRightBorder
          />
          <AccordionRow
            label="관련 사이트 바로가기"
            open={siteOpen}
            onToggle={() => setSiteOpen((v) => !v)}
            items={RELATED_SITES}
          />
        </div>
      </div>

      {/* Main body */}
      <div className="jm-footer-body" style={{ maxWidth: 1400, margin: "0 auto", padding: "64px 40px 32px" }}>
        {/* Logo + tagline */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-80px" }}
          transition={{ duration: 0.8, ease: [0.22, 0.61, 0.36, 1] }}
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "flex-start",
            marginBottom: 56,
            flexWrap: "wrap",
            gap: 40,
          }}
        >
          <div>
            <div style={{ marginBottom: 26 }}>
              <div style={{ display: "flex", flexDirection: "column", lineHeight: 1 }}>
                <span
                  style={{
                    fontFamily: "Pretendard, sans-serif",
                    fontWeight: 900,
                    fontSize: 32,
                    color: "#fff",
                    letterSpacing: "-0.8px",
                  }}
                >
                  진수학
                </span>
                <span
                  style={{
                    fontFamily: "'Prompt', sans-serif",
                    fontWeight: 700,
                    fontSize: 11,
                    letterSpacing: "3px",
                    color: "rgba(255,255,255,0.65)",
                    textTransform: "uppercase",
                    marginTop: 6,
                  }}
                >
                  TRUE MATH ACADEMY
                </span>
              </div>
            </div>
            <p style={{ fontSize: 14, color: "rgba(255,255,255,0.5)", marginBottom: 6, lineHeight: 1.75 }}>
              서울특별시 강남구 (상세 주소)
            </p>
            <p style={{ fontSize: 14, color: "rgba(255,255,255,0.5)", lineHeight: 1.75 }}>
              대표 02-XXX-XXXX&nbsp;&nbsp;·&nbsp;&nbsp;상담 02-XXX-XXXX
            </p>
          </div>

          <div style={{ textAlign: "right", flexShrink: 0 }}>
            <p
              style={{
                fontFamily: "'Prompt', sans-serif",
                fontSize: "clamp(32px, 3.2vw, 56px)",
                fontWeight: 900,
                lineHeight: 1.1,
                letterSpacing: "-1px",
                margin: 0,
              }}
            >
              <span style={{ color: "rgba(255,255,255,0.55)" }}>수학의 본질,</span>
              <br />
              <span style={{ color: "#fff" }}>진수학</span>
            </p>
          </div>
        </motion.div>

        {/* Giant wordmark */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: "-60px" }}
          transition={{ duration: 1.1, ease: [0.22, 0.61, 0.36, 1] }}
          aria-hidden="true"
          style={{
            fontFamily: "'Prompt', sans-serif",
            fontWeight: 900,
            fontSize: "clamp(100px, 18vw, 300px)",
            letterSpacing: "-6px",
            lineHeight: 0.9,
            color: "rgba(255,255,255,0.08)",
            WebkitTextStroke: "1.5px rgba(255,255,255,0.55)",
            textAlign: "center",
            userSelect: "none",
            marginBottom: 40,
            textShadow: "0 0 60px rgba(255,255,255,0.05)",
          }}
        >
          TRUE MATH
        </motion.div>

        {/* Links row 1 */}
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            alignItems: "center",
            marginBottom: 14,
            rowGap: 10,
          }}
        >
          {FOOTER_LINKS_1.map((link, i) => (
            <span key={link} style={{ display: "flex", alignItems: "center" }}>
              <a
                href="#"
                className="jm-footer-link"
                style={{ fontSize: 13, color: "rgba(255,255,255,0.7)" }}
              >
                {link}
              </a>
              {i < FOOTER_LINKS_1.length - 1 && (
                <span style={{ fontSize: 12, color: "rgba(255,255,255,0.15)", margin: "0 12px" }}>·</span>
              )}
            </span>
          ))}
        </div>

        {/* Links row 2 */}
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            alignItems: "center",
            marginBottom: 36,
            rowGap: 10,
          }}
        >
          {FOOTER_LINKS_2.map((link, i) => {
            const emphasized = link === "개인정보처리방침";
            return (
              <span key={link} style={{ display: "flex", alignItems: "center" }}>
                <a
                  href="#"
                  className="jm-footer-link"
                  style={{
                    fontSize: 13,
                    color: emphasized ? "#fff" : "rgba(255,255,255,0.7)",
                    fontWeight: emphasized ? 700 : 400,
                  }}
                >
                  {link}
                </a>
                {i < FOOTER_LINKS_2.length - 1 && (
                  <span style={{ fontSize: 12, color: "rgba(255,255,255,0.15)", margin: "0 12px" }}>·</span>
                )}
              </span>
            );
          })}
        </div>

        {/* Bottom bar */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            paddingTop: 24,
            borderTop: "1px solid rgba(255,255,255,0.1)",
            flexWrap: "wrap",
            gap: 14,
          }}
        >
          <p style={{ fontSize: 12, color: "rgba(255,255,255,0.6)", letterSpacing: "0.3px" }}>
            © 2026 진수학전문학원. All rights reserved.
          </p>

          <div style={{ display: "flex", gap: 6 }}>
            <SocialLink href="#" label="Instagram">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z" />
              </svg>
            </SocialLink>
            <SocialLink href="#" label="Blog">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                <path d="M16.273 12.845L7.376 0H0v24h7.727V11.155L16.624 24H24V0h-7.727z" />
              </svg>
            </SocialLink>
            <SocialLink href="#" label="YouTube">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                <path d="M23.498 6.186a3.016 3.016 0 00-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 00.502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 002.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 002.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" />
              </svg>
            </SocialLink>
          </div>
        </div>
      </div>
    </footer>
  );
}

function AccordionRow({
  label,
  open,
  onToggle,
  items,
  hasRightBorder,
}: {
  label: string;
  open: boolean;
  onToggle: () => void;
  items: string[];
  hasRightBorder?: boolean;
}) {
  return (
    <div style={{ flex: 1, borderRight: hasRightBorder ? "1px solid rgba(255,255,255,0.1)" : "none" }}>
      <motion.button
        onClick={onToggle}
        whileHover={{ backgroundColor: "rgba(255,255,255,0.04)" }}
        transition={{ duration: 0.25 }}
        className="jm-accordion-btn"
        style={{
          width: "100%",
          display: "flex",
          alignItems: "center",
          gap: 8,
          padding: "22px 40px",
          fontSize: 15,
          fontWeight: 700,
          color: "#fff",
          background: "none",
          border: "none",
          cursor: "pointer",
          textAlign: "left",
        }}
      >
        {label}
        <motion.svg
          animate={{ rotate: open ? 180 : 0 }}
          transition={{ duration: 0.35, ease: [0.22, 0.61, 0.36, 1] }}
          width="14"
          height="8"
          viewBox="0 0 14 8"
          fill="none"
          style={{ marginLeft: "auto" }}
        >
          <path d="M1 1L7 7L13 1" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
        </motion.svg>
      </motion.button>

      <AnimatePresence initial={false}>
        {open && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.4, ease: [0.22, 0.61, 0.36, 1] }}
            style={{ overflow: "hidden" }}
          >
            <div
              style={{
                display: "flex",
                flexWrap: "wrap",
                gap: "10px 24px",
                padding: "4px 40px 22px",
              }}
            >
              {items.map((d, i) => (
                <motion.a
                  key={d}
                  href="#"
                  className="jm-footer-link"
                  initial={{ opacity: 0, y: 6 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: i * 0.025, duration: 0.3 }}
                  style={{ fontSize: 13, color: "rgba(255,255,255,0.7)" }}
                >
                  {d}
                </motion.a>
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

function SocialLink({
  href,
  label,
  children,
}: {
  href: string;
  label: string;
  children: React.ReactNode;
}) {
  return (
    <motion.a
      href={href}
      aria-label={label}
      whileHover={{ backgroundColor: "#fff", color: "#000" }}
      transition={{ duration: 0.25 }}
      style={{
        color: "rgba(255,255,255,0.5)",
        width: 40,
        height: 40,
        borderRadius: "50%",
        border: "1px solid rgba(255,255,255,0.2)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        textDecoration: "none",
      }}
    >
      {children}
    </motion.a>
  );
}
