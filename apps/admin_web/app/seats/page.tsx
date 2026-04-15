'use client';
import { useState, useEffect } from 'react';
import { getSeats } from '@/lib/mock-data';
import type { Seat } from '@/lib/types';

const seatStyle: Record<string, string> = {
  studying: 'bg-[#F0EEFF] text-[#6C5CE7]',
  onBreak: 'bg-amber-50 text-amber-600',
  empty: 'bg-gray-100 text-gray-400',
  notCheckedIn: 'bg-red-50 text-red-400',
};

const statusLabel: Record<string, string> = {
  studying: '공부중',
  onBreak: '휴식',
  empty: '빈자리',
  notCheckedIn: '미입실',
};

export default function SeatsPage() {
  const [seats, setSeats] = useState<Seat[]>([]);
  const [hovered, setHovered] = useState<string | null>(null);

  useEffect(() => {
    setSeats(getSeats());
  }, []);

  const occupied = seats.filter(s => s.status === 'studying' || s.status === 'onBreak').length;
  const total = seats.length;
  const pct = total > 0 ? Math.round((occupied / total) * 100) : 0;

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <div className="mb-6">
        <h1 className="text-xl font-bold text-gray-900">좌석 배치</h1>
        <p className="text-sm text-gray-400 mt-0.5">
          <span className="font-semibold tabular-nums text-gray-700">{occupied}</span>
          <span className="text-gray-400">/{total}석 사용 중</span>
          <span className="ml-2 tabular-nums text-[#6C5CE7] font-semibold">{pct}%</span>
        </p>
      </div>

      {/* Legend */}
      <div className="flex gap-5 mb-5 flex-wrap">
        {Object.entries(statusLabel).map(([key, label]) => (
          <div key={key} className="flex items-center gap-1.5">
            <div className={`w-3 h-3 rounded-md ${seatStyle[key].split(' ')[0]}`} />
            <span className="text-xs text-gray-500">{label}</span>
          </div>
        ))}
      </div>

      {/* Seat grid */}
      <div className="bg-white rounded-2xl p-6">
        <div className="grid grid-cols-4 md:grid-cols-6 gap-2">
          {seats.map(seat => (
            <div
              key={seat.id}
              className="relative"
              onMouseEnter={() => setHovered(seat.id)}
              onMouseLeave={() => setHovered(null)}
            >
              <button
                className={`w-full h-12 rounded-xl flex flex-col items-center justify-center transition-all hover:scale-105 active:scale-95 ${seatStyle[seat.status]}`}
              >
                <span className="text-xs font-bold tabular-nums">{seat.seatNo}</span>
              </button>
              {/* Tooltip */}
              {hovered === seat.id && seat.studentName && (
                <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-1.5 z-10 pointer-events-none">
                  <div className="bg-gray-900 text-white text-xs rounded-lg px-2.5 py-1.5 whitespace-nowrap">
                    {seat.studentName}
                    <div className="absolute top-full left-1/2 -translate-x-1/2 border-4 border-transparent border-t-gray-900" />
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
