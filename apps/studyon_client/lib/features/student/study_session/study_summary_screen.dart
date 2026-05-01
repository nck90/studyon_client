import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';

class StudySummaryScreen extends ConsumerStatefulWidget {
  const StudySummaryScreen({super.key});

  @override
  ConsumerState<StudySummaryScreen> createState() => _StudySummaryScreenState();
}

class _StudySummaryScreenState extends ConsumerState<StudySummaryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmtMin(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '$h시간 $m분';
    if (h > 0) return '$h시간';
    return '$m분';
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final todayMin = student.todayStudySeconds ~/ 60;
    final goalSec = student.goalHours * 3600;
    final achieved = goalSec > 0 && student.todayStudySeconds >= goalSec;
    final achieveRate = goalSec > 0
        ? ((student.todayStudySeconds / goalSec) * 100).round().clamp(0, 999)
        : 0;
    final records = student.recentRecords.take(7).toList();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Content ───
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  const SizedBox(height: 32),

                  // Hero
                  Center(
                    child: ScaleTransition(
                      scale: CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: achieved
                                ? const [Color(0xFF00B894), Color(0xFF00CEC9)]
                                : [AppColors.primary, const Color(0xFFA29BFE)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: TossFace(achieved ? '🎉' : '✅', size: 36),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      achieved ? '목표를 달성했어요!' : '공부를 마쳤어요',
                      style: AppTypography.headlineLarge.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      achieved ? '오늘 목표를 모두 채웠어요. 대단해요!' : '오늘 기록을 정리했어요.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Stats grid
                  _AnimatedCard(
                    ctrl: _ctrl,
                    start: 0.2,
                    child: Row(
                      children: [
                        Expanded(child: _StatTile(
                          emoji: '⏱️',
                          label: '공부 시간',
                          value: student.todayStudyFormatted,
                          color: AppColors.primary,
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: _StatTile(
                          emoji: '🎯',
                          label: '달성률',
                          value: '$achieveRate%',
                          color: AppColors.accent,
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AnimatedCard(
                    ctrl: _ctrl,
                    start: 0.3,
                    child: Row(
                      children: [
                        Expanded(child: _StatTile(
                          emoji: '🔥',
                          label: '연속 학습',
                          value: '${student.streakDays}일',
                          color: AppColors.hot,
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: _StatTile(
                          emoji: '🏆',
                          label: '오늘 순위',
                          value: student.todayRank > 0 ? '#${student.todayRank}' : '-',
                          color: const Color(0xFFFFB800),
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Weekly chart
                  if (records.isNotEmpty) ...[
                    _AnimatedCard(
                      ctrl: _ctrl,
                      start: 0.4,
                      child: _WeekChart(records: records),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Comparison
                  _AnimatedCard(
                    ctrl: _ctrl,
                    start: 0.5,
                    child: _ComparisonCard(
                      todayMinutes: todayMin,
                      records: records,
                      fmtMin: _fmtMin,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Next goal
                  _AnimatedCard(
                    ctrl: _ctrl,
                    start: 0.6,
                    child: _NextGoalCard(student: student, fmtMin: _fmtMin),
                  ),

                  const SizedBox(height: 100), // space for buttons
                ],
              ),
            ),

            // ─── Bottom buttons ───
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.bg(context),
                border: const Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PressableScale(
                    onTap: () => context.go('/student/home'),
                    child: Container(
                      width: double.infinity,
                      height: AppSpacing.buttonHeight,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text('홈으로', style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  PressableScale(
                    onTap: () async {
                      await ref.read(studentProvider.notifier).checkOut();
                      if (!mounted) return;
                      context.go('/login');
                    },
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      alignment: Alignment.center,
                      child: Text(
                        '퇴실하기',
                        style: AppTypography.titleMedium.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated wrapper ───
class _AnimatedCard extends StatelessWidget {
  const _AnimatedCard({required this.ctrl, required this.start, required this.child});
  final AnimationController ctrl;
  final double start;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: ctrl,
      curve: Interval(start, (start + 0.25).clamp(0.0, 1.0), curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(anim),
        child: child,
      ),
    );
  }
}

// ─── Stat tile (emoji based) ───
class _StatTile extends StatelessWidget {
  const _StatTile({required this.emoji, required this.label, required this.value, required this.color});
  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TossFace(emoji, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

// ─── Weekly chart ───
class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.records});
  final List<StudyRecord> records;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final labels = const ['월', '화', '수', '목', '금', '토', '일'];
    final start = now.subtract(Duration(days: now.weekday - 1));
    final minutes = <int, int>{};

    for (final r in records) {
      final match = RegExp(r'(\d+)월 (\d+)일').firstMatch(r.date);
      if (match == null) continue;
      final m = int.tryParse(match.group(1)!);
      final d = int.tryParse(match.group(2)!);
      if (m == null || d == null) continue;
      final date = DateTime(now.year, m, d);
      final diff = date.difference(DateTime(start.year, start.month, start.day)).inDays;
      if (diff < 0 || diff > 6) continue;
      minutes.update(diff, (v) => v + r.studyMinutes, ifAbsent: () => r.studyMinutes);
    }

    final data = List.generate(7, (i) => (labels[i], (minutes[i] ?? 0).toDouble()));
    final max = data.fold<double>(1, (best, e) => e.$2 > best ? e.$2 : best);
    final total = data.fold<double>(0, (sum, e) => sum + e.$2) / 60;
    final todayIdx = now.weekday - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('이번 주', style: AppTypography.headlineSmall),
              Text('${total.toStringAsFixed(1)}시간', style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final h = max > 0 ? (data[i].$2 / max) * 80 : 0.0;
                final isToday = i == todayIdx;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: h > 0 ? h : 4,
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.primary : AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data[i].$1,
                          style: AppTypography.caption.copyWith(
                            color: isToday ? AppColors.primary : AppColors.textTertiary,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Comparison card ───
class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.todayMinutes, required this.records, required this.fmtMin});
  final int todayMinutes;
  final List<StudyRecord> records;
  final String Function(int) fmtMin;

  @override
  Widget build(BuildContext context) {
    final hasPrev = records.length > 1;
    final prevMin = hasPrev ? records[1].studyMinutes : 0;
    final delta = todayMinutes - prevMin;
    final avg = records.isEmpty ? 0 : records.fold<int>(0, (s, r) => s + r.studyMinutes) ~/ records.length;
    final avgDelta = todayMinutes - avg;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows_rounded, size: 16, color: AppColors.accent),
              const SizedBox(width: 8),
              Text('기록 비교', style: AppTypography.headlineSmall),
            ],
          ),
          const SizedBox(height: 16),
          _CompRow(
            icon: Icons.history_rounded,
            text: hasPrev ? '어제 대비' : '비교할 어제 기록이 없어요',
            value: hasPrev ? '${delta >= 0 ? '+' : ''}${fmtMin(delta.abs())}' : '-',
            color: hasPrev ? (delta >= 0 ? AppColors.accent : AppColors.hot) : AppColors.textTertiary,
          ),
          const SizedBox(height: 10),
          _CompRow(
            icon: Icons.bar_chart_rounded,
            text: records.isNotEmpty ? '최근 평균 대비' : '기록 수집 중',
            value: records.isNotEmpty ? '${avgDelta >= 0 ? '+' : ''}${fmtMin(avgDelta.abs())}' : '-',
            color: records.isNotEmpty ? (avgDelta >= 0 ? AppColors.primary : AppColors.hot) : AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _CompRow extends StatelessWidget {
  const _CompRow({required this.icon, required this.text, required this.value, required this.color});
  final IconData icon;
  final String text;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: AppTypography.titleMedium.copyWith(color: color, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

// ─── Next goal card ───
class _NextGoalCard extends StatelessWidget {
  const _NextGoalCard({required this.student, required this.fmtMin});
  final StudentState student;
  final String Function(int) fmtMin;

  @override
  Widget build(BuildContext context) {
    final goalSec = student.goalHours * 3600;
    final remaining = goalSec > student.todayStudySeconds
        ? ((goalSec - student.todayStudySeconds) / 60).ceil()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('다음 목표', style: AppTypography.headlineSmall),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bg(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remaining > 0
                      ? '내일은 ${fmtMin(remaining)} 더 채워보세요'
                      : '내일도 같은 흐름을 이어가세요',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                if (student.goalDetail.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '목표: ${student.goalDetail}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
