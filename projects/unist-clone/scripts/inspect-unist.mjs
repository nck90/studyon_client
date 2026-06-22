/* eslint-disable no-console */
// Inspection script for https://www.unist.ac.kr/unist/index.do
// Gathers screenshots, DOM skeleton, asset list, typography and scroll behavior data.
// Outputs everything under docs/research/unist-inspection/.

import { promises as fs } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(__dirname, '..');
const OUT_DIR = path.join(PROJECT_ROOT, 'docs/research/unist-inspection');

const TARGET_URL = 'https://www.unist.ac.kr/unist/index.do';
const VIEWPORT = { width: 1440, height: 900, deviceScaleFactor: 1 };

async function ensureDir(p) {
  await fs.mkdir(p, { recursive: true });
}

async function writeJson(file, data) {
  await fs.writeFile(file, JSON.stringify(data, null, 2), 'utf8');
}

async function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

async function loadPuppeteer() {
  // Try bundled puppeteer first
  try {
    const mod = await import('puppeteer');
    return { pptr: mod.default ?? mod, mode: 'puppeteer' };
  } catch (err) {
    console.warn('[warn] puppeteer import failed, trying puppeteer-core fallback:', err.message);
    const mod = await import('puppeteer-core');
    return { pptr: mod.default ?? mod, mode: 'puppeteer-core' };
  }
}

async function launchBrowser() {
  const { pptr, mode } = await loadPuppeteer();
  const launchOpts = {
    headless: 'new',
    defaultViewport: VIEWPORT,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--lang=ko-KR',
    ],
  };
  if (mode === 'puppeteer-core') {
    launchOpts.executablePath = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
  }
  console.log(`[info] launching ${mode}...`);
  const browser = await pptr.launch(launchOpts);
  return browser;
}

async function main() {
  await ensureDir(OUT_DIR);
  const browser = await launchBrowser();
  const page = await browser.newPage();

  await page.setViewport(VIEWPORT);
  await page.setExtraHTTPHeaders({ 'Accept-Language': 'ko-KR,ko;q=0.9' });
  await page.setUserAgent(
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
  );

  console.log(`[info] navigating to ${TARGET_URL} ...`);
  try {
    await page.goto(TARGET_URL, { waitUntil: 'networkidle2', timeout: 60000 });
  } catch (e) {
    console.warn('[warn] networkidle2 timed out, trying domcontentloaded continue:', e.message);
    try {
      await page.goto(TARGET_URL, { waitUntil: 'domcontentloaded', timeout: 60000 });
    } catch (e2) {
      console.error('[error] navigation failed entirely:', e2.message);
    }
  }

  // Allow hero animations to settle.
  await sleep(2500);

  // -----------------------------
  // 1. Full-page screenshot
  // -----------------------------
  const fullShotPath = path.join(OUT_DIR, '01-full.png');
  console.log('[info] full-page screenshot ->', fullShotPath);
  try {
    await page.screenshot({ path: fullShotPath, fullPage: true });
  } catch (e) {
    console.warn('[warn] full-page screenshot failed:', e.message);
  }

  // -----------------------------
  // 2. Scroll-stepped viewport screenshots (every 100vh)
  // -----------------------------
  const docMetrics = await page.evaluate(() => ({
    scrollHeight: document.body.scrollHeight,
    innerHeight: window.innerHeight,
    innerWidth: window.innerWidth,
  }));
  console.log('[info] doc metrics', docMetrics);

  const stepSize = docMetrics.innerHeight; // 100vh
  const maxScroll = Math.max(0, docMetrics.scrollHeight - docMetrics.innerHeight);
  const steps = Math.ceil(docMetrics.scrollHeight / stepSize);

  for (let i = 0; i < steps; i++) {
    const y = Math.min(i * stepSize, maxScroll);
    await page.evaluate((yy) => {
      window.scrollTo({ top: yy, behavior: 'auto' });
    }, y);
    await sleep(650); // settle for transitions/lazy-load
    const label = y === 0 ? '000' : `${Math.round(y)}`;
    const file = path.join(OUT_DIR, `02-scroll-${label}.png`);
    try {
      await page.screenshot({ path: file, fullPage: false });
      console.log(`[info] scroll shot y=${y} -> ${path.basename(file)}`);
    } catch (e) {
      console.warn('[warn] scroll shot failed at y=', y, e.message);
    }
  }

  // Reset scroll to top for DOM dumps
  await page.evaluate(() => window.scrollTo(0, 0));
  await sleep(300);

  // -----------------------------
  // 3. Document dimensions & sections
  // -----------------------------
  const dimensions = await page.evaluate(() => {
    const candidates = Array.from(
      document.querySelectorAll(
        'section, [class*="section"], [class*="Section"], main > div, main > section, article, .swiper, .slider, .visual, .main-visual'
      )
    );
    const seen = new Set();
    const sections = [];
    for (const el of candidates) {
      if (seen.has(el)) continue;
      seen.add(el);
      const rect = el.getBoundingClientRect();
      if (rect.height < 150) continue; // skip tiny
      sections.push({
        tag: el.tagName.toLowerCase(),
        id: el.id || null,
        className: el.className && typeof el.className === 'string' ? el.className : null,
        top: Math.round(rect.top + window.scrollY),
        left: Math.round(rect.left + window.scrollX),
        width: Math.round(rect.width),
        height: Math.round(rect.height),
      });
    }
    return {
      bodyScrollHeight: document.body.scrollHeight,
      documentScrollHeight: document.documentElement.scrollHeight,
      innerHeight: window.innerHeight,
      innerWidth: window.innerWidth,
      sectionCount: sections.length,
      sections,
    };
  });
  await writeJson(path.join(OUT_DIR, 'dimensions.json'), dimensions);

  // -----------------------------
  // 4. DOM skeleton
  // -----------------------------
  const skeleton = await page.evaluate(() => {
    function trimTree(el, depth, maxDepth) {
      if (!el || el.nodeType !== 1) return '';
      const tag = el.tagName.toLowerCase();
      const attrs = Array.from(el.attributes)
        .filter((a) => ['id', 'class', 'role', 'href', 'src', 'aria-label', 'data-swiper', 'data-aos', 'data-scroll'].includes(a.name) || a.name.startsWith('data-'))
        .map((a) => `${a.name}="${String(a.value).slice(0, 120)}"`)
        .join(' ');
      const open = attrs ? `<${tag} ${attrs}>` : `<${tag}>`;
      if (depth >= maxDepth) {
        const text = (el.textContent || '').trim().slice(0, 60);
        return `${open}${text ? `<!-- text: ${text.replace(/\n/g, ' ')} -->` : ''}</${tag}>`;
      }
      const children = Array.from(el.children);
      if (!children.length) {
        const text = (el.textContent || '').trim().slice(0, 120);
        return `${open}${text ? text.replace(/</g, '&lt;') : ''}</${tag}>`;
      }
      const inner = children.map((c) => trimTree(c, depth + 1, maxDepth)).join('\n');
      return `${open}\n${inner
        .split('\n')
        .map((l) => '  ' + l)
        .join('\n')}\n</${tag}>`;
    }
    const header = document.querySelector('header');
    const footer = document.querySelector('footer');
    const main =
      document.querySelector('main') ||
      document.querySelector('#container') ||
      document.querySelector('#content') ||
      document.body;
    return {
      header: header ? trimTree(header, 0, 4) : '',
      footer: footer ? trimTree(footer, 0, 4) : '',
      mainSelector: main ? (main.id ? `#${main.id}` : main.tagName.toLowerCase()) : null,
      mainChildren: main
        ? Array.from(main.children).slice(0, 20).map((c) => trimTree(c, 0, 4)).join('\n\n')
        : '',
      title: document.title,
      lang: document.documentElement.lang,
    };
  });

  const skeletonHtml = [
    `<!-- TITLE: ${skeleton.title} | LANG: ${skeleton.lang} -->`,
    '',
    '<!-- ==== HEADER ==== -->',
    skeleton.header,
    '',
    `<!-- ==== MAIN (${skeleton.mainSelector}) children ==== -->`,
    skeleton.mainChildren,
    '',
    '<!-- ==== FOOTER ==== -->',
    skeleton.footer,
    '',
  ].join('\n');
  await fs.writeFile(path.join(OUT_DIR, 'dom-skeleton.html'), skeletonHtml, 'utf8');

  // -----------------------------
  // 5. Asset list
  // -----------------------------
  const assets = await page.evaluate(() => {
    const stylesheets = Array.from(document.querySelectorAll('link[rel="stylesheet"]')).map(
      (l) => l.href
    );
    const scripts = Array.from(document.querySelectorAll('script[src]')).map((s) => s.src);
    const inlineScriptPreviews = Array.from(document.querySelectorAll('script:not([src])'))
      .map((s) => (s.textContent || '').trim().slice(0, 200))
      .filter(Boolean)
      .slice(0, 30);

    const libHints = {};
    const needles = [
      'swiper',
      'gsap',
      'scrolltrigger',
      'lenis',
      'locomotive',
      'scrollmagic',
      'aos',
      'framer',
      'splitting',
      'splittype',
      'barba',
      'jquery',
      'bootstrap',
      'slick',
      'owl',
      'fullpage',
      'three',
      'lottie',
      'anime',
    ];
    const all = [...stylesheets, ...scripts].map((u) => u.toLowerCase());
    for (const n of needles) {
      const hits = all.filter((u) => u.includes(n));
      if (hits.length) libHints[n] = hits;
    }
    const resources = performance.getEntriesByType('resource').map((r) => ({
      name: r.name,
      type: r.initiatorType,
      transferSize: r.transferSize,
      duration: Math.round(r.duration),
    }));
    return { stylesheets, scripts, inlineScriptPreviews, libHints, resources };
  });
  await writeJson(path.join(OUT_DIR, 'assets.json'), assets);

  // -----------------------------
  // 6. Marquee / animated elements
  // -----------------------------
  const animated = await page.evaluate(() => {
    const results = [];
    const all = document.querySelectorAll('*');
    let scanned = 0;
    for (const el of all) {
      scanned++;
      if (scanned > 4000) break;
      const cs = getComputedStyle(el);
      const name = cs.animationName;
      const dur = cs.animationDuration;
      if (name && name !== 'none' && dur && dur !== '0s') {
        const sel = el.id
          ? `#${el.id}`
          : el.className && typeof el.className === 'string'
            ? `${el.tagName.toLowerCase()}.${el.className.split(/\s+/).filter(Boolean).slice(0, 2).join('.')}`
            : el.tagName.toLowerCase();
        results.push({
          selector: sel,
          tag: el.tagName.toLowerCase(),
          animationName: name,
          animationDuration: dur,
          animationTimingFunction: cs.animationTimingFunction,
          animationIterationCount: cs.animationIterationCount,
          transform: cs.transform !== 'none' ? cs.transform.slice(0, 60) : null,
          willChange: cs.willChange,
        });
        if (results.length > 50) break;
      }
    }
    return results;
  });
  await writeJson(path.join(OUT_DIR, 'animations.json'), animated);

  // -----------------------------
  // 7. Typography per section heading
  // -----------------------------
  const typography = await page.evaluate(() => {
    const sections = Array.from(
      document.querySelectorAll(
        'section, [class*="section"], [class*="Section"], main > div, main > section'
      )
    ).slice(0, 12);
    const out = [];
    for (const sec of sections) {
      const heading = sec.querySelector('h1, h2, h3');
      if (!heading) continue;
      const cs = getComputedStyle(heading);
      const rect = heading.getBoundingClientRect();
      out.push({
        section: sec.id || (typeof sec.className === 'string' ? sec.className.slice(0, 80) : sec.tagName.toLowerCase()),
        headingTag: heading.tagName.toLowerCase(),
        text: (heading.textContent || '').trim().slice(0, 100),
        fontFamily: cs.fontFamily,
        fontSize: cs.fontSize,
        fontWeight: cs.fontWeight,
        letterSpacing: cs.letterSpacing,
        lineHeight: cs.lineHeight,
        color: cs.color,
        textTransform: cs.textTransform,
        topOffset: Math.round(rect.top + window.scrollY),
      });
      if (out.length >= 10) break;
    }
    // Additionally gather body/base font-family.
    const body = document.body;
    const bcs = getComputedStyle(body);
    return {
      body: {
        fontFamily: bcs.fontFamily,
        fontSize: bcs.fontSize,
        fontWeight: bcs.fontWeight,
        lineHeight: bcs.lineHeight,
        color: bcs.color,
        background: bcs.backgroundColor,
      },
      headings: out,
    };
  });
  await writeJson(path.join(OUT_DIR, 'typography.json'), typography);

  // -----------------------------
  // 8. Scroll / overflow behaviors
  // -----------------------------
  const scrollBehavior = await page.evaluate(() => {
    const html = document.documentElement;
    const body = document.body;
    const hcs = getComputedStyle(html);
    const bcs = getComputedStyle(body);
    // Sample a few cards for transition/will-change
    const cardSelectors = [
      'a', 'article', '.card', '[class*="card"]', '[class*="Card"]', '.news', '.item', '[class*="thumb"]'
    ];
    const cardSamples = [];
    const seen = new Set();
    for (const sel of cardSelectors) {
      const nodes = document.querySelectorAll(sel);
      let count = 0;
      for (const n of nodes) {
        if (count >= 3) break;
        if (seen.has(n)) continue;
        seen.add(n);
        const cs = getComputedStyle(n);
        if (cs.transition && cs.transition !== 'all 0s ease 0s' && cs.transition !== 'none 0s ease 0s') {
          cardSamples.push({
            selector: sel,
            tag: n.tagName.toLowerCase(),
            className: (typeof n.className === 'string' ? n.className : '').slice(0, 80),
            transition: cs.transition.slice(0, 200),
            transform: cs.transform.slice(0, 60),
            willChange: cs.willChange,
            cursor: cs.cursor,
          });
          count++;
        }
      }
    }
    return {
      html: {
        scrollSnapType: hcs.scrollSnapType,
        scrollBehavior: hcs.scrollBehavior,
        overflow: hcs.overflow,
        overflowY: hcs.overflowY,
      },
      body: {
        overflow: bcs.overflow,
        overflowY: bcs.overflowY,
        scrollBehavior: bcs.scrollBehavior,
      },
      cardSamples,
    };
  });
  await writeJson(path.join(OUT_DIR, 'scroll-behavior.json'), scrollBehavior);

  console.log('[info] done. artifacts in', OUT_DIR);
  await browser.close();
}

main().catch((err) => {
  console.error('[fatal]', err);
  process.exit(1);
});
