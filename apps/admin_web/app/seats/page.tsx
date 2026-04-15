'use client';
import { useState, useEffect } from 'react';
import { PageHeader } from '@/components/page-header';
import { getSeats } from '@/lib/mock-data';
import type { Seat } from '@/lib/types';

const statusStyle: Record<string, string> = {
  studying: 'bg-purple-600 text-white',
  break: 'bg-yellow-400 text-gray-800',
  empty: 'bg-gray-100 text-gray-400',
  absent: 'bg-red-400 text-white',
};

const statusLabel: Record<string, string> = {
  studying: '공부중',
  break: '휴식',
  empty: '빈자리',
  absent: '결석',
};

export default function SeatsPage() {
  const [seats, setSeats] = useState<Seat[]>([]);
  const [selected, setSelected] = useState<Seat | null>(null);

  useEffect(() => {
    setSeats(getSeats());
  }, []);

  const occupied = seats.filter(s => s.status === 'studying' || s.status === 'onBreak').length;
  const total = seats.length;

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <PageHeader title="좌석 배치" description="실시간 좌석 현황을 확인합니다" />

      {/* Summary */}
      <div className="flex items-center gap-4 mb-6">
        <div className="bg-white rounded-xl shadow-sm px-5 py-3">
          <span className="text-sm text-gray-500">사용중</span>
          <span className="ml-2 text-lg font-bold text-purple-600">{occupied}</span>
          <span className="text-sm text-gray-400"> / {total}</span>
        </div>
        <div className="bg-white rounded-xl shadow-sm px-5 py-3">
          <span className="text-sm text-gray-500">점유율</span>
          <span className="ml-2 text-lg font-bold text-purple-600">
            {total > 0 ? Math.round((occupied / total) * 100) : 0}%
          </span>
        </div>
      </div>

      {/* Legend */}
      <div className="flex gap-4 mb-4 flex-wrap">
        {Object.entries(statusLabel).map(([key, label]) => (
          <div key={key} className="flex items-center gap-1.5">
            <div className={`w-4 h-4 rounded ${statusStyle[key]}`} />
            <span className="text-xs text-gray-600">{label}</span>
          </div>
        ))}
      </div>

      {/* Seat Grid */}
      <div className="bg-white rounded-2xl shadow-sm p-6">
        <div className="grid grid-cols-4 md:grid-cols-6 gap-3">
          {seats.map(seat => (
            <button
              key={seat.id}
              onClick={() => setSelected(seat.status !== 'empty' ? seat : null)}
              className={`rounded-xl p-3 text-center transition-all active:scale-95 hover:opacity-90 ${statusStyle[seat.status]}`}
            >
              <div className="text-sm font-bold">{seat.seatNo}</div>
              {seat.studentName ? (
                <div className="text-[10px] mt-0.5 opacity-80 truncate">{seat.studentName}</div>
              ) : (
                <div className="text-[10px] mt-0.5 opacity-60">{statusLabel[seat.status]}</div>
              )}
            </button>
          ))}
        </div>
      </div>

      {/* Popup */}
      {selected && (
        <div
          className="fixed inset-0 bg-black/30 flex items-center justify-center z-50 p-4"
          onClick={() => setSelected(null)}
        >
          <div
            className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-sm"
            onClick={e => e.stopPropagation()}
          >
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-bold text-gray-800">좌석 {selected.seatNo}</h3>
              <button onClick={() => setSelected(null)} className="text-gray-400 hover:text-gray-600 text-xl">×</button>
            </div>
            <div className="space-y-3">
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">학생</span>
                <span className="font-medium text-gray-800">{selected.studentName ?? '-'}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">상태</span>
                <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${statusStyle[selected.status]}`}>
                  {statusLabel[selected.status]}
                </span>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
