import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';
import 'package:studyon_client/shared/utils/snackbar_helper.dart';

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
  Timer? _clockTimer;
  String _timeStr = '';
  String _dateStr = '';

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    setState(() {
      _timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      _dateStr = '${now.month}월 ${now.day}일 ${weekdays[now.weekday - 1]}요일';
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scaleCtrl.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _checkIn() async {
    if (_isLoading) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    _scaleCtrl.forward();
    _pulseCtrl.stop();
    ref.read(studentProvider.notifier).checkIn();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      showStudyonSnackbar(context, '입실 완료');
      context.go('/student/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Time
            Text(
              _timeStr,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: isIPad ? 88 : 64,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -3,
                height: 1.0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _dateStr,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: isIPad ? 18 : 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),

            const Spacer(flex: 3),

            // Check-in button
            Stack(
              alignment: Alignment.center,
              children: [
                if (!_isLoading)
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, _) => Container(
                      width: (isIPad ? 96 : 80) + 16 * _pulseCtrl.value,
                      height: (isIPad ? 96 : 80) + 16 * _pulseCtrl.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.04 + 0.03 * _pulseCtrl.value),
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
                        width: isIPad ? 96 : 80,
                        height: isIPad ? 96 : 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isLoading ? AppColors.accent : AppColors.primary,
                        ),
                        child: _isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                ),
                              )
                            : Icon(Icons.arrow_upward_rounded, size: isIPad ? 36 : 30, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _isLoading ? '입실 중' : '입실하기',
                key: ValueKey(_isLoading),
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isLoading ? AppColors.textTertiary : AppColors.textPrimary,
                ),
              ),
            ),

            const Spacer(flex: 2),

            // Bottom info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(student.seatNo, style: const TextStyle(
                  fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textTertiary,
                )),
                Container(width: 1, height: 12, margin: const EdgeInsets.symmetric(horizontal: 16), color: AppColors.cardBorder),
                const Text('공부 중 18명', style: TextStyle(
                  fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textTertiary,
                )),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
