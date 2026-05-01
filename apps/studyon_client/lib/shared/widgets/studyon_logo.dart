import 'package:flutter/material.dart';

class StudyonLogo extends StatelessWidget {
  const StudyonLogo({
    super.key,
    this.scale = 1,
    this.showWordmark = true,
    this.textColor = Colors.white,
  });

  final double scale;
  final bool showWordmark;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 78 * scale,
          height: 64 * scale,
          child: Stack(
            children: [
              _LogoBar(
                color: const Color(0xFF12C46B),
                width: 66 * scale,
                height: 16 * scale,
                top: 0,
              ),
              _LogoBar(
                color: const Color(0xFF45D9FF),
                width: 62 * scale,
                height: 16 * scale,
                top: 22 * scale,
              ),
              _LogoBar(
                color: const Color(0xFFFFC64D),
                width: 58 * scale,
                height: 16 * scale,
                top: 44 * scale,
              ),
            ],
          ),
        ),
        if (showWordmark) ...[
          SizedBox(height: 12 * scale),
          Text(
            '자습ON',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 30 * scale,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -1.2,
              height: 1,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoBar extends StatelessWidget {
  const _LogoBar({
    required this.color,
    required this.width,
    required this.height,
    required this.top,
  });

  final Color color;
  final double width;
  final double height;
  final double top;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(height / 2);
    return Positioned(
      top: top,
      left: 0,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: height * 1.35,
            margin: EdgeInsets.only(right: height * 0.18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: Center(
              child: Container(
                width: height * 0.55,
                height: 2,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
