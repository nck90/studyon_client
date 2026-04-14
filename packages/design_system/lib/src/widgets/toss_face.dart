import 'package:flutter/material.dart';

class TossFace extends StatelessWidget {
  const TossFace(this.emoji, {super.key, this.size = 24});
  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: TextStyle(
        fontFamily: 'TossFace',
        fontSize: size,
        height: 1.0,
      ),
    );
  }
}
