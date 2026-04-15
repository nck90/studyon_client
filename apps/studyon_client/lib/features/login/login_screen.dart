import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../shared/services/local_storage.dart';
import '../../shared/utils/snackbar_helper.dart';
import '../../shared/providers/student_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isAdmin = false;
  bool _isLoading = false;
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _pwController = TextEditingController();
  final _nameFocus = FocusNode();
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
    _nameController.dispose();
    _pwController.dispose();
    _nameFocus.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;

    if (_isAdmin) {
      showStudyonSnackbar(
        context,
        '관리자 영역 연동은 다음 단계에서 이어서 붙입니다. 현재는 학생 앱 실연동 우선입니다.',
        isError: true,
      );
      return;
    }

    final studentNo = _idController.text.trim();
    final name = _nameController.text.trim();
    if (studentNo.isEmpty || name.isEmpty) {
      showStudyonSnackbar(context, '학번과 이름을 입력해 주세요', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(studentProvider.notifier).login(studentNo, name);
      await LocalStorage.setLastLoginId(studentNo);
      if (!mounted) return;
      final student = ref.read(studentProvider);
      context.go(student.isCheckedIn ? '/student/home' : '/student/checkin');
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
                            child: const TossFace('📚', size: 48),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            '자습ON',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1.5,
                            ),
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
                            '실제 백엔드 연결',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
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
                  child: const TossFace('📚', size: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  '자습ON',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
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
        Text(_isAdmin ? '관리자 로그인' : '학생 로그인', style: AppTypography.headlineLarge),
        const SizedBox(height: 32),
        _InputField(
          controller: _idController,
          hint: _isAdmin ? '이메일' : '학번',
          icon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              _isAdmin ? _pwFocus.requestFocus() : _nameFocus.requestFocus(),
        ),
        const SizedBox(height: 12),
        _InputField(
          controller: _isAdmin ? _pwController : _nameController,
          hint: _isAdmin ? '비밀번호' : '이름',
          icon: _isAdmin
              ? Icons.lock_outline_rounded
              : Icons.badge_outlined,
          obscure: _isAdmin,
          focusNode: _isAdmin ? _pwFocus : _nameFocus,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _login(),
        ),
        const SizedBox(height: 32),
        GestureDetector(
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
                  : Text(
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
        if (!_isAdmin) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push('/signup'),
            child: Text(
              '처음이면 회원가입',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
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
    this.obscure = false,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
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
  }
}
