import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'pressable_scale.dart';

class StudyonSectionGroup extends StatelessWidget {
  const StudyonSectionGroup({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    this.backgroundColor = AppColors.surface,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class StudyonListTile extends StatelessWidget {
  const StudyonListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingColor = AppColors.background,
    this.leadingIconColor = AppColors.textSecondary,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.showDivider = false,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Color leadingColor;
  final Color leadingIconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding,
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: leadingColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(leadingIcon, size: 18, color: leadingIconColor),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTypography.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ] else if (onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      content = PressableScale(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          child: content,
        ),
      );
    }

    if (showDivider) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          Padding(
            padding: const EdgeInsets.only(left: 70, right: 20),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: AppColors.border,
            ),
          ),
        ],
      );
    }

    return content;
  }
}
