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

class _CheckInScreenState extends ConsumerState<CheckInScreen> with TickerProviderStateMixin {
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
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat(reverse: true);
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
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
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // Large clock - the hero, like iPad lockscreen
            Text(
              _timeStr,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: isIPad ? 96 : 72,
                fontWeight: FontWeight.w200,
                color: Colors.white,
                letterSpacing: -4,
                height: 1.0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),

            // Date
            Text(
              _dateStr,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: isIPad ? 20 : 17,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              ),
            ),

            const Spacer(flex: 4),

            // Check-in button - subtle, not screaming
            Stack(
              alignment: Alignment.center,
              children: [
                // Pulse ring
                if (!_isLoading)
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, _) => Container(
                      width: (isIPad ? 88 : 76) + 20 * _pulseCtrl.value,
                      height: (isIPad ? 88 : 76) + 20 * _pulseCtrl.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06 + 0.06 * _pulseCtrl.value),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                // Button
                ScaleTransition(
                  scale: _scaleAnim,
                  child: GestureDetector(
                    onTap: _checkIn,
                    child: Container(
                      width: isIPad ? 88 : 76,
                      height: isIPad ? 88 : 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isLoading ? AppColors.accent : Colors.white.withValues(alpha: 0.1),
                        border: _isLoading ? null : Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                      ),
                      child: _isLoading
                          ? const Center(child: SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                          : Icon(Icons.arrow_upward_rounded, size: isIPad ? 32 : 28, color: Colors.white.withValues(alpha: 0.8)),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: _isLoading ? 0.4 : 0.6),
                  letterSpacing: 0.3,
                ),
              ),
            ),

            const Spacer(flex: 3),

            // Bottom info - minimal, like lockscreen bottom
            Text(
              student.seatNo,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
