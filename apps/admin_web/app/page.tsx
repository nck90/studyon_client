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
    studying: 'bg-purple-600 text-white',
    break: 'bg-yellow-400 text-gray-800',
    empty: 'bg-gray-200 text-gray-500',
    absent: 'bg-red-400 text-white',
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
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <KpiCard
          title="현재 입실"
          value={`${data.checkedIn} / ${data.totalSeats}`}
          color="primary"
        />
        <KpiCard
          title="빈 좌석"
          value={data.emptySeats}
          color="accent"
        />
        <KpiCard
          title="총 공부시간"
          value={`${Math.round(data.totalStudyMinutes / 60)}h`}
          color="warm"
        />
        <KpiCard
          title="평균 시간"
          value={`${Math.round(data.avgStudyMinutes / 60)}h`}
          color="hot"
        />
      </div>

      {/* Main content grid */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">

        {/* Seat Grid */}
        <div className="md:col-span-2 bg-white rounded-2xl shadow-sm p-6">
          <h2 className="text-base font-semibold text-gray-800 mb-4">좌석 현황</h2>
          <div className="grid grid-cols-4 md:grid-cols-6 gap-2">
            {data.seats.map((seat: Seat) => (
              <div
                key={seat.id}
                className={`rounded-lg p-2 text-center text-xs font-medium ${seatStatusColor[seat.status]}`}
              >
                <div className="font-bold">{seat.seatNo}</div>
                {seat.studentName ? (
                  <div className="truncate mt-0.5 text-[10px] opacity-80">{seat.studentName}</div>
                ) : (
                  <div className="mt-0.5 text-[10px] opacity-60">{seatStatusLabel[seat.status]}</div>
                )}
              </div>
            ))}
          </div>
          {/* Legend */}
          <div className="flex gap-4 mt-4 flex-wrap">
            {Object.entries(seatStatusLabel).map(([key, label]) => (
              <div key={key} className="flex items-center gap-1.5">
                <div className={`w-3 h-3 rounded-sm ${seatStatusColor[key]}`} />
                <span className="text-xs text-gray-500">{label}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Right column: ranking + chart */}
        <div className="flex flex-col gap-6">
          {/* Top 5 Ranking */}
          <div className="bg-white rounded-2xl shadow-sm p-6">
            <h2 className="text-base font-semibold text-gray-800 mb-4">오늘의 상위 5명</h2>
            <ol className="space-y-3">
              {data.topRankings.slice(0, 5).map((student, idx) => (
                <li key={student.studentId} className="flex items-center gap-3">
                  <span
                    className={`w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold shrink-0 ${
                      idx === 0 ? 'bg-yellow-400 text-yellow-900'
                      : idx === 1 ? 'bg-gray-300 text-gray-700'
                      : idx === 2 ? 'bg-orange-300 text-orange-900'
                      : 'bg-gray-100 text-gray-600'
                    }`}
                  >
                    {idx + 1}
                  </span>
                  <span className="flex-1 text-sm text-gray-800 truncate">{student.studentName}</span>
                  <span className="text-sm font-semibold text-purple-600">{Math.round(student.minutes / 60)}h</span>
                </li>
              ))}
            </ol>
          </div>

          {/* Hourly Chart */}
          <div className="bg-white rounded-2xl shadow-sm p-6">
            <h2 className="text-base font-semibold text-gray-800 mb-4">시간대별 입실</h2>
            <div className="flex items-end gap-1 h-24">
              {hours.map(h => {
                const count = data.hourlyStats?.[h] ?? 0;
                const heightPct = Math.round((count / maxCount) * 100);
                return (
                  <div key={h} className="flex-1 flex flex-col items-center gap-1">
                    <div
                      className="w-full bg-purple-400 rounded-t"
                      style={{ height: `${heightPct}%`, minHeight: count > 0 ? '4px' : '0' }}
                    />
                    <span className="text-[9px] text-gray-400">{h}</span>
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
