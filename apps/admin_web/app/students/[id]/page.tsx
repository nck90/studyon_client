'use client';
import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { getStudent, getAttendance } from '@/lib/mock-data';
import type { Student, Attendance } from '@/lib/types';

const statusDot: Record<string, string> = {
  studying: 'bg-[#6C5CE7]',
  onBreak: 'bg-amber-400',
  notCheckedIn: 'bg-red-400',
  checkedOut: 'bg-gray-300',
};

const statusLabel: Record<string, string> = {
  studying: '공부중',
  onBreak: '휴식',
  notCheckedIn: '미입실',
  checkedOut: '퇴실',
};

export default function StudentDetailPage() {
  const router = useRouter();
  const params = useParams();
  const [student, setStudent] = useState<Student | null>(null);
  const [activityLog, setActivityLog] = useState<Attendance[]>([]);

  useEffect(() => {
    if (params?.id) {
      const found = getStudent(String(params.id));
      setStudent(found ?? null);
      if (found) {
        const today = new Date('2026-04-14');
        const logs: Attendance[] = [];
        for (let d = 0; d < 7; d++) {
          const date = new Date(today);
          date.setDate(today.getDate() - d);
          const dateStr = date.toISOString().split('T')[0];
          const records = getAttendance(dateStr).filter(a => a.studentId === found.id);
          logs.push(...records);
        }
        setActivityLog(logs);
      }
    }
  }, [params?.id]);

  if (!student) {
    return (
      <div className="p-6 md:p-8 max-w-7xl mx-auto">
        <p className="text-gray-400 text-sm">학생 정보를 찾을 수 없습니다.</p>
      </div>
    );
  }

  const todayHours = (student.todayMinutes / 60).toFixed(1);
  const weeklyHours = (student.weeklyMinutes / 60).toFixed(1);

  return (
    <div className="p-6 md:p-8 max-w-4xl mx-auto">
      {/* Back */}
      <button
        onClick={() => router.back()}
        className="text-gray-400 hover:text-gray-600 transition-colors text-lg mb-6 block"
      >
        ←
      </button>

      {/* Profile header */}
      <div className="mb-8">
        <div className="flex items-center gap-3 mb-1">
          <h1 className="text-2xl font-bold text-gray-900">{student.name}</h1>
          <div className="flex items-center gap-1.5">
            <span className={`w-1.5 h-1.5 rounded-full ${statusDot[student.status]}`} />
            <span className="text-sm text-gray-400">{statusLabel[student.status]}</span>
          </div>
        </div>
        <p className="text-sm text-gray-400">
          {student.grade}학년 {student.className} · 학번 {student.studentNo} · 좌석 {student.seatNo ?? '-'}
        </p>
      </div>

      {/* Stats row - no cards, just numbers */}
      <div className="grid grid-cols-4 gap-6 mb-8 bg-white rounded-2xl p-6">
        {[
          { label: '오늘 공부', value: `${todayHours}h` },
          { label: '이번 주', value: `${weeklyHours}h` },
          { label: '연속 출석', value: `${student.streak}일` },
          { label: '주간 목표', value: '달성중' },
        ].map(stat => (
          <div key={stat.label} className="text-center">
            <p className="text-2xl font-extrabold tabular-nums text-gray-900">{stat.value}</p>
            <p className="text-xs font-semibold text-gray-400 mt-1">{stat.label}</p>
          </div>
        ))}
      </div>

      {/* Activity log - timeline */}
      <div className="bg-white rounded-2xl p-6">
        <h3 className="text-sm font-semibold text-gray-400 mb-5">최근 7일 활동</h3>

        {activityLog.length === 0 ? (
          <p className="text-sm text-gray-400 text-center py-8">활동 기록이 없습니다.</p>
        ) : (
          <div className="space-y-0">
            {activityLog.map((log, idx) => (
              <div
                key={idx}
                className={`flex gap-6 py-3 ${idx !== activityLog.length - 1 ? 'border-b border-gray-50' : ''}`}
              >
                <div className="w-24 shrink-0">
                  <p className="text-xs font-semibold text-gray-400 tabular-nums">{log.date.slice(5)}</p>
                </div>
                <div className="flex-1 flex items-center gap-4 text-sm">
                  <span className="text-gray-500 tabular-nums">{log.checkIn ?? '-'}</span>
                  <span className="text-gray-300">→</span>
                  <span className="text-gray-500 tabular-nums">{log.checkOut ?? '재실중'}</span>
                  <span className="ml-auto font-semibold tabular-nums text-[#6C5CE7]">
                    {log.stayMinutes > 0
                      ? `${Math.floor(log.stayMinutes / 60)}h ${log.stayMinutes % 60}m`
                      : '-'}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
