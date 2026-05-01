import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../shared/providers/app_providers.dart';
import '../../shared/providers/student_providers.dart';
import '../../shared/services/local_storage.dart';
import '../../shared/widgets/studyon_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    final onboardingDone = await LocalStorage.isOnboardingDone();
    final isDarkMode = await LocalStorage.isDarkMode();
    ref.read(studentProvider.notifier).setDarkMode(isDarkMode);

    await Future.wait<void>([
      Future<void>.delayed(const Duration(milliseconds: 1400)),
      ref.read(authNotifierProvider.notifier).tryRestore(),
    ]);

    if (!mounted) return;

    if (!onboardingDone) {
      context.go('/onboarding');
      return;
    }

    final authState = ref.read(authNotifierProvider);
    if (!authState.isAuthenticated) {
      context.go('/login');
      return;
    }

    final role = authState.user?.role.toUpperCase();
    if (role == 'STUDENT') {
      try {
        await ref.read(studentProvider.notifier).hydrate();
      } catch (_) {
        // New user with no data — proceed with default state
      }
      if (!mounted) return;
      final student = ref.read(studentProvider);
      context.go(student.isCheckedIn ? '/student/home' : '/student/checkin');
      return;
    }

    context.go('/admin/dashboard');
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppColors.primary),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              StudyonLogo(scale: isIPad ? 1.2 : 1),
              const SizedBox(height: 12),
              Text(
                '자습실 관리 시스템',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.65),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        minHeight: 3,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'STUDYON',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.45),
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
