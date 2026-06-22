import type { Metadata } from 'next';
import { Mail, MessageSquare, HelpCircle, Lock, Trash2 } from 'lucide-react';

export const metadata: Metadata = {
  title: '고객 지원',
  description:
    '자습ON 사용 중 문제가 있거나 문의가 있는 경우 이메일로 연락 주시면 빠르게 답변드립니다.',
};

const faqs = [
  {
    q: '계정을 삭제하고 싶어요.',
    a: '앱 내 "설정 > 계정 삭제"를 통해 직접 처리하거나, hyphendev2025@gmail.com으로 요청해 주시면 영업일 기준 3일 이내에 완전히 삭제합니다. 삭제 후에는 복구가 불가능합니다.',
  },
  {
    q: '비밀번호를 잊어버렸어요.',
    a: '학원 관리자에게 초기화를 요청하시거나, 이메일로 문의해 주시면 본인 확인 후 초기화 링크를 보내드립니다.',
  },
  {
    q: '입실이 안 돼요.',
    a: '로그인 후 체크인 화면에서 화면을 위로 밀어올리면 입실이 됩니다. 좌석이 미배정인 경우에도 입실은 가능하며, 좌석 배정은 관리자가 수동으로 처리합니다. 버튼이 반응하지 않는다면 앱을 한 번 종료 후 재시작해 주세요.',
  },
  {
    q: '공부 시간이 잘못 기록됐어요.',
    a: '백그라운드 전환, 네트워크 끊김 등 특정 상황에서 기록이 누락될 수 있습니다. 해당 날짜, 시간대, 상황을 포함해 hyphendev2025@gmail.com으로 알려주시면 학원 관리자와 협의하여 수정해 드립니다.',
  },
  {
    q: '학원을 바꿨어요. 계정은 어떻게 하나요?',
    a: '기존 학원과의 서비스 계약이 종료되면 기록은 익명화되며, 새로운 학원에서 동일한 아이디로 다시 초대받으실 수 있습니다.',
  },
  {
    q: '개인정보 관련 문의는 어디로 하나요?',
    a: '개인정보 처리방침 페이지 하단의 보호책임자에게 이메일로 문의하시거나, 본 페이지 하단의 연락처를 이용해 주세요.',
  },
];

const quickLinks = [
  {
    icon: Lock,
    title: '개인정보 처리방침',
    desc: '어떤 정보를 어떻게 보관하는지 확인하세요.',
    href: '/privacy',
  },
  {
    icon: Trash2,
    title: '계정 삭제',
    desc: '앱 설정 > 계정 삭제에서 직접 처리하실 수 있어요.',
    href: 'mailto:hyphendev2025@gmail.com?subject=%5B%EC%9E%90%EC%8A%B5ON%5D%20%EA%B3%84%EC%A0%95%20%EC%82%AD%EC%A0%9C%20%EC%9A%94%EC%B2%AD',
  },
  {
    icon: HelpCircle,
    title: '장애·오류 제보',
    desc: '발생 상황, 기기, 앱 버전과 함께 보내 주세요.',
    href: 'mailto:hyphendev2025@gmail.com?subject=%5B%EC%9E%90%EC%8A%B5ON%5D%20%EC%9E%A5%EC%95%A0%20%EC%A0%9C%EB%B3%B4',
  },
];

export default function SupportPage() {
  return (
    <section className="bg-[#fffdf7]">
      <div className="mx-auto max-w-3xl px-5 pt-14 pb-24">
        <p className="text-[13px] font-black uppercase text-[#17483a]">
          Support
        </p>
        <h1 className="mt-3 text-3xl font-black text-[#14120f] sm:text-4xl">
          어떻게 도와드릴까요?
        </h1>
        <p className="mt-4 text-[15px] leading-relaxed text-[#5f645f]">
          자주 묻는 질문을 먼저 확인해 보시고, 답을 찾지 못하셨다면 이메일로 연락 주세요.
          영업일 기준 1~2일 이내에 답변드립니다.
        </p>

        <div className="mt-10 grid gap-3 sm:grid-cols-3">
          {quickLinks.map((l) => (
            <a
              key={l.title}
              href={l.href}
              className="press-scale rounded-lg border border-[#e7dfcf] bg-white p-5 hover:border-[#1fbf75]"
            >
              <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-[#e9fff3] text-[#17483a]">
                <l.icon className="h-4 w-4" aria-hidden />
              </div>
              <h3 className="mt-3 text-[14px] font-black text-[#14120f]">
                {l.title}
              </h3>
              <p className="mt-1 text-[13px] leading-relaxed text-[#5f645f]">{l.desc}</p>
            </a>
          ))}
        </div>

        <h2 className="mt-16 text-[18px] font-black text-[#14120f]">
          자주 묻는 질문
        </h2>
        <div className="mt-4 divide-y divide-[#e7dfcf] rounded-lg border border-[#e7dfcf] bg-white">
          {faqs.map((f, i) => (
            <details key={i} className="group p-5 open:bg-[#fff8e7]">
              <summary className="flex cursor-pointer list-none items-start justify-between gap-4">
                <span className="text-[15px] font-black text-[#14120f]">
                  {f.q}
                </span>
                <span className="mt-0.5 text-[14px] font-black text-[#5f645f] transition-transform group-open:rotate-45">
                  +
                </span>
              </summary>
              <p className="mt-3 text-[14px] leading-relaxed text-[#5f645f]">{f.a}</p>
            </details>
          ))}
        </div>

        <h2 className="mt-16 text-[18px] font-black text-[#14120f]">
          직접 문의
        </h2>
        <div className="mt-4 rounded-lg border border-[#e7dfcf] bg-white p-6">
          <div className="flex items-start gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#e9fff3] text-[#17483a]">
              <Mail className="h-5 w-5" aria-hidden />
            </div>
            <div>
              <p className="text-[14px] font-black text-[#14120f]">이메일</p>
              <a
                href="mailto:hyphendev2025@gmail.com"
                className="mt-1 inline-block text-[14px] font-black text-[#17483a] hover:underline"
              >
                hyphendev2025@gmail.com
              </a>
              <p className="mt-2 text-[13px] leading-relaxed text-[#5f645f]">
                문의 시 기기 모델, OS 버전, 앱 버전, 발생 상황을 함께 보내주시면 더
                빠르게 도와드릴 수 있습니다.
              </p>
            </div>
          </div>
          <div className="mt-5 flex items-start gap-3 border-t border-[#e7dfcf] pt-5">
            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-[#e9fff3] text-[#17483a]">
              <MessageSquare className="h-5 w-5" aria-hidden />
            </div>
            <div>
              <p className="text-[14px] font-black text-[#14120f]">학원 운영자 문의</p>
              <p className="mt-1 text-[13px] leading-relaxed text-[#5f645f]">
                자습ON을 학원에 도입하고 싶으시다면 같은 이메일 주소로 학원명, 인원수,
                원하는 시작일을 적어 보내 주세요.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
