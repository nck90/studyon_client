import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import '../../../shared/providers/providers.dart';

class StudyOverviewScreen extends ConsumerStatefulWidget {
  const StudyOverviewScreen({super.key});

  @override
  ConsumerState<StudyOverviewScreen> createState() => _StudyOverviewScreenState();
}

class _StudyOverviewScreenState extends ConsumerState<StudyOverviewScreen> {
  String _period = 'weekly';
  String _classFilter = '전체';

  static const _periods = [
    ('daily', '오늘'),
    ('weekly', '이번 주'),
    ('monthly', '이번 달'),
  ];

  static const _classes = ['전체', 'A반', 'B반', 'C반'];

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(studyOverviewProvider(_period));

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: overviewAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('오류: $e', style: AppTypography.bodyMedium)),
          data: (data) => _buildContent(data),
        ),
      ),
    );
  }

  Widget _buildContent(StudyOverviewData data) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildClassFilterRow(),
        const SizedBox(height: 16),
        _buildPeriodToggle(),
        const SizedBox(height: 24),
        _buildKpiRow(data),
        const SizedBox(height: 24),
        _buildChartSection(data),
        const SizedBox(height: 24),
        _buildSubjectBreakdown(),
        const SizedBox(height: 24),
        _buildInsightsSection(data),
      ],
    );
  }

  Widget _buildClassFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _classes.map((cls) {
          final isActive = _classFilter == cls;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _classFilter = cls),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.cardBorder,
                  ),
                ),
                child: Text(
                  cls,
                  style: AppTypography.labelLarge.copyWith(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubjectBreakdown() {
    const subjects = [
      ('수학', 0.40, AppColors.primary),
      ('영어', 0.25, AppColors.accent),
      ('과학', 0.20, AppColors.warm),
      ('국어', 0.15, AppColors.hot),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('과목별 학습 비율', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: subjects.map((entry) {
              final (name, pct, color) = entry;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        name,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 10,
                          backgroundColor: AppColors.background,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${(pct * 100).toInt()}%',
                        textAlign: TextAlign.end,
                        style: AppTypography.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('학습 현황', style: AppTypography.headlineLarge),
        const SizedBox(height: 4),
        Text('공부 통계 및 분석', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _periods.map((p) {
          final (value, label) = p;
          final isActive = _period == value;
          return GestureDetector(
            onTap: () => setState(() => _period = value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKpiRow(StudyOverviewData data) {
    final totalHours = (data.totalStudyMinutes / 60).toStringAsFixed(0);
    final avgHours = (data.avgStudyMinutes / 60).toStringAsFixed(1);
    final attendancePct = (data.attendanceRate * 100).toStringAsFixed(0);

    return Row(
      children: [
        Expanded(child: _KpiCard(
          label: '총 공부시간',
          value: '$totalHours시간',
          icon: Icons.timer_rounded,
          color: AppColors.studying,
          bgColor: AppColors.tintPurple,
        )),
        const SizedBox(width: 12),
        Expanded(child: _KpiCard(
          label: '평균 공부시간',
          value: '$avgHours시간',
          icon: Icons.show_chart_rounded,
          color: AppColors.success,
          bgColor: AppColors.tintGreen,
        )),
        const SizedBox(width: 12),
        Expanded(child: _KpiCard(
          label: '출석률',
          value: '$attendancePct%',
          icon: Icons.checklist_rounded,
          color: AppColors.accent,
          bgColor: AppColors.tintPurple,
        )),
        const SizedBox(width: 12),
        Expanded(child: _KpiCard(
          label: '활성 학생',
          value: '${data.activeStudents}명',
          icon: Icons.people_rounded,
          color: AppColors.warning,
          bgColor: AppColors.tintYellow,
        )),
      ],
    );
  }

  Widget _buildChartSection(StudyOverviewData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('일별 공부 시간', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: _BarChart(stats: data.dailyStats),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(StudyOverviewData data) {
    final totalHours = (data.totalStudyMinutes / 60).toStringAsFixed(0);
    final avgHours = (data.avgStudyMinutes / 60).toStringAsFixed(1);

    final insights = [
      _InsightItem(
        icon: Icons.trending_up_rounded,
        color: AppColors.success,
        bgColor: AppColors.tintGreen,
        title: '공부 시간 증가',
        desc: '전주 대비 12% 증가했습니다.',
      ),
      _InsightItem(
        icon: Icons.star_rounded,
        color: AppColors.rankGold,
        bgColor: AppColors.tintYellow,
        title: '최고 기록',
        desc: '이번 주 총 $totalHours시간 달성',
      ),
      _InsightItem(
        icon: Icons.people_rounded,
        color: AppColors.primary,
        bgColor: AppColors.tintPurple,
        title: '활성 학생',
        desc: '평균 ${data.activeStudents}명이 매일 공부 중',
      ),
      _InsightItem(
        icon: Icons.timer_rounded,
        color: AppColors.accent,
        bgColor: AppColors.tintPurple,
        title: '평균 공부 시간',
        desc: '학생 1인당 일 평균 $avgHours시간',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('인사이트', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.5,
          ),
          itemCount: insights.length,
          itemBuilder: (_, i) {
            final insight = insights[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: insight.bgColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(insight.icon, size: 20, color: insight.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(insight.title, style: AppTypography.titleMedium),
                        Text(insight.desc, style: AppTypography.bodySmall, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _InsightItem {
  const _InsightItem({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.desc,
  });
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String desc;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 12),
          Text(label, style: AppTypography.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.headlineMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.stats});
  final List<DailyStat> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();
    final maxMin = stats.map((s) => s.minutes).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: stats.asMap().entries.map((e) {
          final i = e.key;
          final stat = e.value;
          final ratio = maxMin > 0 ? stat.minutes / maxMin : 0.0;
          final isLast = i == stats.length - 1;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${(stat.minutes / 60).toStringAsFixed(0)}h',
                    style: AppTypography.bodySmall.copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 100 * ratio,
                    decoration: BoxDecoration(
                      color: isLast ? AppColors.primary : AppColors.tintPurple,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(stat.date, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
