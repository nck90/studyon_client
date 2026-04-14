import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';
import 'study_log_sheet.dart';

class StudySessionScreen extends ConsumerStatefulWidget {
  const StudySessionScreen({super.key});
  @override
  ConsumerState<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends ConsumerState<StudySessionScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  Timer? _timer;
  int _elapsed = 0;
  int _breakElapsed = 0;
  bool _isPaused = false;
  bool _isStarted = false;
  bool _goalReached = false;
  String? _selectedPlan;

  DateTime? _startedAt;
  DateTime? _pausedAt;
  int _accumulatedBeforePause = 0;
  int _breakAccumulated = 0;

  late final AnimationController _glowCtrl;

  static const int _goalSeconds = 3 * 3600;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Timer auto-recalculates from DateTime diff on next tick — no action needed
  }

  String _fmt(int s) {
    final h = (s ~/ 3600).toString().padLeft(2, '0');
    final m = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$h:$m:$sec';
  }

  void _start() {
    final plans = ref.read(studentProvider).plans;
    if (_selectedPlan == null && plans.isNotEmpty) {
      _showPlanPicker();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _isStarted = true;
      _startedAt = DateTime.now();
    });
    ref.read(studentProvider.notifier).startStudying();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && _startedAt != null) {
        setState(() {
          _elapsed = _accumulatedBeforePause + DateTime.now().difference(_startedAt!).inSeconds;
        });
        if (_elapsed >= _goalSeconds && !_goalReached) {
          _goalReached = true;
          HapticFeedback.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '목표 시간 달성!',
                style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w700, color: Colors.white),
              ),
              backgroundColor: AppColors.accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    });
  }

  void _showExitDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '공부를 중단할까요?',
          style: TextStyle(fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: const Text(
          '기록이 저장되지 않아요',
          style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              '계속 공부',
              style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600, color: AppColors.accent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text(
              '나가기',
              style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600, color: AppColors.hot),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanPicker() {
    final plans = ref.read(studentProvider).plans;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFF1E1E30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag_rounded, size: 18, color: AppColors.primaryLight),
                  const SizedBox(width: 8),
                  const Text(
                    '오늘 어떤 과목을 공부할까요?',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (plans.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      '등록된 계획이 없어요',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                )
              else
                ...plans.map((plan) => GestureDetector(
                      onTap: () {
                        setState(() => _selectedPlan = plan.subject);
                        Navigator.of(ctx).pop();
                        _start();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                plan.subject,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                plan.detail,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${plan.targetHours}h',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _isStarted = true;
                    _startedAt = DateTime.now();
                  });
                  ref.read(studentProvider.notifier).startStudying();
                  _startTimer();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      '과목 없이 시작',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pause() {
    HapticFeedback.lightImpact();
    _accumulatedBeforePause = _elapsed;
    _startedAt = null;
    _pausedAt = DateTime.now();
    setState(() => _isPaused = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _breakElapsed = _breakAccumulated + DateTime.now().difference(_pausedAt!).inSeconds;
      });
    });
  }

  void _resume() {
    HapticFeedback.lightImpact();
    _breakAccumulated = _breakElapsed;
    _pausedAt = null;
    _startedAt = DateTime.now();
    setState(() => _isPaused = false);
    _startTimer();
  }

  Future<void> _end() async {
    _timer?.cancel();
    await StudyLogSheet.show(context);
    if (mounted) {
      ref.read(studentProvider.notifier).addStudyTime(_elapsed);
      ref.read(studentProvider.notifier).addBreakTime(_breakElapsed);
      ref.read(studentProvider.notifier).stopStudying();
      context.go('/student/summary');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final progress = (_elapsed / _goalSeconds).clamp(0.0, 1.0);
    final subject = _selectedPlan ?? (student.goalSubject.isNotEmpty ? student.goalSubject : '공부');

    // Sizes adapt to screen
    final screenH = MediaQuery.of(context).size.height;
    final ringSize = isIPad ? (screenH * 0.38).clamp(240.0, 360.0) : 200.0;
    final timerFontSize = isIPad ? (ringSize * 0.18).clamp(36.0, 56.0) : 40.0;

    return PopScope(
      canPop: !_isStarted,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: EdgeInsets.fromLTRB(isIPad ? 32.0 : 20.0, 12, isIPad ? 32.0 : 20.0, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.close_rounded, size: 20, color: Colors.white70),
                      ),
                    ),
                    const Spacer(),
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: !_isStarted
                            ? Colors.white.withValues(alpha: 0.06)
                            : (_isPaused ? AppColors.warm.withValues(alpha: 0.15) : AppColors.accent.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: !_isStarted ? Colors.white38 : (_isPaused ? AppColors.warm : AppColors.accent),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            !_isStarted ? '준비' : (_isPaused ? '휴식' : '집중'),
                            style: TextStyle(
                              fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w600,
                              color: !_isStarted ? Colors.white38 : (_isPaused ? AppColors.warm : AppColors.accent),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Subject label
                    Text(subject, style: TextStyle(
                      fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white38,
                    )),
                  ],
                ),
              ),

              // Main timer area - centered, full width
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Timer ring
                      SizedBox(
                        width: ringSize,
                        height: ringSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow
                            if (_isStarted && !_isPaused)
                              AnimatedBuilder(
                                animation: _glowCtrl,
                                builder: (context, _) => Container(
                                  width: ringSize,
                                  height: ringSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary.withValues(alpha: 0.03 + 0.04 * _glowCtrl.value),
                                  ),
                                ),
                              ),
                            // Ring
                            RepaintBoundary(
                              child: CustomPaint(
                                size: Size(ringSize - 20, ringSize - 20),
                                painter: _RingPainter(progress: progress, isPaused: _isPaused),
                              ),
                            ),
                            // Time
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  _fmt(_elapsed),
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: timerFontSize,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Progress text
                      Text(
                        '${(progress * 100).toInt()}%  목표 3시간',
                        style: TextStyle(
                          fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        () {
                          final remaining = (_goalSeconds - _elapsed).clamp(0, _goalSeconds);
                          final m = (remaining ~/ 60).toString().padLeft(2, '0');
                          final s = (remaining % 60).toString().padLeft(2, '0');
                          return '남은 시간 $m:$s';
                        }(),
                        style: TextStyle(
                          fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      if (!_isStarted) ...[
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _showPlanPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.flag_rounded, size: 16, color: AppColors.primaryLight),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedPlan ?? '과목 선택',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedPlan != null ? Colors.white : Colors.white54,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white38),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom section - stats + buttons
              Padding(
                padding: EdgeInsets.fromLTRB(isIPad ? 80.0 : 24.0, 0, isIPad ? 80.0 : 24.0, 0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      // Mini stats row
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStat(label: '공부', value: _fmt(_elapsed).substring(0, 5), color: AppColors.primaryLight),
                          ),
                          Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.08)),
                          Expanded(
                            child: _MiniStat(label: '휴식', value: _fmt(_breakElapsed).substring(0, 5), color: AppColors.warm),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Goal progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: Colors.white.withValues(alpha: 0.06),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      if (!_isStarted)
                        Semantics(
                          label: '공부 시작',
                          button: true,
                          child: _ActionBtn(label: '시작', icon: Icons.play_arrow_rounded, color: AppColors.accent, onTap: _start),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: Semantics(
                                label: _isPaused ? '공부 재개' : '휴식',
                                button: true,
                                child: _ActionBtn(
                                  label: _isPaused ? '재개' : '휴식',
                                  icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                  color: Colors.transparent,
                                  borderColor: Colors.white.withValues(alpha: 0.15),
                                  textColor: Colors.white70,
                                  onTap: _isPaused ? _resume : _pause,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Semantics(
                                label: '공부 종료',
                                button: true,
                                child: _ActionBtn(label: '종료', icon: Icons.stop_rounded, color: AppColors.hot, onTap: _end),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: isIPad ? 40 : 24),
                    ],
                  ),
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thin colored top line accent
        Container(
          height: 2,
          width: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(
          fontFamily: 'Pretendard', fontSize: 22, fontWeight: FontWeight.w700,
          color: color, fontFeatures: const [FontFeature.tabularFigures()],
        )),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(
          fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white38,
        )),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.icon, required this.color, required this.onTap, this.borderColor, this.textColor});
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Color? borderColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != null ? Border.all(color: borderColor!, width: 1.5) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: textColor ?? Colors.white),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(
              fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w700,
              color: textColor ?? Colors.white,
            )),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.isPaused});
  final double progress;
  final bool isPaused;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Track
    canvas.drawCircle(center, radius, Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8);

    if (progress > 0) {
      // Progress arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, 2 * pi * progress, false,
        Paint()
          ..color = isPaused ? const Color(0xFFFDCB6E) : const Color(0xFF6C5CE7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress || old.isPaused != isPaused;
}
