"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";

const navItems = [
  { label: "수업안내", href: "#" },
  { label: "강사소개", href: "#" },
  { label: "합격실적", href: "#" },
  { label: "학원소개", href: "#" },
  { label: "상담신청", href: "#" },
];

export function Header() {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 80);
    handleScroll();
    window.addEventListener("scroll", handleScroll, { passive: true });
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const fg = scrolled ? "#111" : "#fff";
  const muted = scrolled ? "#666" : "rgba(255,255,255,0.7)";

  return (
    <motion.header
      className="jm-header"
      initial={{ y: -20, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.6, ease: [0.22, 0.61, 0.36, 1] }}
      style={{
        position: "fixed",
        top: 0,
        left: 0,
        width: "100%",
        zIndex: 10000,
        height: 85,
        backgroundColor: scrolled ? "rgba(255,255,255,0.92)" : "transparent",
        backdropFilter: scrolled ? "blur(18px) saturate(1.4)" : "none",
        WebkitBackdropFilter: scrolled ? "blur(18px) saturate(1.4)" : "none",
        borderBottom: scrolled ? "1px solid #EAEAEA" : "1px solid transparent",
        transition:
          "background-color 0.4s ease, border-color 0.4s ease, backdrop-filter 0.4s ease",
      }}
    >
      <style
        dangerouslySetInnerHTML={{
          __html: `
            .jm-nav-link { position: relative; }
            .jm-nav-link::after {
              content: "";
              position: absolute;
              left: 25px;
              right: 25px;
              bottom: 26px;
              height: 1px;
              background: currentColor;
              transform: scaleX(0);
              transform-origin: left center;
              transition: transform 480ms cubic-bezier(0.22, 0.61, 0.36, 1);
            }
            .jm-nav-link:hover::after { transform: scaleX(1); }

            .jm-icon-btn {
              position: relative;
              overflow: hidden;
            }
            .jm-icon-btn::before {
              content: "";
              position: absolute;
              inset: 0;
              background: rgba(255,255,255,0.1);
              opacity: 0;
              transition: opacity 240ms ease;
            }
            .jm-icon-btn:hover::before { opacity: 1; }

            @media (max-width: 768px) {
              .jm-desktop-nav { display: none !important; }
              .jm-phone-display { display: none !important; }
              .jm-header { height: 64px !important; }
              .jm-header-inner { padding: 0 12px 0 16px !important; }
              .jm-logo-main { font-size: 20px !important; }
            }
          `,
        }}
      />

      <div
        className="jm-header-inner"
        style={{
          display: "flex",
          alignItems: "center",
          gap: "10px 30px",
          padding: "0 10px 0 40px",
          height: "100%",
        }}
      >
        <motion.a
          href="#"
          style={{ maxWidth: 220, flexShrink: 0, textDecoration: "none", display: "block" }}
          whileHover={{ opacity: 0.75 }}
          transition={{ duration: 0.25 }}
        >
          <div style={{ display: "flex", flexDirection: "column", lineHeight: 1 }}>
            <span
              className="jm-logo-main"
              style={{
                fontFamily: "Pretendard, sans-serif",
                fontWeight: 900,
                fontSize: 24,
                letterSpacing: "-0.5px",
                color: fg,
                transition: "color 0.3s ease",
              }}
            >
              진수학
            </span>
            <span
              style={{
                fontFamily: "'Prompt', sans-serif",
                fontWeight: 700,
                fontSize: 10,
                letterSpacing: "2px",
                color: muted,
                textTransform: "uppercase",
                marginTop: 1,
                transition: "color 0.3s ease",
              }}
            >
              TRUE MATH
            </span>
          </div>
        </motion.a>

        <nav
          className="jm-desktop-nav"
          style={{
            flex: 1,
            padding: "0 48px",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            height: "100%",
          }}
        >
          {navItems.map((item, i) => (
            <motion.a
              key={item.label}
              href={item.href}
              className="jm-nav-link"
              initial={{ opacity: 0, y: -8 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.15 + i * 0.05, duration: 0.5 }}
              style={{
                padding: "32px 25px",
                fontWeight: 700,
                fontSize: 17,
                lineHeight: "21px",
                color: fg,
                transition: "color 0.3s ease",
                display: "inline-block",
                whiteSpace: "nowrap",
                textDecoration: "none",
              }}
            >
              {item.label}
            </motion.a>
          ))}
        </nav>

        <div style={{ display: "flex", alignItems: "center", gap: 16, flexShrink: 0 }}>
          <div className="jm-phone-display">
          <AnimatePresence mode="wait">
            <motion.div
              key={scrolled ? "s" : "t"}
              initial={{ opacity: 0, x: 6 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -6 }}
              transition={{ duration: 0.25 }}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 6,
                color: fg,
                fontSize: 14,
                fontWeight: 500,
              }}
            >
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
                <path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.95 10.5 19.79 19.79 0 01.88 1.82 2 2 0 012.88 0h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L7.09 7.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45 12.84 12.84 0 002.81.7A2 2 0 0122 14.92z" />
              </svg>
              <span>02-XXX-XXXX</span>
            </motion.div>
          </AnimatePresence>
          </div>

          <div
            style={{
              display: "flex",
              alignItems: "center",
              overflow: "hidden",
              background: scrolled ? "#111" : "rgba(255,255,255,0.1)",
              border: scrolled ? "1px solid #111" : "1px solid rgba(255,255,255,0.25)",
              borderRadius: 26,
              height: 44,
              backdropFilter: scrolled ? "none" : "blur(12px)",
              WebkitBackdropFilter: scrolled ? "none" : "blur(12px)",
              transition: "background 0.4s ease, border-color 0.4s ease",
            }}
          >
            <motion.a
              href="#"
              whileHover={{ backgroundColor: scrolled ? "#fff" : "#fff", color: "#111" }}
              transition={{ duration: 0.3 }}
              style={{
                display: "flex",
                alignItems: "center",
                height: "100%",
                padding: "0 22px",
                gap: 7,
                color: scrolled ? "#fff" : "#fff",
                textDecoration: "none",
              }}
            >
              <span
                style={{
                  fontSize: 13,
                  fontWeight: 700,
                  letterSpacing: "0.5px",
                  whiteSpace: "nowrap",
                  color: "inherit",
                }}
              >
                무료 상담
              </span>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M5 12h14M12 5l7 7-7 7" />
              </svg>
            </motion.a>

            <div style={{ width: 1, height: 18, background: "rgba(255,255,255,0.15)" }} />

            <motion.button
              className="jm-icon-btn"
              whileTap={{ scale: 0.92 }}
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                height: "100%",
                width: 48,
                background: "none",
                border: "none",
                cursor: "pointer",
              }}
              aria-label="검색"
            >
              <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <circle cx="10.5" cy="10.5" r="7.5" />
                <path d="M21 21l-4-4" />
              </svg>
            </motion.button>

            <div style={{ width: 1, height: 18, background: "rgba(255,255,255,0.15)" }} />

            <motion.button
              className="jm-icon-btn"
              whileTap={{ scale: 0.92 }}
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                height: "100%",
                width: 48,
                background: "none",
                border: "none",
                cursor: "pointer",
              }}
              aria-label="메뉴"
            >
              <svg width="16" height="16" viewBox="0 0 16 16" fill="#fff">
                <rect x="0" y="0" width="3.5" height="3.5" rx="0.8" />
                <rect x="6.25" y="0" width="3.5" height="3.5" rx="0.8" />
                <rect x="12.5" y="0" width="3.5" height="3.5" rx="0.8" />
                <rect x="0" y="6.25" width="3.5" height="3.5" rx="0.8" />
                <rect x="6.25" y="6.25" width="3.5" height="3.5" rx="0.8" />
                <rect x="12.5" y="6.25" width="3.5" height="3.5" rx="0.8" />
                <rect x="0" y="12.5" width="3.5" height="3.5" rx="0.8" />
                <rect x="6.25" y="12.5" width="3.5" height="3.5" rx="0.8" />
                <rect x="12.5" y="12.5" width="3.5" height="3.5" rx="0.8" />
              </svg>
            </motion.button>
          </div>
        </div>
      </div>
    </motion.header>
  );
}
