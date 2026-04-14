import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Dark mode context-aware helpers ──
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  static Color bg(BuildContext context) => isDark(context) ? darkBg : background;
  static Color card(BuildContext context) => isDark(context) ? darkSurface : surface;
  static Color text(BuildContext context) => isDark(context) ? darkText : textPrimary;
  static Color textSub(BuildContext context) => isDark(context) ? darkTextSub : textSecondary;
  static Color borderColor(BuildContext context) => isDark(context) ? const Color(0xFF2A2A3E) : cardBorder;

  // ── Brand ──
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5A4BD1);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primarySurface = Color(0xFFF0EEFF);

  // ── Accent ──
  static const Color accent = Color(0xFF00B894);
  static const Color accentLight = Color(0xFFE6F9F3);

  // ── Warm / Hot ──
  static const Color warm = Color(0xFFFDCB6E);
  static const Color warmLight = Color(0xFFFFF8E1);
  static const Color hot = Color(0xFFE17055);
  static const Color hotLight = Color(0xFFFFF0EC);

  // ── Semantic ──
  static const Color success = Color(0xFF00B894);
  static const Color successLight = Color(0xFFE6F9F3);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFDEDEB);

  // ── Neutral ──
  static const Color background = Color(0xFFF2F3F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEEECF5);
  static const Color divider = Color(0xFFEEECF5);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textTertiary = Color(0xFFB2BEC3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color disabled = Color(0xFFDFE6E9);

  // ── Status ──
  static const Color studying = Color(0xFF6C5CE7);
  static const Color onBreak = Color(0xFFFDCB6E);
  static const Color checkedIn = Color(0xFF00B894);
  static const Color checkedOut = Color(0xFFB2BEC3);
  static const Color notCheckedIn = Color(0xFFE74C3C);
  static const Color empty = Color(0xFFDFE6E9);

  // ── Ranking ──
  static const Color rankGold = Color(0xFFFFB800);
  static const Color rankSilver = Color(0xFFA8B0BC);
  static const Color rankBronze = Color(0xFFCD7F32);

  // ── Tinted surfaces ──
  static const Color tintPurple = Color(0xFFF0EEFF);
  static const Color tintMint = Color(0xFFE6F9F3);
  static const Color tintYellow = Color(0xFFFFF8E1);
  static const Color tintCoral = Color(0xFFFFF0EC);
  static const Color tintBlue = Color(0xFFE8F3FF);
  static const Color tintPink = Color(0xFFFCE4EC);

  // ── Dark mode (study session) ──
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkCard = Color(0xFF0F3460);
  static const Color darkText = Color(0xFFEAEAEA);
  static const Color darkTextSub = Color(0xFF8E8EA0);

  // ── Gradients ──
  static const List<Color> primaryGradient = [Color(0xFF6C5CE7), Color(0xFFA29BFE)];
  static const List<Color> warmGradient = [Color(0xFFFDCB6E), Color(0xFFF8A500)];
  static const List<Color> mintGradient = [Color(0xFF00B894), Color(0xFF55EFC4)];
  static const List<Color> darkGradient = [Color(0xFF1A1A2E), Color(0xFF16213E)];
  static const List<Color> coralGradient = [Color(0xFFE17055), Color(0xFFE66767)];

  // ── Legacy compat ──
  static const Color border = cardBorder;
  static const Color info = primary;
  static const Color infoLight = tintPurple;
  static const Color late_ = Color(0xFFFF8900);

  // ── Legacy tint aliases (for backward compat) ──
  static const Color tintGreen = tintMint;
  static const Color tintOrange = Color(0xFFFFF4E5);

  // ── Subject colors ──
  static const Color subjectMath = Color(0xFF6C5CE7); // primary purple
  static const Color subjectEnglish = Color(0xFF00B894); // mint
  static const Color subjectScience = Color(0xFFFDCB6E); // warm yellow
  static const Color subjectKorean = Color(0xFFE17055); // coral
  static const Color subjectSocial = Color(0xFF74B9FF); // sky blue
  static const Color subjectOther = Color(0xFFB2BEC3); // gray

  static Color subjectColor(String subject) {
    switch (subject) {
      case '수학': return subjectMath;
      case '영어': return subjectEnglish;
      case '과학': return subjectScience;
      case '국어': return subjectKorean;
      case '사회': return subjectSocial;
      default: return subjectOther;
    }
  }

  static Color subjectTint(String subject) {
    switch (subject) {
      case '수학': return tintPurple;
      case '영어': return tintMint;
      case '과학': return tintYellow;
      case '국어': return tintCoral;
      case '사회': return tintBlue;
      default: return background;
    }
  }
}
