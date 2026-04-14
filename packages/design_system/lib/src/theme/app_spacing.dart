import 'package:flutter/material.dart';

abstract final class AppSpacing {
  // ── 8px grid base units ──
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // ── Semantic gaps (Toss-style) ──
  static const double microGap = 8;    // micro spacing between tightly related items
  static const double cardGap = 16;    // gap between related items inside a section
  static const double sectionGap = 32; // gap between major sections

  // ── Layout padding ──
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: xl);

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusFull = 9999;

  static const double cardRadius = radiusXl;
  static const double buttonRadius = 12; // Toss: 12px, not full pill for main buttons
  static const double chipRadius = radiusFull;
  static const double inputRadius = radiusMd;

  // ── Button heights (Toss spec) ──
  static const double buttonHeightPrimary = 48;  // primary CTA
  static const double buttonHeightSecondary = 40; // secondary action
  static const double buttonHeightSmall = 32;    // small/compact

  // Legacy alias
  static const double buttonHeight = buttonHeightPrimary;
}
