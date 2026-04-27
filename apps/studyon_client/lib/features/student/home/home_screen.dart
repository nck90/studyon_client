import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final student = ref.watch(studentProvider);
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final pad = isIPad ? 28.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: RefreshIndicator(
        onRefresh: () => ref.read(studentProvider.notifier).hydrate(),
        color: AppColors.primary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Purple Hero Banner ──
            _HeroBanner(isIPad: isIPad, pad: pad, student: student),

            // ── Not checked in warning ──
            if (!student.isCheckedIn)
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.hot.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.hot),
                      const SizedBox(width: 8),
                      Text('아직 입실 전이에요',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.hot, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

            // ── Info cards: 3 columns iPad / stacked phone ──
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
              child: isIPad
                  ? SizedBox(
                      height: 160,
                      child: Row(
                        children: [
                          Expanded(flex: 4, child: _GoalCard(student: student)),
                          const SizedBox(width: 12),
                          Expanded(flex: 4, child: _WeeklyChart(student: student)),
                          const SizedBox(width: 12),
                          Expanded(flex: 3, child: _RoomStatusCard()),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        _GoalCard(student: student),
                        const SizedBox(height: 12),
                        _WeeklyChart(student: student),
                        const SizedBox(height: 12),
                        _RoomStatusCard(),
                      ],
                    ),
            ),

            // ── Plans + Recent ──
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
              child: _RecommendationCard(student: student),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
              child: isIPad
                  ? SizedBox(
                      height: 160,
                      child: Row(
                        children: [
                          Expanded(child: _TodayPlans(student: student, onTap: () => context.push('/student/plan'))),
                          const SizedBox(width: 12),
                          Expanded(child: _RecentActivity(student: student)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        _TodayPlans(student: student, onTap: () => context.push('/student/plan')),
                        const SizedBox(height: 12),
                        _RecentActivity(student: student),
                      ],
                    ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends ConsumerStatefulWidget {
  const _RecommendationCard({required this.student});

  final StudentState student;

  @override
  ConsumerState<_RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends ConsumerState<_RecommendationCard> {
  bool _isApplying = false;

  String _riskLabel(String riskLevel) {
    switch (riskLevel) {
      case 'HIGH':
        return '집중 점검';
      case 'MEDIUM':
        return '리듬 보정';
      default:
        return '안정적';
    }
  }

  Color _riskColor(String riskLevel) {
    switch (riskLevel) {
      case 'HIGH':
        return AppColors.hot;
      case 'MEDIUM':
        return AppColors.warm;
      default:
        return AppColors.accent;
    }
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remain = minutes % 60;
    if (hours == 0) return '$remain분';
    if (remain == 0) return '$hours시간';
    return '$hours시간 $remain분';
  }

  Future<void> _applyRecommendation() async {
    setState(() => _isApplying = true);
    try {
      await ref.read(studentProvider.notifier).applyRecommendation();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('추천 계획을 오늘 일정에 추가했어요'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('추천 계획을 불러오지 못했어요'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.hot,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendation = widget.student.recommendation;
    final riskColor = _riskColor(recommendation.riskLevel);
    // Filter to math only for math academy
    final mathFocusSubjects = recommendation.focusSubjects.where((s) => s == '수학').toList();
    final mathPlanTemplate = recommendation.planTemplate.where((item) => item.subject == '수학').toList();
    final existingKeys = widget.student.plans
        .map((plan) => '${plan.subject}|${plan.detail}')
        .toSet();
    final missingTemplates = mathPlanTemplate.where((item) {
      return !existingKeys.contains('${item.subject}|${item.detail}');
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('오늘의 추천', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _riskLabel(recommendation.riskLevel),
                  style: AppTypography.labelSmall.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '권장 공부 시간 ${_formatMinutes(recommendation.recommendedTargetMinutes)}',
            style: AppTypography.headlineSmall.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            '집중 과목 수학',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          if (mathFocusSubjects.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mathFocusSubjects.map((subject) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    subject,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.subjectColor(subject),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (mathPlanTemplate.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...mathPlanTemplate.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: AppColors.subjectColor(item.subject),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.detail,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.subject} · ${_formatMinutes(item.targetMinutes)}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StudyonButton(
                  label: missingTemplates.isEmpty ? '추천 반영 완료' : '추천 계획 가져오기',
                  onPressed: missingTemplates.isEmpty || _isApplying
                      ? null
                      : _applyRecommendation,
                  variant: StudyonButtonVariant.primary,
                  icon: Icons.file_download_done_rounded,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.push('/student/plan'),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '직접 편집',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Hero Banner
// ─────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.isIPad, required this.pad, required this.student});
  final bool isIPad;
  final double pad;
  final StudentState student;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '좋은 아침이에요';
    if (hour < 18) return '좋은 오후에요';
    return '오늘도 수고했어요';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 28),
          child: isIPad
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(flex: 5, child: _buildContent(context)),
                    const SizedBox(width: 32),
                    _DailyProgressRing(progress: student.goalProgress, size: 120),
                  ],
                )
              : _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final seatLabel = student.seatNo.isEmpty ? '좌석 미배정' : student.seatNo;
    final displayName = student.name.isEmpty ? '학생' : '${student.name}님';
    final rankLabel = student.todayRank > 0 ? '#${student.todayRank} 순위' : '순위 집계 중';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top: seat + bell
        Row(
          children: [
            Text(seatLabel, style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.6))),
            const Spacer(),
            Semantics(
              label: '알림',
              button: true,
              child: GestureDetector(
                onTap: () => context.push('/student/notifications'),
                child: Icon(Icons.notifications_none_rounded, size: 20, color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Greeting + Name
        Text(_greeting(), style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, color: Colors.white.withValues(alpha: 0.6))),
        const SizedBox(height: 2),
        Text(displayName, style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85))),
        const SizedBox(height: 8),

        // Big time
        _AnimatedStudyTime(isIPad: isIPad, totalSeconds: student.todayStudySeconds),
        const SizedBox(height: 4),
        Text('오늘 공부', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 0.3)),
        const SizedBox(height: 16),

        // Chips: streak + rank
        Row(
          children: [
            const TossFace('🔥', size: 15),
            const SizedBox(width: 4),
            Text('${student.streakDays}일 연속', style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85))),
            const SizedBox(width: 20),
            Text(rankLabel, style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85), fontFeatures: const [FontFeature.tabularFigures()])),
          ],
        ),
        const SizedBox(height: 16),

        // CTA
        if (student.isCheckedIn)
          Builder(
            builder: (context) {
              final shouldResumeLabel =
                  student.isStudying || student.todayStudySeconds > 0;
              return Semantics(
                label: shouldResumeLabel ? '이어서 공부' : '공부 시작',
                button: true,
                child: GestureDetector(
                  onTap: () => context.push('/student/study-session'),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(shouldResumeLabel ? '이어서 공부' : '공부 시작',
                          style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _DailyProgressRing extends StatelessWidget {
  const _DailyProgressRing({required this.progress, required this.size});
  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size, height: size,
            child: CircularProgressIndicator(
              value: progress, strokeWidth: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontFamily: 'Pretendard', fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])),
              Text('달성', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedStudyTime extends StatelessWidget {
  const _AnimatedStudyTime({required this.isIPad, required this.totalSeconds});
  final bool isIPad;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final targetMinutes = totalSeconds ~/ 60;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: targetMinutes.toDouble()),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        final mins = value.round();
        final h = mins ~/ 60;
        final m = mins % 60;
        final text = h > 0 ? '$h시간 $m분' : (m > 0 ? '$m분' : '0분');
        return Text(text, style: TextStyle(
          fontFamily: 'Pretendard', fontSize: isIPad ? 44 : 36, fontWeight: FontWeight.w800,
          color: Colors.white, letterSpacing: -1, height: 1.0, fontFeatures: const [FontFeature.tabularFigures()],
        ));
      },
    );
  }
}

// ─────────────────────────────────────────────────
// Goal Card
// ─────────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.student});
  final StudentState student;

  @override
  Widget build(BuildContext context) {
    final subject = student.goalSubject.isNotEmpty ? student.goalSubject : '계획 미설정';
    final detail = student.goalDetail.isNotEmpty ? student.goalDetail : '목표를 설정해주세요';
    final progress = student.goalProgress;

    return Semantics(
      label: '오늘 목표 ${(progress * 100).toInt()}퍼센트',
      child: PressableScale(
        onTap: () => context.push('/student/plan'),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('오늘 목표', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.3)),
                  const Spacer(),
                  Text('${(progress * 100).toInt()}%', style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary, fontFeatures: const [FontFeature.tabularFigures()])),
                ],
              ),
              const SizedBox(height: 12),
              Text(subject, style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.subjectColor(subject))),
              const SizedBox(height: 4),
              Text(detail, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 14),
              StudyonProgressBar(value: progress, height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Weekly Chart
// ─────────────────────────────────────────────────
class _WeeklyChart extends StatefulWidget {
  const _WeeklyChart({required this.student});
  final StudentState student;

  @override
  State<_WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<_WeeklyChart> {
  String? _selectedDay;

  List<(String, double)> _weeklyHours() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final labels = const ['월', '화', '수', '목', '금', '토', '일'];
    final dailyMinutes = <int, int>{};

    for (final record in widget.student.recentRecords) {
      final match = RegExp(r'(\d+)월 (\d+)일').firstMatch(record.date);
      if (match == null) continue;
      final month = int.tryParse(match.group(1)!);
      final day = int.tryParse(match.group(2)!);
      if (month == null || day == null) continue;
      final date = DateTime(now.year, month, day);
      final diff = date.difference(DateTime(start.year, start.month, start.day)).inDays;
      if (diff < 0 || diff > 6) continue;
      dailyMinutes.update(diff, (value) => value + record.studyMinutes, ifAbsent: () => record.studyMinutes);
    }

    return List.generate(7, (index) {
      final hours = (dailyMinutes[index] ?? 0) / 60;
      return (labels[index], hours);
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _weeklyHours();
    final maxH = days.fold<double>(1.0, (maxValue, item) => item.$2 > maxValue ? item.$2 : maxValue);
    final totalHours = days.fold<double>(0, (sum, item) => sum + item.$2);
    final todayLabel = const ['월', '화', '수', '목', '금', '토', '일'][DateTime.now().weekday - 1];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('이번 주', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.3)),
              const Spacer(),
              Text('${totalHours.toStringAsFixed(1)}h', style: const TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, fontFeatures: [FontFeature.tabularFigures()])),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((d) {
                final (label, hours) = d;
                final isToday = label == todayLabel;
                final isSel = _selectedDay == label;
                final dimmed = _selectedDay != null && !isSel;
                final ratio = hours / maxH;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = isSel ? null : label),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isSel) Text('${hours}h', style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          if (isSel) const SizedBox(height: 2),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity: dimmed ? 0.3 : 1.0,
                                child: FractionallySizedBox(
                                  heightFactor: ratio.clamp(0.08, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: (isToday || isSel) ? AppColors.primary : const Color(0xFFE5E7EB),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(label, style: TextStyle(fontFamily: 'Pretendard', fontSize: 11,
                            fontWeight: (isToday || isSel) ? FontWeight.w700 : FontWeight.w400,
                            color: (isToday || isSel) ? AppColors.primary : AppColors.textTertiary)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Room Status
// ─────────────────────────────────────────────────
class _RoomStatusCard extends ConsumerWidget {
  const _RoomStatusCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(16)),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: ref.read(studentRepositoryProvider).getSeatMap(),
        builder: (context, snapshot) {
          final seats = snapshot.data ?? const <Map<String, dynamic>>[];
          final studying = seats.where((seat) => seat['uiStatus'] == 'studying').length;
          final onBreak = seats.where((seat) => seat['uiStatus'] == 'onBreak').length;
          final empty = seats.where((seat) => seat['uiStatus'] == 'empty').length;
          final total = seats.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('학원', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.3)),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$studying', style: const TextStyle(fontFamily: 'Pretendard', fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFeatures: [FontFeature.tabularFigures()])),
                    Text('/$total', style: const TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textTertiary, fontFeatures: [FontFeature.tabularFigures()])),
                  ],
                ),
                const SizedBox(height: 8),
                Text('공부 $studying · 휴식 $onBreak · 빈자리 $empty', style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: AppColors.textTertiary)),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Today Plans
// ─────────────────────────────────────────────────
class _TodayPlans extends StatelessWidget {
  const _TodayPlans({required this.student, required this.onTap});
  final StudentState student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('오늘 할 일', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.3)),
              const Spacer(),
              GestureDetector(onTap: onTap, child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 14),
          if (student.plans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('등록된 계획이 없어요', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
            )
          else
            ...student.plans.take(3).map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: plan.progress >= 1.0 ? AppColors.accent : AppColors.cardBorder, width: 1.5),
                      color: plan.progress >= 1.0 ? AppColors.accent : Colors.transparent,
                    ),
                    child: plan.progress >= 1.0 ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 10),
                  Text(plan.subject, style: TextStyle(fontFamily: 'Pretendard', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.subjectColor(plan.subject))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(plan.detail, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
                  Text(plan.targetLabel, style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: AppColors.textTertiary, fontFeatures: [FontFeature.tabularFigures()])),
                ],
              ),
            )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Recent Activity
// ─────────────────────────────────────────────────
class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.student});
  final StudentState student;

  String _formatRecordDate(String raw) {
    final match = RegExp(r'(\d+)월 (\d+)일').firstMatch(raw);
    if (match == null) return raw;
    return '${match.group(1)}/${match.group(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card(context), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('최근 활동', style: TextStyle(fontFamily: 'Pretendard', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.3)),
          const SizedBox(height: 14),
          if (student.recentRecords.isEmpty)
            Text('기록이 없어요', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary))
          else
            ...student.recentRecords.take(3).map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(width: 44, child: Text(_formatRecordDate(r.date), style: const TextStyle(fontFamily: 'Pretendard', fontSize: 12, color: AppColors.textTertiary))),
                  Text(r.subject, style: TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.subjectColor(r.subject))),
                  const Spacer(),
                  Text('${r.studyMinutes ~/ 60}h ${r.studyMinutes % 60}m', style: const TextStyle(fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFeatures: [FontFeature.tabularFigures()])),
                ],
              ),
            )),
        ],
      ),
    );
  }
}
