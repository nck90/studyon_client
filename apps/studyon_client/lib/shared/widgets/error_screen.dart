import 'package:flutter/material.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    this.title = '문제가 발생했어요',
    this.message = '잠시 후 다시 시도해 주세요',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.tintCoral,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 36, color: AppColors.hot),
            ),
            const SizedBox(height: 24),
            Text(title, style: AppTypography.headlineMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.tintPurple,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '다시 시도',
                    style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
