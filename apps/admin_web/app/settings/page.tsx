'use client';
import { useState } from 'react';

function Toggle({ enabled, onChange }: { enabled: boolean; onChange: (v: boolean) => void }) {
  return (
    <button
      onClick={() => onChange(!enabled)}
      className={`relative w-11 h-6 rounded-full transition-colors ${enabled ? 'bg-[#6C5CE7]' : 'bg-gray-200'}`}
    >
      <span
        className={`absolute top-0.5 w-5 h-5 bg-white rounded-full shadow-sm transition-transform ${
          enabled ? 'translate-x-5' : 'translate-x-0.5'
        }`}
      />
    </button>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="bg-white rounded-2xl p-6">
      <h3 className="text-sm font-semibold text-gray-400 mb-5">{title}</h3>
      {children}
    </div>
  );
}

function InputField({
  label,
  type = 'text',
  value,
  onChange,
  min,
  max,
}: {
  label: string;
  type?: string;
  value: string;
  onChange: (v: string) => void;
  min?: string;
  max?: string;
}) {
  return (
    <div>
      <label className="text-xs font-semibold text-gray-400 mb-1.5 block">{label}</label>
      <input
        type={type}
        value={value}
        onChange={e => onChange(e.target.value)}
        min={min}
        max={max}
        className="w-full rounded-xl bg-gray-50 border-0 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#6C5CE7]/20"
      />
    </div>
  );
}

export default function SettingsPage() {
  const [roomName, setRoomName] = useState('자습실 A');
  const [totalSeats, setTotalSeats] = useState('40');
  const [openTime, setOpenTime] = useState('09:00');
  const [closeTime, setCloseTime] = useState('22:00');
  const [breakTime, setBreakTime] = useState('20');

  const [notifCheckIn, setNotifCheckIn] = useState(true);
  const [notifCheckOut, setNotifCheckOut] = useState(true);
  const [notifRanking, setNotifRanking] = useState(false);
  const [notifAlert, setNotifAlert] = useState(true);

  const [showResetConfirm, setShowResetConfirm] = useState(false);
  const [saved, setSaved] = useState(false);

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <div className="p-6 md:p-8 max-w-3xl mx-auto">
      <div className="mb-6">
        <h1 className="text-xl font-bold text-gray-900">설정</h1>
        <p className="text-sm text-gray-400 mt-0.5">자습실 운영 환경을 설정합니다</p>
      </div>

      <div className="space-y-4">
        {/* Room info */}
        <Section title="자습실 정보">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <InputField label="자습실 이름" value={roomName} onChange={setRoomName} />
            <InputField label="총 좌석 수" type="number" value={totalSeats} onChange={setTotalSeats} min="1" />
          </div>
        </Section>

        {/* Operating hours */}
        <Section title="운영 시간">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <InputField label="개방 시간" type="time" value={openTime} onChange={setOpenTime} />
            <InputField label="마감 시간" type="time" value={closeTime} onChange={setCloseTime} />
            <InputField label="최대 휴식 (분)" type="number" value={breakTime} onChange={setBreakTime} min="5" max="60" />
          </div>
        </Section>

        {/* Notifications */}
        <Section title="알림 규칙">
          <div className="space-y-4">
            {[
              { label: '입실 알림', desc: '학생이 입실할 때 알림', value: notifCheckIn, set: setNotifCheckIn },
              { label: '퇴실 알림', desc: '학생이 퇴실할 때 알림', value: notifCheckOut, set: setNotifCheckOut },
              { label: '일일 랭킹 알림', desc: '매일 오후 10시 랭킹 집계 알림', value: notifRanking, set: setNotifRanking },
              { label: '이상 행동 알림', desc: '장시간 이석 등 이상 감지 시 알림', value: notifAlert, set: setNotifAlert },
            ].map(item => (
              <div key={item.label} className="flex items-center justify-between py-0.5">
                <div>
                  <p className="text-sm font-semibold text-gray-800">{item.label}</p>
                  <p className="text-xs text-gray-400 mt-0.5">{item.desc}</p>
                </div>
                <Toggle enabled={item.value} onChange={item.set} />
              </div>
            ))}
          </div>
        </Section>

        {/* Data management */}
        <Section title="데이터 관리">
          <div className="flex flex-wrap gap-3">
            <button
              onClick={() => alert('CSV 파일을 다운로드합니다.')}
              className="h-10 px-4 bg-gray-100 text-gray-700 text-sm font-semibold rounded-xl hover:bg-gray-200 transition-colors"
            >
              CSV 내보내기
            </button>
            <button
              onClick={() => setShowResetConfirm(true)}
              className="h-10 px-4 bg-red-50 text-red-500 text-sm font-semibold rounded-xl hover:bg-red-100 transition-colors"
            >
              데이터 초기화
            </button>
          </div>
        </Section>

        {/* Save */}
        <div className="flex justify-end">
          <button
            onClick={handleSave}
            className={`h-11 px-8 rounded-xl text-sm font-semibold transition-all ${
              saved ? 'bg-emerald-500 text-white' : 'bg-[#6C5CE7] text-white hover:bg-[#5A4BD1]'
            }`}
          >
            {saved ? '저장됨' : '설정 저장'}
          </button>
        </div>
      </div>

      {/* Reset Confirm Modal */}
      {showResetConfirm && (
        <div
          className="fixed inset-0 bg-black/30 flex items-center justify-center z-50 p-4"
          onClick={() => setShowResetConfirm(false)}
        >
          <div
            className="bg-white rounded-2xl shadow-xl p-8 w-full max-w-sm"
            onClick={e => e.stopPropagation()}
          >
            <h3 className="text-base font-bold text-gray-900 mb-2">데이터 초기화</h3>
            <p className="text-sm text-gray-500 mb-6 leading-relaxed">
              모든 출석 기록과 공부 시간 데이터가 삭제됩니다. 이 작업은 되돌릴 수 없습니다.
            </p>
            <div className="flex gap-2">
              <button
                onClick={() => setShowResetConfirm(false)}
                className="flex-1 h-11 bg-gray-100 text-gray-700 rounded-xl text-sm font-semibold hover:bg-gray-200 transition-colors"
              >
                취소
              </button>
              <button
                onClick={() => { alert('데이터가 초기화되었습니다.'); setShowResetConfirm(false); }}
                className="flex-1 h-11 bg-red-500 text-white rounded-xl text-sm font-semibold hover:bg-red-600 transition-colors"
              >
                초기화
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
