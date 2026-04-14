import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum StudyonButtonVariant { primary, secondary, danger, text }

class StudyonButton extends StatelessWidget {
  const StudyonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = StudyonButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.isSmall = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final StudyonButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Border? border;

    switch (variant) {
      case StudyonButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        border = null;
      case StudyonButtonVariant.secondary:
        bg = AppColors.background;
        fg = AppColors.textPrimary;
        border = Border.all(color: AppColors.cardBorder, width: 1.5);
      case StudyonButtonVariant.danger:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        border = null;
      case StudyonButtonVariant.text:
        bg = Colors.transparent;
        fg = AppColors.textSecondary;
        border = null;
    }

    final double height = isSmall ? AppSpacing.buttonHeightSmall : AppSpacing.buttonHeight;

    Widget child;
    if (isLoading) {
      child = SizedBox(
        width: 20, height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: fg),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: fg,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      );
    } else {
      child = Text(
        label,
        style: TextStyle(
          fontSize: isSmall ? 14 : 16,
          fontWeight: FontWeight.w700,
          color: fg,
          fontFamily: 'Pretendard',
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: isExpanded ? double.infinity : null,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: isExpanded ? 0 : 24),
        decoration: BoxDecoration(
          color: onPressed == null && !isLoading ? AppColors.disabled : bg,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: border,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
