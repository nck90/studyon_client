#!/usr/bin/env node
// ONE store portal automation starter.
// Inspect the live portal once, then replace selectors if the account UI differs.
// Keep credentials in environment variables or CI secrets.

import { chromium } from "playwright";

const config = {
  portalUrl: process.env.ONESTORE_PORTAL_URL || "https://dev.onestore.co.kr/",
  username: process.env.ONESTORE_USERNAME,
  password: process.env.ONESTORE_PASSWORD,
  packageName:
    process.env.ONESTORE_PACKAGE_NAME || "com.studyon.studyon_client",
  artifactPath:
    process.env.ONESTORE_ARTIFACT_PATH ||
    "build/app/outputs/bundle/release/app-release.aab",
  submitForVerification:
    process.env.ONESTORE_SUBMIT_FOR_VERIFICATION === "true",
};

for (const [key, value] of Object.entries(config)) {
  if (!value && key !== "submitForVerification") {
    throw new Error(`Missing required config: ${key}`);
  }
}

const browser = await chromium.launch({ headless: false });
const context = await browser.newContext();
const page = await context.newPage();

try {
  await page.goto(config.portalUrl, { waitUntil: "domcontentloaded" });

  await page.getByLabel(/id|email|account|아이디|이메일/i).fill(config.username);
  await page.getByLabel(/password|비밀번호/i).fill(config.password);
  await page.getByRole("button", { name: /login|로그인/i }).click();
  await page.waitForLoadState("networkidle");

  await page
    .getByRole("textbox", { name: /search|검색/i })
    .fill(config.packageName);
  await page.keyboard.press("Enter");
  await page.getByText(config.packageName, { exact: false }).click();

  await page.getByRole("link", { name: /binary|바이너리|apk|aab/i }).click();
  await page.getByRole("button", { name: /upload|등록|수정|변경/i }).click();
  await page.setInputFiles('input[type="file"]', config.artifactPath);
  await page.getByRole("button", { name: /save|저장|next|다음/i }).click();
  await page.waitForLoadState("networkidle");

  if (config.submitForVerification) {
    await page
      .getByRole("button", { name: /submit|검수|심사|verification|제출/i })
      .click();
    await page
      .getByRole("button", { name: /confirm|확인|submit|제출/i })
      .click();
  }

  console.log("ONE store portal automation reached requested end state.");
} finally {
  await context.close();
  await browser.close();
}
