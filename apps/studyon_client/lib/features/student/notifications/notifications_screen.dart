import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../../shared/providers/student_providers.dart';

class StudentNotificationsScreen extends ConsumerStatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  ConsumerState<StudentNotificationsScreen> createState() =>
      _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState
    extends ConsumerState<StudentNotificationsScreen> {
  final Set<String> _expandedIds = {};
  bool _markingAll = false;

  Future<void> _handleTap(NotificationItem notification) async {
    setState(() {
      if (_expandedIds.contains(notification.id)) {
        _expandedIds.remove(notification.id);
      } else {
        _expandedIds.add(notification.id);
      }
    });

    if (notification.isRead) return;
    await ref.read(studentProvider.notifier).markNotificationRead(notification.id);
  }

  Future<void> _markAllRead(List<NotificationItem> notifications) async {
    setState(() => _markingAll = true);
    try {
      for (final notification in notifications.where((item) => !item.isRead)) {
        await ref.read(studentProvider.notifier).markNotificationRead(
              notification.id,
            );
      }
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final hPad = isIPad ? 28.0 : 20.0;
    final notifications = ref.watch(studentProvider).notifications;
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
              child: Row(
                children: [
                  PressableScale(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('알림', style: AppTypography.headlineLarge),
                  const Spacer(),
                  if (unreadCount > 0)
                    GestureDetector(
                      onTap: _markingAll ? null : () => _markAllRead(notifications),
                      child: Text(
                        _markingAll ? '처리 중...' : '전체 읽음',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.tintPurple,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        '읽지 않음 $unreadCount',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: notifications.isEmpty
                  ? _buildEmptyState()
                  : _buildGroupedList(hPad, notifications),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(NotificationItem notification) {
    return notification.timeAgo.contains('방금') ||
        notification.timeAgo.contains('분 전') ||
        notification.timeAgo.contains('시간 전');
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildGroupedList(double hPad, List<NotificationItem> notifications) {
    final todayItems = notifications.where(_isToday).toList();
    final olderItems = notifications.where((n) => !_isToday(n)).toList();
    final items = <Widget>[];

    if (todayItems.isNotEmpty) {
      items.add(_buildSectionHeader('오늘'));
      for (final notification in todayItems) {
        items.add(
          _NotificationCard(
            notification: notification,
            isExpanded: _expandedIds.contains(notification.id),
            onTap: () => _handleTap(notification),
          ),
        );
        items.add(const SizedBox(height: 10));
      }
    }

    if (olderItems.isNotEmpty) {
      items.add(_buildSectionHeader('이전'));
      for (final notification in olderItems) {
        items.add(
          _NotificationCard(
            notification: notification,
            isExpanded: _expandedIds.contains(notification.id),
            onTap: () => _handleTap(notification),
          ),
        );
        items.add(const SizedBox(height: 10));
      }
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 40),
      children: items,
    );
  }

  Widget _buildEmptyState() {
    return const EmptyState(
      icon: Icons.notifications_none_rounded,
      message: '새 알림이 없어요',
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.isExpanded,
    required this.onTap,
  });

  final NotificationItem notification;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = _notificationMeta(notification.type);

    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: notification.isRead ? AppColors.cardBorder : meta.bg,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: meta.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(meta.icon, color: meta.iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.timeAgo,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notification.body,
              maxLines: isExpanded ? null : 2,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

({IconData icon, Color iconColor, Color bg}) _notificationMeta(String type) {
  switch (type) {
    case 'warning':
      return (
        icon: Icons.timer_off_rounded,
        iconColor: AppColors.error,
        bg: AppColors.tintPink,
      );
    case 'ranking':
    case 'achievement':
      return (
        icon: Icons.emoji_events_rounded,
        iconColor: AppColors.warm,
        bg: AppColors.tintYellow,
      );
    case 'schedule':
      return (
        icon: Icons.event_seat_rounded,
        iconColor: AppColors.accent,
        bg: AppColors.tintMint,
      );
    default:
      return (
        icon: Icons.notifications_rounded,
        iconColor: AppColors.primary,
        bg: AppColors.tintPurple,
      );
  }
}
