#!/usr/bin/env node
// Scrape brand images for 진수학 (True Math) from Instagram + Naver Blog.
// Saves images to public/images/brand/ as brand-NN.jpg and writes manifest.json.

import puppeteer from "puppeteer";
import { promises as fs } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(__dirname, "..");
const BRAND_DIR = path.join(PROJECT_ROOT, "public", "images", "brand");
const DEBUG_DIR = path.join(BRAND_DIR, "_debug");

const USER_AGENT =
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36";
const ACCEPT_LANG = "ko-KR,ko;q=0.9";

const IG_URL = "https://www.instagram.com/truemath10000/";
const NAVER_URL =
  "https://blog.naver.com/truemath10000/222226279953";
const NAVER_POST_VIEW =
  "https://blog.naver.com/PostView.naver?blogId=truemath10000&logNo=222226279953";

const MAX_TOTAL = 40;
const MAX_BYTES = 20 * 1024 * 1024; // 20 MB

let totalBytes = 0;

async function ensureDirs() {
  await fs.mkdir(BRAND_DIR, { recursive: true });
  await fs.mkdir(DEBUG_DIR, { recursive: true });
}

function extFromContentType(ct) {
  if (!ct) return "jpg";
  if (ct.includes("png")) return "png";
  if (ct.includes("webp")) return "jpg"; // we coerce to .jpg extension per spec
  if (ct.includes("gif")) return "gif";
  return "jpg";
}

async function downloadImage(page, url) {
  // Use page.evaluate with fetch so we inherit cookies/referrer when needed.
  try {
    const result = await page.evaluate(async (u) => {
      try {
        const res = await fetch(u, { credentials: "include" });
        if (!res.ok) return { ok: false, status: res.status };
        const blob = await res.blob();
        const buf = await blob.arrayBuffer();
        let binary = "";
        const bytes = new Uint8Array(buf);
        const chunk = 0x8000;
        for (let i = 0; i < bytes.length; i += chunk) {
          binary += String.fromCharCode.apply(
            null,
            bytes.subarray(i, i + chunk)
          );
        }
        return {
          ok: true,
          contentType: res.headers.get("content-type") || "",
          base64: btoa(binary),
          size: bytes.length,
        };
      } catch (e) {
        return { ok: false, error: String(e) };
      }
    }, url);
    if (!result || !result.ok) return null;
    const buffer = Buffer.from(result.base64, "base64");
    return { buffer, contentType: result.contentType, size: result.size };
  } catch (e) {
    return null;
  }
}

async function downloadDirect(url, referer) {
  try {
    const res = await fetch(url, {
      headers: {
        "User-Agent": USER_AGENT,
        "Accept-Language": ACCEPT_LANG,
        Referer: referer || "",
      },
    });
    if (!res.ok) return null;
    const ct = res.headers.get("content-type") || "";
    const ab = await res.arrayBuffer();
    return { buffer: Buffer.from(ab), contentType: ct, size: ab.byteLength };
  } catch (e) {
    return null;
  }
}

async function measureImage(page, url) {
  // Returns {width, height} if possible without downloading full binary twice.
  try {
    return await page.evaluate(
      (u) =>
        new Promise((resolve) => {
          const img = new Image();
          img.onload = () =>
            resolve({ width: img.naturalWidth, height: img.naturalHeight });
          img.onerror = () => resolve(null);
          img.src = u;
          setTimeout(() => resolve(null), 7000);
        }),
      url
    );
  } catch {
    return null;
  }
}

async function scrapeInstagram(browser, entries, counters) {
  const page = await browser.newPage();
  await page.setUserAgent(USER_AGENT);
  await page.setExtraHTTPHeaders({ "Accept-Language": ACCEPT_LANG });
  await page.setViewport({ width: 1280, height: 900 });

  try {
    console.log("[instagram] navigating", IG_URL);
    await page.goto(IG_URL, { waitUntil: "domcontentloaded", timeout: 60000 });
    await new Promise((r) => setTimeout(r, 3000));

    // Gather og:image + any article img + any visible <img>
    const candidates = await page.evaluate(() => {
      const out = [];
      const push = (url, alt) => {
        if (!url) return;
        out.push({ url, alt: alt || "" });
      };
      document
        .querySelectorAll('meta[property="og:image"], meta[name="og:image"]')
        .forEach((m) => push(m.getAttribute("content"), "og:image"));
      document.querySelectorAll("article img").forEach((i) => {
        push(i.getAttribute("src"), i.getAttribute("alt") || "");
      });
      document.querySelectorAll("img").forEach((i) => {
        const src = i.getAttribute("src");
        if (src && src.startsWith("http")) {
          push(src, i.getAttribute("alt") || "");
        }
      });
      return out;
    });

    // Detect login wall
    const bodyText = await page.evaluate(() => document.body.innerText || "");
    const loginWall =
      /log in|로그인|Instagram에 가입하세요|See photos and videos/i.test(
        bodyText
      ) && candidates.length < 3;

    if (loginWall) {
      console.log("[instagram] login wall detected - capturing debug HTML");
      const html = await page.content();
      await fs.writeFile(
        path.join(DEBUG_DIR, "instagram-login-wall.html"),
        html,
        "utf8"
      );
    }

    console.log(
      `[instagram] found ${candidates.length} candidate img URLs (loginWall=${loginWall})`
    );

    // Dedup + filter
    const seen = new Set();
    for (const c of candidates) {
      if (!c.url) continue;
      if (seen.has(c.url)) continue;
      seen.add(c.url);
      // Skip obvious avatars / icons (profile pic thumbnails are usually s150x150 or similar)
      if (/s150x150|s320x320|profile_pic/i.test(c.url)) continue;
      if (entries.length >= MAX_TOTAL) break;
      if (totalBytes >= MAX_BYTES) break;

      const dim = await measureImage(page, c.url);
      if (!dim) {
        console.log("[instagram] skip (cannot measure)", c.url.slice(0, 80));
        continue;
      }
      if (dim.width < 400 || dim.height < 200) {
        console.log(
          `[instagram] skip small ${dim.width}x${dim.height}`,
          c.url.slice(0, 80)
        );
        continue;
      }

      const dl = (await downloadImage(page, c.url)) ||
        (await downloadDirect(c.url, IG_URL));
      if (!dl) {
        console.log("[instagram] download failed", c.url.slice(0, 80));
        continue;
      }
      if (dl.size < 10_000) {
        console.log("[instagram] skip tiny bytes", dl.size);
        continue;
      }
      if (totalBytes + dl.size > MAX_BYTES) {
        console.log("[instagram] byte budget reached");
        break;
      }

      const idx = ++counters.n;
      const ext = extFromContentType(dl.contentType);
      const filename = `brand-${String(idx).padStart(2, "0")}.${
        ext === "gif" ? "gif" : "jpg"
      }`;
      await fs.writeFile(path.join(BRAND_DIR, filename), dl.buffer);
      totalBytes += dl.size;
      entries.push({
        filename,
        source: "instagram",
        alt: c.alt,
        url: c.url,
        width: dim.width,
        height: dim.height,
      });
      console.log(
        `[instagram] saved ${filename} (${dim.width}x${dim.height}, ${(
          dl.size / 1024
        ).toFixed(1)}KB)`
      );
    }
  } catch (err) {
    console.error("[instagram] fatal:", err.message);
    try {
      const html = await page.content();
      await fs.writeFile(
        path.join(DEBUG_DIR, "instagram-error.html"),
        html,
        "utf8"
      );
    } catch {}
  } finally {
    await page.close();
  }
}

async function scrapeNaver(browser, entries, counters) {
  const page = await browser.newPage();
  await page.setUserAgent(USER_AGENT);
  await page.setExtraHTTPHeaders({ "Accept-Language": ACCEPT_LANG });
  await page.setViewport({ width: 1280, height: 900 });

  let postTitle = "";
  try {
    console.log("[naver] navigating", NAVER_POST_VIEW);
    await page.goto(NAVER_POST_VIEW, {
      waitUntil: "domcontentloaded",
      timeout: 60000,
    });
    await new Promise((r) => setTimeout(r, 3000));

    // Title
    postTitle = await page.evaluate(() => {
      const t =
        document.querySelector(".se-title-text") ||
        document.querySelector(".pcol1") ||
        document.querySelector("title");
      return (t?.innerText || t?.textContent || "").trim();
    });
    console.log("[naver] post title:", postTitle);

    // Collect image URLs
    let candidates = await page.evaluate(() => {
      const imgs = Array.from(document.querySelectorAll("img"));
      return imgs
        .map((i) => ({
          src:
            i.getAttribute("data-lazy-src") ||
            i.getAttribute("data-src") ||
            i.getAttribute("src"),
          alt: i.getAttribute("alt") || "",
        }))
        .filter((x) => x.src && x.src.startsWith("http"));
    });

    // Also try the blog iframe approach if the direct post view yielded nothing.
    if (candidates.length === 0) {
      console.log("[naver] direct post view empty, trying iframe path");
      await page.goto(NAVER_URL, {
        waitUntil: "domcontentloaded",
        timeout: 60000,
      });
      await new Promise((r) => setTimeout(r, 3000));
      const frames = page.frames();
      for (const fr of frames) {
        if (/PostView/i.test(fr.url()) || fr.name() === "mainFrame") {
          try {
            const inFrame = await fr.evaluate(() => {
              return Array.from(document.querySelectorAll("img"))
                .map((i) => ({
                  src:
                    i.getAttribute("data-lazy-src") ||
                    i.getAttribute("data-src") ||
                    i.getAttribute("src"),
                  alt: i.getAttribute("alt") || "",
                }))
                .filter((x) => x.src && x.src.startsWith("http"));
            });
            candidates = candidates.concat(inFrame);
          } catch (e) {
            console.log("[naver] frame eval fail:", e.message);
          }
        }
      }
    }

    console.log(`[naver] found ${candidates.length} candidate img URLs`);

    const seen = new Set();
    for (const c of candidates) {
      let src = c.src;
      if (!src) continue;
      // Prefer full-resolution version: strip type=w80 etc. Naver CDN uses ?type=w800
      const originalSrc = src;
      src = src.replace(/\?type=w\d+.*$/i, "");
      src = src.replace(/&type=w\d+/i, "");
      if (seen.has(src)) continue;
      seen.add(src);

      if (entries.length >= MAX_TOTAL) break;
      if (totalBytes >= MAX_BYTES) break;

      // Skip avatars / small helper assets (profile_thumb, logo sprites)
      if (
        /storep-phinf|bs_static|sprite|icon|profile_thumb|ssl\.pstatic\.net\/static/i.test(
          src
        )
      ) {
        continue;
      }

      const dim = await measureImage(page, src);
      if (!dim) {
        console.log("[naver] skip unmeasured", src.slice(0, 80));
        continue;
      }
      if (dim.width < 400 || dim.height < 200) {
        console.log(
          `[naver] skip small ${dim.width}x${dim.height}`,
          src.slice(0, 80)
        );
        continue;
      }

      const dl =
        (await downloadImage(page, src)) ||
        (await downloadDirect(src, NAVER_URL));
      if (!dl) {
        console.log("[naver] download failed", src.slice(0, 80));
        continue;
      }
      if (dl.size < 10_000) {
        console.log("[naver] skip tiny bytes", dl.size);
        continue;
      }
      if (totalBytes + dl.size > MAX_BYTES) {
        console.log("[naver] byte budget reached");
        break;
      }

      const idx = ++counters.n;
      const ext = extFromContentType(dl.contentType);
      const filename = `brand-${String(idx).padStart(2, "0")}.${
        ext === "gif" ? "gif" : "jpg"
      }`;
      await fs.writeFile(path.join(BRAND_DIR, filename), dl.buffer);
      totalBytes += dl.size;
      entries.push({
        filename,
        source: "naver-blog",
        alt: c.alt || postTitle,
        url: originalSrc,
        width: dim.width,
        height: dim.height,
      });
      console.log(
        `[naver] saved ${filename} (${dim.width}x${dim.height}, ${(
          dl.size / 1024
        ).toFixed(1)}KB)`
      );
    }
  } catch (err) {
    console.error("[naver] fatal:", err.message);
    try {
      const html = await page.content();
      await fs.writeFile(
        path.join(DEBUG_DIR, "naver-error.html"),
        html,
        "utf8"
      );
    } catch {}
  } finally {
    await page.close();
  }
}

async function main() {
  await ensureDirs();

  const browser = await puppeteer.launch({
    headless: true,
    args: [
      "--no-sandbox",
      "--disable-setuid-sandbox",
      "--lang=ko-KR,ko",
    ],
  });

  const entries = [];
  const counters = { n: 0 };

  // Run Instagram first, then Naver - keep sequential so counters stay clean.
  try {
    await scrapeInstagram(browser, entries, counters);
  } catch (e) {
    console.error("[instagram] outer error:", e.message);
  }
  try {
    await scrapeNaver(browser, entries, counters);
  } catch (e) {
    console.error("[naver] outer error:", e.message);
  }

  await browser.close();

  // Write manifest
  const manifest = {};
  for (const e of entries) {
    manifest[e.filename] = {
      source: e.source,
      alt: e.alt,
      url: e.url,
      width: e.width,
      height: e.height,
    };
  }
  await fs.writeFile(
    path.join(BRAND_DIR, "manifest.json"),
    JSON.stringify(manifest, null, 2),
    "utf8"
  );

  const igCount = entries.filter((e) => e.source === "instagram").length;
  const nvCount = entries.filter((e) => e.source === "naver-blog").length;
  console.log("---- Summary ----");
  console.log(`Instagram: ${igCount}`);
  console.log(`Naver Blog: ${nvCount}`);
  console.log(`Total: ${entries.length}`);
  console.log(`Bytes: ${(totalBytes / 1024 / 1024).toFixed(2)} MB`);
  console.log(`Manifest: ${path.join(BRAND_DIR, "manifest.json")}`);
}

main().catch((e) => {
  console.error("FATAL:", e);
  process.exit(1);
});
