# STUDYON TV Display Web

TV 디스플레이용 Next.js 16 앱이다. 현재는 standalone 배포 기준으로 빌드할 수 있게 준비되어 있다.

## Local run

```bash
npm install
npm run dev
```

기본 개발 포트는 `11112`다.

## Production build

```bash
npm run build
```

standalone 배포 런타임과 정적 파일까지 포함하려면 루트 스크립트를 사용한다.

```bash
cd /Users/bagjun-won/studyon
./scripts/build_web_release.sh
```

실행:

```bash
PORT=11112 HOSTNAME=0.0.0.0 node .next/standalone/server.js
```

## Environment

- `PORT`: server port
- `HOSTNAME`: bind address

예시는 [.env.example](/Users/bagjun-won/studyon/apps/tv_display_web/.env.example:1)에 있다.
