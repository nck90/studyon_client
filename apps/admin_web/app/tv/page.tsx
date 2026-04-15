'use client';
import { useState } from 'react';
import type { ReactElement } from 'react';

type TvMode = 'ranking' | 'seats' | 'message' | 'clock';

const modeLabel: Record<TvMode, string> = {
  ranking: '랭킹',
  seats: '좌석 현황',
  message: '메시지',
  clock: '시계',
};

const modeDesc: Record<TvMode, string> = {
  ranking: '오늘의 공부 랭킹',
  seats: '실시간 좌석 배치도',
  message: '자유 메시지',
  clock: '현재 시각',
};

export default function TvPage() {
  const [mode, setMode] = useState<TvMode>('ranking');
  const [message, setMessage] = useState('열심히 공부합시다!');
  const [currentTime] = useState(() => {
    const now = new Date();
    return now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' });
  });

  const previewContent: Record<TvMode, ReactElement> = {
    ranking: (
      <div className="text-center">
        <p className="text-yellow-400 text-xs font-bold mb-4 tracking-widest">오늘의 랭킹</p>
        {['최지아 6h 50m', '임채원 6h 30m', '정하은 6h'].map((line, i) => (
          <p
            key={i}
            className={`font-bold mb-1 tabular-nums ${
              i === 0 ? 'text-yellow-300 text-lg' : 'text-white/60 text-sm'
            }`}
          >
            <span className={`mr-2 ${i === 0 ? 'text-yellow-400' : 'text-white/30'}`}>
              {i + 1}
            </span>
            {line}
          </p>
        ))}
      </div>
    ),
    seats: (
      <div className="w-full">
        <p className="text-yellow-400 text-xs font-bold mb-3 text-center tracking-widest">좌석 현황</p>
        <div className="grid grid-cols-6 gap-1">
          {Array.from({ length: 22 }, (_, i) => (
            <div
              key={i}
              className={`h-5 rounded text-[7px] flex items-center justify-center font-bold ${
                i % 3 === 0 ? 'bg-purple-500/80 text-white'
                : i % 7 === 0 ? 'bg-amber-500/60 text-white'
                : 'bg-white/10 text-white/30'
              }`}
            >
              {String.fromCharCode(65 + Math.floor(i / 6))}{(i % 6) + 1}
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
        <p className="text-white text-5xl font-extrabold tabular-nums">{currentTime}</p>
        <p className="text-white/40 text-sm mt-2">
          {new Date().toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' })}
        </p>
      </div>
    ),
  };

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <div className="mb-6">
        <h1 className="text-xl font-bold text-gray-900">TV 제어</h1>
        <p className="text-sm text-gray-400 mt-0.5">자습실 TV 화면을 관리합니다</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        {/* Controls */}
        <div className="space-y-4">
          {/* Mode grid */}
          <div className="bg-white rounded-2xl p-5">
            <p className="text-xs font-semibold text-gray-400 mb-4">표시 모드</p>
            <div className="grid grid-cols-2 gap-2">
              {(Object.keys(modeLabel) as TvMode[]).map(m => (
                <button
                  key={m}
                  onClick={() => setMode(m)}
                  className={`p-4 rounded-xl text-left transition-all ${
                    mode === m
                      ? 'bg-[#F0EEFF] ring-2 ring-[#6C5CE7]/30'
                      : 'bg-gray-50 hover:bg-gray-100'
                  }`}
                >
                  <p className={`font-semibold text-sm ${mode === m ? 'text-[#6C5CE7]' : 'text-gray-700'}`}>
                    {modeLabel[m]}
                  </p>
                  <p className="text-xs text-gray-400 mt-0.5">{modeDesc[m]}</p>
                </button>
              ))}
            </div>
          </div>

          {/* Message input */}
          {mode === 'message' && (
            <div className="bg-white rounded-2xl p-5">
              <p className="text-xs font-semibold text-gray-400 mb-3">메시지 내용</p>
              <textarea
                value={message}
                onChange={e => setMessage(e.target.value)}
                placeholder="TV에 표시할 메시지를 입력하세요"
                rows={3}
                className="w-full rounded-xl bg-gray-50 border-0 px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-[#6C5CE7]/20 placeholder:text-gray-400 resize-none"
              />
            </div>
          )}

          {/* Control buttons */}
          <div className="bg-white rounded-2xl p-5">
            <p className="text-xs font-semibold text-gray-400 mb-3">제어</p>
            <div className="flex gap-2">
              <button
                onClick={() => alert('화면을 새로고침했습니다.')}
                className="flex-1 h-10 bg-gray-100 text-gray-700 rounded-xl text-sm font-semibold hover:bg-gray-200 transition-colors"
              >
                새로고침
              </button>
              <button
                onClick={() => alert('전체화면 모드로 전환합니다.')}
                className="flex-1 h-10 bg-[#6C5CE7] text-white rounded-xl text-sm font-semibold hover:bg-[#5A4BD1] transition-colors"
              >
                전체화면
              </button>
            </div>
          </div>
        </div>

        {/* Preview */}
        <div>
          <p className="text-xs font-semibold text-gray-400 mb-3">미리보기 — {modeLabel[mode]}</p>
          <div className="bg-gray-950 rounded-2xl overflow-hidden aspect-video flex items-center justify-center p-8">
            {previewContent[mode]}
          </div>
          <p className="text-xs text-gray-400 mt-2 text-center">실제 TV 화면과 동일하게 표시됩니다</p>
        </div>
      </div>
    </div>
  );
}
