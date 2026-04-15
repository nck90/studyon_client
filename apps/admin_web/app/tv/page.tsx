'use client';
import { useState } from 'react';
import type { ReactElement } from 'react';
import { PageHeader } from '@/components/page-header';

type TvMode = 'ranking' | 'seats' | 'message' | 'clock';

const modeLabel: Record<TvMode, string> = {
  ranking: '랭킹',
  seats: '좌석 현황',
  message: '메시지',
  clock: '시계',
};

const modeDesc: Record<TvMode, string> = {
  ranking: '오늘의 공부 랭킹을 표시합니다',
  seats: '실시간 좌석 배치도를 표시합니다',
  message: '자유 메시지를 표시합니다',
  clock: '현재 시각과 날짜를 표시합니다',
};

export default function TvPage() {
  const [mode, setMode] = useState<TvMode>('ranking');
  const [message, setMessage] = useState('열심히 공부합시다!');
  const [currentTime, setCurrentTime] = useState(() => {
    const now = new Date();
    return now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' });
  });

  const previewContent: Record<TvMode, ReactElement> = {
    ranking: (
      <div className="text-center">
        <p className="text-yellow-400 text-sm font-bold mb-4">오늘의 랭킹</p>
        {['1위 홍길동 8.5h', '2위 김철수 7.2h', '3위 이영희 6.8h'].map((line, i) => (
          <p key={i} className={`text-white font-semibold ${i === 0 ? 'text-xl' : 'text-base opacity-80'} mb-1`}>{line}</p>
        ))}
      </div>
    ),
    seats: (
      <div>
        <p className="text-yellow-400 text-xs font-bold mb-3 text-center">좌석 현황</p>
        <div className="grid grid-cols-6 gap-1">
          {Array.from({ length: 24 }, (_, i) => (
            <div
              key={i}
              className={`h-6 rounded text-[8px] flex items-center justify-center font-bold ${
                i % 3 === 0 ? 'bg-purple-500 text-white' : i % 5 === 0 ? 'bg-yellow-500 text-black' : 'bg-gray-700 text-gray-400'
              }`}
            >
              {i + 1}
            </div>
          ))}
        </div>
      </div>
    ),
    message: (
      <div className="text-center px-4">
        <p className="text-white text-xl font-bold leading-relaxed">{message || '메시지를 입력하세요'}</p>
      </div>
    ),
    clock: (
      <div className="text-center">
        <p className="text-white text-5xl font-bold tabular-nums">{currentTime}</p>
        <p className="text-gray-400 text-sm mt-2">
          {new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}
        </p>
      </div>
    ),
  };

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <PageHeader title="TV 제어" description="자습실 TV 화면을 관리합니다" />

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        {/* Controls */}
        <div className="space-y-6">
          {/* Mode selector */}
          <div className="bg-white rounded-2xl shadow-sm p-6">
            <h3 className="text-sm font-semibold text-gray-700 mb-4">표시 모드</h3>
            <div className="grid grid-cols-2 gap-3">
              {(Object.keys(modeLabel) as TvMode[]).map(m => (
                <button
                  key={m}
                  onClick={() => setMode(m)}
                  className={`p-4 rounded-xl border-2 text-left transition-all ${
                    mode === m ? 'border-[#6C5CE7] bg-[#F0EEFF]' : 'border-gray-100 hover:border-gray-200'
                  }`}
                >
                  <p className={`font-semibold text-sm ${mode === m ? 'text-[#6C5CE7]' : 'text-gray-700'}`}>
                    {modeLabel[m]}
                  </p>
                  <p className="text-[11px] text-gray-400 mt-0.5">{modeDesc[m]}</p>
                </button>
              ))}
            </div>
          </div>

          {/* Message input */}
          {mode === 'message' && (
            <div className="bg-white rounded-2xl shadow-sm p-6">
              <h3 className="text-sm font-semibold text-gray-700 mb-3">메시지 내용</h3>
              <textarea
                value={message}
                onChange={e => setMessage(e.target.value)}
                placeholder="TV에 표시할 메시지를 입력하세요"
                rows={3}
                className="w-full border border-gray-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-purple-300 resize-none"
              />
            </div>
          )}

          {/* Control buttons */}
          <div className="bg-white rounded-2xl shadow-sm p-6">
            <h3 className="text-sm font-semibold text-gray-700 mb-4">제어</h3>
            <div className="flex gap-3">
              <button
                onClick={() => {
                  const now = new Date();
                  setCurrentTime(now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' }));
                  alert('화면을 새로고침했습니다.');
                }}
                className="flex-1 py-3 bg-gray-100 text-gray-700 rounded-xl text-sm font-medium hover:bg-gray-200 transition-colors"
              >
                새로고침
              </button>
              <button
                onClick={() => alert('전체화면 모드로 전환합니다.')}
                className="flex-1 py-3 bg-[#6C5CE7] text-white rounded-xl text-sm font-medium hover:bg-[#5A4BD1] transition-colors"
              >
                전체화면
              </button>
            </div>
          </div>
        </div>

        {/* Preview */}
        <div>
          <h3 className="text-sm font-semibold text-gray-700 mb-3">미리보기</h3>
          <div className="bg-gray-900 rounded-2xl shadow-lg overflow-hidden aspect-video flex items-center justify-center p-8">
            <div className="text-center w-full">
              <p className="text-gray-600 text-[10px] mb-4 uppercase tracking-widest">자습ON TV — {modeLabel[mode]}</p>
              {previewContent[mode]}
            </div>
          </div>
          <p className="text-xs text-gray-400 mt-2 text-center">실제 TV 화면과 동일하게 표시됩니다</p>
        </div>
      </div>
    </div>
  );
}
