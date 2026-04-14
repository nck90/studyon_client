import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: AppColors.primary,
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: AppColors.background,

    // NO shadows anywhere
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shadowColor: Colors.transparent,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
        foregroundColor: AppColors.textPrimary,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 15),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: -0.3, fontFamily: 'Pretendard',
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Pretendard'),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, fontFamily: 'Pretendard'),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.divider, thickness: 1, space: 0,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      selectedColor: AppColors.textPrimary,
      elevation: 0,
      pressElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    dialogTheme: DialogThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      backgroundColor: AppColors.surface,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 0,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      elevation: 0,
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: const TextStyle(
        color: AppColors.textOnPrimary,
        fontSize: 14,
        fontFamily: 'Pretendard',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),

    navigationRailTheme: const NavigationRailThemeData(
      elevation: 0,
      backgroundColor: AppColors.surface,
      selectedIconTheme: IconThemeData(color: AppColors.primary),
      unselectedIconTheme: IconThemeData(color: AppColors.textTertiary),
      selectedLabelTextStyle: TextStyle(
        color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600,
        fontFamily: 'Pretendard',
      ),
      unselectedLabelTextStyle: TextStyle(
        color: AppColors.textTertiary, fontSize: 12,
        fontFamily: 'Pretendard',
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: AppColors.darkBg,

    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkSurface,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        textStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        side: BorderSide(color: AppColors.darkCard, width: 1.5),
        foregroundColor: AppColors.darkText,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkTextSub,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.darkTextSub, fontSize: 15),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: AppColors.darkText, letterSpacing: -0.3, fontFamily: 'Pretendard',
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.darkTextSub,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Pretendard'),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, fontFamily: 'Pretendard'),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.darkCard, thickness: 1, space: 0,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.primary,
      elevation: 0,
      pressElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    dialogTheme: DialogThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      backgroundColor: AppColors.darkSurface,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 0,
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      elevation: 0,
      backgroundColor: AppColors.darkText,
      contentTextStyle: const TextStyle(
        color: AppColors.darkBg,
        fontSize: 14,
        fontFamily: 'Pretendard',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      behavior: SnackBarBehavior.floating,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),

    navigationRailTheme: const NavigationRailThemeData(
      elevation: 0,
      backgroundColor: AppColors.darkSurface,
      selectedIconTheme: IconThemeData(color: AppColors.primary),
      unselectedIconTheme: IconThemeData(color: AppColors.darkTextSub),
      selectedLabelTextStyle: TextStyle(
        color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600,
        fontFamily: 'Pretendard',
      ),
      unselectedLabelTextStyle: TextStyle(
        color: AppColors.darkTextSub, fontSize: 12,
        fontFamily: 'Pretendard',
      ),
    ),
  );
}
