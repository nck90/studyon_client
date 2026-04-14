import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class StudyonInput extends StatelessWidget {
  const StudyonInput({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.icon,
    this.obscure = false,
    this.maxLines = 1,
    this.onChanged,
    this.keyboardType,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final IconData? icon;
  final bool obscure;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: const TextStyle(
            fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
          )),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          obscureText: obscure,
          maxLines: maxLines,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Pretendard',
              color: AppColors.textTertiary,
              fontSize: 15,
            ),
            fillColor: AppColors.background,
            filled: true,
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textTertiary, size: 20)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
