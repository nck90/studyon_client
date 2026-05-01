import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import '../../../shared/providers/providers.dart';

class AdminAttendanceScreen extends ConsumerStatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  ConsumerState<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends ConsumerState<AdminAttendanceScreen> {
  String _selectedDate = '2024-04-14';
  String _viewMode = 'daily'; // daily | weekly | monthly

  // Calendar state
  DateTime _calendarMonth = DateTime(2024, 4);

  static const _viewModes = [
    ('daily',   '일간'),
    ('weekly',  '주간'),
    ('monthly', '월간'),
  ];

  // Mock attendance rate data per day (0.0–1.0); null = no data
  static const Map<int, double> _dailyRates = {
    1: 0.92, 2: 0.85, 3: 0.78, 4: 0.55, 5: 0.60,
    7: 0.88, 8: 0.91, 9: 0.45, 10: 0.72, 11: 0.83,
    12: 0.30, 13: 0.95, 14: 0.87,
  };

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(adminAttendanceProvider(_selectedDate));
    final summaryAsync = ref.watch(
      adminAttendanceSummaryProvider((mode: _viewMode, date: _selectedDate)),
    );

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('출결 관리', style: AppTypography.headlineLarge),
                          const SizedBox(height: 4),
                          Text(_selectedDate, style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                      if (_viewMode == 'daily')
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime.now(),
                              builder: (ctx, child) => Theme(
                                data: Theme.of(ctx).copyWith(
                                  colorScheme: const ColorScheme.light(primary: AppColors.primary),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate =
                                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text('날짜 선택', style: AppTypography.titleMedium.copyWith(color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // View mode toggle
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _viewModes.map((entry) {
                        final (value, label) = entry;
                        final isActive = _viewMode == value;
                        return GestureDetector(
                          onTap: () => setState(() => _viewMode = value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 1),
                            ),
                            child: Text(
                              label,
                              style: AppTypography.titleMedium.copyWith(
                                color: isActive ? Colors.white : AppColors.textSecondary,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            if (_viewMode == 'daily') ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _buildCalendar(),
              ),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: _viewMode == 'daily'
                  ? attendanceAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      error: (e, _) => Center(child: Text('오류: $e', style: AppTypography.bodyMedium)),
                      data: (records) => _buildContent(records),
                    )
                  : summaryAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      error: (e, _) => Center(child: Text('오류: $e', style: AppTypography.bodyMedium)),
                      data: (summary) => _buildAggregateView(_viewMode, summary),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final year = _calendarMonth.year;
    final month = _calendarMonth.month;
    final firstWeekday = DateTime(year, month, 1).weekday; // 1=Mon … 7=Sun
    final startOffset = firstWeekday - 1; // Mon-based offset
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
    final today = DateTime.now();
    final selectedParts = _selectedDate.split('-');
    final selYear = int.parse(selectedParts[0]);
    final selMonth = int.parse(selectedParts[1]);
    final selDay = int.parse(selectedParts[2]);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month navigation
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1);
                }),
                child: const Icon(Icons.chevron_left_rounded, size: 22, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Text(
                '$year년 $month월',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() {
                  _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1);
                }),
                child: const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Day labels
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
          const SizedBox(height: 8),
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
            itemCount: startOffset + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startOffset) return const SizedBox();
              final day = index - startOffset + 1;
              final isSelected = year == selYear && month == selMonth && day == selDay;
              final isToday = today.year == year && today.month == month && today.day == day;
              final rate = _dailyRates[day];

              // Dot color based on rate
              Color? dotColor;
              if (rate != null) {
                if (rate > 0.8) {
                  dotColor = AppColors.success;
                } else if (rate >= 0.5) {
                  dotColor = AppColors.warning;
                } else {
                  dotColor = AppColors.error;
                }
              }

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedDate =
                      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                }),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isToday
                                ? AppColors.tintPurple
                                : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isToday && !isSelected
                            ? Border.all(color: AppColors.primary, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                            fontWeight: (isSelected || isToday) ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    dotColor != null
                        ? Container(
                            width: 4, height: 4,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          )
                        : const SizedBox(height: 4),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            children: [
              _CalendarLegendDot(color: AppColors.success, label: '높음 (>80%)'),
              const SizedBox(width: 16),
              _CalendarLegendDot(color: AppColors.warning, label: '보통 (50-80%)'),
              const SizedBox(width: 16),
              _CalendarLegendDot(color: AppColors.error, label: '낮음 (<50%)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAggregateView(String mode, AttendanceSummary summary) {
    final isWeekly = mode == 'weekly';
    final period = summary.periodLabel;
    final attendanceRate = '${(summary.attendanceRate * 100).round()}%';
    final avgStayHours = (summary.avgStayMinutes / 60).toStringAsFixed(1);
    final days = isWeekly ? 7 : 30;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.tintPurple,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              period,
              style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),
          // Stat cards
          Row(
            children: [
              Expanded(child: _AggregateStat(label: '출석률', value: attendanceRate, icon: Icons.check_circle_outline_rounded, color: AppColors.success, bgColor: AppColors.tintGreen)),
              const SizedBox(width: 10),
              Expanded(child: _AggregateStat(label: '평균 체류', value: '$avgStayHours시간', icon: Icons.timer_outlined, color: AppColors.primary, bgColor: AppColors.tintPurple)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _AggregateStat(label: '지각', value: '${summary.lateCount}건', icon: Icons.schedule_rounded, color: AppColors.warning, bgColor: AppColors.tintYellow)),
              const SizedBox(width: 10),
              Expanded(child: _AggregateStat(label: '결석', value: '${summary.absentCount}명', icon: Icons.cancel_outlined, color: AppColors.error, bgColor: AppColors.tintPink)),
            ],
          ),
          const SizedBox(height: 24),
          // Summary note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWeekly ? '주간 요약' : '월간 요약',
                  style: AppTypography.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  isWeekly
                      ? '지난 $days일 동안 총 ${summary.totalCount}건의 출결이 집계되었습니다. 평균 체류 시간은 $avgStayHours시간입니다.'
                      : '이번 달 $days일 동안 평균 출석률 $attendanceRate를 기록했습니다. 결석 ${summary.absentCount}건, 지각 ${summary.lateCount}건입니다.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<AdminAttendanceRecord> records) {
    final checkedIn = records.where((r) => r.status != 'absent').length;
    final absent = records.where((r) => r.status == 'absent').length;
    final lateCount = records.where((r) => r.isLate).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _buildSummaryRow(checkedIn, absent, lateCount, records.length),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: records.isEmpty
              ? const EmptyState(message: '출결 기록이 없습니다.', icon: Icons.checklist_rounded)
              : _buildAttendanceList(records),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(int checkedIn, int absent, int lateCount, int total) {
    return Row(
      children: [
        Expanded(child: _SummaryCard(label: '입실', count: checkedIn, color: AppColors.success, bgColor: AppColors.tintGreen)),
        const SizedBox(width: 10),
        Expanded(child: _SummaryCard(label: '결석', count: absent, color: AppColors.error, bgColor: AppColors.tintPink)),
        const SizedBox(width: 10),
        Expanded(child: _SummaryCard(label: '지각', count: lateCount, color: AppColors.warning, bgColor: AppColors.tintYellow)),
        const SizedBox(width: 10),
        Expanded(child: _SummaryCard(label: '전체', count: total, color: AppColors.primary, bgColor: AppColors.tintPurple)),
      ],
    );
  }

  Widget _buildAttendanceList(List<AdminAttendanceRecord> records) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1, color: AppColors.cardBorder),
          Expanded(
            child: ListView.separated(
              itemCount: records.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.cardBorder),
              itemBuilder: (context, i) => _AttendanceRow(record: records[i], index: i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('#', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary))),
          Expanded(flex: 2, child: Text('학생', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary))),
          Expanded(child: Text('입실 시간', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary))),
          Expanded(child: Text('공부 시간', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary))),
          SizedBox(width: 80, child: Text('상태', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary))),
        ],
      ),
    );
  }
}

class _CalendarLegendDot extends StatelessWidget {
  const _CalendarLegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}

class _AggregateStat extends StatelessWidget {
  const _AggregateStat({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.headlineMedium.copyWith(color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
  });
  final String label;
  final int count;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall),
          const SizedBox(height: 4),
          Text(
            '$count명',
            style: AppTypography.headlineMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.record, required this.index});
  final AdminAttendanceRecord record;
  final int index;

  Color _statusColor(String status, bool isLate) {
    if (status == 'absent') return AppColors.error;
    if (isLate) return AppColors.warning;
    return AppColors.success;
  }

  String _statusLabel(String status, bool isLate) {
    if (status == 'absent') return '결석';
    if (isLate) return '지각';
    return '입실';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(record.status, record.isLate);
    final label = _statusLabel(record.status, record.isLate);
    final hours = record.stayMinutes ~/ 60;
    final mins = record.stayMinutes % 60;
    final stayLabel = record.stayMinutes > 0
        ? (hours > 0 ? '$hours시간 $mins분' : '$mins분')
        : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('${index + 1}', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.tintPurple,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Center(
                    child: Text(
                      'S',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  record.studentName.isEmpty
                      ? '학생 ${record.studentNo}'
                      : record.studentName,
                  style: AppTypography.titleMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              record.checkInAt ?? '—',
              style: AppTypography.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(stayLabel, style: AppTypography.bodyMedium),
          ),
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                label,
                style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
