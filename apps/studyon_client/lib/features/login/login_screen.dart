import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_models/studyon_models.dart';

import '../../shared/services/local_storage.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/utils/snackbar_helper.dart';
import '../../shared/providers/student_providers.dart';
import '../../shared/widgets/studyon_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isAdmin = false;
  bool _isLoading = false;
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _restoreLastLoginId();
  }

  Future<void> _restoreLastLoginId() async {
    final lastLoginId = await LocalStorage.getLastLoginId();
    if (!mounted || lastLoginId == null) return;
    _idController.text = lastLoginId;
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;

    final loginId = _idController.text.trim();
    final password = _pwController.text.trim();
    if (loginId.isEmpty || password.isEmpty) {
      showStudyonSnackbar(context, '아이디와 비밀번호를 입력해 주세요', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isAdmin) {
        await ref.read(authNotifierProvider.notifier).loginAsAdmin(
              AdminLoginRequest(email: loginId, password: password),
            );
      } else {
        await ref.read(studentProvider.notifier).login(loginId, password);
      }
      await LocalStorage.setLastLoginId(loginId);
      if (!mounted) return;
      if (_isAdmin) {
        context.go('/admin/dashboard');
      } else {
        final student = ref.read(studentProvider);
        context.go(student.isCheckedIn ? '/student/home' : '/student/checkin');
      }
    } catch (error) {
      if (!mounted) return;
      showStudyonSnackbar(context, '로그인에 실패했어요: $error', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;

    if (isIPad) {
      return Scaffold(
        body: Row(
          children: [
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
                          GestureDetector(
                            onLongPress: () =>
                                setState(() => _isAdmin = !_isAdmin),
                            child: const StudyonLogo(scale: 0.95),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 48,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            _isAdmin ? '관리자 준비 중' : '학생 로그인',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(32, 80, 32, 48),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onLongPress: () => setState(() => _isAdmin = !_isAdmin),
                  child: const StudyonLogo(scale: 0.9),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: _buildForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(_isAdmin ? '관리자 로그인' : '학생 로그인', style: AppTypography.headlineLarge),
        ),
        const SizedBox(height: 32),
        _InputField(
          identifier: 'login-id',
          controller: _idController,
          hint: _isAdmin ? '이메일' : '아이디',
          icon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _pwFocus.requestFocus(),
        ),
        const SizedBox(height: 12),
        _InputField(
          identifier: 'login-password',
          controller: _pwController,
          hint: '비밀번호',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          focusNode: _pwFocus,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _login(),
        ),
        const SizedBox(height: 32),
        Semantics(
          container: true,
          button: true,
          enabled: !_isLoading,
          identifier: 'login-submit',
          label: _isAdmin ? '관리자 로그인' : '로그인',
          onTap: _login,
          child: GestureDetector(
            onTap: _login,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : ExcludeSemantics(
                        child: Text(
                          _isAdmin ? '관리자 로그인' : '로그인',
                          style: const TextStyle(
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
        if (!_isAdmin) ...[
          const SizedBox(height: 16),
          Semantics(
            container: true,
            button: true,
            identifier: 'go-signup',
            label: '처음이면 회원가입',
            onTap: () => context.push('/signup'),
            child: TextButton(
              onPressed: () => context.push('/signup'),
              child: ExcludeSemantics(
                child: Text(
                  '처음이면 회원가입',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.identifier,
    this.obscure = false,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? identifier;
  final bool obscure;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      obscureText: obscure,
      focusNode: focusNode,
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
