'use client';
import { useState, useEffect } from 'react';
import { KpiCard } from '@/components/kpi-card';
import { PageHeader } from '@/components/page-header';
import { getDashboard } from '@/lib/mock-data';
import type { DashboardData, Seat } from '@/lib/types';

export default function Dashboard() {
  const [data, setData] = useState<DashboardData | null>(null);

  useEffect(() => {
    setData(getDashboard());
  }, []);

  if (!data) return null;

  const seatStatusColor: Record<string, string> = {
    studying: 'bg-gray-800 text-white',
    break: 'bg-amber-100 text-amber-700',
    empty: 'bg-gray-50 text-gray-300',
    absent: 'bg-red-50 text-red-400',
  };

  const seatStatusLabel: Record<string, string> = {
    studying: '공부중',
    break: '휴식',
    empty: '빈자리',
    absent: '결석',
  };

  const hours = Array.from({ length: 14 }, (_, i) => i + 9);
  const maxCount = Math.max(...hours.map(h => data.hourlyStats?.[h] ?? 0), 1);

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <PageHeader title="대시보드" description="자습실 현황을 한눈에 확인하세요" />

      {/* KPI Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-8">
        <KpiCard
          title="현재 입실"
          value={`${data.checkedIn} / ${data.totalSeats}`}
          emoji="🏫"
        />
        <KpiCard
          title="빈 좌석"
          value={data.emptySeats}
          emoji="💺"
        />
        <KpiCard
          title="총 공부시간"
          value={`${Math.round(data.totalStudyMinutes / 60)}h`}
          emoji="⏱"
        />
        <KpiCard
          title="평균 시간"
          value={`${Math.round(data.avgStudyMinutes / 60)}h`}
          emoji="📊"
        />
      </div>

      {/* Main content grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-5">

        {/* Seat Grid */}
        <div className="md:col-span-2 bg-white rounded-2xl p-6">
          <h2 className="text-sm font-semibold text-gray-500 mb-4 tracking-wide">좌석 현황</h2>
          <div className="grid grid-cols-5 md:grid-cols-7 gap-1.5">
            {data.seats.map((seat: Seat) => (
              <div
                key={seat.id}
                className={`rounded-lg p-1.5 text-center text-[10px] font-medium ${seatStatusColor[seat.status]}`}
              >
                <div className="font-bold text-xs">{seat.seatNo}</div>
                {seat.studentName ? (
                  <div className="truncate mt-0.5 opacity-70">{seat.studentName}</div>
                ) : (
                  <div className="mt-0.5 opacity-50">{seatStatusLabel[seat.status]}</div>
                )}
              </div>
            ))}
          </div>
          {/* Legend */}
          <div className="flex gap-4 mt-4 flex-wrap">
            {Object.entries(seatStatusLabel).map(([key, label]) => (
              <div key={key} className="flex items-center gap-1.5">
                <div className={`w-2.5 h-2.5 rounded-sm ${seatStatusColor[key]}`} />
                <span className="text-xs text-gray-400">{label}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Right column: ranking + chart */}
        <div className="flex flex-col gap-5">
          {/* Top 5 Ranking */}
          <div className="bg-white rounded-2xl p-6">
            <h2 className="text-sm font-semibold text-gray-500 mb-4 tracking-wide">오늘의 상위 5명</h2>
            <ol className="space-y-3">
              {data.topRankings.slice(0, 5).map((student, idx) => (
                <li key={student.studentId} className="flex items-center gap-3">
                  <span
                    className={`w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold shrink-0 ${
                      idx === 0 ? 'bg-amber-400 text-amber-900'
                      : idx === 1 ? 'bg-gray-200 text-gray-600'
                      : idx === 2 ? 'bg-orange-200 text-orange-700'
                      : 'bg-gray-50 text-gray-400'
                    }`}
                  >
                    {idx + 1}
                  </span>
                  <span className="flex-1 text-sm text-gray-800 truncate">{student.studentName}</span>
                  <span className="text-sm font-bold text-gray-900 tabular-nums">{Math.round(student.minutes / 60)}h</span>
                </li>
              ))}
            </ol>
          </div>

          {/* Hourly Chart */}
          <div className="bg-white rounded-2xl p-6">
            <h2 className="text-sm font-semibold text-gray-500 mb-4 tracking-wide">시간대별 입실</h2>
            <div className="flex items-end gap-1 h-20">
              {hours.map(h => {
                const count = data.hourlyStats?.[h] ?? 0;
                const heightPct = Math.round((count / maxCount) * 100);
                return (
                  <div key={h} className="flex-1 flex flex-col items-center gap-1">
                    <div
                      className="w-full bg-gray-200 rounded-sm"
                      style={{ height: `${heightPct}%`, minHeight: count > 0 ? '3px' : '0' }}
                    />
                    <span className="text-[8px] text-gray-300">{h}</span>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
