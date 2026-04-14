import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';
import '../../../shared/utils/snackbar_helper.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});
  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late final AnimationController _pulseCtrl;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;
  late final Timer _clockTimer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut),
    );
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scaleCtrl.dispose();
    _clockTimer.cancel();
    super.dispose();
  }

  void _checkIn() async {
    if (_isLoading) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    _scaleCtrl.forward();
    _pulseCtrl.stop();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      ref.read(studentProvider.notifier).checkIn();
      showStudyonSnackbar(context, '입실 완료');
      context.go('/student/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final timeStr =
        '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final dateStr = '${_now.month}월 ${_now.day}일 (${weekdays[_now.weekday - 1]})';
    const buttonSize = 148.0;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Clock
                Text(
                  timeStr,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -3,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                // Button with pulse
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!_isLoading)
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (context, _) => Container(
                          width: buttonSize + 30 + 30 * _pulseCtrl.value,
                          height: buttonSize + 30 + 30 * _pulseCtrl.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(
                              alpha: 0.04 + 0.04 * _pulseCtrl.value,
                            ),
                          ),
                        ),
                      ),
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: Semantics(
                        label: '입실하기',
                        button: true,
                        child: GestureDetector(
                          onTap: _checkIn,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _isLoading
                                    ? AppColors.mintGradient
                                    : AppColors.primaryGradient,
                              ),
                            ),
                            child: _isLoading
                                ? const Center(
                                    child: SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.door_front_door_outlined,
                                    size: 52,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isLoading
                      ? Text(
                          '입실 처리 중',
                          key: const ValueKey('l'),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        )
                      : Text(
                          '입실하기',
                          key: const ValueKey('r'),
                          style: AppTypography.headlineLarge.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                // Compact info row: seat + streak
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_seat_rounded, size: 15, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      '좌석 ${student.seatNo}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 3,
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(
                        color: AppColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const TossFace('🔥', size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '7일 연속',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 1),
                // Mini info cards at bottom
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Row(
                    children: const [
                      Expanded(child: _MiniInfo(label: '오늘 목표', value: '수학 3시간')),
                      SizedBox(width: 12),
                      Expanded(child: _MiniInfo(label: '자습실', value: '18 / 22명')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
