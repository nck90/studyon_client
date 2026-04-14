import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

class _NotifData {
  const _NotifData({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isUnread = false,
  });
  final String id;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String body;
  final String timeAgo;
  final bool isUnread;
}

const _mockNotifications = [
  _NotifData(
    id: '1',
    icon: Icons.access_time_rounded,
    iconColor: AppColors.hot,
    iconBg: AppColors.tintCoral,
    title: '자습실 마감 안내',
    body: '오늘 자습실은 21:30에 마감됩니다. 정리 후 퇴실해 주세요.',
    timeAgo: '30분 전',
    isUnread: true,
  ),
  _NotifData(
    id: '2',
    icon: Icons.event_seat_rounded,
    iconColor: AppColors.accent,
    iconBg: AppColors.tintMint,
    title: '좌석 재배정 안내',
    body: '내일 오전 10시에 좌석 재배정이 진행됩니다. 지정된 좌석을 확인해 주세요.',
    timeAgo: '2시간 전',
    isUnread: true,
  ),
  _NotifData(
    id: '3',
    icon: Icons.emoji_events_rounded,
    iconColor: AppColors.warm,
    iconBg: AppColors.tintYellow,
    title: '이번 주 랭킹 1위',
    body: '이번 주 학습 시간 랭킹 1위를 달성했습니다. 총 32시간 30분을 기록했어요.',
    timeAgo: '1일 전',
    isUnread: false,
  ),
  _NotifData(
    id: '4',
    icon: Icons.timer_off_rounded,
    iconColor: AppColors.error,
    iconBg: AppColors.tintPink,
    title: '휴식 시간 초과',
    body: '허용된 휴식 시간(30분)이 15분 초과되었습니다. 자리로 돌아와 주세요.',
    timeAgo: '2일 전',
    isUnread: false,
  ),
  _NotifData(
    id: '5',
    icon: Icons.notifications_rounded,
    iconColor: AppColors.primary,
    iconBg: AppColors.tintPurple,
    title: '4월 학습 목표 달성',
    body: '이번 달 목표 학습 시간 60시간을 달성했습니다. 꾸준한 노력에 박수를 보냅니다.',
    timeAgo: '3일 전',
    isUnread: false,
  ),
];

class StudentNotificationsScreen extends StatefulWidget {
  const StudentNotificationsScreen({super.key});

  @override
  State<StudentNotificationsScreen> createState() => _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {
  late List<_NotifData> _notifications;
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _notifications = List.from(_mockNotifications);
  }

  void _handleTap(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
        // Mark as read
        final idx = _notifications.indexWhere((n) => n.id == id);
        if (idx != -1 && _notifications[idx].isUnread) {
          final n = _notifications[idx];
          _notifications[idx] = _NotifData(
            id: n.id,
            icon: n.icon,
            iconColor: n.iconColor,
            iconBg: n.iconBg,
            title: n.title,
            body: n.body,
            timeAgo: n.timeAgo,
            isUnread: false,
          );
        }
      }
    });
  }

  int get _unreadCount => _notifications.where((n) => n.isUnread).length;

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final hPad = isIPad ? 28.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('알림', style: AppTypography.headlineLarge),
                  const Spacer(),
                  // Mark all read button
                  if (_unreadCount > 0)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _notifications = _notifications.map((n) => _NotifData(
                            id: n.id,
                            icon: n.icon,
                            iconColor: n.iconColor,
                            iconBg: n.iconBg,
                            title: n.title,
                            body: n.body,
                            timeAgo: n.timeAgo,
                            isUnread: false,
                          )).toList();
                        });
                      },
                      child: Text('전체 읽음', style: AppTypography.titleMedium.copyWith(color: AppColors.primary)),
                    ),
                  // Unread badge
                  if (_unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.tintPurple,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        '읽지 않음 $_unreadCount',
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
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : _buildGroupedList(hPad),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(_NotifData n) {
    return n.timeAgo.contains('분 전') || n.timeAgo.contains('시간 전');
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

  Widget _buildGroupedList(double hPad) {
    final todayItems = _notifications.where(_isToday).toList();
    final olderItems = _notifications.where((n) => !_isToday(n)).toList();

    final items = <Widget>[];

    if (todayItems.isNotEmpty) {
      items.add(_buildSectionHeader('오늘'));
      for (final n in todayItems) {
        items.add(_NotificationCard(
          notif: n,
          isExpanded: _expandedIds.contains(n.id),
          onTap: () => _handleTap(n.id),
        ));
        items.add(const SizedBox(height: 10));
      }
    }

    if (olderItems.isNotEmpty) {
      items.add(_buildSectionHeader('이전'));
      for (final n in olderItems) {
        items.add(_NotificationCard(
          notif: n,
          isExpanded: _expandedIds.contains(n.id),
          onTap: () => _handleTap(n.id),
        ));
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
      icon: Icons.notifications_off_outlined,
      message: '알림이 없습니다\n새로운 알림이 오면 여기에 표시됩니다',
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notif, required this.isExpanded, required this.onTap});
  final _NotifData notif;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isUnread ? AppColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notif.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(notif.icon, size: 20, color: notif.iconColor),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (notif.isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif.body,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notif.timeAgo,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                  if (!isExpanded) ...[
                    const SizedBox(height: 4),
                    Text(
                      notif.body,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
