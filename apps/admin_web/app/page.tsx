'use client';
import { useState, useEffect } from 'react';
import { getDashboard } from '@/lib/mock-data';
import type { DashboardData, Seat } from '@/lib/types';

export default function Dashboard() {
  const [data, setData] = useState<DashboardData | null>(null);
  useEffect(() => { setData(getDashboard()); }, []);
  if (!data) return null;

  const occupancy = Math.round((data.checkedIn / data.totalSeats) * 100);
  const hours = Array.from({ length: 14 }, (_, i) => i + 9);
  const maxHourly = Math.max(...hours.map(h => data.hourlyStats[h] ?? 0), 1);

  return (
    <div className="p-6 md:p-8">
      {/* Header */}
      <div className="flex items-end justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 tracking-tight">대시보드</h1>
        </div>
        <p className="text-sm text-gray-400">{new Date().toLocaleDateString('ko-KR', { month: 'long', day: 'numeric', weekday: 'short' })}</p>
      </div>

      {/* KPI section: Hero + side stack */}
      <div className="flex gap-4 mb-6">
        {/* Hero: 입실 현황 */}
        <div className="flex-[2] bg-white rounded-2xl p-6">
          <div className="flex items-center justify-between mb-4">
            <span className="text-xs font-semibold text-gray-400 tracking-wide">현재 입실</span>
            <span className="toss-face text-lg">🏫</span>
          </div>
          <div className="flex items-end gap-3 mb-4">
            <span className="text-5xl font-extrabold text-gray-900 tabular-nums leading-none">{data.checkedIn}</span>
            <span className="text-lg text-gray-400 font-medium mb-1">/ {data.totalSeats}석</span>
          </div>
          <div className="w-full h-2 bg-gray-100 rounded-full overflow-hidden">
            <div className="h-full bg-[#6C5CE7] rounded-full transition-all" style={{ width: `${occupancy}%` }} />
          </div>
          <p className="text-xs text-gray-400 mt-2">{occupancy}% 점유</p>
        </div>

        {/* Side stack */}
        <div className="flex-1 flex flex-col gap-4">
          <div className="bg-white rounded-2xl p-5 flex-1">
            <p className="text-xs font-semibold text-gray-400 mb-2">빈 좌석</p>
            <p className="text-3xl font-extrabold text-gray-900 tabular-nums">{data.emptySeats}<span className="text-sm font-normal text-gray-400 ml-1">석</span></p>
          </div>
          <div className="bg-white rounded-2xl p-5 flex-1">
            <p className="text-xs font-semibold text-gray-400 mb-2">총 공부시간</p>
            <p className="text-3xl font-extrabold text-gray-900 tabular-nums">{Math.round(data.totalStudyMinutes / 60)}<span className="text-sm font-normal text-gray-400 ml-1">시간</span></p>
          </div>
          <div className="bg-white rounded-2xl p-5 flex-1">
            <p className="text-xs font-semibold text-gray-400 mb-2">평균</p>
            <p className="text-3xl font-extrabold text-gray-900 tabular-nums">{(data.avgStudyMinutes / 60).toFixed(1)}<span className="text-sm font-normal text-gray-400 ml-1">시간</span></p>
          </div>
        </div>
      </div>

      {/* Seat grid + Ranking (60/40) */}
      <div className="flex gap-4 mb-6">
        {/* Seats */}
        <div className="flex-[3] bg-white rounded-2xl p-6">
          <p className="text-sm font-bold text-gray-800 mb-4">좌석 현황</p>
          <div className="grid grid-cols-6 gap-2 mb-4">
            {data.seats.map((seat: Seat) => (
              <div
                key={seat.id}
                className={`rounded-lg p-2 text-center cursor-pointer transition-transform hover:scale-105 ${
                  seat.status === 'studying' ? 'bg-[#F0EEFF]' :
                  seat.status === 'onBreak' ? 'bg-amber-50' :
                  seat.status === 'notCheckedIn' ? 'bg-red-50' : 'bg-gray-50'
                }`}
              >
                <p className={`text-[10px] font-bold ${
                  seat.status === 'studying' ? 'text-[#6C5CE7]' :
                  seat.status === 'onBreak' ? 'text-amber-600' :
                  seat.status === 'notCheckedIn' ? 'text-red-400' : 'text-gray-300'
                }`}>{seat.seatNo}</p>
                {seat.studentName && (
                  <p className="text-[9px] text-gray-500 mt-0.5 truncate">{seat.studentName}</p>
                )}
              </div>
            ))}
          </div>
          {/* Legend */}
          <div className="flex gap-4 text-[10px] text-gray-400">
            <span><span className="inline-block w-2 h-2 rounded-full bg-[#6C5CE7] mr-1" />공부 중</span>
            <span><span className="inline-block w-2 h-2 rounded-full bg-amber-400 mr-1" />휴식</span>
            <span><span className="inline-block w-2 h-2 rounded-full bg-gray-200 mr-1" />빈자리</span>
            <span><span className="inline-block w-2 h-2 rounded-full bg-red-300 mr-1" />미입실</span>
          </div>
        </div>

        {/* Ranking */}
        <div className="flex-[2] bg-white rounded-2xl p-6">
          <p className="text-sm font-bold text-gray-800 mb-4">오늘 TOP 5</p>
          <div className="space-y-3">
            {data.topRankings.slice(0, 5).map((r, i) => (
              <div key={r.studentId} className="flex items-center gap-3 group cursor-pointer hover:bg-gray-50 rounded-lg p-2 -mx-2 transition-colors">
                <span className={`w-6 text-xs font-bold tabular-nums ${
                  i === 0 ? 'text-amber-500' : i === 1 ? 'text-gray-400' : i === 2 ? 'text-orange-400' : 'text-gray-300'
                }`}>{i + 1}</span>
                <span className="flex-1 text-sm font-medium text-gray-800">{r.studentName}</span>
                <span className="text-sm font-bold text-gray-600 tabular-nums">{Math.floor(r.minutes / 60)}h {r.minutes % 60}m</span>
                {r.trend !== 0 && (
                  <span className={`text-[10px] font-bold ${r.trend > 0 ? 'text-green-500' : 'text-red-400'}`}>
                    {r.trend > 0 ? '↑' : '↓'}{Math.abs(r.trend)}
                  </span>
                )}
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Hourly chart */}
      <div className="bg-white rounded-2xl p-6">
        <p className="text-sm font-bold text-gray-800 mb-4">시간대별 현황</p>
        <div className="flex items-end gap-1 h-32">
          {hours.map(h => {
            const val = data.hourlyStats[h] ?? 0;
            const pct = val / maxHourly;
            const now = new Date().getHours();
            const isCurrent = h === now;
            return (
              <div key={h} className="flex-1 flex flex-col items-center gap-1 group cursor-pointer">
                <span className={`text-[9px] font-bold tabular-nums opacity-0 group-hover:opacity-100 transition-opacity ${isCurrent ? 'text-[#6C5CE7] !opacity-100' : 'text-gray-500'}`}>{val}</span>
                <div className="w-full flex-1 flex items-end">
                  <div
                    className={`w-full rounded-t transition-all group-hover:opacity-80 ${isCurrent ? 'bg-[#6C5CE7]' : 'bg-gray-200 group-hover:bg-gray-300'}`}
                    style={{ height: `${Math.max(pct * 100, 4)}%` }}
                  />
                </div>
                <span className={`text-[9px] ${isCurrent ? 'text-[#6C5CE7] font-bold' : 'text-gray-300'}`}>{h}</span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
