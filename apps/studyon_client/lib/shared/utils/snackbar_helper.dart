import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

void showStudyonSnackbar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  // ignore: deprecated_member_use
  SemanticsService.announce(
    message,
    Directionality.of(context),
    assertiveness: isError ? Assertiveness.assertive : Assertiveness.polite,
  );
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Semantics(
        liveRegion: true,
        child: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: isError ? AppColors.hot : AppColors.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 2),
    ),
  );
}
