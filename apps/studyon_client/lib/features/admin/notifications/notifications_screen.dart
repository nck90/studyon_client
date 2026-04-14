import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import '../../../shared/providers/providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  void _showComposeSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.bg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('공지 작성', style: AppTypography.headlineSmall),
            const SizedBox(height: 20),
            TextField(
              controller: titleCtrl,
              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 15, color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: '제목',
                labelStyle: const TextStyle(fontFamily: 'Pretendard', fontSize: 13, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 15, color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: '내용',
                labelStyle: const TextStyle(fontFamily: 'Pretendard', fontSize: 13, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('공지가 전송되었어요',
                      style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
                  backgroundColor: AppColors.accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                ));
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('전송', style: TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifAsync = ref.watch(adminNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComposeSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
        label: const Text('공지 작성', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: SafeArea(
        child: notifAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('오류: $e', style: AppTypography.bodyMedium)),
          data: (notifications) => _buildContent(context, notifications),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<AdminNotification> notifications) {
    final unread = notifications.where((n) => !n.isRead).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('알림', style: AppTypography.headlineLarge),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            '$unread',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '총 ${notifications.length}개',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
              if (unread > 0)
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('모두 읽음 처리되었어요', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
                      backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                  child: Text(
                    '모두 읽음',
                    style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: notifications.isEmpty
              ? const EmptyState(
                  message: '새로운 알림이 없습니다.',
                  icon: Icons.notifications_none_rounded,
                )
              : _buildNotificationList(notifications),
        ),
      ],
    );
  }

  Widget _buildNotificationList(List<AdminNotification> notifications) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: notifications.asMap().entries.map((e) {
              return _NotificationRow(
                notification: e.value,
                isLast: e.key == notifications.length - 1,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.notification, required this.isLast});
  final AdminNotification notification;
  final bool isLast;

  IconData _iconForType(String type) {
    switch (type) {
      case 'attendance': return Icons.login_rounded;
      case 'checkout': return Icons.logout_rounded;
      case 'late': return Icons.schedule_rounded;
      case 'goal': return Icons.star_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'attendance': return AppColors.success;
      case 'checkout': return AppColors.textSecondary;
      case 'late': return AppColors.warning;
      case 'goal': return AppColors.rankGold;
      default: return AppColors.primary;
    }
  }

  Color _bgForType(String type) {
    switch (type) {
      case 'attendance': return AppColors.tintGreen;
      case 'checkout': return AppColors.background;
      case 'late': return AppColors.tintYellow;
      case 'goal': return AppColors.tintYellow;
      default: return AppColors.tintPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(notification.type);
    final bg = _bgForType(notification.type);
    final icon = _iconForType(notification.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.transparent : AppColors.tintPurple.withValues(alpha: 0.3),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(AppSpacing.cardRadius))
            : BorderRadius.zero,
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(notification.title, style: AppTypography.titleMedium),
                    Text(notification.createdAt, style: AppTypography.bodySmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notification.body, style: AppTypography.bodyMedium),
              ],
            ),
          ),
          if (!notification.isRead) ...[
            const SizedBox(width: 10),
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
