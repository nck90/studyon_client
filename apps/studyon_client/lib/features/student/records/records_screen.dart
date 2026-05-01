import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../../shared/providers/student_providers.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  String _selectedSubject = '전체';

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds초';
    final minutes = seconds ~/ 60;
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m분';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final pad = isIPad ? 32.0 : 20.0;
    final student = ref.watch(studentProvider);
    final records = student.recentRecords;
    final subjects = ['전체', ...{...records.map((record) => record.subject)}];
    final filteredRecords = _selectedSubject == '전체'
        ? records
        : records.where((record) => record.subject == _selectedSubject).toList();
    final bestSeconds = records.fold<int>(
      0,
      (best, record) => max(best, record.studySeconds),
    );
    final achievedCount = records.where((record) => record.goalAchieved).length;
    final subjectSeconds = student.dailySubjectSeconds.isNotEmpty
        ? Map<String, int>.from(student.dailySubjectSeconds)
        : <String, int>{};
    if (subjectSeconds.isEmpty) {
      for (final record in records) {
        subjectSeconds.update(
          record.subject,
          (value) => value + record.studySeconds,
          ifAbsent: () => record.studySeconds,
        );
      }
    }
    final chartRecords = records.take(7).toList().reversed.toList();
    final targetSeconds = student.todayTargetMinutes * 60;
    final attainment = targetSeconds == 0
        ? 0.0
        : (student.todayStudySeconds / targetSeconds).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
              child: Row(
                children: [
                  Text('내 기록', style: AppTypography.headlineLarge),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: AppColors.warm,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${student.streakDays}일 연속',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isIPad ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isIPad ? 1.8 : 1.55,
                children: [
                  _StatCard(
                    label: '이번 주',
                    value: _formatDuration(
                      student.weeklyStudySeconds > 0
                          ? student.weeklyStudySeconds
                          : student.weeklyStudyMinutes * 60,
                    ),
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.primary,
                    bgColor: AppColors.tintPurple,
                  ),
                  _StatCard(
                    label: '이번 달',
                    value: _formatDuration(
                      student.monthlyStudySeconds > 0
                          ? student.monthlyStudySeconds
                          : student.monthlyStudyMinutes * 60,
                    ),
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.accent,
                    bgColor: AppColors.tintMint,
                  ),
                  _StatCard(
                    label: '오늘 공부',
                    value: _formatDuration(student.todayStudySeconds),
                    icon: Icons.access_time_rounded,
                    color: AppColors.primary,
                    bgColor: AppColors.tintPurple,
                  ),
                  _StatCard(
                    label: '오늘 달성률',
                    value: '${(attainment * 100).round()}%',
                    icon: Icons.flag_rounded,
                    color: attainment >= 1 ? AppColors.accent : AppColors.warm,
                    bgColor: attainment >= 1
                        ? AppColors.tintMint
                        : AppColors.tintYellow,
                  ),
                  _StatCard(
                    label: '최고 기록',
                    value: _formatDuration(bestSeconds),
                    icon: Icons.workspace_premium_rounded,
                    color: AppColors.rankGold,
                    bgColor: AppColors.tintYellow,
                  ),
                  _StatCard(
                    label: '달성한 기록',
                    value: '$achievedCount개',
                    icon: Icons.event_available_rounded,
                    color: AppColors.warm,
                    bgColor: AppColors.tintYellow,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: _InsightCard(student: student),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: _RecentChartCard(records: chartRecords),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: _SubjectSummaryCard(subjectSeconds: subjectSeconds),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: subjects.map((subject) {
                    final selected = _selectedSubject == subject;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSubject = subject),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.tintPurple
                                : AppColors.card(context),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull,
                            ),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            subject,
                            style: AppTypography.labelLarge.copyWith(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: filteredRecords.isEmpty
                    ? const EmptyState(
                        icon: Icons.bar_chart_rounded,
                        message: '기록이 아직 없어요',
                      )
                    : Column(
                        children: filteredRecords.map((record) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.divider,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: record.goalAchieved
                                        ? AppColors.tintMint
                                        : AppColors.tintYellow,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    record.goalAchieved
                                        ? Icons.check_rounded
                                        : Icons.menu_book_rounded,
                                    color: record.goalAchieved
                                        ? AppColors.accent
                                        : AppColors.warm,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record.subject,
                                        style: AppTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        record.goalDetail,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        record.date,
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatDuration(record.studySeconds),
                                      style: AppTypography.titleMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      record.goalAchieved ? '목표 달성' : '진행 중',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: record.goalAchieved
                                            ? AppColors.accent
                                            : AppColors.warm,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentChartCard extends StatelessWidget {
  const _RecentChartCard({required this.records});

  final List<StudyRecord> records;

  @override
  Widget build(BuildContext context) {
    final maxSeconds = records.isEmpty
        ? 1
        : records
            .map((record) => record.studySeconds)
            .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('최근 학습 흐름', style: AppTypography.headlineSmall),
          const SizedBox(height: 20),
          if (records.isEmpty)
            const EmptyState(
              icon: Icons.insights_rounded,
              message: '표시할 기록이 아직 없어요',
            )
          else
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: records.map((record) {
                  final ratio = (record.studySeconds / maxSeconds).clamp(0.08, 1.0);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            record.studySeconds < 60
                                ? '${record.studySeconds}s'
                                : '${(record.studySeconds / 60).ceil()}m',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: ratio,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: record.goalAchieved
                                        ? AppColors.primary
                                        : AppColors.primary.withValues(alpha: 0.24),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            record.date.replaceAll('월 ', '/').split('일').first,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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

class _SubjectSummaryCard extends StatelessWidget {
  const _SubjectSummaryCard({required this.subjectSeconds});

  final Map<String, int> subjectSeconds;

  @override
  Widget build(BuildContext context) {
    final sortedEntries = subjectSeconds.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sortedEntries.fold<int>(0, (sum, item) => sum + item.value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('과목별 분포', style: AppTypography.headlineSmall),
          const SizedBox(height: 16),
          if (sortedEntries.isEmpty)
            const EmptyState(
              icon: Icons.pie_chart_rounded,
              message: '과목별 집계를 만들 기록이 없어요',
            )
          else
            Column(
              children: sortedEntries.map((entry) {
                final ratio = total == 0 ? 0.0 : entry.value / total;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 54,
                        child: Text(
                          entry.key,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 10,
                            backgroundColor: AppColors.background,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(ratio * 100).round()}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.student});

  final StudentState student;

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m분';
    if (m == 0) return '$h시간';
    return '$h시간 $m분';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('실행 인사이트', style: AppTypography.headlineSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InsightTile(
                  label: '오늘 목표',
                  value:
                      '${student.dailyAchievedRate.round()}% / ${_formatMinutes(student.todayTargetMinutes)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InsightTile(
                  label: '오늘 체류',
                  value: _formatMinutes(student.todayAttendanceMinutes),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InsightTile(
                  label: '주간 페이지',
                  value: '${student.weeklyPagesCompleted}p',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InsightTile(
                  label: '월간 문제',
                  value: '${student.monthlyProblemsSolved}문제',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
