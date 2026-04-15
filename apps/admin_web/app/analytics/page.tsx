'use client';
import { useState, useEffect } from 'react';
import { getAnalytics } from '@/lib/mock-data';
import type { AnalyticsData } from '@/lib/types';

const PERIODS = [
  { value: 'week', label: '이번 주' },
  { value: 'month', label: '이번 달' },
  { value: 'semester', label: '이번 학기' },
];

const SUBJECT_COLORS = ['#6C5CE7', '#00B894', '#FDCB6E', '#E17055', '#74B9FF'];

export default function AnalyticsPage() {
  const [period, setPeriod] = useState('week');
  const [selectedClass, setSelectedClass] = useState('전체');
  const [data, setData] = useState<AnalyticsData | null>(null);

  useEffect(() => {
    setData(getAnalytics(period, selectedClass));
  }, [period, selectedClass]);

  const classes = ['전체', '1학년', '2학년', '3학년'];
  const maxDaily = Math.max(...(data?.dailyHours ?? []).map(d => d.hours), 1);
  const maxSubject = Math.max(...(data?.subjectDistribution ?? []).map(s => s.hours), 1);

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <div className="mb-6">
        <h1 className="text-xl font-bold text-gray-900">분석</h1>
        <p className="text-sm text-gray-400 mt-0.5">학습 통계와 트렌드</p>
      </div>

      {/* Period segmented control */}
      <div className="flex items-center gap-3 mb-6 flex-wrap">
        <div className="flex bg-gray-100 rounded-xl p-1">
          {PERIODS.map(p => (
            <button
              key={p.value}
              onClick={() => setPeriod(p.value)}
              className={`px-4 py-1.5 rounded-lg text-sm font-semibold transition-all ${
                period === p.value ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500'
              }`}
            >
              {p.label}
            </button>
          ))}
        </div>

        <div className="flex gap-1.5">
          {classes.map(cls => (
            <button
              key={cls}
              onClick={() => setSelectedClass(cls)}
              className={`h-8 px-3 rounded-lg text-xs font-semibold transition-all ${
                selectedClass === cls
                  ? 'bg-[#F0EEFF] text-[#6C5CE7]'
                  : 'bg-white text-gray-500 hover:bg-gray-50'
              }`}
            >
              {cls}
            </button>
          ))}
        </div>
      </div>

      {/* KPI row - no cards, just numbers */}
      <div className="bg-white rounded-2xl p-6 mb-6">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          {[
            { label: '총 공부시간', value: `${data?.totalHours ?? 0}h` },
            { label: '평균 공부시간', value: `${data?.avgHours ?? 0}h` },
            { label: '출석률', value: `${data?.attendanceRate ?? 0}%` },
            { label: '활성 학생', value: `${data?.activeStudents ?? 0}명` },
          ].map(kpi => (
            <div key={kpi.label}>
              <p className="text-2xl font-extrabold tabular-nums text-gray-900">{kpi.value}</p>
              <p className="text-xs font-semibold text-gray-400 mt-1">{kpi.label}</p>
            </div>
          ))}
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Daily bar chart */}
        <div className="bg-white rounded-2xl p-6">
          <h3 className="text-sm font-semibold text-gray-400 mb-5">일별 공부시간</h3>
          <div className="flex items-end gap-2 h-36">
            {(data?.dailyHours ?? []).map((d, idx) => {
              const heightPct = Math.round((d.hours / maxDaily) * 100);
              return (
                <div key={idx} className="flex-1 flex flex-col items-center gap-1 group">
                  <span className="text-[10px] text-gray-400 tabular-nums opacity-0 group-hover:opacity-100 transition-opacity">
                    {d.hours}h
                  </span>
                  <div
                    className="w-full bg-[#6C5CE7] rounded-t-lg transition-all hover:bg-[#5A4BD1] cursor-default"
                    style={{ height: `${heightPct}%`, minHeight: d.hours > 0 ? '4px' : '0' }}
                  />
                  <span className="text-[11px] text-gray-400 font-medium">{d.day}</span>
                </div>
              );
            })}
          </div>
        </div>

        {/* Subject distribution */}
        <div className="bg-white rounded-2xl p-6">
          <h3 className="text-sm font-semibold text-gray-400 mb-5">과목별 분포</h3>
          <div className="space-y-4">
            {(data?.subjectDistribution ?? []).map((s, idx) => {
              const pct = Math.round((s.hours / maxSubject) * 100);
              const color = SUBJECT_COLORS[idx % SUBJECT_COLORS.length];
              return (
                <div key={idx}>
                  <div className="flex justify-between text-sm mb-1.5">
                    <span className="font-semibold text-gray-700">{s.subject}</span>
                    <span className="tabular-nums text-gray-400 font-medium">{s.hours}h</span>
                  </div>
                  <div className="w-full bg-gray-100 rounded-full h-1.5">
                    <div
                      className="h-1.5 rounded-full transition-all"
                      style={{ width: `${pct}%`, backgroundColor: color }}
                    />
                  </div>
                </div>
              );
            })}
            {(data?.subjectDistribution ?? []).length === 0 && (
              <p className="text-gray-400 text-sm text-center py-8">데이터가 없습니다.</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
