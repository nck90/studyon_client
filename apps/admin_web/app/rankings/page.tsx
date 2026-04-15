'use client';
import { useState, useEffect } from 'react';
import { getRankings } from '@/lib/mock-data';
import type { RankingItem } from '@/lib/types';

type Period = 'daily' | 'weekly' | 'monthly';

const periodLabel: Record<Period, string> = { daily: '일간', weekly: '주간', monthly: '월간' };

const rankColor = (rank: number) => {
  if (rank === 1) return 'text-yellow-500';
  if (rank === 2) return 'text-gray-400';
  if (rank === 3) return 'text-amber-600';
  return 'text-gray-300';
};

export default function RankingsPage() {
  const [period, setPeriod] = useState<Period>('daily');
  const [rankings, setRankings] = useState<RankingItem[]>([]);
  const [showAward, setShowAward] = useState(false);

  useEffect(() => {
    setRankings(getRankings(period));
  }, [period]);

  const top1 = rankings[0];

  return (
    <div className="p-6 md:p-8 max-w-3xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-xl font-bold text-gray-900">랭킹</h1>
        <button
          onClick={() => setShowAward(true)}
          className="h-10 px-4 bg-amber-400 text-amber-900 text-sm font-semibold rounded-xl hover:bg-amber-500 transition-colors"
        >
          시상하기
        </button>
      </div>

      {/* Segmented control */}
      <div className="flex bg-gray-100 rounded-xl p-1 mb-6 w-fit">
        {(['daily', 'weekly', 'monthly'] as Period[]).map(p => (
          <button
            key={p}
            onClick={() => setPeriod(p)}
            className={`px-5 py-1.5 rounded-lg text-sm font-semibold transition-all ${
              period === p ? 'bg-white text-gray-900 shadow-sm' : 'text-gray-500'
            }`}
          >
            {periodLabel[p]}
          </button>
        ))}
      </div>

      {/* Leaderboard */}
      <div className="bg-white rounded-2xl overflow-hidden">
        {rankings.map((entry, idx) => (
          <div
            key={entry.studentId}
            className={`flex items-center gap-4 px-6 py-4 hover:bg-gray-50/50 transition-colors cursor-default ${
              idx !== rankings.length - 1 ? 'border-b border-gray-50' : ''
            }`}
          >
            {/* Rank number */}
            <span className={`w-7 text-center text-lg font-extrabold tabular-nums ${rankColor(entry.rank)}`}>
              {entry.rank}
            </span>

            {/* Name */}
            <span className="flex-1 font-semibold text-gray-800">{entry.studentName}</span>

            {/* Time */}
            <span className="tabular-nums font-semibold text-[#6C5CE7]">
              {Math.floor(entry.minutes / 60)}h {entry.minutes % 60}m
            </span>

            {/* Trend arrow */}
            <span className={`w-8 text-right text-sm font-semibold tabular-nums ${
              entry.trend > 0 ? 'text-emerald-500' : entry.trend < 0 ? 'text-red-400' : 'text-gray-300'
            }`}>
              {entry.trend > 0 ? `↑${entry.trend}` : entry.trend < 0 ? `↓${Math.abs(entry.trend)}` : '−'}
            </span>
          </div>
        ))}

        {rankings.length === 0 && (
          <div className="text-center py-16 text-gray-400 text-sm">데이터가 없습니다.</div>
        )}
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
            <p className="text-3xl mb-4">🏆</p>
            <p className="text-xs font-semibold text-gray-400 mb-1">
              {periodLabel[period]} 1위
            </p>
            {top1 && (
              <>
                <p className="text-2xl font-extrabold text-gray-900 mb-1">{top1.studentName}</p>
                <p className="text-sm text-gray-400 mb-6 tabular-nums">
                  총 {Math.floor(top1.minutes / 60)}시간 {top1.minutes % 60}분
                </p>
              </>
            )}
            <button
              onClick={() => { alert('시상 처리 완료!'); setShowAward(false); }}
              className="w-full h-12 bg-[#6C5CE7] text-white rounded-xl font-semibold text-sm hover:bg-[#5A4BD1] transition-colors"
            >
              시상하기
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
