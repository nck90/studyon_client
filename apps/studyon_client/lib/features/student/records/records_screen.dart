import 'dart:math';
import 'package:flutter/material.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String _selectedSubject = '전체';

  static const _subjects = ['전체', '수학', '영어', '과학', '국어'];

  // Mock record data with subjects for filtering
  static const _allRecords = [
    (date: '4월 14일 (토)', time: '3시간 12분', goal: '수학 문제풀이', subject: '수학', achieved: true),
    (date: '4월 13일 (금)', time: '3시간 30분', goal: '영어 단어', subject: '영어', achieved: true),
    (date: '4월 12일 (목)', time: '2시간 48분', goal: '과학 개념', subject: '과학', achieved: false),
    (date: '4월 11일 (수)', time: '1시간 50분', goal: '국어 지문', subject: '국어', achieved: false),
    (date: '4월 10일 (화)', time: '3시간 15분', goal: '수학 기출', subject: '수학', achieved: true),
    (date: '4월 9일 (월)', time: '2시간 40분', goal: '영어 독해', subject: '영어', achieved: true),
    (date: '4월 8일 (일)', time: '1시간 20분', goal: '국사 복습', subject: '국어', achieved: false),
  ];

  List<({String date, String time, String goal, String subject, bool achieved})> get _filteredRecords {
    if (_selectedSubject == '전체') return _allRecords;
    return _allRecords.where((r) => r.subject == _selectedSubject).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final pad = isIPad ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
              child: Row(
                children: [
                  Text('내 기록', style: AppTypography.headlineLarge),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.warm),
                      const SizedBox(width: 4),
                      Text(
                        '7일 연속',
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

            // Stats section: iPad = 3x2 grid, phone = 2x2
            if (isIPad)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: '이번 주',
                        value: '17h',
                        icon: Icons.calendar_today_rounded,
                        color: AppColors.primary,
                        bgColor: AppColors.tintPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: '이번 달',
                        value: '68h',
                        icon: Icons.bar_chart_rounded,
                        color: AppColors.accent,
                        bgColor: AppColors.tintMint,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: '출석률',
                        value: '95%',
                        icon: Icons.check_circle_outline_rounded,
                        color: AppColors.accent,
                        bgColor: AppColors.tintMint,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: '달성률',
                        value: '82%',
                        icon: Icons.flag_rounded,
                        color: AppColors.warm,
                        bgColor: AppColors.tintYellow,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: '오늘 공부',
                        value: '2h',
                        subtitle: '14분',
                        icon: Icons.access_time_rounded,
                        color: AppColors.primary,
                        bgColor: AppColors.tintPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: '최고 기록',
                        value: '5h',
                        subtitle: '30분',
                        icon: Icons.workspace_premium_rounded,
                        color: AppColors.rankGold,
                        bgColor: AppColors.tintYellow,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: const [
                    _StatCard(
                      label: '이번 주',
                      value: '17h',
                      icon: Icons.calendar_today_rounded,
                      color: AppColors.primary,
                      bgColor: AppColors.tintPurple,
                    ),
                    _StatCard(
                      label: '이번 달',
                      value: '68h',
                      icon: Icons.bar_chart_rounded,
                      color: AppColors.accent,
                      bgColor: AppColors.tintMint,
                    ),
                    _StatCard(
                      label: '출석률',
                      value: '95%',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.accent,
                      bgColor: AppColors.tintMint,
                    ),
                    _StatCard(
                      label: '달성률',
                      value: '82%',
                      icon: Icons.flag_rounded,
                      color: AppColors.warm,
                      bgColor: AppColors.tintYellow,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Weekly chart - wider/taller on iPad
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: _WeeklyChartCard(),
            ),
            const SizedBox(height: 24),

            // Subject distribution donut chart
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: const _SubjectDonutCard(),
            ),
            const SizedBox(height: 24),

            // Subject filter chips
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _subjects.map((subject) {
                    final selected = _selectedSubject == subject;
                    final color = subject == '전체'
                        ? AppColors.primary
                        : AppColors.subjectColor(subject);
                    return Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedSubject = subject),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              subject,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                color: selected ? AppColors.textPrimary : AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 180),
                              opacity: selected ? 1.0 : 0.0,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // iPad: records + calendar side by side; phone: stacked
            if (isIPad)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Recent records list
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '최근 기록',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.card(context),
                              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                            ),
                            child: _filteredRecords.isEmpty
                                ? const EmptyState(
                                    icon: Icons.bar_chart_rounded,
                                    message: '해당 과목 기록이 없어요',
                                  )
                                : Column(
                                    children: [
                                      for (int i = 0; i < _filteredRecords.length; i++) ...[
                                        if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                                        _RecordRow(
                                          date: _filteredRecords[i].date,
                                          time: _filteredRecords[i].time,
                                          goal: _filteredRecords[i].goal,
                                          achieved: _filteredRecords[i].achieved,
                                        ),
                                      ],
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Right: Attendance calendar
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '출석 현황',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
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
                                    Text('4월 출석 현황', style: AppTypography.headlineSmall),
                                    Text(
                                      '출석 12일',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const _AttendanceCalendar(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Phone: attendance calendar full width
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Container(
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
                          Text('4월 출석 현황', style: AppTypography.headlineSmall),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.tintPurple,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                            child: Text(
                              '출석 12일',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _AttendanceCalendar(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent records label
              Padding(
                padding: EdgeInsets.fromLTRB(pad, 0, pad, 8),
                child: Text(
                  '최근 기록',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: _filteredRecords.isEmpty
                      ? const EmptyState(
                          icon: Icons.bar_chart_rounded,
                          message: '해당 과목 기록이 없어요',
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < _filteredRecords.length; i++) ...[
                              if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                              _RecordRow(
                                date: _filteredRecords[i].date,
                                time: _filteredRecords[i].time,
                                goal: _filteredRecords[i].goal,
                                achieved: _filteredRecords[i].achieved,
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeeklyChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
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
              Text('주간 학습', style: AppTypography.headlineSmall),
              Text(
                '이번 주',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: isIPad ? 220 : 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _DayBar(day: '월', hours: 2.5),
                _DayBar(day: '화', hours: 3.2),
                _DayBar(day: '수', hours: 1.8),
                _DayBar(day: '목', hours: 2.8),
                _DayBar(day: '금', hours: 3.5),
                _DayBar(day: '토', hours: 4.0, isToday: true),
                _DayBar(day: '일', hours: 0),
              ],
            ),
          ),
          if (isIPad) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _ChartLegendDot(color: AppColors.primary, label: '오늘'),
                const SizedBox(width: 16),
                _ChartLegendDot(color: AppColors.primary.withValues(alpha: 0.25), label: '다른 날'),
                const Spacer(),
                Text(
                  '이번 주 총 17시간',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ChartLegendDot extends StatelessWidget {
  const _ChartLegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
      ],
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
    this.subtitle,
  });
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;

  // Parse numeric prefix from value string for animation (e.g. "17h" -> 17, "95%" -> 95)
  double get _numericEnd {
    final match = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(value);
    return match != null ? double.parse(match.group(1)!) : 0;
  }

  String get _suffix {
    final match = RegExp(r'^[\d.]+(.*)$').firstMatch(value);
    return match?.group(1) ?? '';
  }

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _numericEnd),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, _) => Text(
                      '${val.toInt()}$_suffix',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        subtitle!,
                        style: AppTypography.labelSmall.copyWith(
                          color: color.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.day, required this.hours, this.isToday = false});
  final String day;
  final double hours;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: hours > 0
                    ? FractionallySizedBox(
                        heightFactor: (hours / 4.0).clamp(0.05, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              day,
              style: AppTypography.labelSmall.copyWith(
                color: isToday ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceCalendar extends StatefulWidget {
  const _AttendanceCalendar();

  @override
  State<_AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<_AttendanceCalendar> {
  // Days 1-14 are attended (mock data), today is 14
  static const _attendedDays = {1, 2, 3, 4, 7, 8, 9, 10, 11, 12, 13, 14};
  static const _today = 14;
  // April 2026 starts on Wednesday (index 2 in Mon-Sun week)
  static const _startOffset = 2;
  static const _daysInMonth = 30;

  // Mock study records per day
  static const _dayRecords = {
    1: '수학 2시간 30분',
    2: '영어 1시간 50분',
    3: '수학 3시간 12분',
    4: '과학 2시간 05분',
    7: '수학 3시간 30분',
    8: '영어 2시간 40분',
    9: '국어 1시간 20분',
    10: '수학 4시간 00분',
    11: '영어 3시간 15분',
    12: '과학 2시간 48분',
    13: '수학 3시간 30분',
    14: '수학 3시간 12분',
  };

  int? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      children: [
        // Day of week labels
        Row(
          children: dayLabels.map((d) => Expanded(
            child: Center(
              child: Text(
                d,
                style: AppTypography.labelSmall.copyWith(
                  color: d == '일' ? AppColors.hot.withValues(alpha: 0.7) : AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 10),
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: _startOffset + _daysInMonth,
          itemBuilder: (context, index) {
            if (index < _startOffset) return const SizedBox();
            final day = index - _startOffset + 1;
            final isAttended = _attendedDays.contains(day);
            final isToday = day == _today;
            final isFuture = day > _today;
            final isSelected = _selectedDay == day;

            Color? bgColor;
            if (isToday) {
              bgColor = AppColors.primary;
            } else if (isAttended) {
              final alpha = 0.6 + 0.4 * (day / _today);
              bgColor = AppColors.primary.withValues(alpha: alpha);
            }

            return GestureDetector(
              onTap: isAttended || isToday
                  ? () => setState(() => _selectedDay = isSelected ? null : day)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 2.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: AppTypography.labelSmall.copyWith(
                    color: isAttended || isToday
                        ? Colors.white
                        : isFuture
                            ? AppColors.textTertiary.withValues(alpha: 0.4)
                            : AppColors.textTertiary,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ),
            );
          },
        ),
        // Selected day info row
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: _selectedDay != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.tintPurple,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          '4월 $_selectedDay일',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '·',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _dayRecords[_selectedDay] ?? '',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Subject Distribution Donut Chart
// ─────────────────────────────────────────────
class _SubjectData {
  final String name;
  final double percentage;
  final Color color;
  const _SubjectData(this.name, this.percentage, this.color);
}

class _SubjectDonutCard extends StatelessWidget {
  const _SubjectDonutCard();

  static const _data = [
    _SubjectData('수학', 0.40, AppColors.primary),
    _SubjectData('영어', 0.30, AppColors.accent),
    _SubjectData('과학', 0.15, AppColors.warm),
    _SubjectData('국어', 0.10, AppColors.hot),
    _SubjectData('기타', 0.05, AppColors.textTertiary),
  ];

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
          Text('과목별 분포', style: AppTypography.headlineSmall),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _DonutChartPainter(_data),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '68h',
                            style: AppTypography.headlineMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '이번 달',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _data.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          '${(item.percentage * 100).toInt()}%',
                          style: AppTypography.labelSmall.copyWith(
                            color: item.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<_SubjectData> data;
  _DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const strokeWidth = 24.0;
    var startAngle = -pi / 2;

    for (final item in data) {
      final sweepAngle = 2 * pi * item.percentage;
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.04,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.date,
    required this.time,
    required this.goal,
    this.achieved = false,
  });
  final String date;
  final String time;
  final String goal;
  final bool achieved;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  goal,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.subjectColor(goal.split(' ').first),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
