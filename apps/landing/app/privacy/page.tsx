import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: '개인정보 처리방침',
  description:
    '자습ON이 수집·이용·보관하는 개인정보의 종류, 목적, 보유 기간 및 이용자의 권리에 대한 안내입니다.',
};

const UPDATED = '2026-04-22';
const EFFECTIVE = '2026-05-01';

export default function PrivacyPage() {
  return (
    <section className="bg-[#fffdf7]">
      <div className="mx-auto max-w-3xl px-5 pt-14 pb-24">
        <p className="text-[13px] font-black uppercase text-[#17483a]">
          Privacy Policy
        </p>
        <h1 className="mt-3 text-3xl font-black text-[#14120f] sm:text-4xl">
          개인정보 처리방침
        </h1>
        <p className="mt-3 text-[14px] text-[#5f645f]">
          최종 수정일 {UPDATED} · 시행일 {EFFECTIVE}
        </p>

        <div className="prose-kr mt-10">
          <p>
            hyphen(이하 &quot;회사&quot;)은 모바일 앱 <strong>자습ON</strong>(이하
            &quot;서비스&quot;)을 제공하면서 이용자의 개인정보 보호를 중요하게 생각하며,
            「개인정보 보호법」 등 관련 법령을 준수합니다. 본 방침은 회사가 어떤 정보를
            수집하고 어떻게 이용·보관·파기하는지, 그리고 이용자가 어떤 권리를 가지는지를
            설명합니다.
          </p>

          <h2>1. 수집하는 개인정보 항목</h2>
          <p>서비스는 다음 항목을 수집합니다.</p>
          <ul>
            <li>
              <strong>필수</strong> — 로그인 아이디, 비밀번호(해시 저장), 이름, 학번, 학년/반
            </li>
            <li>
              <strong>선택</strong> — 전화번호, 프로필 이미지
            </li>
            <li>
              <strong>서비스 이용 기록</strong> — 입실/퇴실 시각, 좌석 배정, 학습 시간,
              과목별 학습량, 계획 달성률, 알림 수신 기록
            </li>
            <li>
              <strong>기기 정보</strong> — 기기 식별자(Device Code), OS 종류 및 버전,
              앱 버전, 접속 IP 주소, 접속 시간
            </li>
            <li>
              <strong>이미지</strong> — 이용자가 직접 선택한 입실 화면 배경 이미지(기기
              내부 저장, 서버 전송 없음)
            </li>
          </ul>
          <p>
            회사는 민감정보(건강, 종교, 사상, 정치적 견해 등) 및 주민등록번호를 수집하지
            않습니다.
          </p>

          <h2>2. 수집 방법</h2>
          <ul>
            <li>회원가입 및 학원 관리자 초대 시 이용자 직접 입력</li>
            <li>서비스 이용 과정에서 자동 생성·기록</li>
            <li>학원 관리자(운영자)에 의한 최초 등록</li>
          </ul>

          <h2>3. 이용 목적</h2>
          <ul>
            <li>
              <strong>서비스 제공</strong> — 로그인, 학원 자습실 출석 관리, 좌석 배정,
              학습 시간 측정, 학습 계획 관리, 학원 내 랭킹 산정
            </li>
            <li>
              <strong>학습 인사이트 제공</strong> — 개인 리포트, 추천 학습량, 과목 밸런스
              분석
            </li>
            <li>
              <strong>서비스 품질 관리</strong> — 오류 원인 분석, 서비스 안정성 확보, 부정
              이용 방지
            </li>
            <li>
              <strong>고객 문의 대응</strong> — 이메일 문의에 대한 응답, 장애/불만 처리
            </li>
          </ul>
          <p>
            회사는 수집 시점에 고지한 목적 외의 용도로 이용자의 개인정보를 이용하지
            않습니다.
          </p>

          <h2>4. 보유 및 이용 기간</h2>
          <ul>
            <li>
              <strong>회원 정보</strong> — 탈퇴 시까지. 탈퇴 즉시 지체 없이 파기.
            </li>
            <li>
              <strong>학습 기록</strong> — 소속 학원과의 서비스 계약 기간 동안. 학원
              계약 종료 시 익명화 또는 파기.
            </li>
            <li>
              <strong>접속 로그(IP·기기)</strong> — 관련 법령에 따라 최대 3개월 보관 후
              파기.
            </li>
            <li>
              <strong>법령 상 보존 의무</strong> — 「전자상거래 등에서의 소비자보호에 관한
              법률」 등 관련 법령이 요구하는 경우 해당 기간 동안 보관.
            </li>
          </ul>

          <h2>5. 제3자 제공 및 처리 위탁</h2>
          <p>
            회사는 이용자의 개인정보를 외부 제3자에게 판매하거나 마케팅 목적으로 제공하지
            않습니다. 다만, 안정적인 서비스 운영을 위해 다음과 같은 업무를 위탁할 수
            있으며, 이 경우 수탁자·업무 범위를 본 방침에 명시하고 관리·감독합니다.
          </p>
          <ul>
            <li>
              <strong>클라우드 인프라</strong> — 서비스 서버 호스팅 및 데이터베이스 운영
            </li>
            <li>
              <strong>모니터링·로그 분석</strong> — 장애 탐지 및 서비스 품질 관리
            </li>
          </ul>
          <p>
            법령에 따라 수사 기관이 영장에 근거해 요청하는 경우에 한해 관계 기관에
            제공될 수 있습니다.
          </p>

          <h2>6. 국외 이전</h2>
          <p>
            현재 자습ON은 국내 리전의 인프라에 데이터를 저장합니다. 국외 이전이 필요한
            변경이 발생할 경우 본 방침을 사전에 개정·공지합니다.
          </p>

          <h2>7. 이용자의 권리와 행사 방법</h2>
          <p>이용자는 언제든지 다음 권리를 행사할 수 있습니다.</p>
          <ul>
            <li>개인정보 열람 및 정정 요청</li>
            <li>회원 탈퇴 및 개인정보 삭제 요청</li>
            <li>개인정보 처리 정지 요청</li>
            <li>수집·이용 동의 철회</li>
          </ul>
          <p>
            앱 내 <strong>설정 &gt; 계정</strong>에서 직접 처리할 수 있으며, 불가한 경우{' '}
            <a href="mailto:hyphendev2025@gmail.com">hyphendev2025@gmail.com</a>로 요청해
            주시면 지체 없이 대응합니다. 만 14세 미만 아동의 경우 법정대리인의 동의를
            받아 가입하며, 법정대리인이 이용자의 권리를 대리 행사할 수 있습니다.
          </p>

          <h2>8. 개인정보의 안전성 확보 조치</h2>
          <ul>
            <li>전송 구간 암호화(HTTPS/TLS 1.2 이상)</li>
            <li>비밀번호의 안전한 단방향 해시 저장(bcrypt 등)</li>
            <li>액세스 토큰의 iOS Keychain / Android Keystore 저장</li>
            <li>접근 권한 분리 및 접근 로그 기록</li>
            <li>정기적인 보안 점검 및 취약점 조치</li>
          </ul>

          <h2>9. 쿠키 및 유사 기술</h2>
          <p>
            모바일 앱은 일반적인 의미의 웹 쿠키를 사용하지 않습니다. 로그인 상태 유지를
            위해 액세스 토큰·리프레시 토큰을 기기 내 안전한 저장소에 보관합니다.
          </p>

          <h2>10. 광고 식별자 및 추적</h2>
          <p>
            자습ON은 Apple IDFA, Google AAID 등 광고 식별자를 수집하지 않으며, 사용자
            추적을 위한 SDK를 포함하지 않습니다.
          </p>

          <h2>11. 개인정보 보호책임자</h2>
          <p>
            회사는 개인정보 처리에 관한 업무를 총괄 담당하는 책임자를 지정하고 있습니다.
          </p>
          <ul>
            <li>개인정보 보호책임자 — hyphen (hyphendev2025@gmail.com)</li>
          </ul>

          <h2>12. 권익 침해 구제 방법</h2>
          <p>
            개인정보 침해로 인한 상담·신고가 필요한 경우 아래 기관에 문의할 수 있습니다.
          </p>
          <ul>
            <li>개인정보침해신고센터 (privacy.kisa.or.kr / 국번없이 118)</li>
            <li>개인정보보호위원회 (pipc.go.kr / 국번없이 182)</li>
            <li>대검찰청 사이버범죄수사단 (spo.go.kr / 국번없이 1301)</li>
            <li>경찰청 사이버수사국 (cyberbureau.police.go.kr / 국번없이 182)</li>
          </ul>

          <h2>13. 방침의 변경</h2>
          <p>
            본 방침은 법령·서비스 변경에 따라 개정될 수 있습니다. 중요한 변경이 있을
            경우 앱 내 공지 또는 이메일을 통해 사전 고지하며, 변경된 방침은 시행일부터
            적용됩니다.
          </p>

          <h2>14. 문의</h2>
          <p>
            본 방침과 관련한 문의는 <a href="mailto:hyphendev2025@gmail.com">hyphendev2025@gmail.com</a>으로
            보내 주세요.
          </p>
        </div>
      </div>
    </section>
  );
}
