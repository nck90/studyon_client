'use client';
import { useState, useEffect } from 'react';
import { getNotifications } from '@/lib/mock-data';
import type { AppNotification } from '@/lib/types';

const typeLabel: Record<string, string> = {
  announcement: '공지',
  attendance: '출석',
  late: '지각',
  checkout: '퇴실',
  goal: '목표',
};

function formatTime(iso: string): string {
  try {
    const d = new Date(iso);
    return d.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' });
  } catch {
    return iso;
  }
}

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<AppNotification[]>([]);
  const [expanded, setExpanded] = useState<string | null>(null);
  const [showCompose, setShowCompose] = useState(false);
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');

  useEffect(() => {
    setNotifications(getNotifications());
  }, []);

  const toggle = (id: string) => {
    setExpanded(prev => (prev === id ? null : id));
    setNotifications(prev => prev.map(n => (n.id === id ? { ...n, isRead: true } : n)));
  };

  const unreadCount = notifications.filter(n => !n.isRead).length;

  return (
    <div className="p-6 md:p-8 max-w-3xl mx-auto pb-24">
      <div className="mb-6">
        <h1 className="text-xl font-bold text-gray-900">알림</h1>
        <p className="text-sm text-gray-400 mt-0.5">
          {unreadCount > 0 ? `읽지 않은 알림 ${unreadCount}개` : '모든 알림을 읽었습니다'}
        </p>
      </div>

      <div className="space-y-1.5">
        {notifications.map(notif => (
          <div
            key={notif.id}
            onClick={() => toggle(notif.id)}
            className="bg-white rounded-2xl px-5 py-4 cursor-pointer hover:bg-gray-50/50 transition-colors"
          >
            <div className="flex items-start gap-3">
              {/* Unread dot or spacer */}
              <div className="mt-1.5 shrink-0 w-1.5">
                {!notif.isRead && (
                  <span className="block w-1.5 h-1.5 rounded-full bg-[#6C5CE7]" />
                )}
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between gap-2 mb-0.5">
                  <div className="flex items-center gap-2 min-w-0">
                    <span className="text-xs font-semibold text-gray-400 shrink-0">
                      {typeLabel[notif.type] ?? notif.type}
                    </span>
                    <p className={`text-sm font-semibold truncate ${!notif.isRead ? 'text-gray-900' : 'text-gray-600'}`}>
                      {notif.title}
                    </p>
                  </div>
                  <span className="text-xs text-gray-400 shrink-0 tabular-nums">{formatTime(notif.createdAt)}</span>
                </div>
                <p className={`text-sm text-gray-500 ${expanded === notif.id ? '' : 'truncate'}`}>
                  {notif.body}
                </p>
              </div>
            </div>
          </div>
        ))}

        {notifications.length === 0 && (
          <div className="text-center py-20 text-gray-400 text-sm">알림이 없습니다.</div>
        )}
      </div>

      {/* Floating compose button */}
      <button
        onClick={() => setShowCompose(true)}
        className="fixed bottom-8 right-8 w-14 h-14 bg-[#6C5CE7] text-white rounded-full shadow-lg hover:bg-[#5A4BD1] transition-colors flex items-center justify-center text-2xl font-light"
        title="공지 작성"
      >
        +
      </button>

      {/* Compose Modal */}
      {showCompose && (
        <div
          className="fixed inset-0 bg-black/30 flex items-center justify-center z-50 p-4"
          onClick={() => setShowCompose(false)}
        >
          <div
            className="bg-white rounded-2xl shadow-xl p-6 w-full max-w-md"
            onClick={e => e.stopPropagation()}
          >
            <div className="flex items-center justify-between mb-5">
              <h3 className="text-base font-bold text-gray-900">공지 작성</h3>
              <button
                onClick={() => setShowCompose(false)}
                className="w-8 h-8 flex items-center justify-center text-gray-400 hover:text-gray-600 transition-colors rounded-xl hover:bg-gray-100 text-lg"
              >
                ×
              </button>
            </div>
            <div className="space-y-3">
              <div>
                <label className="text-xs font-semibold text-gray-400 mb-1.5 block">제목</label>
                <input
                  type="text"
                  value={title}
                  onChange={e => setTitle(e.target.value)}
                  placeholder="공지 제목을 입력하세요"
                  className="w-full rounded-xl bg-gray-50 border-0 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#6C5CE7]/20 placeholder:text-gray-400"
                />
              </div>
              <div>
                <label className="text-xs font-semibold text-gray-400 mb-1.5 block">내용</label>
                <textarea
                  value={body}
                  onChange={e => setBody(e.target.value)}
                  placeholder="공지 내용을 입력하세요"
                  rows={4}
                  className="w-full rounded-xl bg-gray-50 border-0 px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#6C5CE7]/20 placeholder:text-gray-400 resize-none"
                />
              </div>
              <button
                onClick={() => {
                  if (!title.trim()) return;
                  const newNotif: AppNotification = {
                    id: Date.now().toString(),
                    type: 'announcement',
                    title,
                    body,
                    createdAt: new Date().toISOString(),
                    isRead: false,
                  };
                  setNotifications(prev => [newNotif, ...prev]);
                  setTitle('');
                  setBody('');
                  setShowCompose(false);
                }}
                className="w-full h-12 bg-[#6C5CE7] text-white rounded-xl font-semibold text-sm hover:bg-[#5A4BD1] transition-colors"
              >
                발송하기
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
