# 자습ON Landing

Marketing landing + Privacy/Support pages for the 자습ON app.

## Stack
- Next.js 16 (App Router, webpack build) · React 19 · Tailwind CSS 4 · TypeScript
- Standalone output, containerized via the included `Dockerfile` (port 12222)

## Pages
- `/` — marketing hero, features, privacy preview, CTA
- `/privacy` — privacy policy (App Store / Play Store ready)
- `/support` — FAQ, contact email, quick links

## Local development

```bash
npm install
npm run dev   # http://localhost:12222
```

## Production build

```bash
npm run build
npm run start # runs next start on port 12222
```

## Deploy

Via `@3xhaust/deploy-cli`, project name `studyon-landing`, domain `studyon-landing.hyphen.it.com` (or a custom domain configured in the deploy platform).

```bash
deploy deploy studyon-landing
```
