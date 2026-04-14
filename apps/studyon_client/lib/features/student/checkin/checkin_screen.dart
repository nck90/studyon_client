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

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scaleCtrl.dispose();
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
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final dateStr = '${now.month}월 ${now.day}일 (${weekdays[now.weekday - 1]})';
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;

    final checkInSection = _CheckInSection(
      timeStr: timeStr,
      dateStr: dateStr,
      isIPad: isIPad,
      isLoading: _isLoading,
      pulseCtrl: _pulseCtrl,
      scaleAnim: _scaleAnim,
      onCheckIn: _checkIn,
      seatNo: student.seatNo,
    );

    final infoSection = _InfoSection(isIPad: isIPad);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isIPad
            ? Row(
                children: [
                  Expanded(flex: 5, child: checkInSection),
                  Container(width: 1, color: AppColors.divider),
                  Expanded(flex: 4, child: infoSection),
                ],
              )
            : ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: checkInSection,
                  ),
                  infoSection,
                ],
              ),
      ),
    );
  }
}

class _CheckInSection extends StatelessWidget {
  const _CheckInSection({
    required this.timeStr,
    required this.dateStr,
    required this.isIPad,
    required this.isLoading,
    required this.pulseCtrl,
    required this.scaleAnim,
    required this.onCheckIn,
    required this.seatNo,
  });
  final String timeStr;
  final String dateStr;
  final bool isIPad;
  final bool isLoading;
  final AnimationController pulseCtrl;
  final Animation<double> scaleAnim;
  final VoidCallback onCheckIn;
  final String seatNo;

  @override
  Widget build(BuildContext context) {
    final buttonSize = isIPad ? 160.0 : 140.0;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time
          Text(
            timeStr,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: isIPad ? 56 : 48,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateStr,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
          // Button with pulse
          Stack(
            alignment: Alignment.center,
            children: [
              if (!isLoading)
                AnimatedBuilder(
                  animation: pulseCtrl,
                  builder: (context, _) => Container(
                    width: buttonSize + 30 + 30 * pulseCtrl.value,
                    height: buttonSize + 30 + 30 * pulseCtrl.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(
                        alpha: 0.04 + 0.04 * pulseCtrl.value,
                      ),
                    ),
                  ),
                ),
              ScaleTransition(
                scale: scaleAnim,
                child: Semantics(
                  label: '입실하기',
                  button: true,
                  child: GestureDetector(
                    onTap: onCheckIn,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: buttonSize,
                      height: buttonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isLoading
                              ? AppColors.mintGradient
                              : AppColors.primaryGradient,
                        ),
                      ),
                      child: isLoading
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
                          : Icon(
                              Icons.door_front_door_outlined,
                              size: isIPad ? 56 : 48,
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
            child: isLoading
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
          // Seat chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.event_seat_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  '좌석 $seatNo',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.isIPad});
  final bool isIPad;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isIPad ? 32.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isIPad) const SizedBox(height: 8),
          // Streak
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const TossFace('🔥', size: 28),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '연속 7일',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Mini week attendance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이번 주 출석',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: ['월', '화', '수', '목', '금', '토', '일']
                      .asMap()
                      .entries
                      .map((e) {
                    final attended = e.key < 5;
                    final isToday = e.key == 5;
                    return Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: attended
                                  ? AppColors.primary
                                  : (isToday
                                      ? AppColors.accent
                                      : AppColors.background),
                            ),
                            child: Center(
                              child: attended
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : isToday
                                      ? const Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: Colors.white,
                                        )
                                      : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            e.value,
                            style: AppTypography.labelSmall.copyWith(
                              color: isToday
                                  ? AppColors.accent
                                  : (attended
                                      ? AppColors.primary
                                      : AppColors.textTertiary),
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Today's goal
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '오늘 목표',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '수학 수1 3단원 문제풀이',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '3시간',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Room status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_rounded, size: 20, color: AppColors.accent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '자습실 현황',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '공부 중 18명',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '18/22',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
