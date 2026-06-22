import 'package:flutter/material.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

const _rpgAssetRoot = 'assets/images/rpg';

class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({super.key, required this.character, this.size = 100});

  final Map<String, dynamic> character;
  final double size;

  @override
  Widget build(BuildContext context) {
    final stageKey =
        (character['stageAssetKey'] ??
                character['growthStage'] ??
                _stageForLevel((character['level'] as num?)?.toInt() ?? 1))
            .toString();
    final equippedItems =
        (character['equippedItems'] as List?)?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Image.asset(
            '$_rpgAssetRoot/$stageKey.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => CustomPaint(
              size: Size.square(size),
              painter: _FallbackCharacterPainter(),
            ),
          ),
          Positioned(
            right: -size * 0.04,
            bottom: -size * 0.04,
            child: _EquippedItemStack(items: equippedItems, size: size * 0.32),
          ),
        ],
      ),
    );
  }
}

class RpgThemePreview extends StatelessWidget {
  const RpgThemePreview({super.key, required this.preset});

  final String preset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      '$_rpgAssetRoot/theme_$preset.png',
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.themeSeeds[preset] ?? AppColors.primary,
        ),
      ),
    );
  }
}

class _EquippedItemStack extends StatelessWidget {
  const _EquippedItemStack({required this.items, required this.size});

  final List<Map<String, dynamic>> items;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visible = items
        .where((item) => item['category'] != 'BACKGROUND')
        .take(3)
        .toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: visible
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: CharacterItemIcon(
                  svgKey: item['svgKey']?.toString() ?? '',
                  size: size * 0.54,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FallbackCharacterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.36;

    final bgPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.width * 0.22),
      ),
      bgPaint,
    );

    final bodyPaint = Paint()..color = const Color(0xFFF8E8D0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.38),
        width: r * 1.32,
        height: r * 0.82,
      ),
      bodyPaint,
    );
    canvas.drawCircle(Offset(cx, cy - r * 0.12), r, bodyPaint);

    final eyePaint = Paint()..color = const Color(0xFF2D3436);
    canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.18), r * 0.08, eyePaint);
    canvas.drawCircle(Offset(cx + r * 0.3, cy - r * 0.18), r * 0.08, eyePaint);

    final mouthPaint = Paint()
      ..color = const Color(0xFF2D3436)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.08),
        width: r * 0.42,
        height: r * 0.25,
      ),
      0,
      3.14,
      false,
      mouthPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FallbackCharacterPainter oldDelegate) => false;
}

class CharacterItemIcon extends StatelessWidget {
  const CharacterItemIcon({super.key, required this.svgKey, this.size = 40});

  final String svgKey;
  final double size;

  String get _emoji {
    return switch (svgKey) {
      'hat_cap' => '🧢',
      'hat_crown' => '👑',
      'hat_grad' => '🎓',
      'hat_catears' => '🐱',
      'glasses_round' => '👓',
      'glasses_sun' => '🕶️',
      'glasses_heart' => '💕',
      'glasses_vr' => '🥽',
      'outfit_hoodie' => '🧥',
      'outfit_uniform' => '👔',
      'outfit_hero' => '🦸',
      'outfit_hanbok' => '👘',
      'bg_sky' => '☁️',
      'bg_space' => '🌌',
      'bg_sakura' => '🌸',
      'bg_rainbow' => '🌈',
      'expr_smile' => '😊',
      'expr_sleepy' => '😴',
      'expr_angry' => '😠',
      'expr_heartEyes' => '😍',
      _ => '✨',
    };
  }

  @override
  Widget build(BuildContext context) {
    return TossFace(_emoji, size: size);
  }
}

String _stageForLevel(int level) {
  if (level >= 15) return 'stage_05';
  if (level >= 10) return 'stage_04';
  if (level >= 6) return 'stage_03';
  if (level >= 3) return 'stage_02';
  return 'stage_01';
}
