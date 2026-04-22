import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_core/studyon_core.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../shared/providers/student_providers.dart';
import '../../shared/services/local_storage.dart';
import '../../shared/utils/snackbar_helper.dart';
import '../../shared/widgets/studyon_logo.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pwFocus = FocusNode();
  final _nameFocus = FocusNode();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _pwFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final loginId = _loginIdController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || loginId.isEmpty || password.isEmpty) {
      showStudyonSnackbar(
        context,
        '이름, 아이디, 비밀번호는 필수입니다',
        isError: true,
      );
      return;
    }
    if (password.length < 8) {
      showStudyonSnackbar(
        context,
        '비밀번호는 8자 이상이어야 합니다',
        isError: true,
      );
      return;
    }

    final autoStudentNo =
        'S${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    setState(() => _isSubmitting = true);
    try {
      await ref.read(studentProvider.notifier).signup(
            loginId: loginId,
            password: password,
            studentNo: autoStudentNo,
            name: name,
            phone: phone.isEmpty ? null : phone,
          );
      await LocalStorage.setLastLoginId(loginId);
      if (!mounted) return;
      final student = ref.read(studentProvider);
      context.go(student.isCheckedIn ? '/student/home' : '/student/checkin');
    } catch (error) {
      if (!mounted) return;
      showStudyonSnackbar(
        context,
        '회원가입에 실패했어요: ${_errorMessage(error)}',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _errorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;

    if (isIPad) {
      return Scaffold(
        body: Row(
          children: [
            // Left brand area
            Expanded(
              flex: 5,
              child: Container(
                color: AppColors.primary,
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const StudyonLogo(scale: 1.05),
                          const SizedBox(height: 8),
                          Text(
                            '수학학원 학습 관리',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 48,
                      left: 0,
                      right: 0,
                      child: Text(
                        '새로운 학생 등록',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right form area
            Expanded(
              flex: 4,
              child: Container(
                color: AppColors.surface,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: _buildForm(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Phone layout
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
                  _buildForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('회원가입', style: AppTypography.headlineLarge),
        const SizedBox(height: 8),
        Text(
          '아이디와 비밀번호를 만들고 시작해요.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        _SignupField(
          identifier: 'signup-name',
          controller: _nameController,
          hint: '이름',
          icon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        _SignupField(
          identifier: 'signup-id',
          controller: _loginIdController,
          hint: '아이디',
          icon: Icons.alternate_email_rounded,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        _SignupField(
          identifier: 'signup-password',
          controller: _passwordController,
          hint: '비밀번호',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        _SignupField(
          identifier: 'signup-phone',
          controller: _phoneController,
          hint: '전화번호 (선택)',
          icon: Icons.phone_outlined,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 28),
        Semantics(
          container: true,
          button: true,
          enabled: !_isSubmitting,
          identifier: 'signup-submit',
          label: '가입하고 시작하기',
          onTap: _submit,
          child: GestureDetector(
          onTap: _submit,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.primaryGradient,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
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
                  : ExcludeSemantics(
                      child: const Text(
                        '가입하고 시작하기',
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
        ),
        ),
        const SizedBox(height: 16),
        Semantics(
          container: true,
          button: true,
          identifier: 'go-login',
          label: '이미 계정이 있어요',
          onTap: () => context.pop(),
          child: TextButton(
            onPressed: () => context.pop(),
            child: ExcludeSemantics(
              child: Text(
                '이미 계정이 있어요',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignupField extends StatelessWidget {
  const _SignupField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.identifier,
    this.obscure = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? identifier;
  final bool obscure;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      obscureText: obscure,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Pretendard',
          color: AppColors.textTertiary,
          fontSize: 15,
        ),
        fillColor: AppColors.background,
        filled: true,
        prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
    if (identifier == null) return field;
    return Semantics(identifier: identifier, container: true, child: field);
  }
}
