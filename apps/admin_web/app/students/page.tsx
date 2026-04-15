'use client';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { getStudents } from '@/lib/mock-data';
import type { Student } from '@/lib/types';

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

const statusText: Record<string, string> = {
  studying: 'text-[#6C5CE7]',
  onBreak: 'text-amber-600',
  notCheckedIn: 'text-red-500',
  checkedOut: 'text-gray-400',
};

export default function StudentsPage() {
  const router = useRouter();
  const [students, setStudents] = useState<Student[]>([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    setStudents(getStudents());
  }, []);

  const filtered = students.filter(s =>
    s.name.includes(search) ||
    s.studentNo.includes(search) ||
    `${s.grade}학년 ${s.className}`.includes(search)
  );

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-xl font-bold text-gray-900">학생 관리</h1>
          <p className="text-sm text-gray-400 mt-0.5">등록된 학생 {students.length}명</p>
        </div>
        <button
          onClick={() => alert('학생 추가 기능은 준비 중입니다.')}
          className="h-10 px-4 bg-[#6C5CE7] text-white text-sm font-semibold rounded-xl hover:bg-[#5A4BD1] transition-colors"
        >
          학생 추가
        </button>
      </div>

      <div className="mb-5">
        <input
          type="text"
          placeholder="이름, 학번으로 검색"
          value={search}
          onChange={e => setSearch(e.target.value)}
          className="w-full max-w-sm rounded-xl bg-gray-100 border-0 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#6C5CE7]/20 placeholder:text-gray-400"
        />
      </div>

      {/* Desktop table */}
      <div className="hidden md:block bg-white rounded-2xl overflow-hidden">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-gray-100">
              <th className="text-left px-6 py-4 text-xs font-semibold text-gray-400">이름</th>
              <th className="text-left px-6 py-4 text-xs font-semibold text-gray-400">학년/반</th>
              <th className="text-left px-6 py-4 text-xs font-semibold text-gray-400">좌석</th>
              <th className="text-left px-6 py-4 text-xs font-semibold text-gray-400">상태</th>
              <th className="text-left px-6 py-4 text-xs font-semibold text-gray-400">오늘 공부시간</th>
              <th className="text-left px-6 py-4 text-xs font-semibold text-gray-400">이번 주</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((student, idx) => (
              <tr
                key={student.id}
                onClick={() => router.push(`/students/${student.id}`)}
                className={`hover:bg-gray-50/50 transition-colors cursor-pointer ${idx !== filtered.length - 1 ? 'border-b border-gray-50' : ''}`}
              >
                <td className="px-6 py-4 font-semibold text-gray-800">{student.name}</td>
                <td className="px-6 py-4 text-gray-500">{student.grade}학년 {student.className}</td>
                <td className="px-6 py-4 text-gray-500">{student.seatNo ?? '-'}</td>
                <td className="px-6 py-4">
                  <div className="flex items-center gap-2">
                    <span className={`w-1.5 h-1.5 rounded-full shrink-0 ${statusDot[student.status]}`} />
                    <span className={`text-sm ${statusText[student.status]}`}>{statusLabel[student.status]}</span>
                  </div>
                </td>
                <td className="px-6 py-4 tabular-nums text-gray-700 font-medium">
                  {(student.todayMinutes / 60).toFixed(1)}h
                </td>
                <td className="px-6 py-4 tabular-nums text-gray-500">
                  {(student.weeklyMinutes / 60).toFixed(1)}h
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && (
          <div className="text-center py-16 text-gray-400 text-sm">검색 결과가 없습니다.</div>
        )}
      </div>

      {/* Mobile cards */}
      <div className="md:hidden space-y-2">
        {filtered.map(student => (
          <div
            key={student.id}
            onClick={() => router.push(`/students/${student.id}`)}
            className="bg-white rounded-2xl p-4 cursor-pointer active:bg-gray-50 transition-colors"
          >
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span className={`w-1.5 h-1.5 rounded-full shrink-0 ${statusDot[student.status]}`} />
                <span className="font-semibold text-gray-800">{student.name}</span>
              </div>
              <span className="text-sm font-semibold tabular-nums text-gray-700">
                {(student.todayMinutes / 60).toFixed(1)}h
              </span>
            </div>
            <p className="text-xs text-gray-400 mt-1 ml-3.5">{student.grade}학년 {student.className} · {student.seatNo ?? '-'}</p>
          </div>
        ))}
        {filtered.length === 0 && (
          <div className="text-center py-16 text-gray-400 text-sm">검색 결과가 없습니다.</div>
        )}
      </div>
    </div>
  );
}
