import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';
import 'package:studyon_models/studyon_models.dart';
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
  bool _pomodoroNotified = false;
  String? _selectedPlan;
  String? _selectedPlanId;
  String? _sessionId;
  bool _isSubmitting = false;

  DateTime? _startedAt;
  DateTime? _pausedAt;
  int _accumulatedBeforePause = 0;
  int _breakAccumulated = 0;
  static const int _goalSeconds = 3 * 3600;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    _startSessionOnServer();
  }

  Future<void> _startSessionOnServer() async {
    try {
      final session = await ref.read(studentRepositoryProvider).startSession(
            linkedPlanId: _selectedPlanId,
          );
      _sessionId = session.id;
      _syncFromSession(session);
      _startTimer();
    } catch (_) {
      if (!mounted) return;
      ref.read(studentProvider.notifier).stopStudying();
      setState(() {
        _isStarted = false;
        _startedAt = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('공부 시작에 실패했어요'),
          backgroundColor: AppColors.hot,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _syncFromSession(StudySession session) {
    setState(() {
      _sessionId = session.id;
      _elapsed = session.studyMinutes * 60;
      _breakElapsed = session.breakMinutes * 60;
      _accumulatedBeforePause = _elapsed;
      _breakAccumulated = _breakElapsed;
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && _startedAt != null) {
        setState(() {
          _elapsed = _accumulatedBeforePause + DateTime.now().difference(_startedAt!).inSeconds;
        });
        if (_elapsed >= 1500 && !_pomodoroNotified && !_isPaused) {
          _pomodoroNotified = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('25분 집중 완료! 잠시 휴식하세요',
                  style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
              backgroundColor: AppColors.warm,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ));
          }
        }
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('공부를 멈출까요?', style: TextStyle(fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: const Text('지금 나가면 이번 기록은 저장되지 않아요.', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: AppColors.textSecondary)),
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
      backgroundColor: Colors.white,
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
                  const Icon(Icons.flag_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    '오늘 어떤 과목을 공부할까요?',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                )
              else
                ...plans.map((plan) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlan = plan.subject;
                          _selectedPlanId = plan.id;
                        });
                        Navigator.of(ctx).pop();
                        _start();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.divider),
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
                                  color: AppColors.primary,
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
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${plan.targetHours}h',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                color: AppColors.textTertiary,
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
                    _selectedPlanId = null;
                    _isStarted = true;
                    _startedAt = DateTime.now();
                  });
                  ref.read(studentProvider.notifier).startStudying();
                  _startSessionOnServer();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      '과목 없이 시작',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
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

  Future<void> _pause() async {
    if (_sessionId == null || _isSubmitting) return;
    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);
    try {
      final session = await ref.read(studentRepositoryProvider).pauseSession(_sessionId!);
      _syncFromSession(session);
      _accumulatedBeforePause = _elapsed;
      _startedAt = null;
      _pausedAt = DateTime.now();
      setState(() => _isPaused = true);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _breakElapsed =
              _breakAccumulated + DateTime.now().difference(_pausedAt!).inSeconds;
        });
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('휴식 전환에 실패했어요'),
            backgroundColor: AppColors.hot,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resume() async {
    if (_sessionId == null || _isSubmitting) return;
    HapticFeedback.lightImpact();
    setState(() => _isSubmitting = true);
    try {
      final session = await ref.read(studentRepositoryProvider).resumeSession(_sessionId!);
      _syncFromSession(session);
      _breakAccumulated = _breakElapsed;
      _pausedAt = null;
      _startedAt = DateTime.now();
      setState(() => _isPaused = false);
      _startTimer();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('공부 재개에 실패했어요'),
            backgroundColor: AppColors.hot,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _end() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('공부를 종료할까요?', style: TextStyle(fontFamily: 'Pretendard', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text(
          '${_fmt(_elapsed)} 동안 공부했어요.',
          style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('계속', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600, color: AppColors.accent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('종료', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600, color: AppColors.hot)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final draft = await StudyLogSheet.show(
      context,
      initialSubject: _selectedPlan,
    );
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      _timer?.cancel();
      StudySession? session;
      if (_sessionId != null) {
        session = await ref.read(studentRepositoryProvider).endSession(_sessionId!);
        _syncFromSession(session);
      }

      final subjectName =
          draft?.subject ?? _selectedPlan ?? ref.read(studentProvider).goalSubject;

      await ref.read(studentRepositoryProvider).createStudyLog(
            subjectName: subjectName.isEmpty ? '공부' : subjectName,
            planId: _selectedPlanId,
            studySessionId: session?.id ?? _sessionId,
            memo: draft?.memo,
            progressPercent: (_elapsed / _goalSeconds).clamp(0.0, 1.0),
            isCompleted: draft?.goalCompleted ?? (_elapsed >= _goalSeconds),
          );

      await ref.read(studentProvider.notifier).hydrate();
      ref.read(studentProvider.notifier).stopStudying();
      if (mounted) context.go('/student/summary');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('공부 종료 저장에 실패했어요'),
            backgroundColor: AppColors.hot,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      _startTimer();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final progress = (_elapsed / _goalSeconds).clamp(0.0, 1.0);
    final subject = _selectedPlan ?? (student.goalSubject.isNotEmpty ? student.goalSubject : '공부');

    return PopScope(
      canPop: !_isStarted,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _showExitDialog();
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF7F8FB), Color(0xFFF2F3F5)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(isIPad ? 32.0 : 20.0, 12, isIPad ? 32.0 : 20.0, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _isStarted ? _showExitDialog : () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xE8E9EDF4)),
                          ),
                          child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF555B65)),
                        ),
                      ),
                      const Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.76),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: !_isStarted
                                    ? const Color(0xE8E9EDF4)
                                    : (_isPaused ? AppColors.warm.withValues(alpha: 0.30) : AppColors.accent.withValues(alpha: 0.22)),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: !_isStarted ? AppColors.textTertiary : (_isPaused ? AppColors.warm : AppColors.accent),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  !_isStarted ? '준비' : (_isPaused ? '휴식' : '집중'),
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: !_isStarted ? AppColors.textTertiary : (_isPaused ? AppColors.hot : AppColors.accent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.76),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xE8E9EDF4)),
                        ),
                        child: Text(
                          subject,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: isIPad ? 820 : double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: isIPad ? 32 : 20),
                      padding: EdgeInsets.fromLTRB(isIPad ? 48 : 24, 30, isIPad ? 48 : 24, 28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFFFFF), Color(0xFFF6F7FA)],
                        ),
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(color: const Color(0xFFE8EBF2)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0B1A1D29),
                            blurRadius: 28,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            !_isStarted ? '공부를 시작해요' : (_isPaused ? '잠깐 쉬고 있어요' : '집중 흐름을 유지하고 있어요'),
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '시선이 바로 꽂히는 타이머로 정리했어요.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          _AppleStyleTimer(value: _fmt(_elapsed), isIPad: isIPad),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFE8EBF2)),
                            ),
                            child: Text(
                              '${(progress * 100).toInt()}% 진행 중 · 목표 3시간',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            () {
                              final remaining = (_goalSeconds - _elapsed).clamp(0, _goalSeconds);
                              final h = (remaining ~/ 3600).toString().padLeft(2, '0');
                              final m = ((remaining % 3600) ~/ 60).toString().padLeft(2, '0');
                              final s = (remaining % 60).toString().padLeft(2, '0');
                              return '남은 시간 $h:$m:$s';
                            }(),
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: const Color(0xFFE9ECF4),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                          if (!_isStarted) ...[
                            const SizedBox(height: 22),
                            GestureDetector(
                              onTap: _showPlanPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F6FA),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFFE8EBF2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.flag_rounded, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedPlan ?? '과목 선택',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _selectedPlan != null ? AppColors.textPrimary : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textTertiary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(isIPad ? 80.0 : 24.0, 0, isIPad ? 80.0 : 24.0, 0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _MiniStat(label: '공부', value: _fmt(_elapsed).substring(0, 5), color: AppColors.primary),
                            ),
                            Container(width: 1, height: 32, color: AppColors.divider),
                            Expanded(
                              child: _MiniStat(label: '휴식', value: _fmt(_breakElapsed).substring(0, 5), color: AppColors.warm),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: AppColors.primarySurface,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!_isStarted)
                          Semantics(
                            label: '공부 시작',
                            button: true,
                            child: _ActionBtn(
                              label: '시작',
                              icon: Icons.play_arrow_rounded,
                              color: AppColors.accent,
                              onTap: _start,
                            ),
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
                                    color: Colors.white,
                                    borderColor: AppColors.divider,
                                    textColor: AppColors.textSecondary,
                                    onTap: () {
                                      if (_isSubmitting) return;
                                      if (_isPaused) {
                                        _resume();
                                      } else {
                                        _pause();
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Semantics(
                                  label: '공부 종료',
                                  button: true,
                                  child: _ActionBtn(
                                    label: '종료',
                                    icon: Icons.stop_rounded,
                                    color: AppColors.hot,
                                    onTap: () {
                                      if (_isSubmitting) return;
                                      _end();
                                    },
                                  ),
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
          fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
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
          borderRadius: BorderRadius.circular(18),
          border: borderColor != null ? Border.all(color: borderColor!, width: 1.2) : null,
          boxShadow: color == Colors.white
              ? const []
              : const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
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

class _AppleStyleTimer extends StatelessWidget {
  const _AppleStyleTimer({required this.value, required this.isIPad});

  final String value;
  final bool isIPad;

  @override
  Widget build(BuildContext context) {
    final chars = value.split('');
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final ch in chars)
            ch == ':'
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: isIPad ? 12 : 8),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: isIPad ? 72 : 58,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2A2D33),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  )
                : _AppleDigitCard(digit: ch, isIPad: isIPad),
        ],
      ),
    );
  }
}

class _AppleDigitCard extends StatelessWidget {
  const _AppleDigitCard({required this.digit, required this.isIPad});

  final String digit;
  final bool isIPad;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isIPad ? 92 : 70,
      height: isIPad ? 132 : 102,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EAF1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFFFFF), Color(0xFFF6F8FC)],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(isIPad ? 20 : 18),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF0F3F8), Color(0xFFE8ECF3)],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(isIPad ? 20 : 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: isIPad ? 65 : 50,
            child: Container(height: 1, color: const Color(0xFFDDE1EA)),
          ),
          Positioned(
            left: 14,
            right: 14,
            top: 8,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.06),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                digit,
                key: ValueKey(digit),
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: isIPad ? 70 : 54,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF171A20),
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
