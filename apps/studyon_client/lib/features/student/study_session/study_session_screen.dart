import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';
import 'package:studyon_models/studyon_models.dart';
import 'study_log_sheet.dart';

const List<String> _lifeQuotes = [
  '오늘의 노력이 내일의 나를 만듭니다.',
  '작은 한 걸음이 큰 변화를 만듭니다.',
  '집중은 재능보다 강합니다.',
  '꾸준함이 천재를 이깁니다.',
  '지금 흘리는 땀은 미래의 자신이 고마워할 것입니다.',
  '성공은 매일의 작은 노력이 쌓인 결과입니다.',
  '오늘 못한 한 문제가 내일의 정답이 됩니다.',
  '시간을 지배하는 자가 결과를 지배합니다.',
  '쉬운 길은 익숙해지지만, 어려운 길은 강해집니다.',
  '책상 앞 30분이 인생을 바꿉니다.',
  '실력은 거짓말하지 않습니다.',
  '오늘 한 페이지가 내일의 자신감입니다.',
  '집중하는 그 순간이 가장 빠른 길입니다.',
  '포기하지 않으면 결국 도착합니다.',
  '어제보다 1분 더 집중하는 사람이 결국 이깁니다.',
];

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
  String _selectedSubject = '수학';
  String? _selectedPlanId;
  String? _sessionId;
  bool _isSubmitting = false;
  String _quote = '';

  DateTime? _startedAt;
  DateTime? _pausedAt;
  int _accumulatedBeforePause = 0;
  int _breakAccumulated = 0;
  static const int _goalSeconds = 3 * 3600;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _quote = _lifeQuotes[Random().nextInt(_lifeQuotes.length)];
    _tryRestoreSession();
  }

  void _refreshQuote() {
    setState(() {
      _quote = _lifeQuotes[Random().nextInt(_lifeQuotes.length)];
    });
  }

  Future<void> _tryRestoreSession() async {
    try {
      final session = await ref.read(studentRepositoryProvider).getActiveSession();
      if (session == null || !mounted) return;
      final plans = ref.read(studentProvider).plans;
      String restoredSubject = _selectedSubject;
      if (session.linkedPlanId != null) {
        final plan = plans.firstWhere(
          (p) => p.id == session.linkedPlanId,
          orElse: () => StudyPlanItem(
            id: '',
            subject: _selectedSubject,
            detail: '',
          ),
        );
        if (plan.subject.isNotEmpty) {
          restoredSubject = plan.subject;
          _selectedPlanId = plan.id.isEmpty ? null : plan.id;
        }
      }
      setState(() {
        _isStarted = true;
        _selectedSubject = restoredSubject;
      });
      _syncFromSession(session);
      if (session.status == 'ACTIVE') {
        _startedAt = DateTime.now();
        _startTimer();
      } else if (session.status == 'PAUSED') {
        setState(() {
          _isPaused = true;
          _pausedAt = DateTime.now();
        });
        _startBreakTimer();
      }
      ref.read(studentProvider.notifier).startStudying();
    } catch (_) {
      // No active session — normal state
    }
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

  Future<void> _pickPlanAndStart() async {
    final plans = ref.read(studentProvider).plans;
    final selection = await showModalBottomSheet<_PlanPick>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanPickerSheet(
        plans: plans,
        currentSubject: _selectedSubject,
      ),
    );
    if (selection == null || !mounted) return;
    setState(() {
      _selectedSubject = selection.subject;
      _selectedPlanId = selection.planId;
    });
    _start();
  }

  Future<void> _changeSubject() async {
    final plans = ref.read(studentProvider).plans;
    final selection = await showModalBottomSheet<_PlanPick>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanPickerSheet(
        plans: plans,
        currentSubject: _selectedSubject,
        currentPlanId: _selectedPlanId,
      ),
    );
    if (selection == null || !mounted) return;
    setState(() {
      _selectedSubject = selection.subject;
      _selectedPlanId = selection.planId;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('과목을 ${selection.subject}(으)로 바꿨어요',
              style: const TextStyle(
                  fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _start() {
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
      _elapsed = session.studySeconds > 0
          ? session.studySeconds
          : session.studyMinutes * 60;
      _breakElapsed = session.breakSeconds > 0
          ? session.breakSeconds
          : session.breakMinutes * 60;
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

  void _startBreakTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_pausedAt == null) return;
      setState(() {
        _breakElapsed =
            _breakAccumulated + DateTime.now().difference(_pausedAt!).inSeconds;
      });
    });
  }

  void _showExitDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('공부를 멈출까요?',
            style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text(ctx))),
        content: Text('지금 나가면 이번 기록은 저장되지 않아요.',
            style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                color: AppColors.textSub(ctx))),
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
      _startBreakTimer();
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
        backgroundColor: AppColors.card(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('공부를 종료할까요?',
            style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text(ctx))),
        content: Text(
          '${_fmt(_elapsed)} 동안 공부했어요.',
          style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: AppColors.textSub(ctx)),
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
      initialSubject: _selectedSubject,
    );
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      _timer?.cancel();
      StudySession? session;
      if (_sessionId != null) {
        try {
          session = await ref.read(studentRepositoryProvider).endSession(_sessionId!);
          _syncFromSession(session);
        } catch (_) {
          // session may already be ended; continue with log creation
        }
      }

      final subjectName = (draft?.subject.trim().isNotEmpty ?? false)
          ? draft!.subject
          : (_selectedSubject.trim().isNotEmpty
              ? _selectedSubject
              : ref.read(studentProvider).goalSubject);

      await ref.read(studentRepositoryProvider).createStudyLog(
            subjectName: subjectName.isEmpty ? '공부' : subjectName,
            planId: _selectedPlanId,
            studySessionId: session?.id ?? _sessionId,
            studyMinutes: session?.studyMinutes ?? (_elapsed ~/ 60),
            studySeconds: session?.studySeconds ?? _elapsed,
            pagesCompleted: draft?.pageCount ?? 0,
            problemsSolved: draft?.problemCount ?? 0,
            memo: draft?.memo,
            progressPercent: (_elapsed / _goalSeconds).clamp(0.0, 1.0),
            isCompleted: draft?.goalCompleted ?? (_elapsed >= _goalSeconds),
          );

      // Multi-pass hydrate so today/recent records refresh reliably
      await ref.read(studentProvider.notifier).hydrate();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await ref.read(studentProvider.notifier).hydrate();

      ref.read(studentProvider.notifier).stopStudying();
      _sessionId = null;
      if (mounted) context.go('/student/summary');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('공부 종료 저장에 실패했어요. 다시 시도해 주세요'),
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
    ref.watch(studentProvider);
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final progress = (_elapsed / _goalSeconds).clamp(0.0, 1.0);
    final isDark = AppColors.isDark(context);

    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF12122A)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F8FB), Color(0xFFF2F3F5)],
          );

    final cardGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F2238), Color(0xFF14172B)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF6F7FA)],
          );

    final cardBorder =
        isDark ? const Color(0xFF2A2D44) : const Color(0xFFE8EBF2);
    final pillBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.78);
    final pillBorder =
        isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xE8E9EDF4);
    final mutedText = isDark ? AppColors.darkTextSub : AppColors.textSecondary;
    final headlineText = isDark ? AppColors.darkText : AppColors.textPrimary;

    return PopScope(
      canPop: !_isStarted,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _showExitDialog();
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: bgGradient),
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
                            color: pillBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: pillBorder),
                          ),
                          child: Icon(Icons.close_rounded,
                              size: 20,
                              color: isDark
                                  ? AppColors.darkText
                                  : const Color(0xFF555B65)),
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
                              color: pillBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: !_isStarted
                                    ? pillBorder
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
                                    color: !_isStarted
                                        ? AppColors.textTertiary
                                        : (_isPaused ? AppColors.hot : AppColors.accent),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Semantics(
                        label: '과목 변경',
                        button: true,
                        child: GestureDetector(
                          onTap: _changeSubject,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: pillBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: pillBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedSubject,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: mutedText,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.expand_more_rounded,
                                    size: 16, color: mutedText),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Random life quote (refresh on tap)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      isIPad ? 32.0 : 20.0, 14, isIPad ? 32.0 : 20.0, 0),
                  child: GestureDetector(
                    onTap: _refreshQuote,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: pillBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.format_quote_rounded,
                              size: 18,
                              color: isDark
                                  ? AppColors.primaryLight
                                  : AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _quote,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: mutedText,
                                height: 1.4,
                              ),
                            ),
                          ),
                          Icon(Icons.refresh_rounded,
                              size: 16, color: AppColors.textTertiary),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: isIPad ? 820 : double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: isIPad ? 32 : 20),
                      padding: EdgeInsets.fromLTRB(isIPad ? 48 : 24, 30, isIPad ? 48 : 24, 28),
                      decoration: BoxDecoration(
                        gradient: cardGradient,
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(color: cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0x33000000)
                                : const Color(0x0B1A1D29),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            !_isStarted ? '공부를 시작해요' : (_isPaused ? '잠깐 쉬고 있어요' : '집중 흐름을 유지하고 있어요'),
                            style: AppTypography.headlineSmall.copyWith(
                              color: headlineText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            !_isStarted
                                ? '시작하면 과목을 골라드릴게요'
                                : '시선이 바로 꽂히는 타이머로 정리했어요.',
                            style: AppTypography.bodySmall
                                .copyWith(color: mutedText),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          _AppleStyleTimer(
                              value: _fmt(_elapsed), isIPad: isIPad, isDark: isDark),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: cardBorder),
                            ),
                            child: Text(
                              '${(progress * 100).toInt()}% 진행 중 · 목표 3시간',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary,
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
                            style: AppTypography.bodySmall
                                .copyWith(color: mutedText),
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: isDark
                                  ? const Color(0xFF252849)
                                  : const Color(0xFFE9ECF4),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
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
                              child: _MiniStat(
                                  label: '공부',
                                  value: _fmt(_elapsed).substring(0, 5),
                                  color: AppColors.primary,
                                  textColor: mutedText),
                            ),
                            Container(
                                width: 1,
                                height: 32,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : AppColors.divider),
                            Expanded(
                              child: _MiniStat(
                                  label: '휴식',
                                  value: _fmt(_breakElapsed).substring(0, 5),
                                  color: AppColors.warm,
                                  textColor: mutedText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: isDark
                                ? const Color(0xFF252849)
                                : AppColors.primarySurface,
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
                              onTap: _pickPlanAndStart,
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
                                    color: isDark
                                        ? const Color(0xFF252849)
                                        : Colors.white,
                                    borderColor: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : AppColors.divider,
                                    textColor: isDark
                                        ? AppColors.darkText
                                        : AppColors.textSecondary,
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
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });
  final String label;
  final String value;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w500, color: textColor,
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
  const _AppleStyleTimer(
      {required this.value, required this.isIPad, required this.isDark});

  final String value;
  final bool isIPad;
  final bool isDark;

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
                        color: isDark
                            ? AppColors.darkText
                            : const Color(0xFF2A2D33),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  )
                : _AppleDigitCard(digit: ch, isIPad: isIPad, isDark: isDark),
        ],
      ),
    );
  }
}

class _AppleDigitCard extends StatelessWidget {
  const _AppleDigitCard(
      {required this.digit, required this.isIPad, required this.isDark});

  final String digit;
  final bool isIPad;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isIPad ? 92 : 70,
      height: isIPad ? 132 : 102,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2238) : const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2D44) : const Color(0xFFE7EAF1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0x33000000)
                : const Color(0x0A0F172A),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? const [Color(0xFF24284A), Color(0xFF1A1D38)]
                            : const [Color(0xFFFFFFFF), Color(0xFFF6F8FC)],
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
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? const [Color(0xFF1A1D38), Color(0xFF12152C)]
                            : const [Color(0xFFF0F3F8), Color(0xFFE8ECF3)],
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
            child: Container(
                height: 1,
                color: isDark
                    ? const Color(0xFF2A2D44)
                    : const Color(0xFFDDE1EA)),
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
                    Colors.white.withValues(alpha: isDark ? 0.06 : 0.85),
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
                  color: isDark
                      ? AppColors.darkText
                      : const Color(0xFF171A20),
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

class _PlanPick {
  const _PlanPick({required this.subject, this.planId});
  final String subject;
  final String? planId;
}

class _PlanPickerSheet extends StatefulWidget {
  const _PlanPickerSheet({
    required this.plans,
    required this.currentSubject,
    this.currentPlanId,
  });

  final List<StudyPlanItem> plans;
  final String currentSubject;
  final String? currentPlanId;

  @override
  State<_PlanPickerSheet> createState() => _PlanPickerSheetState();
}

class _PlanPickerSheetState extends State<_PlanPickerSheet> {
  late String _subject;
  String? _planId;
  bool _customMode = false;
  final TextEditingController _customCtrl = TextEditingController();

  static const _fallbackSubjects = ['수학', '영어', '국어', '과학', '사회', '기타'];

  @override
  void initState() {
    super.initState();
    _subject = widget.currentSubject;
    _planId = widget.currentPlanId;
    if (_subject.isEmpty) _subject = _fallbackSubjects.first;
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final plans = widget.plans
        .where((p) => p.progress < 1.0)
        .toList(); // hide already-completed plans
    final subjectsFromPlans = {for (final p in plans) p.subject};
    final subjects = <String>{
      ..._fallbackSubjects,
      ...subjectsFromPlans,
      if (_subject.isNotEmpty) _subject,
    }.toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(28),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('어떤 과목으로 시작할까요?',
                style: AppTypography.headlineSmall
                    .copyWith(color: AppColors.text(context))),
            const SizedBox(height: 6),
            Text('계획에 등록된 항목을 고르거나 과목을 선택해 주세요',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 18),
            if (plans.isNotEmpty) ...[
              Text('오늘의 계획',
                  style: AppTypography.labelLarge
                      .copyWith(color: AppColors.textSub(context))),
              const SizedBox(height: 8),
              ...plans.map((p) {
                final selected = _planId == p.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _planId = p.id;
                      _subject = p.subject;
                      _customMode = false;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.tintPurple
                            : AppColors.bg(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.subjectTint(p.subject),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              p.subject,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.subjectColor(p.subject),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              p.detail,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.text(context),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            p.targetLabel,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSub(context),
                            ),
                          ),
                          if (selected) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle_rounded,
                                size: 18, color: AppColors.primary),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
            Text('계획 없이 과목만 선택',
                style: AppTypography.labelLarge
                    .copyWith(color: AppColors.textSub(context))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: subjects.map((s) {
                final selected = _planId == null && _subject == s && !_customMode;
                return GestureDetector(
                  onTap: () => setState(() {
                    _subject = s;
                    _planId = null;
                    _customMode = false;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.subjectTint(s)
                          : AppColors.bg(context),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? AppColors.subjectColor(s)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      s,
                      style: AppTypography.labelLarge.copyWith(
                        color: selected
                            ? AppColors.subjectColor(s)
                            : AppColors.textSub(context),
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            StudyonButton(
              label: '이 과목으로 시작',
              onPressed: () {
                Navigator.of(context).pop(
                  _PlanPick(subject: _subject, planId: _planId),
                );
              },
              variant: StudyonButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}
