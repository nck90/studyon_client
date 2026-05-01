import 'package:flutter/material.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

/// Renders a cute round character with equipped items.
/// Uses CustomPaint for a kawaii mascot style (카카오프렌즈-inspired).
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    super.key,
    required this.character,
    this.size = 100,
  });

  final Map<String, dynamic> character;
  final double size;

  @override
  Widget build(BuildContext context) {
    final equippedItems = (character['equippedItems'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final bgItem = equippedItems.where((e) => e['category'] == 'BACKGROUND').firstOrNull;
    final hatItem = equippedItems.where((e) => e['category'] == 'HAT').firstOrNull;
    final glassesItem = equippedItems.where((e) => e['category'] == 'GLASSES').firstOrNull;
    final outfitItem = equippedItems.where((e) => e['category'] == 'OUTFIT').firstOrNull;
    final exprItem = equippedItems.where((e) => e['category'] == 'EXPRESSION').firstOrNull;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CharacterPainter(
          bgKey: bgItem?['svgKey'] as String?,
          hatKey: hatItem?['svgKey'] as String?,
          glassesKey: glassesItem?['svgKey'] as String?,
          outfitKey: outfitItem?['svgKey'] as String?,
          exprKey: exprItem?['svgKey'] as String?,
        ),
      ),
    );
  }
}

class _CharacterPainter extends CustomPainter {
  _CharacterPainter({
    this.bgKey,
    this.hatKey,
    this.glassesKey,
    this.outfitKey,
    this.exprKey,
  });

  final String? bgKey;
  final String? hatKey;
  final String? glassesKey;
  final String? outfitKey;
  final String? exprKey;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    // Background circle
    if (bgKey != null) {
      final bgColor = _bgColor(bgKey!);
      canvas.drawCircle(Offset(cx, cy), r * 1.25, Paint()..color = bgColor.withValues(alpha: 0.3));
    }

    // Body (round blob)
    final bodyPaint = Paint()..color = const Color(0xFFF8E8D0);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + r * 0.35), width: r * 1.3, height: r * 0.8),
      bodyPaint,
    );

    // Outfit
    if (outfitKey != null) {
      final outfitPaint = Paint()..color = _outfitColor(outfitKey!);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy + r * 0.4), width: r * 1.35, height: r * 0.75),
        outfitPaint,
      );
    }

    // Head (big round)
    final headPaint = Paint()..color = const Color(0xFFF8E8D0);
    canvas.drawCircle(Offset(cx, cy - r * 0.15), r, headPaint);

    // Cheek blush
    final blushPaint = Paint()..color = const Color(0xFFFFB8B8).withValues(alpha: 0.5);
    canvas.drawCircle(Offset(cx - r * 0.55, cy + r * 0.15), r * 0.18, blushPaint);
    canvas.drawCircle(Offset(cx + r * 0.55, cy + r * 0.15), r * 0.18, blushPaint);

    // Eyes
    _drawExpression(canvas, cx, cy - r * 0.15, r, exprKey);

    // Glasses
    if (glassesKey != null) {
      _drawGlasses(canvas, cx, cy - r * 0.15, r, glassesKey!);
    }

    // Hat
    if (hatKey != null) {
      _drawHat(canvas, cx, cy - r * 0.15, r, hatKey!);
    }
  }

  void _drawExpression(Canvas canvas, double cx, double cy, double r, String? key) {
    final eyePaint = Paint()..color = const Color(0xFF2D3436);

    switch (key) {
      case 'expr_sleepy':
        // Sleepy half-closed eyes
        eyePaint.style = PaintingStyle.stroke;
        eyePaint.strokeWidth = r * 0.06;
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx - r * 0.3, cy), width: r * 0.3, height: r * 0.15),
          0, 3.14, false, eyePaint,
        );
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx + r * 0.3, cy), width: r * 0.3, height: r * 0.15),
          0, 3.14, false, eyePaint,
        );
        break;
      case 'expr_angry':
        // Angry eyes with brows
        canvas.drawCircle(Offset(cx - r * 0.3, cy), r * 0.08, eyePaint);
        canvas.drawCircle(Offset(cx + r * 0.3, cy), r * 0.08, eyePaint);
        final browPaint = Paint()
          ..color = const Color(0xFF2D3436)
          ..strokeWidth = r * 0.06
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(cx - r * 0.45, cy - r * 0.2), Offset(cx - r * 0.2, cy - r * 0.12), browPaint);
        canvas.drawLine(Offset(cx + r * 0.45, cy - r * 0.2), Offset(cx + r * 0.2, cy - r * 0.12), browPaint);
        break;
      case 'expr_heartEyes':
        // Heart eyes
        final heartPaint = Paint()..color = const Color(0xFFE17055);
        _drawHeart(canvas, cx - r * 0.3, cy - r * 0.05, r * 0.15, heartPaint);
        _drawHeart(canvas, cx + r * 0.3, cy - r * 0.05, r * 0.15, heartPaint);
        break;
      default:
        // Default smile
        canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.05), r * 0.09, eyePaint);
        canvas.drawCircle(Offset(cx + r * 0.3, cy - r * 0.05), r * 0.09, eyePaint);
        // Sparkle
        final sparklePaint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(cx - r * 0.27, cy - r * 0.08), r * 0.03, sparklePaint);
        canvas.drawCircle(Offset(cx + r * 0.33, cy - r * 0.08), r * 0.03, sparklePaint);
    }

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF2D3436)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.05
      ..strokeCap = StrokeCap.round;

    if (key == 'expr_angry') {
      canvas.drawLine(Offset(cx - r * 0.15, cy + r * 0.3), Offset(cx + r * 0.15, cy + r * 0.3), mouthPaint);
    } else {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy + r * 0.25), width: r * 0.4, height: r * 0.25),
        0, 3.14, false, mouthPaint,
      );
    }
  }

  void _drawHeart(Canvas canvas, double cx, double cy, double s, Paint paint) {
    final path = Path()
      ..moveTo(cx, cy + s * 0.5)
      ..cubicTo(cx - s, cy - s * 0.3, cx - s * 0.5, cy - s, cx, cy - s * 0.4)
      ..cubicTo(cx + s * 0.5, cy - s, cx + s, cy - s * 0.3, cx, cy + s * 0.5);
    canvas.drawPath(path, paint);
  }

  void _drawGlasses(Canvas canvas, double cx, double cy, double r, String key) {
    final glassPaint = Paint()
      ..color = key == 'glasses_sun' ? const Color(0xFF2D3436) : const Color(0xFF636E72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06;

    if (key == 'glasses_heart') {
      final heartPaint = Paint()..color = const Color(0xFFE17055).withValues(alpha: 0.4);
      _drawHeart(canvas, cx - r * 0.3, cy, r * 0.2, heartPaint);
      _drawHeart(canvas, cx + r * 0.3, cy, r * 0.2, heartPaint);
    } else {
      canvas.drawCircle(Offset(cx - r * 0.3, cy), r * 0.2, glassPaint);
      canvas.drawCircle(Offset(cx + r * 0.3, cy), r * 0.2, glassPaint);
      canvas.drawLine(Offset(cx - r * 0.1, cy), Offset(cx + r * 0.1, cy), glassPaint);
    }

    if (key == 'glasses_sun') {
      final lensPaint = Paint()..color = const Color(0xFF2D3436).withValues(alpha: 0.6);
      canvas.drawCircle(Offset(cx - r * 0.3, cy), r * 0.18, lensPaint);
      canvas.drawCircle(Offset(cx + r * 0.3, cy), r * 0.18, lensPaint);
    }
  }

  void _drawHat(Canvas canvas, double cx, double cy, double r, String key) {
    final hatPaint = Paint();

    switch (key) {
      case 'hat_crown':
        hatPaint.color = const Color(0xFFFFB800);
        // Crown base
        canvas.drawRect(
          Rect.fromLTWH(cx - r * 0.5, cy - r * 0.85, r, r * 0.25),
          hatPaint,
        );
        // Crown points
        final path = Path()
          ..moveTo(cx - r * 0.5, cy - r * 0.85)
          ..lineTo(cx - r * 0.4, cy - r * 1.15)
          ..lineTo(cx - r * 0.15, cy - r * 0.9)
          ..lineTo(cx, cy - r * 1.2)
          ..lineTo(cx + r * 0.15, cy - r * 0.9)
          ..lineTo(cx + r * 0.4, cy - r * 1.15)
          ..lineTo(cx + r * 0.5, cy - r * 0.85)
          ..close();
        canvas.drawPath(path, hatPaint);
        break;
      case 'hat_grad':
        hatPaint.color = const Color(0xFF2D3436);
        canvas.drawRect(
          Rect.fromLTWH(cx - r * 0.6, cy - r * 0.9, r * 1.2, r * 0.08),
          hatPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(cx - r * 0.35, cy - r * 1.1, r * 0.7, r * 0.22),
          hatPaint,
        );
        break;
      case 'hat_catears':
        hatPaint.color = const Color(0xFFF8E8D0);
        // Left ear
        final leftEar = Path()
          ..moveTo(cx - r * 0.55, cy - r * 0.5)
          ..lineTo(cx - r * 0.4, cy - r * 1.15)
          ..lineTo(cx - r * 0.1, cy - r * 0.65)
          ..close();
        canvas.drawPath(leftEar, hatPaint);
        // Right ear
        final rightEar = Path()
          ..moveTo(cx + r * 0.55, cy - r * 0.5)
          ..lineTo(cx + r * 0.4, cy - r * 1.15)
          ..lineTo(cx + r * 0.1, cy - r * 0.65)
          ..close();
        canvas.drawPath(rightEar, hatPaint);
        // Inner pink
        final innerPaint = Paint()..color = const Color(0xFFFFB8B8);
        final leftInner = Path()
          ..moveTo(cx - r * 0.48, cy - r * 0.55)
          ..lineTo(cx - r * 0.38, cy - r * 1.0)
          ..lineTo(cx - r * 0.18, cy - r * 0.65)
          ..close();
        canvas.drawPath(leftInner, innerPaint);
        final rightInner = Path()
          ..moveTo(cx + r * 0.48, cy - r * 0.55)
          ..lineTo(cx + r * 0.38, cy - r * 1.0)
          ..lineTo(cx + r * 0.18, cy - r * 0.65)
          ..close();
        canvas.drawPath(rightInner, innerPaint);
        break;
      default: // hat_cap
        hatPaint.color = AppColors.primary;
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx, cy - r * 0.7), width: r * 1.4, height: r * 0.7),
          3.14, 3.14, true, hatPaint,
        );
        // Brim
        canvas.drawRect(
          Rect.fromLTWH(cx - r * 0.75, cy - r * 0.72, r * 1.5, r * 0.1),
          hatPaint,
        );
    }
  }

  Color _bgColor(String key) {
    switch (key) {
      case 'bg_sky': return const Color(0xFF74B9FF);
      case 'bg_space': return const Color(0xFF2D3436);
      case 'bg_sakura': return const Color(0xFFFFB8B8);
      case 'bg_rainbow': return const Color(0xFFA29BFE);
      default: return const Color(0xFF74B9FF);
    }
  }

  Color _outfitColor(String key) {
    switch (key) {
      case 'outfit_hoodie': return const Color(0xFF636E72);
      case 'outfit_uniform': return const Color(0xFF2D3436);
      case 'outfit_hero': return const Color(0xFFE17055);
      case 'outfit_hanbok': return const Color(0xFFE84393);
      default: return const Color(0xFF636E72);
    }
  }

  @override
  bool shouldRepaint(covariant _CharacterPainter old) =>
      bgKey != old.bgKey || hatKey != old.hatKey || glassesKey != old.glassesKey ||
      outfitKey != old.outfitKey || exprKey != old.exprKey;
}

/// Simple icon for shop item preview.
class CharacterItemIcon extends StatelessWidget {
  const CharacterItemIcon({super.key, required this.svgKey, this.size = 40});

  final String svgKey;
  final double size;

  String get _emoji {
    if (svgKey.startsWith('hat_')) {
      switch (svgKey) {
        case 'hat_cap': return '🧢';
        case 'hat_crown': return '👑';
        case 'hat_grad': return '🎓';
        case 'hat_catears': return '🐱';
      }
    }
    if (svgKey.startsWith('glasses_')) {
      switch (svgKey) {
        case 'glasses_round': return '👓';
        case 'glasses_sun': return '🕶️';
        case 'glasses_heart': return '💕';
        case 'glasses_vr': return '🥽';
      }
    }
    if (svgKey.startsWith('outfit_')) {
      switch (svgKey) {
        case 'outfit_hoodie': return '🧥';
        case 'outfit_uniform': return '👔';
        case 'outfit_hero': return '🦸';
        case 'outfit_hanbok': return '👘';
      }
    }
    if (svgKey.startsWith('bg_')) {
      switch (svgKey) {
        case 'bg_sky': return '☁️';
        case 'bg_space': return '🌌';
        case 'bg_sakura': return '🌸';
        case 'bg_rainbow': return '🌈';
      }
    }
    if (svgKey.startsWith('expr_')) {
      switch (svgKey) {
        case 'expr_smile': return '😊';
        case 'expr_sleepy': return '😴';
        case 'expr_angry': return '😠';
        case 'expr_heartEyes': return '😍';
      }
    }
    return '✨';
  }

  @override
  Widget build(BuildContext context) {
    return TossFace(_emoji, size: size);
  }
}
