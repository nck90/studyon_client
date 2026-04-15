'use client';
import { useState, useEffect } from 'react';
import { PageHeader } from '@/components/page-header';
import { getAttendance } from '@/lib/mock-data';
import type { Attendance } from '@/lib/types';

type ViewMode = 'daily' | 'weekly' | 'monthly';

const statusStyle: Record<string, string> = {
  present: 'bg-green-100 text-green-700',
  late: 'bg-yellow-100 text-yellow-700',
  absent: 'bg-red-100 text-red-700',
};

const statusLabel: Record<string, string> = {
  present: '출석',
  late: '지각',
  absent: '결석',
};

export default function AttendancePage() {
  const [date, setDate] = useState(() => new Date().toISOString().split('T')[0]);
  const [view, setView] = useState<ViewMode>('daily');
  const [data, setData] = useState<Attendance[]>([]);

  useEffect(() => {
    setData(getAttendance(date));
  }, [date, view]);

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <PageHeader title="출석 관리" description="학생 출결 현황을 확인합니다" />

      {/* Controls */}
      <div className="flex flex-wrap gap-3 mb-6">
        <input
          type="date"
          value={date}
          onChange={e => setDate(e.target.value)}
          className="border border-gray-200 rounded-xl px-4 py-2.5 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-purple-300"
        />
        <div className="flex bg-white border border-gray-200 rounded-xl overflow-hidden">
          {(['daily', 'weekly', 'monthly'] as ViewMode[]).map(v => (
            <button
              key={v}
              onClick={() => setView(v)}
              className={`px-4 py-2.5 text-sm font-medium transition-colors ${
                view === v ? 'bg-[#6C5CE7] text-white' : 'text-gray-600 hover:bg-gray-50'
              }`}
            >
              {v === 'daily' ? '일간' : v === 'weekly' ? '주간' : '월간'}
            </button>
          ))}
        </div>
      </div>

      {view === 'daily' && (
        <>
          {/* Table: PC */}
          <div className="hidden md:block bg-white rounded-2xl shadow-sm overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 border-b border-gray-100">
                <tr>
                  <th className="text-left px-6 py-4 text-gray-500 font-medium">이름</th>
                  <th className="text-left px-6 py-4 text-gray-500 font-medium">입실 시간</th>
                  <th className="text-left px-6 py-4 text-gray-500 font-medium">퇴실 시간</th>
                  <th className="text-left px-6 py-4 text-gray-500 font-medium">체류 시간</th>
                  <th className="text-left px-6 py-4 text-gray-500 font-medium">상태</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-50">
                {(data).map((record: Attendance) => (
                  <tr key={record.studentId} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4 font-medium text-gray-800">{record.studentName}</td>
                    <td className="px-6 py-4 text-gray-600">{record.checkIn ?? '-'}</td>
                    <td className="px-6 py-4 text-gray-600">{record.checkOut ?? '-'}</td>
                    <td className="px-6 py-4 text-gray-600">{record.stayMinutes != null ? `${Math.floor(record.stayMinutes / 60)}h ${record.stayMinutes % 60}m` : '-'}</td>
                    <td className="px-6 py-4">
                      <span className={`px-3 py-1 rounded-full text-xs font-medium ${statusStyle[record.status]}`}>
                        {statusLabel[record.status]}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {(data).length === 0 && (
              <div className="text-center py-16 text-gray-400">출석 데이터가 없습니다.</div>
            )}
          </div>

          {/* Card list: Mobile */}
          <div className="md:hidden space-y-3">
            {(data).map((record: Attendance) => (
              <div key={record.studentId} className="bg-white rounded-2xl shadow-sm p-4">
                <div className="flex items-start justify-between">
                  <p className="font-semibold text-gray-800">{record.studentName}</p>
                  <span className={`px-3 py-1 rounded-full text-xs font-medium ${statusStyle[record.status]}`}>
                    {statusLabel[record.status]}
                  </span>
                </div>
                <div className="flex gap-4 mt-2 text-xs text-gray-500">
                  <span>입실: {record.checkIn ?? '-'}</span>
                  <span>퇴실: {record.checkOut ?? '-'}</span>
                  <span>체류: {record.stayMinutes != null ? `${Math.floor(record.stayMinutes / 60)}h ${record.stayMinutes % 60}m` : '-'}</span>
                </div>
              </div>
            ))}
            {(data).length === 0 && (
              <div className="text-center py-16 text-gray-400">출석 데이터가 없습니다.</div>
            )}
          </div>
        </>
      )}

      {view !== 'daily' && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {[
            { label: '출석', value: data.filter(r => r.status === 'present').length, color: 'text-green-600' },
            { label: '지각', value: data.filter(r => r.status === 'late').length, color: 'text-yellow-600' },
            { label: '결석', value: data.filter(r => r.status === 'absent').length, color: 'text-red-600' },
            { label: '출석률', value: `${data.length > 0 ? Math.round(data.filter(r => r.status !== 'absent').length / data.length * 100) : 0}%`, color: 'text-[#6C5CE7]' },
          ].map(stat => (
            <div key={stat.label} className="bg-white rounded-2xl shadow-sm p-6 text-center">
              <p className={`text-3xl font-bold ${stat.color}`}>{stat.value}</p>
              <p className="text-sm text-gray-500 mt-2">{stat.label}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
