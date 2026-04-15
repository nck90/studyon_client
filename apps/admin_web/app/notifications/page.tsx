'use client';
import { useState, useEffect } from 'react';
import { PageHeader } from '@/components/page-header';
import { getNotifications } from '@/lib/mock-data';
import type { AppNotification } from '@/lib/types';

const typeIcon: Record<string, string> = {
  announcement: '📢',
  attendance: 'ℹ',
  late: '⚠',
  checkout: '↩',
  goal: '★',
};

const typeStyle: Record<string, string> = {
  announcement: 'bg-blue-100 text-blue-700',
  attendance: 'bg-gray-100 text-gray-600',
  late: 'bg-red-100 text-red-600',
  checkout: 'bg-gray-100 text-gray-600',
  goal: 'bg-yellow-100 text-yellow-700',
};

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
    setExpanded(prev => prev === id ? null : id);
    setNotifications(prev =>
      prev.map(n => n.id === id ? { ...n, isRead: true } : n)
    );
  };

  const unreadCount = notifications.filter(n => !n.isRead).length;

  return (
    <div className="p-6 md:p-8 max-w-7xl mx-auto">
      <div className="flex items-start justify-between mb-6">
        <PageHeader
          title="알림"
          description={unreadCount > 0 ? `읽지 않은 알림 ${unreadCount}개` : '모든 알림을 읽었습니다'}
        />
        <button
          onClick={() => setShowCompose(true)}
          className="px-5 py-2.5 bg-purple-600 text-white text-sm font-medium rounded-xl hover:bg-purple-700 transition-colors whitespace-nowrap"
        >
          공지 작성
        </button>
      </div>

      <div className="space-y-3">
        {notifications.map(notif => (
          <div
            key={notif.id}
            onClick={() => toggle(notif.id)}
            className={`bg-white rounded-2xl shadow-sm p-5 cursor-pointer transition-all hover:shadow-md ${
              !notif.isRead ? 'border-l-4 border-purple-500' : ''
            }`}
          >
            <div className="flex items-start gap-4">
              <div className={`w-9 h-9 rounded-xl flex items-center justify-center text-sm shrink-0 ${typeStyle[notif.type]}`}>
                {typeIcon[notif.type] ?? 'ℹ'}
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between gap-2">
                  <p className={`font-semibold text-sm ${!notif.isRead ? 'text-gray-900' : 'text-gray-700'}`}>
                    {notif.title}
                  </p>
                  <div className="flex items-center gap-2 shrink-0">
                    {!notif.isRead && (
                      <span className="w-2 h-2 rounded-full bg-purple-500" />
                    )}
                    <span className="text-xs text-gray-400">{notif.createdAt}</span>
                  </div>
                </div>
                <p className="text-xs text-gray-500 mt-0.5 truncate">{notif.body}</p>
              </div>
            </div>

            {expanded === notif.id && (
              <div className="mt-4 pt-4 border-t border-gray-100">
                <p className="text-sm text-gray-700 leading-relaxed whitespace-pre-wrap">{notif.body}</p>
              </div>
            )}
          </div>
        ))}

        {notifications.length === 0 && (
          <div className="text-center py-20 text-gray-400">알림이 없습니다.</div>
        )}
      </div>

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
              <h3 className="text-lg font-bold text-gray-800">공지 작성</h3>
              <button onClick={() => setShowCompose(false)} className="text-gray-400 hover:text-gray-600 text-xl">×</button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="text-xs font-medium text-gray-500 mb-1 block">제목</label>
                <input
                  type="text"
                  value={title}
                  onChange={e => setTitle(e.target.value)}
                  placeholder="공지 제목을 입력하세요"
                  className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-purple-300"
                />
              </div>
              <div>
                <label className="text-xs font-medium text-gray-500 mb-1 block">내용</label>
                <textarea
                  value={body}
                  onChange={e => setBody(e.target.value)}
                  placeholder="공지 내용을 입력하세요"
                  rows={4}
                  className="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-purple-300 resize-none"
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
                    createdAt: '방금',
                    isRead: false,
                  };
                  setNotifications(prev => [newNotif, ...prev]);
                  setTitle('');
                  setBody('');
                  setShowCompose(false);
                }}
                className="w-full py-3 bg-purple-600 text-white rounded-xl font-medium hover:bg-purple-700 transition-colors"
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
