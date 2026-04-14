import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAdmin = false;
  final _idController = TextEditingController();
  final _pwController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _login() {
    if (_isAdmin) {
      context.go('/admin/dashboard');
    } else {
      context.go('/student/checkin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;

    if (isIPad) {
      return Scaffold(
        body: Row(
          children: [
            // Left: Gradient branding panel
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Stack(
                  children: [
                    // Branding content
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
                    // Bottom stats
                    Positioned(
                      bottom: 48,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            '현재 이용 중',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '18명',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 28,
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
            // Right: Form panel
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

    // Phone layout: stacked gradient header + form
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
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
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
        Text('로그인', style: AppTypography.headlineLarge),
        const SizedBox(height: 32),
        _InputField(
          controller: _idController,
          hint: '아이디',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),
        _InputField(
          controller: _pwController,
          hint: '비밀번호',
          icon: Icons.lock_outline_rounded,
          obscure: true,
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
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
