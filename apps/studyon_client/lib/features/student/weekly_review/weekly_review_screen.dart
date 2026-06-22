import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../../shared/providers/student_providers.dart';

class WeeklyReviewScreen extends ConsumerWidget {
  const WeeklyReviewScreen({super.key});

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m분';
    if (m == 0) return '$h시간';
    return '$h시간 $m분';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider);
    final weeklySeconds = student.weeklyStudySeconds > 0
        ? student.weeklyStudySeconds
        : student.weeklyStudyMinutes * 60;
    final targetMinutes = student.weeklyTargetMinutes > 0
        ? student.weeklyTargetMinutes
        : student.todayTargetMinutes * 7;
    final targetSeconds = targetMinutes * 60;
    final achievedRate = targetSeconds == 0
        ? student.weeklyAchievedRate
        : (weeklySeconds / targetSeconds * 100).clamp(0, 999).toDouble();
    final topSubjects = student.dailySubjectSeconds.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final recommendation = student.recommendation;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 4),
                Text('주간 회고', style: AppTypography.headlineLarge),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.targetUniversityName.isEmpty
                        ? '이번 주 학습 리듬'
                        : '${student.targetUniversityName}까지 가는 이번 주',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _ReviewMetric(
                          label: '공부시간',
                          value: _formatDuration(weeklySeconds),
                          icon: Icons.timer_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ReviewMetric(
                          label: '달성률',
                          value: '${achievedRate.round()}%',
                          icon: Icons.flag_rounded,
                          color: achievedRate >= 100
                              ? AppColors.accent
                              : AppColors.warm,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ReviewMetric(
                          label: '페이지',
                          value: '${student.weeklyPagesCompleted}p',
                          icon: Icons.menu_book_rounded,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ReviewMetric(
                          label: '문제',
                          value: '${student.weeklyProblemsSolved}문제',
                          icon: Icons.edit_note_rounded,
                          color: AppColors.hot,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: '과목별 회고',
              child: topSubjects.isEmpty
                  ? const _EmptyText('이번 주 과목별 기록이 아직 없어요.')
                  : Column(
                      children: topSubjects.take(5).map((entry) {
                        final max = topSubjects.first.value;
                        final width = max == 0 ? 0.0 : entry.value / max;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    entry.key,
                                    style: AppTypography.titleMedium,
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatDuration(entry.value),
                                    style: AppTypography.labelLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: width,
                                  minHeight: 8,
                                  backgroundColor: AppColors.bg(context),
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: '다음 주 추천',
              child: recommendation.planTemplate.isEmpty
                  ? const _EmptyText('추천 계획을 만들려면 학습 기록을 더 쌓아 주세요.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '추천 목표 ${recommendation.recommendedTargetMinutes}분 · ${recommendation.focusSubjects.join(', ')} 집중',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...recommendation.planTemplate.map(
                          (plan) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.bg(context),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${plan.subject} · ${plan.detail}',
                                    style: AppTypography.titleMedium,
                                  ),
                                ),
                                Text('${plan.targetMinutes}분'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        StudyonButton(
                          label: '추천 계획 추가',
                          icon: Icons.add_rounded,
                          onPressed: () =>
                              ref.read(studentProvider.notifier).applyRecommendation(),
                          variant: StudyonButtonVariant.primary,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: '받은 배지',
              child: student.badges.isEmpty
                  ? const _EmptyText('이번 주 첫 배지를 노려보세요.')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: student.badges
                          .take(8)
                          .map(
                            (badge) => Chip(
                              avatar: Text(badge.emoji),
                              label: Text(badge.name),
                              backgroundColor: AppColors.tintPurple,
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewMetric extends StatelessWidget {
  const _ReviewMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 12),
          Text(label, style: AppTypography.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.titleLarge),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
