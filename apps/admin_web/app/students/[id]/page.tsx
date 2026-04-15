'use client';
import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { PageHeader } from '@/components/page-header';
import { getStudent, getAttendance } from '@/lib/mock-data';
import type { Student, Attendance } from '@/lib/types';

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
        // Gather last 7 days of attendance for this student
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
        <p className="text-gray-500">학생 정보를 찾을 수 없습니다.</p>
      </div>
    );
  }

  const todayHours = Math.round(student.todayMinutes / 60 * 10) / 10;
  const weeklyHours = Math.round(student.weeklyMinutes / 60 * 10) / 10;

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <button
        onClick={() => router.back()}
        className="flex items-center gap-2 text-sm text-purple-600 hover:text-purple-800 mb-6 font-medium"
      >
        <span>←</span> 뒤로 가기
      </button>

      <PageHeader title={student.name} description={`학번 ${student.studentNo}`} />

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
        {/* Profile Card */}
        <div className="md:col-span-1">
          <div className="bg-white rounded-2xl shadow-sm p-6">
            <div className="w-16 h-16 rounded-full bg-purple-100 flex items-center justify-center mb-4">
              <span className="text-2xl font-bold text-purple-600">{student.name[0]}</span>
            </div>
            <h2 className="text-xl font-bold text-gray-800">{student.name}</h2>
            <p className="text-sm text-gray-500 mt-1">학번 {student.studentNo}</p>

            <div className="mt-6 space-y-3">
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">학년/반</span>
                <span className="font-medium text-gray-800">{student.grade}학년 {student.className}반</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">현재 좌석</span>
                <span className="font-medium text-gray-800">{student.seatNo ?? '-'}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">상태</span>
                <span className={`font-medium ${
                  student.status === 'studying' ? 'text-purple-600'
                  : student.status === 'onBreak' ? 'text-yellow-600'
                  : 'text-gray-500'
                }`}>
                  {student.status === 'studying' ? '공부중'
                  : student.status === 'onBreak' ? '휴식'
                  : student.status === 'notCheckedIn' ? '미입실'
                  : '퇴실'}
                </span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">연속 출석</span>
                <span className="font-medium text-gray-800">{student.streak}일</span>
              </div>
            </div>
          </div>
        </div>

        {/* Stats + Activity */}
        <div className="md:col-span-2 flex flex-col gap-6">
          {/* Stats Row */}
          <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
            {[
              { label: '오늘 공부', value: `${todayHours}h` },
              { label: '이번 주', value: `${weeklyHours}h` },
              { label: '연속 출석', value: `${student.streak}일` },
            ].map(stat => (
              <div key={stat.label} className="bg-white rounded-2xl shadow-sm p-4 text-center">
                <p className="text-2xl font-bold text-purple-600">{stat.value}</p>
                <p className="text-xs text-gray-500 mt-1">{stat.label}</p>
              </div>
            ))}
          </div>

          {/* Activity Log */}
          <div className="bg-white rounded-2xl shadow-sm p-6">
            <h3 className="text-base font-semibold text-gray-800 mb-4">활동 기록</h3>
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="border-b border-gray-100">
                  <tr>
                    <th className="text-left py-2 pr-4 text-gray-500 font-medium">날짜</th>
                    <th className="text-left py-2 pr-4 text-gray-500 font-medium">입실</th>
                    <th className="text-left py-2 pr-4 text-gray-500 font-medium">퇴실</th>
                    <th className="text-left py-2 text-gray-500 font-medium">공부시간</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {activityLog.map((log, idx) => (
                    <tr key={idx}>
                      <td className="py-3 pr-4 text-gray-600">{log.date}</td>
                      <td className="py-3 pr-4 text-gray-600">{log.checkIn ?? '-'}</td>
                      <td className="py-3 pr-4 text-gray-600">{log.checkOut ?? '-'}</td>
                      <td className="py-3 font-medium text-purple-600">{Math.round(log.stayMinutes / 60 * 10) / 10}h</td>
                    </tr>
                  ))}
                  {activityLog.length === 0 && (
                    <tr>
                      <td colSpan={4} className="py-8 text-center text-gray-400">활동 기록이 없습니다.</td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
