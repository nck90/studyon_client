import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../shared/providers/student_providers.dart';
import '../../shared/services/local_storage.dart';
import '../../shared/utils/snackbar_helper.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _studentNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _studentNoController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final studentNo = _studentNoController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (studentNo.isEmpty || name.isEmpty) {
      showStudyonSnackbar(context, '학번과 이름은 필수입니다', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(studentProvider.notifier).signup(
            studentNo: studentNo,
            name: name,
            phone: phone.isEmpty ? null : phone,
          );
      await LocalStorage.setLastLoginId(studentNo);
      if (!mounted) return;
      final student = ref.read(studentProvider);
      context.go(student.isCheckedIn ? '/student/home' : '/student/checkin');
    } catch (error) {
      if (!mounted) return;
      showStudyonSnackbar(context, '회원가입에 실패했어요: $error', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      PressableScale(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('학생 회원가입', style: AppTypography.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    '학번과 이름으로 바로 시작할 수 있게 계정을 만들어요.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SignupField(
                    controller: _studentNoController,
                    hint: '학번',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 12),
                  _SignupField(
                    controller: _nameController,
                    hint: '이름',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _SignupField(
                    controller: _phoneController,
                    hint: '전화번호(선택)',
                    icon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Center(
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                '회원가입하고 시작',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupField extends StatelessWidget {
  const _SignupField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        fillColor: AppColors.surface,
        filled: true,
        prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
