'use client';
import { useState, useEffect } from 'react';
import { KpiCard } from '@/components/kpi-card';
import { PageHeader } from '@/components/page-header';
import { getAnalytics } from '@/lib/mock-data';
import type { AnalyticsData } from '@/lib/types';

const PERIODS = [
  { value: 'week', label: '이번 주' },
  { value: 'month', label: '이번 달' },
  { value: 'semester', label: '이번 학기' },
];

const DAYS = ['월', '화', '수', '목', '금', '토', '일'];

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
      <PageHeader title="분석" description="학습 통계와 트렌드를 확인합니다" />

      {/* Period selector */}
      <div className="flex gap-2 mb-6 flex-wrap">
        {PERIODS.map(p => (
          <button
            key={p.value}
            onClick={() => setPeriod(p.value)}
            className={`px-4 py-2 rounded-xl text-sm font-medium transition-colors ${
              period === p.value ? 'bg-purple-600 text-white' : 'bg-white text-gray-600 border border-gray-200 hover:bg-gray-50'
            }`}
          >
            {p.label}
          </button>
        ))}
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <KpiCard title="총 공부시간" value={`${data?.totalHours ?? 0}h`} color="primary" />
        <KpiCard title="평균 공부시간" value={`${data?.avgHours ?? 0}h`} color="accent" />
        <KpiCard title="출석률" value={`${data?.attendanceRate ?? 0}%`} color="warm" />
        <KpiCard title="활성 학생" value={data?.activeStudents ?? 0} color="hot" />
      </div>

      {/* Class filter chips */}
      <div className="flex gap-2 mb-6 flex-wrap">
        {classes.map(cls => (
          <button
            key={cls}
            onClick={() => setSelectedClass(cls)}
            className={`px-4 py-1.5 rounded-full text-xs font-medium transition-colors ${
              selectedClass === cls ? 'bg-purple-600 text-white' : 'bg-white text-gray-600 border border-gray-200'
            }`}
          >
            {cls}
          </button>
        ))}
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Daily hours bar chart */}
        <div className="bg-white rounded-2xl shadow-sm p-6">
          <h3 className="text-base font-semibold text-gray-800 mb-4">일별 공부시간</h3>
          <div className="flex items-end gap-2 h-40">
            {(data?.dailyHours ?? []).map((d, idx) => {
              const heightPct = Math.round((d.hours / maxDaily) * 100);
              return (
                <div key={idx} className="flex-1 flex flex-col items-center gap-1">
                  <span className="text-[10px] text-gray-500 font-medium">{d.hours}h</span>
                  <div
                    className="w-full bg-purple-500 rounded-t-lg transition-all"
                    style={{ height: `${heightPct}%`, minHeight: d.hours > 0 ? '4px' : '0' }}
                  />
                  <span className="text-[10px] text-gray-400">{DAYS[idx % 7]}</span>
                </div>
              );
            })}
          </div>
        </div>

        {/* Subject distribution */}
        <div className="bg-white rounded-2xl shadow-sm p-6">
          <h3 className="text-base font-semibold text-gray-800 mb-4">과목별 분포</h3>
          <div className="space-y-3">
            {(data?.subjectDistribution ?? []).map((s, idx) => {
              const pct = Math.round((s.hours / maxSubject) * 100);
              return (
                <div key={idx}>
                  <div className="flex justify-between text-xs mb-1">
                    <span className="text-gray-700 font-medium">{s.subject}</span>
                    <span className="text-gray-500">{s.hours}h</span>
                  </div>
                  <div className="w-full bg-gray-100 rounded-full h-2">
                    <div
                      className="bg-purple-500 h-2 rounded-full transition-all"
                      style={{ width: `${pct}%` }}
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
