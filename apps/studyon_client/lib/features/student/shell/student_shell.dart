import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';

class StudentShell extends ConsumerWidget {
  const StudentShell({super.key, required this.child});
  final Widget child;

  void _showCheckoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('퇴실하시겠어요?', style: AppTypography.headlineSmall),
        content: Text(
          '퇴실하면 공부 기록이 저장돼요.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('취소', style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showDailySummarySheet(context, ref);
            },
            child: Text('퇴실', style: AppTypography.titleMedium.copyWith(color: AppColors.hot, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showDailySummarySheet(BuildContext context, WidgetRef ref) {
    final student = ref.read(studentProvider);
    final studyH = student.todayStudySeconds ~/ 3600;
    final studyM = (student.todayStudySeconds % 3600) ~/ 60;
    final breakH = student.todayBreakSeconds ~/ 3600;
    final breakM = (student.todayBreakSeconds % 3600) ~/ 60;
    final completedPlans = student.plans.where((p) => p.progress >= 1.0).length;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.tintPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.summarize_rounded, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Text('오늘 학습 요약', style: AppTypography.headlineSmall),
                ],
              ),
              const SizedBox(height: 24),
              _SummaryRow(
                icon: Icons.timer_rounded,
                color: AppColors.primary,
                label: '공부 시간',
                value: studyH > 0 ? '$studyH시간 $studyM분' : '$studyM분',
              ),
              const SizedBox(height: 14),
              _SummaryRow(
                icon: Icons.coffee_rounded,
                color: AppColors.warm,
                label: '휴식 시간',
                value: breakH > 0 ? '$breakH시간 $breakM분' : '$breakM분',
              ),
              const SizedBox(height: 14),
              _SummaryRow(
                icon: Icons.check_circle_rounded,
                color: AppColors.accent,
                label: '완료한 계획',
                value: '$completedPlans / ${student.plans.length}개',
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await ref.read(studentProvider.notifier).checkOut();
                  if (context.mounted) context.go('/login');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/student/home')) return 0;
    if (loc.startsWith('/student/records')) return 1;
    if (loc.startsWith('/student/rankings')) return 2;
    if (loc.startsWith('/student/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final idx = _index(context);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 700;

    if (isWide) {
      // iPad: Sidebar navigation
      return Scaffold(
        backgroundColor: AppColors.bg(context),
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 220,
              color: AppColors.card(context),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                      child: Text('자습ON', style: TextStyle(
                        fontFamily: 'Pretendard', fontSize: 22, fontWeight: FontWeight.w800,
                        color: AppColors.primary, letterSpacing: -0.5,
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                      child: Text(
                        student.name.isEmpty ? '학생' : '${student.name}님',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ),
                    // Nav items
                    _SidebarItem(icon: Icons.home_rounded, label: '홈', selected: idx == 0,
                      onTap: () => context.go('/student/home')),
                    _SidebarItem(icon: Icons.bar_chart_rounded, label: '기록', selected: idx == 1,
                      onTap: () => context.go('/student/records')),
                    _SidebarItem(icon: Icons.leaderboard_rounded, label: '랭킹', selected: idx == 2,
                      onTap: () => context.go('/student/rankings')),
                    _SidebarItem(icon: Icons.person_rounded, label: '프로필', selected: idx == 3,
                      onTap: () => context.go('/student/profile')),
                    const Spacer(),
                    // Seat info at bottom
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.tintPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event_seat_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.seatNo.isEmpty
                                      ? '좌석 미배정'
                                      : '좌석 ${student.seatNo}',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  student.isCheckedIn ? '입실 중' : '미입실',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Checkout button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: GestureDetector(
                        onTap: () => _showCheckoutDialog(context, ref),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.tintCoral,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded, size: 18, color: AppColors.hot),
                              const SizedBox(width: 8),
                              Text(
                                '퇴실하기',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.hot,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Divider
            Container(width: 1, color: AppColors.borderColor(context)),
            // Content
            Expanded(child: child),
          ],
        ),
      );
    }

    // Phone: Bottom tab bar (keep existing)
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          border: Border(top: BorderSide(color: AppColors.borderColor(context), width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _BottomTab(icon: Icons.home_rounded, label: '홈', selected: idx == 0,
                  onTap: () => context.go('/student/home')),
                _BottomTab(icon: Icons.bar_chart_rounded, label: '기록', selected: idx == 1,
                  onTap: () => context.go('/student/records')),
                _BottomTab(icon: Icons.leaderboard_rounded, label: '랭킹', selected: idx == 2,
                  onTap: () => context.go('/student/rankings')),
                _BottomTab(icon: Icons.person_rounded, label: '프로필', selected: idx == 3,
                  onTap: () => context.go('/student/profile')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.icon, required this.color, required this.label, required this.value});
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Semantics(
        container: true,
        button: true,
        selected: selected,
        identifier: 'nav-$label',
        label: label,
        onTap: onTap,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.tintPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: Icon(icon, size: 22, color: selected ? AppColors.primary : AppColors.textTertiary),
                ),
                const SizedBox(width: 14),
                ExcludeSemantics(
                  child: Text(label, style: TextStyle(
                    fontFamily: 'Pretendard', fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomTab extends StatelessWidget {
  const _BottomTab({required this.icon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        container: true,
        button: true,
        selected: selected,
        identifier: 'nav-$label',
        label: label,
        onTap: onTap,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Icon(icon, size: 22, color: selected ? AppColors.primary : AppColors.textTertiary),
              ),
              const SizedBox(height: 4),
              ExcludeSemantics(
                child: Text(label, style: TextStyle(
                  fontFamily: 'Pretendard', fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? AppColors.primary : AppColors.textTertiary,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
