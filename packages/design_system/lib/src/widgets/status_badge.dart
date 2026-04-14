import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  final String label;
  final Color? color;
  final Color? backgroundColor;

  // ── Factory constructors ──
  factory StatusBadge.checkedIn() =>
      const StatusBadge(label: '입실', color: AppColors.checkedIn);

  factory StatusBadge.studying() =>
      const StatusBadge(label: '공부 중', color: AppColors.studying);

  factory StatusBadge.onBreak() =>
      const StatusBadge(label: '휴식 중', color: AppColors.onBreak);

  factory StatusBadge.checkedOut() =>
      const StatusBadge(label: '퇴실', color: AppColors.checkedOut);

  factory StatusBadge.notCheckedIn() =>
      const StatusBadge(label: '미입실', color: AppColors.notCheckedIn);

  factory StatusBadge.completed() =>
      const StatusBadge(label: '완료', color: AppColors.success);

  factory StatusBadge.pending() =>
      const StatusBadge(label: '대기', color: AppColors.textTertiary);

  factory StatusBadge.late_() =>
      const StatusBadge(label: '지각', color: AppColors.late_);

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppColors.primary;
    final bg = backgroundColor ?? fg.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
