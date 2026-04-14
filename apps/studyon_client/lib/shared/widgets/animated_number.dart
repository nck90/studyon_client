import 'package:flutter/material.dart';

class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 600),
    this.suffix = '',
    this.prefix = '',
  });

  final double value;
  final TextStyle style;
  final Duration duration;
  final String suffix;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        final display = val == val.roundToDouble()
            ? val.toInt().toString()
            : val.toStringAsFixed(1);
        return Text('$prefix$display$suffix', style: style);
      },
    );
  }
}
