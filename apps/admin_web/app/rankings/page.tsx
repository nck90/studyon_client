'use client';
import { useState, useEffect } from 'react';
import { PageHeader } from '@/components/page-header';
import { getRankings } from '@/lib/mock-data';
import type { RankingItem } from '@/lib/types';

type Period = 'daily' | 'weekly' | 'monthly';

export default function RankingsPage() {
  const [period, setPeriod] = useState<Period>('daily');
  const [rankings, setRankings] = useState<RankingItem[]>([]);
  const [showAward, setShowAward] = useState(false);

  useEffect(() => {
    setRankings(getRankings(period));
  }, [period]);

  const top3 = rankings.slice(0, 3);
  const rest = rankings.slice(3);

  const podiumOrder = [top3[1], top3[0], top3[2]].filter(Boolean) as RankingItem[];
  const podiumHeight = ['h-20', 'h-28', 'h-16'];
  const podiumRank = [2, 1, 3];
  const medalColor = [
    'bg-gray-300 text-gray-700',
    'bg-yellow-400 text-yellow-900',
    'bg-orange-300 text-orange-900',
  ];

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <div className="flex items-start justify-between mb-6">
        <PageHeader title="랭킹" description="열심히 공부한 학생들을 확인합니다" />
        <button
          onClick={() => setShowAward(true)}
          className="px-5 py-2.5 bg-yellow-400 text-yellow-900 text-sm font-semibold rounded-xl hover:bg-yellow-500 transition-colors whitespace-nowrap"
        >
          시상하기
        </button>
      </div>

      {/* Period tabs */}
      <div className="flex bg-gray-100 rounded-xl p-1 mb-8 w-fit">
        {(['daily', 'weekly', 'monthly'] as Period[]).map(p => (
          <button
            key={p}
            onClick={() => setPeriod(p)}
            className={`px-5 py-2 rounded-lg text-sm font-medium transition-colors ${
              period === p ? 'bg-white text-[#6C5CE7] shadow-sm' : 'text-gray-500'
            }`}
          >
            {p === 'daily' ? '일간' : p === 'weekly' ? '주간' : '월간'}
          </button>
        ))}
      </div>

      {/* Podium */}
      {top3.length >= 1 && (
        <div className="bg-gradient-to-br from-purple-50 to-indigo-50 rounded-2xl p-8 mb-8">
          <h3 className="text-center text-sm font-medium text-purple-700 mb-6">상위 3명</h3>
          <div className="flex items-end justify-center gap-6">
            {podiumOrder.map((entry, idx) => {
              if (!entry) return null;
              return (
                <div key={entry.studentId} className="flex flex-col items-center gap-2">
                  <div className="w-12 h-12 rounded-full bg-purple-100 flex items-center justify-center">
                    <span className="text-lg font-bold text-[#6C5CE7]">{entry.studentName[0]}</span>
                  </div>
                  <p className="text-sm font-semibold text-gray-800">{entry.studentName}</p>
                  <p className="text-xs text-[#6C5CE7] font-medium tabular-nums">{Math.round(entry.minutes / 60)}h</p>
                  <div className={`w-20 ${podiumHeight[idx]} ${medalColor[idx]} rounded-t-xl flex items-center justify-center`}>
                    <span className="text-2xl font-black">{podiumRank[idx]}</span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      )}

      {/* Leaderboard */}
      <div className="bg-white rounded-2xl shadow-sm overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-gray-50 border-b border-gray-100">
            <tr>
              <th className="text-left px-6 py-4 text-gray-500 font-medium">순위</th>
              <th className="text-left px-6 py-4 text-gray-500 font-medium">이름</th>
              <th className="text-left px-6 py-4 text-gray-500 font-medium">공부시간</th>
              <th className="text-left px-6 py-4 text-gray-500 font-medium hidden md:table-cell">변동</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-50">
            {rest.map((entry: RankingItem) => (
              <tr key={entry.studentId} className="hover:bg-gray-50 transition-colors">
                <td className="px-6 py-4">
                  <span className="w-7 h-7 rounded-full bg-gray-100 text-gray-600 flex items-center justify-center text-xs font-bold">
                    {entry.rank}
                  </span>
                </td>
                <td className="px-6 py-4 font-medium text-gray-800">{entry.studentName}</td>
                <td className="px-6 py-4 font-semibold text-[#6C5CE7] tabular-nums">{Math.round(entry.minutes / 60)}h</td>
                <td className="px-6 py-4 hidden md:table-cell">
                  <span className={`text-xs font-medium ${
                    entry.trend > 0 ? 'text-green-600' : entry.trend < 0 ? 'text-red-600' : 'text-gray-400'
                  }`}>
                    {entry.trend > 0 ? `+${entry.trend}` : entry.trend === 0 ? '-' : entry.trend}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Award Modal */}
      {showAward && (
        <div
          className="fixed inset-0 bg-black/30 flex items-center justify-center z-50 p-4"
          onClick={() => setShowAward(false)}
        >
          <div
            className="bg-white rounded-2xl shadow-xl p-8 w-full max-w-sm text-center"
            onClick={e => e.stopPropagation()}
          >
            <div className="text-4xl mb-4">🏆</div>
            <h3 className="text-lg font-bold text-gray-800 mb-2">시상 안내</h3>
            <p className="text-sm text-gray-500 mb-2">
              {period === 'daily' ? '오늘' : period === 'weekly' ? '이번 주' : '이번 달'} 1위
            </p>
            {top3[0] && (
              <p className="text-2xl font-bold text-[#6C5CE7] mb-1">{top3[0].studentName}</p>
            )}
            {top3[0] && (
              <p className="text-sm text-gray-500 mb-6">총 {Math.round(top3[0].minutes / 60)}시간 공부</p>
            )}
            <button
              onClick={() => { alert('시상 처리 완료!'); setShowAward(false); }}
              className="w-full py-3 bg-[#6C5CE7] text-white rounded-xl font-medium hover:bg-[#5A4BD1] transition-colors"
            >
              시상하기
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
