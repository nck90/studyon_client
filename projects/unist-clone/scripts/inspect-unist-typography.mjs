/* eslint-disable no-console */
// Secondary inspection script: deep-dive on typography & animations after scrolling.
// Runs headless, scrolls the page to trigger lazy content, then samples computed styles.

import { promises as fs } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import puppeteer from 'puppeteer';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUT_DIR = path.resolve(__dirname, '../docs/research/unist-inspection');

const TARGET_URL = 'https://www.unist.ac.kr/unist/index.do';
const VIEWPORT = { width: 1440, height: 900, deviceScaleFactor: 1 };

async function sleep(ms) { return new Promise((r) => setTimeout(r, ms)); }

async function main() {
  const browser = await puppeteer.launch({
    headless: 'new',
    defaultViewport: VIEWPORT,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--lang=ko-KR'],
  });
  const page = await browser.newPage();
  await page.setExtraHTTPHeaders({ 'Accept-Language': 'ko-KR,ko;q=0.9' });
  await page.setViewport(VIEWPORT);
  await page.setUserAgent(
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
  );
  console.log('[info] goto', TARGET_URL);
  await page.goto(TARGET_URL, { waitUntil: 'networkidle2', timeout: 60000 });
  await sleep(2500);

  // Scroll slowly down the page to trigger lazy animations/AOS elements
  const totalH = await page.evaluate(() => document.body.scrollHeight);
  const step = 600;
  for (let y = 0; y < totalH; y += step) {
    await page.evaluate((yy) => window.scrollTo({ top: yy, behavior: 'auto' }), y);
    await sleep(250);
  }
  await page.evaluate(() => window.scrollTo(0, 0));
  await sleep(600);

  // ---- Typography: target known wrappers + any headings ----
  const typo = await page.evaluate(() => {
    const wrappers = [
      '.main-visual-inner',
      '.main-content-inner01.kr',
      '.main-content-inner02',
      '.main-content-box03',
      '.main-content-inner04.kr',
      '.main-content-box05',
      '.main-content-inner06',
    ];
    const out = [];
    for (const sel of wrappers) {
      const sec = document.querySelector(sel);
      if (!sec) continue;
      // Pick heading candidates — h1/h2/h3, and also large text nodes
      const heads = sec.querySelectorAll('h1, h2, h3, h4, .tit, .title, strong, em, b, .main-tit, .sub-tit, .eng, .kor');
      const sampled = [];
      for (const h of heads) {
        if (sampled.length >= 5) break;
        const cs = getComputedStyle(h);
        const text = (h.textContent || '').trim();
        if (!text || text.length < 2) continue;
        if (parseFloat(cs.fontSize) < 16) continue; // skip tiny labels
        sampled.push({
          tag: h.tagName.toLowerCase(),
          className: (typeof h.className === 'string' ? h.className : '').slice(0, 80),
          text: text.slice(0, 80),
          fontFamily: cs.fontFamily,
          fontSize: cs.fontSize,
          fontWeight: cs.fontWeight,
          letterSpacing: cs.letterSpacing,
          lineHeight: cs.lineHeight,
          color: cs.color,
          textTransform: cs.textTransform,
        });
      }
      out.push({ section: sel, samples: sampled });
    }
    // Body fallback
    const bcs = getComputedStyle(document.body);
    return {
      body: {
        fontFamily: bcs.fontFamily,
        fontSize: bcs.fontSize,
        fontWeight: bcs.fontWeight,
        lineHeight: bcs.lineHeight,
        color: bcs.color,
        background: bcs.backgroundColor,
      },
      sections: out,
    };
  });
  await fs.writeFile(path.join(OUT_DIR, 'typography.json'), JSON.stringify(typo, null, 2));
  console.log('[info] typography sections:', typo.sections.length);

  // ---- Animations: broader scan (CSS animations + inline transforms + scroll-driven via GSAP) ----
  const anims = await page.evaluate(() => {
    const results = [];
    const nodes = document.querySelectorAll('*');
    let scanned = 0;
    for (const el of nodes) {
      scanned++;
      if (scanned > 8000) break;
      const cs = getComputedStyle(el);
      const animName = cs.animationName;
      const animDur = cs.animationDuration;
      const transition = cs.transition;
      const transform = cs.transform;
      const willChange = cs.willChange;
      const hasAnim = animName && animName !== 'none' && animDur && animDur !== '0s';
      const hasGSAPInline = el.getAttribute('style') && /translate|scale|rotate|opacity/i.test(el.getAttribute('style')) && el.style.cssText.includes('will-change');
      if (hasAnim || hasGSAPInline) {
        const sel = el.id
          ? `#${el.id}`
          : el.className && typeof el.className === 'string'
            ? `${el.tagName.toLowerCase()}.${el.className.split(/\s+/).filter(Boolean).slice(0, 2).join('.')}`
            : el.tagName.toLowerCase();
        results.push({
          selector: sel,
          animationName: animName,
          animationDuration: animDur,
          animationTimingFunction: cs.animationTimingFunction,
          animationIterationCount: cs.animationIterationCount,
          transition: transition.slice(0, 160),
          willChange,
          inlineStyle: (el.getAttribute('style') || '').slice(0, 160),
        });
        if (results.length > 80) break;
      }
    }
    // Also look for marquee class names
    const marqueeEls = Array.from(document.querySelectorAll('[class*="marquee"], [class*="rolling"], [class*="ticker"]')).slice(0, 20).map((el) => ({
      tag: el.tagName.toLowerCase(),
      className: typeof el.className === 'string' ? el.className : '',
      width: el.getBoundingClientRect().width,
    }));
    return { animated: results, marqueeCandidates: marqueeEls };
  });
  await fs.writeFile(path.join(OUT_DIR, 'animations.json'), JSON.stringify(anims, null, 2));
  console.log('[info] animated elements:', anims.animated.length, 'marquee candidates:', anims.marqueeCandidates.length);

  // ---- Lenis / ScrollTrigger detection at runtime ----
  const runtime = await page.evaluate(() => {
    const w = window;
    return {
      hasLenis: Boolean(w.Lenis || w.lenis),
      hasGSAP: Boolean(w.gsap),
      hasScrollTrigger: Boolean(w.ScrollTrigger),
      hasAOS: Boolean(w.AOS),
      hasSwiper: Boolean(w.Swiper),
      hasJQueryMarquee: Boolean(w.jQuery && w.jQuery.fn && w.jQuery.fn.marquee),
      userAgent: navigator.userAgent,
      innerWidth: w.innerWidth,
      innerHeight: w.innerHeight,
      scrollBehavior: getComputedStyle(document.documentElement).scrollBehavior,
      htmlOverflow: getComputedStyle(document.documentElement).overflow,
      bodyOverflow: getComputedStyle(document.body).overflow,
      lenisOnHtml: document.documentElement.classList.contains('lenis'),
      lenisScrollingClass: document.documentElement.className,
    };
  });
  await fs.writeFile(path.join(OUT_DIR, 'runtime.json'), JSON.stringify(runtime, null, 2));
  console.log('[info] runtime detect', runtime);

  // ---- Grid / container widths ----
  const layout = await page.evaluate(() => {
    const probes = [
      '.wrap.main-page',
      '.main-container',
      '.main-content-wrap01',
      '.main-content-wrap02',
      '.main-content-wrap03',
      '.main-content-wrap04',
      '.main-content-wrap05',
      '.main-content-wrap06',
      '.footer-wrap',
      '.header-wrap',
    ];
    return probes.map((sel) => {
      const el = document.querySelector(sel);
      if (!el) return { sel, found: false };
      const r = el.getBoundingClientRect();
      const cs = getComputedStyle(el);
      return {
        sel,
        found: true,
        top: Math.round(r.top + window.scrollY),
        width: Math.round(r.width),
        height: Math.round(r.height),
        maxWidth: cs.maxWidth,
        paddingTop: cs.paddingTop,
        paddingBottom: cs.paddingBottom,
        paddingLeft: cs.paddingLeft,
        paddingRight: cs.paddingRight,
        background: cs.backgroundColor,
        display: cs.display,
      };
    });
  });
  await fs.writeFile(path.join(OUT_DIR, 'layout.json'), JSON.stringify(layout, null, 2));

  await browser.close();
  console.log('[info] done.');
}

main().catch((e) => { console.error(e); process.exit(1); });
