import 'package:flutter/material.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

void showStudyonSnackbar(
  BuildContext context,
  String message, {
  bool isSuccess = true,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isSuccess ? AppColors.accent : AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
  );
}
