import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_models/studyon_models.dart';
import '../../../shared/providers/providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(adminDashboardProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminDashboardProvider),
          child: dashAsync.when(
            loading: () => Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 120, height: 24),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      Expanded(child: ShimmerCard(height: 100)),
                      SizedBox(width: 12),
                      Expanded(child: ShimmerCard(height: 100)),
                      SizedBox(width: 12),
                      Expanded(child: ShimmerCard(height: 100)),
                      SizedBox(width: 12),
                      Expanded(child: ShimmerCard(height: 100)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Expanded(child: ShimmerCard(height: 300)),
                ],
              ),
            ),
            error: (e, _) => Center(child: Text('오류: $e', style: AppTypography.bodyMedium)),
            data: (dash) => _buildContent(context, dash),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdminDashboardData dash) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        return ListView(
          padding: const EdgeInsets.all(28),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildKpiRow(context, dash),
            const SizedBox(height: 28),
            if (isWide)
              _buildThreeColumnLayout(context, dash)
            else
              _buildStackedLayout(context, dash),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('대시보드', style: AppTypography.headlineLarge),
        const SizedBox(height: 4),
        Text('실시간 자습실 현황', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }

  Widget _buildThreeColumnLayout(BuildContext context, AdminDashboardData dash) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: _buildSeatSection(context, dash)),
          const SizedBox(width: 20),
          Expanded(flex: 4, child: _buildRankingSection(context, dash)),
          const SizedBox(width: 20),
          Expanded(flex: 3, child: _buildHourlyChart(context)),
        ],
      ),
    );
  }

  Widget _buildStackedLayout(BuildContext context, AdminDashboardData dash) {
    return Column(
      children: [
        _buildSeatSection(context, dash),
        const SizedBox(height: 28),
        _buildRankingSection(context, dash),
        const SizedBox(height: 28),
        _buildHourlyChart(context),
      ],
    );
  }

  Widget _buildKpiRow(BuildContext context, AdminDashboardData dash) {
    final totalHours = (dash.totalStudyMinutes / 60).toStringAsFixed(0);
    final avgHours = (dash.avgStudyMinutes / 60).toStringAsFixed(1);
    final totalHoursNum = dash.totalStudyMinutes / 60;
    final avgHoursNum = dash.avgStudyMinutes / 60;
    return Row(
      children: [
        Expanded(child: PressableScale(
          onTap: () => context.go('/admin/attendance'),
          child: _KpiCard(
            label: '현재 입실',
            targetValue: dash.checkedIn.toDouble(),
            suffix: '명',
            icon: Icons.people_rounded,
            color: AppColors.primary,
            bgColor: AppColors.tintPurple,
            isDecimal: false,
          ),
        )),
        const SizedBox(width: 12),
        Expanded(child: PressableScale(
          onTap: () => context.go('/admin/seats'),
          child: _KpiCard(
            label: '빈 좌석',
            targetValue: dash.emptySeats.toDouble(),
            suffix: '개',
            icon: Icons.event_seat_rounded,
            color: AppColors.textTertiary,
            bgColor: AppColors.background,
            isDecimal: false,
          ),
        )),
        const SizedBox(width: 12),
        Expanded(child: PressableScale(
          onTap: () => context.go('/admin/study-overview'),
          child: _KpiCard(
            label: '총 공부시간',
            targetValue: totalHoursNum,
            suffix: '시간',
            icon: Icons.timer_rounded,
            color: AppColors.success,
            bgColor: AppColors.tintMint,
            isDecimal: false,
            displayOverride: '$totalHours시간',
          ),
        )),
        const SizedBox(width: 12),
        Expanded(child: PressableScale(
          onTap: () => context.go('/admin/study-overview'),
          child: _KpiCard(
            label: '평균 공부시간',
            targetValue: avgHoursNum,
            suffix: '시간',
            icon: Icons.show_chart_rounded,
            color: AppColors.warning,
            bgColor: AppColors.tintYellow,
            isDecimal: true,
            displayOverride: '$avgHours시간',
          ),
        )),
      ],
    );
  }

  Widget _buildSeatSection(BuildContext context, AdminDashboardData dash) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('좌석 현황', style: AppTypography.headlineSmall),
            _buildSeatLegend(),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: _SeatGrid(seats: dash.seats),
        ),
      ],
    );
  }

  Widget _buildSeatLegend() {
    final items = [
      ('공부 중', AppColors.studying),
      ('휴식', AppColors.onBreak),
      ('미입실', AppColors.notCheckedIn),
      ('빈 좌석', AppColors.empty),
    ];
    return Wrap(
      spacing: 12,
      children: items.map((item) {
        final (label, color) = item;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 4),
            Text(label, style: AppTypography.bodySmall),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHourlyChart(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('시간대별 현황', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const _HourlyBarChart(),
        ),
      ],
    );
  }

  Widget _buildRankingSection(BuildContext context, AdminDashboardData dash) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('실시간 TOP 5', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: dash.topRankings.take(5).toList().asMap().entries.map((e) {
              return _RankRow(item: e.value, isLast: e.key == 4);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// Animated KPI card that counts up from 0 to target value over 800ms
class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.targetValue,
    required this.suffix,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.isDecimal,
    this.displayOverride,
  });

  final String label;
  final double targetValue;
  final String suffix;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool isDecimal;
  // When provided, shows this exact string instead of computing from animated value
  final String? displayOverride;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: bgColor == AppColors.background
            ? Border.all(color: AppColors.cardBorder)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 14),
          Text(label, style: AppTypography.bodySmall),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: targetValue),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              final String display;
              if (displayOverride != null) {
                if (isDecimal) {
                  display = '${value.toStringAsFixed(1)}$suffix';
                } else {
                  display = '${value.toStringAsFixed(0)}$suffix';
                }
              } else {
                display = '${value.toStringAsFixed(0)}$suffix';
              }
              return Text(display, style: AppTypography.headlineLarge.copyWith(color: color));
            },
          ),
        ],
      ),
    );
  }
}

// Seat grid with pulsing animation for onBreak seats
class _SeatGrid extends StatefulWidget {
  const _SeatGrid({required this.seats});
  final List<Seat> seats;

  @override
  State<_SeatGrid> createState() => _SeatGridState();
}

class _SeatGridState extends State<_SeatGrid> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.12, end: 0.28).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _colorForStatus(String status) {
    switch (status) {
      case 'studying': return AppColors.studying;
      case 'onBreak': return AppColors.onBreak;
      case 'notCheckedIn': return AppColors.notCheckedIn;
      default: return AppColors.empty;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'studying': return '공부 중';
      case 'onBreak': return '휴식';
      default: return status;
    }
  }

  void _showSeatInfo(BuildContext context, Seat seat) {
    final color = _colorForStatus(seat.status);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(seat.assignedStudentName ?? '빈 좌석', style: AppTypography.headlineMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel(seat.status),
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('좌석 ${seat.seatNo}', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 16),
            if (seat.assignedStudentName != null)
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/admin/students');
                },
                child: Text(
                  '학생 상세 보기',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.4,
      ),
      itemCount: widget.seats.length,
      itemBuilder: (ctx, i) {
        final seat = widget.seats[i];
        final color = _colorForStatus(seat.status);
        final isOnBreak = seat.status == 'onBreak';
        final hasStudent = seat.status == 'studying' || seat.status == 'onBreak';

        Widget seatBox;
        if (isOnBreak) {
          seatBox = AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: _pulseAnimation.value),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.45)),
                ),
                child: child,
              );
            },
            child: _SeatContent(seat: seat, color: color),
          );
        } else {
          seatBox = Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: _SeatContent(seat: seat, color: color),
          );
        }

        if (hasStudent) {
          return GestureDetector(
            onTap: () => _showSeatInfo(ctx, seat),
            child: seatBox,
          );
        }
        return seatBox;
      },
    );
  }
}

class _SeatContent extends StatelessWidget {
  const _SeatContent({required this.seat, required this.color});
  final Seat seat;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          seat.seatNo,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        if (seat.assignedStudentName != null) ...[
          const SizedBox(height: 2),
          Text(
            seat.assignedStudentName!.length > 3
                ? seat.assignedStudentName!.substring(0, 3)
                : seat.assignedStudentName!,
            style: AppTypography.bodySmall.copyWith(fontSize: 10),
          ),
        ],
      ],
    );
  }
}

class _HourlyBarChart extends StatelessWidget {
  const _HourlyBarChart();

  static const _hourlyData = [
    (9, 2), (10, 8), (11, 12), (12, 10), (13, 6), (14, 9),
    (15, 14), (16, 16), (17, 15), (18, 12), (19, 18), (20, 16),
    (21, 10), (22, 5),
  ];

  @override
  Widget build(BuildContext context) {
    final currentHour = DateTime.now().hour;
    final maxCount = _hourlyData.map((e) => e.$2).reduce(max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('체크인 현황', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
            Text(
              '최대 $maxCount명',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _hourlyData.map((entry) {
              final (hour, count) = entry;
              final isCurrentHour = hour == currentHour;
              final ratio = maxCount > 0 ? count / maxCount : 0.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: ratio.clamp(0.04, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: isCurrentHour
                                    ? const LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: AppColors.primaryGradient,
                                      )
                                    : null,
                                color: isCurrentHour ? null : AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$hour시',
                        style: AppTypography.labelSmall.copyWith(
                          color: isCurrentHour ? AppColors.primary : AppColors.textTertiary,
                          fontWeight: isCurrentHour ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 9,
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
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.item, required this.isLast});
  final RankingItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final rank = item.rankNo;
    final colors = [AppColors.rankGold, AppColors.rankSilver, AppColors.rankBronze];
    final rankColor = rank <= 3 ? colors[rank - 1] : AppColors.textTertiary;
    final hours = item.score ~/ 60;
    final mins = item.score % 60;
    final timeLabel = hours > 0 ? '$hours시간 $mins분' : '$mins분';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: rank <= 3 ? rankColor.withValues(alpha: 0.12) : AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTypography.labelLarge.copyWith(color: rankColor),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(item.studentName, style: AppTypography.titleLarge)),
          Text(
            timeLabel,
            style: AppTypography.bodyMedium.copyWith(
              color: rank <= 3 ? rankColor : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
