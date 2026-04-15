'use client';
import { useState, useEffect } from 'react';
import { getAttendance } from '@/lib/mock-data';
import type { Attendance } from '@/lib/types';

type ViewMode = 'daily' | 'weekly' | 'monthly';

const statusDot: Record<string, string> = {
  present: 'bg-emerald-400',
  late: 'bg-amber-400',
  absent: 'bg-red-400',
};

const statusText: Record<string, string> = {
  present: 'text-emerald-600',
  late: 'text-amber-600',
  absent: 'text-red-500',
};

const statusLabel: Record<string, string> = {
  present: '출석',
  late: '지각',
  absent: '결석',
};

function formatDate(dateStr: string): string {
  const d = new Date(dateStr);
  return d.toLocaleDateString('ko-KR', { month: 'long', day: 'numeric', weekday: 'short' });
}

export default function AttendancePage() {
  const [date, setDate] = useState('2026-04-14');
  const [view, setView] = useState<ViewMode>('daily');
  const [data, setData] = useState<Attendance[]>([]);

  useEffect(() => {
    setData(getAttendance(date));
  }, [date, view]);

  const navigateDate = (dir: number) => {
    const d = new Date(date);
    d.setDate(d.getDate() + dir);
    setDate(d.toISOString().split('T')[0]);
  };

  const viewLabels: Record<ViewMode, string> = { daily: '일간', weekly: '주간', monthly: '월간' };

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <div className="mb-6">
        <h1 className="text-xl font-bold text-gray-900">출석 관리</h1>
      </div>

      {/* Controls */}
      <div className="flex flex-wrap items-center gap-3 mb-6">
        {/* Date navigator */}
        <div className="flex items-center gap-2 bg-white rounded-xl px-3 py-2">
          <button
            onClick={() => navigateDate(-1)}
            className="w-7 h-7 flex items-center justify-center text-gray-400 hover:text-gray-700 transition-colors rounded-lg hover:bg-gray-100"
          >
            ‹
          </button>
          <span className="text-sm font-semibold text-gray-700 min-w-[120px] text-center tabular-nums">
            {formatDate(date)}
          </span>
          <button
            onClick={() => navigateDate(1)}
            className="w-7 h-7 flex items-center justify-center text-gray-400 hover:text-gray-700 transition-colors rounded-lg hover:bg-gray-100"
          >
            ›
          </button>
        </div>

        {/* Segmented control */}
        <div className="flex bg-gray-100 rounded-xl p-1">
          {(['daily', 'weekly', 'monthly'] as ViewMode[]).map(v => (
            <button
              key={v}
              onClick={() => setView(v)}
              className={`px-4 py-1.5 rounded-lg text-sm font-semibold transition-all ${
                view === v ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500'
              }`}
            >
              {viewLabels[v]}
            </button>
          ))}
        </div>
      </div>

      {view === 'daily' && (
        <>
          {/* Desktop table */}
          <div className="hidden md:block bg-white rounded-2xl overflow-hidden">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-gray-100">
                  <th className="text-left px-6 py-4 text-xs font-semibold text-gray-400">이름</th>
                  <th className="text-left px-6 py-4 text-xs font-semibold text-gray-400">입실</th>
                  <th className="text-left px-6 py-4 text-xs font-semibold text-gray-400">퇴실</th>
                  <th className="text-left px-6 py-4 text-xs font-semibold text-gray-400">체류시간</th>
                  <th className="text-left px-6 py-4 text-xs font-semibold text-gray-400">상태</th>
                </tr>
              </thead>
              <tbody>
                {data.map((record, idx) => (
                  <tr
                    key={record.studentId}
                    className={`hover:bg-gray-50/50 transition-colors cursor-default ${idx !== data.length - 1 ? 'border-b border-gray-50' : ''}`}
                  >
                    <td className="px-6 py-4 font-semibold text-gray-800">{record.studentName}</td>
                    <td className="px-6 py-4 tabular-nums text-gray-500">{record.checkIn ?? '-'}</td>
                    <td className="px-6 py-4 tabular-nums text-gray-500">{record.checkOut ?? '재실중'}</td>
                    <td className="px-6 py-4 tabular-nums text-gray-700 font-medium">
                      {record.stayMinutes > 0
                        ? `${Math.floor(record.stayMinutes / 60)}h ${record.stayMinutes % 60}m`
                        : '-'}
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <span className={`w-1.5 h-1.5 rounded-full shrink-0 ${statusDot[record.status]}`} />
                        <span className={`text-sm ${statusText[record.status]}`}>{statusLabel[record.status]}</span>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {data.length === 0 && (
              <div className="text-center py-16 text-gray-400 text-sm">출석 데이터가 없습니다.</div>
            )}
          </div>

          {/* Mobile cards */}
          <div className="md:hidden space-y-2">
            {data.map(record => (
              <div key={record.studentId} className="bg-white rounded-2xl p-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className={`w-1.5 h-1.5 rounded-full shrink-0 ${statusDot[record.status]}`} />
                    <span className="font-semibold text-gray-800">{record.studentName}</span>
                  </div>
                  <span className={`text-sm font-semibold ${statusText[record.status]}`}>
                    {statusLabel[record.status]}
                  </span>
                </div>
                <div className="flex gap-3 mt-2 ml-3.5 text-xs text-gray-400 tabular-nums">
                  <span>입실 {record.checkIn ?? '-'}</span>
                  <span>퇴실 {record.checkOut ?? '재실중'}</span>
                  <span>
                    {record.stayMinutes > 0
                      ? `${Math.floor(record.stayMinutes / 60)}h ${record.stayMinutes % 60}m`
                      : '-'}
                  </span>
                </div>
              </div>
            ))}
            {data.length === 0 && (
              <div className="text-center py-16 text-gray-400 text-sm">출석 데이터가 없습니다.</div>
            )}
          </div>
        </>
      )}

      {view !== 'daily' && (
        <div className="bg-white rounded-2xl p-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            {[
              { label: '출석', value: data.filter(r => r.status === 'present').length, color: 'text-emerald-500' },
              { label: '지각', value: data.filter(r => r.status === 'late').length, color: 'text-amber-500' },
              { label: '결석', value: data.filter(r => r.status === 'absent').length, color: 'text-red-500' },
              {
                label: '출석률',
                value: `${data.length > 0 ? Math.round(data.filter(r => r.status !== 'absent').length / data.length * 100) : 0}%`,
                color: 'text-[#6C5CE7]',
              },
            ].map(stat => (
              <div key={stat.label} className="text-center">
                <p className={`text-3xl font-extrabold tabular-nums ${stat.color}`}>{stat.value}</p>
                <p className="text-xs font-semibold text-gray-400 mt-1">{stat.label}</p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
