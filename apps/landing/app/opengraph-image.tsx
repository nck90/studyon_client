import { ImageResponse } from 'next/og';

export const runtime = 'edge';
export const alt = '자습ON — 학원 자습실 스마트 관리';
export const size = { width: 1200, height: 630 };
export const contentType = 'image/png';

export default function Image() {
  return new ImageResponse(
    (
      <div
        style={{
          width: '100%',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          padding: '80px',
          background:
            'radial-gradient(800px 400px at 20% 20%, rgba(108,92,231,0.35), transparent 60%), radial-gradient(600px 300px at 80% 80%, rgba(162,155,254,0.25), transparent 60%), #0B0B12',
          color: 'white',
        }}
      >
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 16,
            fontSize: 28,
            fontWeight: 800,
            letterSpacing: '-0.03em',
            color: '#A29BFE',
          }}
        >
          <div
            style={{
              width: 36,
              height: 36,
              borderRadius: 10,
              background: '#6C5CE7',
            }}
          />
          자습ON
        </div>
        <div
          style={{
            marginTop: 40,
            fontSize: 88,
            fontWeight: 800,
            letterSpacing: '-0.04em',
            lineHeight: 1.05,
          }}
        >
          집중은 스스로,
          <br />
          기록은 자습ON이.
        </div>
        <div
          style={{
            marginTop: 36,
            fontSize: 26,
            fontWeight: 500,
            color: '#C6C3D6',
            letterSpacing: '-0.02em',
          }}
        >
          학원 자습실 전용 학습 관리 · iOS · Android
        </div>
      </div>
    ),
    { ...size },
  );
}
