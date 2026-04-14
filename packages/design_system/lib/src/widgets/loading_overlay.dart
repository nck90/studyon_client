import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// STUDYON 로딩 오버레이
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
              ),
            ),
          ),
      ],
    );
  }
}
