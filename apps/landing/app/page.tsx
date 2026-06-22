import Image from 'next/image';
import Link from 'next/link';

const captures = [
  {
    src: '/studyon/ios/onboarding-time.png',
    title: '학습 시간 관리',
    body: '공부 시작부터 종료까지 자동으로 기록하고 분석해요',
  },
  {
    src: '/studyon/ios/onboarding-seat.png',
    title: '스마트 좌석',
    body: '실시간 좌석 현황을 확인하고 바로 착석해요',
  },
  {
    src: '/studyon/ios/onboarding-growth.png',
    title: '랭킹 & 성장',
    body: '친구들과 경쟁하며 매일 성장하는 나를 확인해요',
  },
];

export default function HomePage() {
  return (
    <>
      <section className="pick-hero">
        <div className="mass-logo" aria-hidden>
          STUDYON
        </div>
        <div className="center-copy">
          <p>자습실 집중을 켜는 가장 가벼운 앱</p>
          <h1>공부 시간, 좌석, 성장까지<br />한 번에 관리해요</h1>
          <Link href="#preview" className="pill-link">
            앱 미리보기
          </Link>
        </div>
        <div className="hero-peek" aria-hidden>
          <Image
            src="/studyon/ios/onboarding-time.png"
            alt=""
            width={472}
            height={1024}
            priority
          />
        </div>
      </section>

      <section id="preview" className="phone-showcase" aria-label="자습ON iOS 실제 실행 화면">
        <div className="floating-word word-left">FOCUS</div>
        <div className="floating-word word-right">GROWTH</div>
        <div className="capture-row">
          {captures.map((capture, index) => (
            <article className={`capture-card capture-${index + 1}`} key={capture.title}>
              <div className="device-shot">
                <Image
                  src={capture.src}
                  alt={`iOS 시뮬레이터에서 실행한 자습ON ${capture.title} 화면`}
                  width={472}
                  height={1024}
                  sizes="(max-width: 720px) 72vw, 310px"
                  priority={index === 1}
                />
              </div>
              <div className="caption">
                <strong>{capture.title}</strong>
                <span>{capture.body}</span>
              </div>
            </article>
          ))}
        </div>
      </section>

      <section className="soft-section">
        <div className="soft-copy">
          <p className="micro">NEW STUDY ROUTINE</p>
          <h2>켜놓기만 하는 앱이 아니라<br />다시 공부로 돌아오게 만드는 앱.</h2>
        </div>
        <div className="soft-grid">
          <div>
            <span>01</span>
            <strong>집중 복귀</strong>
            <p>iOS에서 강제 차단 대신 앱 이탈 기록과 복귀 알림으로 심사 안전성을 지킵니다.</p>
          </div>
          <div>
            <span>02</span>
            <strong>퀘스트 보상</strong>
            <p>입실, 공부 타이머, 목표 달성을 XP와 포인트로 연결합니다.</p>
          </div>
          <div>
            <span>03</span>
            <strong>테마 꾸미기</strong>
            <p>목표 이미지와 캐릭터 성장 화면으로 매일 보고 싶은 자습 화면을 만듭니다.</p>
          </div>
        </div>
      </section>

      <section className="character-strip">
        <div className="strip-logo">자습ON</div>
        <div className="character-line">
          {['stage_01', 'stage_02', 'stage_03', 'stage_04', 'stage_05'].map((stage, index) => (
            <Image
              key={stage}
              src={`/studyon/rpg/${stage}.png`}
              alt={`자습ON 성장 캐릭터 ${index + 1}단계`}
              width={180}
              height={180}
            />
          ))}
        </div>
      </section>

      <section className="policy-cta">
        <h2>심사에 필요한 페이지도 같은 톤으로 정리했어요.</h2>
        <div>
          <Link href="/privacy">개인정보 처리방침</Link>
          <Link href="/support">고객 지원</Link>
        </div>
      </section>
    </>
  );
}
