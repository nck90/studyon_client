import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static const String _fontFamily = 'Pretendard';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 34, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, height: 1.2, letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 26, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.3, letterSpacing: -0.3,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.35, letterSpacing: -0.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.4, letterSpacing: 0.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.4, letterSpacing: 0.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.4, letterSpacing: 0.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.4, letterSpacing: 0.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.55,
  );

  // bodySmall: 12px (Toss uses 12 for secondary text, not 13)
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textTertiary, height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.4, letterSpacing: 0.3,
  );

  // labelSmall: Toss-style micro label — 11px w600 tracking 0.5
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.textTertiary, height: 1.4, letterSpacing: 0.5,
  );

  // caption: tiny metadata — 10px w500 tertiary
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily, fontSize: 10, fontWeight: FontWeight.w500,
    color: AppColors.textTertiary, height: 1.4,
  );

  static const TextStyle timerDisplay = TextStyle(
    fontFamily: _fontFamily, fontSize: 56, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1.0, letterSpacing: -1,
  );

  // Legacy alias
  static const TextStyle displayExtraLarge = displayLarge;
  static const TextStyle tvLargeNumber = TextStyle(
    fontFamily: _fontFamily, fontSize: 72, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
    height: 1.0,
  );
}
