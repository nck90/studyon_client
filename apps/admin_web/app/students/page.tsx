'use client';
import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { PageHeader } from '@/components/page-header';
import { getStudents } from '@/lib/mock-data';
import type { Student } from '@/lib/types';

const statusStyle: Record<string, string> = {
  studying: 'bg-purple-100 text-purple-700',
  break: 'bg-yellow-100 text-yellow-700',
  absent: 'bg-red-100 text-red-700',
  checkedOut: 'bg-gray-100 text-gray-600',
};

const statusLabel: Record<string, string> = {
  studying: '공부중',
  break: '휴식',
  absent: '미입실',
  checkedOut: '퇴실',
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
    `${s.grade}학년 ${s.className}반`.includes(search)
  );

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <PageHeader title="학생 관리" description="등록된 학생 목록을 확인하고 관리합니다" />

      {/* Search + Add */}
      <div className="flex gap-3 mb-6">
        <input
          type="text"
          placeholder="이름, 학번으로 검색"
          value={search}
          onChange={e => setSearch(e.target.value)}
          className="flex-1 border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-purple-300 bg-white"
        />
        <button
          onClick={() => alert('학생 추가 기능은 준비 중입니다.')}
          className="px-5 py-2.5 bg-purple-600 text-white text-sm font-medium rounded-xl hover:bg-purple-700 transition-colors whitespace-nowrap"
        >
          학생 추가
        </button>
      </div>

      {/* Table: PC */}
      <div className="hidden md:block bg-white rounded-2xl shadow-sm overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-gray-50 border-b border-gray-100">
            <tr>
              <th className="text-left px-6 py-4 text-gray-500 font-medium">이름</th>
              <th className="text-left px-6 py-4 text-gray-500 font-medium">학년/반</th>
              <th className="text-left px-6 py-4 text-gray-500 font-medium">좌석</th>
              <th className="text-left px-6 py-4 text-gray-500 font-medium">상태</th>
              <th className="text-left px-6 py-4 text-gray-500 font-medium">오늘 공부시간</th>
              <th className="text-left px-6 py-4 text-gray-500 font-medium">작업</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-50">
            {filtered.map(student => (
              <tr
                key={student.id}
                onClick={() => router.push(`/students/${student.id}`)}
                className="hover:bg-gray-50 cursor-pointer transition-colors"
              >
                <td className="px-6 py-4 font-medium text-gray-800">{student.name}</td>
                <td className="px-6 py-4 text-gray-600">{student.grade}학년 {student.className}반</td>
                <td className="px-6 py-4 text-gray-600">{student.seatNo ?? '-'}</td>
                <td className="px-6 py-4">
                  <span className={`px-3 py-1 rounded-full text-xs font-medium ${statusStyle[student.status]}`}>
                    {statusLabel[student.status]}
                  </span>
                </td>
                <td className="px-6 py-4 text-gray-600">{Math.round(student.todayMinutes / 60)}시간</td>
                <td className="px-6 py-4">
                  <button
                    onClick={e => { e.stopPropagation(); router.push(`/students/${student.id}`); }}
                    className="text-purple-600 hover:text-purple-800 text-xs font-medium"
                  >
                    상세보기
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {filtered.length === 0 && (
          <div className="text-center py-16 text-gray-400">검색 결과가 없습니다.</div>
        )}
      </div>

      {/* Card list: Mobile */}
      <div className="md:hidden space-y-3">
        {filtered.map(student => (
          <div
            key={student.id}
            onClick={() => router.push(`/students/${student.id}`)}
            className="bg-white rounded-2xl shadow-sm p-4 cursor-pointer active:bg-gray-50"
          >
            <div className="flex items-start justify-between">
              <div>
                <p className="font-semibold text-gray-800">{student.name}</p>
                <p className="text-xs text-gray-500 mt-0.5">{student.grade}학년 {student.className}반 | 학번 {student.studentNo}</p>
              </div>
              <span className={`px-3 py-1 rounded-full text-xs font-medium ${statusStyle[student.status]}`}>
                {statusLabel[student.status]}
              </span>
            </div>
            <div className="flex gap-4 mt-3 text-xs text-gray-500">
              <span>좌석: {student.seatNo ?? '-'}</span>
              <span>오늘: {Math.round(student.todayMinutes / 60)}시간</span>
            </div>
          </div>
        ))}
        {filtered.length === 0 && (
          <div className="text-center py-16 text-gray-400">검색 결과가 없습니다.</div>
        )}
      </div>
    </div>
  );
}
