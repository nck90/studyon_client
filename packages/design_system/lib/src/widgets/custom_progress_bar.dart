import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StudyonProgressBar extends StatelessWidget {
  const StudyonProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color,
    this.trackColor,
  });
  final double value;
  final double height;
  final Color? color;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: trackColor ?? const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: constraints.maxWidth * value.clamp(0.0, 1.0),
              height: height,
              decoration: BoxDecoration(
                color: color ?? AppColors.primary,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        );
      },
    );
  }
}
