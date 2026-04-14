import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool _collapsed = false;

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/admin/dashboard')) return 0;
    if (loc.startsWith('/admin/students')) return 1;
    if (loc.startsWith('/admin/seats')) return 2;
    if (loc.startsWith('/admin/attendance')) return 3;
    if (loc.startsWith('/admin/study-overview')) return 4;
    if (loc.startsWith('/admin/rankings')) return 5;
    if (loc.startsWith('/admin/notifications')) return 6;
    if (loc.startsWith('/admin/tv')) return 7;
    if (loc.startsWith('/admin/settings')) return 8;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _index(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 700;
    // Auto-collapse sidebar in narrow Split View
    final effectiveCollapsed = _collapsed || !isWide;
    final w = effectiveCollapsed ? 64.0 : 240.0;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: w,
            color: AppColors.card(context),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(effectiveCollapsed ? 16 : 20, 24, effectiveCollapsed ? 16 : 20, 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _collapsed = !_collapsed),
                        child: Icon(
                          effectiveCollapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
                          size: 22,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (!effectiveCollapsed) ...[
                        const SizedBox(width: 12),
                        Text(
                          '자습ON',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!effectiveCollapsed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '관리자',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                      ),
                    ),
                  ),
                const Divider(height: 1),
                const SizedBox(height: 8),
                // Nav items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: effectiveCollapsed ? 8 : 12),
                    children: [
                      _NavItem(
                        icon: Icons.dashboard_rounded,
                        label: '대시보드',
                        idx: 0,
                        current: idx,
                        collapsed: effectiveCollapsed,
                        onTap: () => context.go('/admin/dashboard'),
                      ),
                      _NavItem(
                        icon: Icons.people_rounded,
                        label: '학생 관리',
                        idx: 1,
                        current: idx,
                        collapsed: effectiveCollapsed,
                        onTap: () => context.go('/admin/students'),
                      ),
                      _NavItem(
                        icon: Icons.event_seat_rounded,
                        label: '좌석 관리',
                        idx: 2,
                        current: idx,
                        collapsed: effectiveCollapsed,
                        onTap: () => context.go('/admin/seats'),
                      ),
                      _NavItem(
                        icon: Icons.fact_check_rounded,
                        label: '출결 관리',
                        idx: 3,
                        current: idx,
                        collapsed: effectiveCollapsed,
                        onTap: () => context.go('/admin/attendance'),
                      ),
                      _NavItem(
                        icon: Icons.bar_chart_rounded,
                        label: '학습 현황',
                        idx: 4,
                        current: idx,
                        collapsed: effectiveCollapsed,
                        onTap: () => context.go('/admin/study-overview'),
                      ),
                      _NavItem(
                        icon: Icons.leaderboard_rounded,
                        label: '랭킹',
                        idx: 5,
                        current: idx,
                        collapsed: effectiveCollapsed,
                        onTap: () => context.go('/admin/rankings'),
                      ),
                      _NavItem(
                        icon: Icons.notifications_rounded,
                        label: '알림',
                        idx: 6,
                        current: idx,
                        collapsed: effectiveCollapsed,
                        onTap: () => context.go('/admin/notifications'),
                      ),
                      _NavItem(
                        icon: Icons.tv_rounded,
                        label: 'TV 제어',
                        idx: 7,
                        current: idx,
                        collapsed: effectiveCollapsed,
                        onTap: () => context.go('/admin/tv'),
                      ),
                      _NavItem(
                        icon: Icons.settings_rounded,
                        label: '설정',
                        idx: 8,
                        current: idx,
                        collapsed: effectiveCollapsed,
                        onTap: () => context.go('/admin/settings'),
                      ),
                    ],
                  ),
                ),
                // Admin info
                Padding(
                  padding: EdgeInsets.all(effectiveCollapsed ? 8 : 16),
                  child: effectiveCollapsed
                      ? Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.tintPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              '원',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.tintPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    '원',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('김원장', style: AppTypography.titleMedium),
                                    Text(
                                      '원장',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
          Container(width: 1, color: AppColors.divider),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.idx,
    required this.current,
    required this.collapsed,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final int idx;
  final int current;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = idx == current;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 14,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.tintPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: collapsed
              ? Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: selected ? AppColors.primary : AppColors.textTertiary,
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: selected ? AppColors.primary : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
