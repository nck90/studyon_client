import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
// TossFace is exported from studyon_design_system

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});
  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen>
    with TickerProviderStateMixin {
  int _tab = 0;
  final _tabs = ['오늘', '주간', '월간'];
  late final AnimationController _podiumCtrl;

  @override
  void initState() {
    super.initState();
    _podiumCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _podiumCtrl.dispose();
    super.dispose();
  }

  final _data = [
    ('김민수', '4시간 12분'),
    ('박지현', '3시간 48분'),
    ('이서준', '3시간 12분'),
    ('정다은', '2시간 58분'),
    ('최우진', '2시간 34분'),
    ('박서연', '2시간 12분'),
    ('강지호', '1시간 58분'),
    ('윤하은', '1시간 45분'),
    ('임준혁', '1시간 30분'),
    ('송유나', '1시간 12분'),
  ];

  // Trend data: positive = moved up, negative = moved down, 0 = no change
  final _trends = [0, 1, -2, 3, -1, 0, 2, -1, 1, 0];

  // Weekly rank history for rank trend chart (rank per day Mon-Sun, 0 = no data)
  // My rank (index 2 = 이서준) over the week
  final _weeklyRanks = [5, 4, 4, 3, 3, 3, 0]; // Mon-Sun, 0 = no data yet

  // Current user is rank 3 (이서준)
  static const int _myRank = 3;

  Widget _animatedPodium(double delay, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _podiumCtrl,
          curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _podiumCtrl,
          curve: Interval(delay, delay + 0.4),
        ),
        child: child,
      ),
    );
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
                  Text('랭킹', style: AppTypography.headlineLarge),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TossFace('🔥', size: 14),
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
            const SizedBox(height: 20),

            // Period tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final selected = _tab == i;
                  return Semantics(
                    label: '${_tabs[i]} 랭킹',
                    button: true,
                    selected: selected,
                    child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _tab = i);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: i < _tabs.length - 1 ? 24 : 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _tabs[i],
                            style: AppTypography.titleMedium.copyWith(
                              color: selected ? AppColors.textPrimary : AppColors.textTertiary,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: selected ? 1.0 : 0.0,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
                }),
              ),
            ),
            const SizedBox(height: 20),

            // iPad: My rank + Podium side by side; Phone: stacked
            if (isIPad)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: My rank hero card (taller, more stats)
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.primaryGradient,
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '나의 순위',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '3',
                                  style: AppTypography.displayLarge.copyWith(
                                    color: Colors.white,
                                    fontSize: 56,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6, left: 4),
                                  child: Text(
                                    '위',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Stats
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                              ),
                              child: Column(
                                children: [
                                  _MyRankStatRow(
                                    label: '오늘 공부 시간',
                                    value: '3시간 12분',
                                    icon: Icons.timer_outlined,
                                  ),
                                  const SizedBox(height: 12),
                                  _MyRankStatRow(
                                    label: '1위까지 남은 시간',
                                    value: '1시간 00분',
                                    icon: Icons.arrow_upward_rounded,
                                  ),
                                  const SizedBox(height: 12),
                                  _MyRankStatRow(
                                    label: '전날 대비',
                                    value: '▼ 2단계',
                                    icon: Icons.trending_down_rounded,
                                    valueColor: const Color(0xFFFF7675),
                                  ),
                                  const SizedBox(height: 12),
                                  _MyRankStatRow(
                                    label: '이번 주 최고 순위',
                                    value: '2위',
                                    icon: Icons.emoji_events_outlined,
                                    valueColor: AppColors.rankGold,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Badges row
                            Row(
                              children: [
                                _RankBadge(
                                  icon: Icons.arrow_downward_rounded,
                                  iconColor: const Color(0xFFFF7675),
                                  label: '2',
                                ),
                                const SizedBox(width: 8),
                                _RankBadge(
                                  icon: Icons.arrow_upward_rounded,
                                  iconColor: Colors.white,
                                  label: '1위까지 36분',
                                  wide: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Right: Podium
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'TOP 3',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(child: _animatedPodium(0.0, _PodiumColumn(rank: 2, name: _data[1].$1, time: _data[1].$2, podiumHeight: 110, crownIcon: Icons.workspace_premium_rounded, crownColor: AppColors.rankSilver, borderColor: AppColors.rankSilver, nameColor: AppColors.rankSilver, isMyRank: _myRank == 2, trend: '+1', trendUp: true))),
                                const SizedBox(width: 8),
                                Expanded(child: _animatedPodium(0.15, _PodiumColumn(rank: 1, name: _data[0].$1, time: _data[0].$2, podiumHeight: 140, crownIcon: Icons.emoji_events_rounded, crownColor: AppColors.rankGold, borderColor: AppColors.rankGold, nameColor: AppColors.rankGold, isMyRank: _myRank == 1, trend: '-', trendUp: null))),
                                const SizedBox(width: 8),
                                Expanded(child: _animatedPodium(0.3, _PodiumColumn(rank: 3, name: _data[2].$1, time: _data[2].$2, podiumHeight: 90, crownIcon: Icons.military_tech_rounded, crownColor: AppColors.rankBronze, borderColor: AppColors.rankBronze, nameColor: AppColors.rankBronze, isMyRank: _myRank == 3, trend: '-2', trendUp: false))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Phone: My rank hero card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '나의 순위',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '3',
                                style: AppTypography.displayLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 56,
                                  fontWeight: FontWeight.w800,
                                  height: 1.0,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6, left: 4),
                                child: Text(
                                  '위',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '3시간 12분',
                            style: AppTypography.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '오늘 공부 시간',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _RankBadge(
                                icon: Icons.arrow_downward_rounded,
                                iconColor: const Color(0xFFFF7675),
                                label: '2',
                              ),
                              const SizedBox(width: 8),
                              _RankBadge(
                                icon: Icons.arrow_upward_rounded,
                                iconColor: Colors.white,
                                label: '1위까지 36분',
                                wide: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Phone: TOP 3 Podium
              Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TOP 3',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: _animatedPodium(0.0, _PodiumColumn(rank: 2, name: _data[1].$1, time: _data[1].$2, podiumHeight: 100, crownIcon: Icons.workspace_premium_rounded, crownColor: AppColors.rankSilver, borderColor: AppColors.rankSilver, nameColor: AppColors.rankSilver, isMyRank: _myRank == 2, trend: '+1', trendUp: true))),
                          const SizedBox(width: 8),
                          Expanded(child: _animatedPodium(0.15, _PodiumColumn(rank: 1, name: _data[0].$1, time: _data[0].$2, podiumHeight: 120, crownIcon: Icons.emoji_events_rounded, crownColor: AppColors.rankGold, borderColor: AppColors.rankGold, nameColor: AppColors.rankGold, isMyRank: _myRank == 1, trend: '-', trendUp: null))),
                          const SizedBox(width: 8),
                          Expanded(child: _animatedPodium(0.3, _PodiumColumn(rank: 3, name: _data[2].$1, time: _data[2].$2, podiumHeight: 90, crownIcon: Icons.military_tech_rounded, crownColor: AppColors.rankBronze, borderColor: AppColors.rankBronze, nameColor: AppColors.rankBronze, isMyRank: _myRank == 3, trend: '-2', trendUp: false))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Leaderboard - table layout on iPad with mini bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Column(
                  children: List.generate(_data.length - 3, (i) {
                    final rank = i + 4;
                    final (name, time) = _data[rank - 1];
                    final isMe = rank == _myRank;
                    final trend = _trends[rank - 1];

                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isIPad ? 24 : 20,
                        vertical: isIPad ? 16 : 14,
                      ),
                      decoration: BoxDecoration(
                        color: isMe
                            ? AppColors.primary.withValues(alpha: 0.04)
                            : Colors.transparent,
                        border: i < _data.length - 4
                            ? const Border(
                                bottom: BorderSide(
                                  color: AppColors.divider,
                                  width: 0.5,
                                ),
                              )
                            : null,
                        borderRadius: i == _data.length - 4
                            ? const BorderRadius.vertical(bottom: Radius.circular(AppSpacing.radiusXl))
                            : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '$rank',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isMe ? AppColors.primary : AppColors.textTertiary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Text(
                              isMe ? '$name (나)' : name,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isMe ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (trend != 0) ...[
                            Text(
                              trend > 0 ? '↑$trend' : '↓${trend.abs()}',
                              style: AppTypography.labelSmall.copyWith(
                                color: trend > 0 ? AppColors.accent : AppColors.hot,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            time,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isMe ? AppColors.primary : AppColors.textSecondary,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Weekly rank trend chart (iPad only - show on both but styled differently)
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
                        Text('주간 추이', style: AppTypography.headlineSmall),
                        Text(
                          '나의 순위 변화',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: isIPad ? 120 : 80,
                      child: _WeeklyRankChart(
                        ranks: _weeklyRanks,
                        maxRank: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '순위가 낮을수록 위에 표시됩니다',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyRankStatRow extends StatelessWidget {
  const _MyRankStatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor = Colors.white,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.wide = false,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 12 : 10,
        vertical: wide ? 6 : 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: iconColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyRankChart extends StatelessWidget {
  const _WeeklyRankChart({required this.ranks, required this.maxRank});
  final List<int> ranks;
  final int maxRank;

  @override
  Widget build(BuildContext context) {
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(ranks.length, (i) {
        final rank = ranks[i];
        final hasData = rank > 0;
        // Invert: rank 1 = top, rank maxRank = bottom
        final frac = hasData ? (maxRank - rank + 1) / maxRank : 0.0;
        final isLatest = hasData && (i == ranks.length - 1 || ranks[i + 1] == 0);

        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Track line
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Center(
                        child: Container(
                          width: 1,
                          color: AppColors.divider,
                        ),
                      ),
                    ),
                    // Dot at rank position
                    if (hasData)
                      Align(
                        alignment: Alignment(0, 1 - frac * 2),
                        child: Container(
                          width: isLatest ? 14 : 10,
                          height: isLatest ? 14 : 10,
                          decoration: BoxDecoration(
                            color: isLatest ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            border: isLatest
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                            boxShadow: isLatest
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                    )
                                  ]
                                : null,
                          ),
                          child: hasData && isLatest
                              ? null
                              : null,
                        ),
                      ),
                    // Rank label next to latest dot
                    if (isLatest && hasData)
                      Align(
                        alignment: Alignment(0.8, 1 - frac * 2),
                        child: Text(
                          '$rank위',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                days[i],
                style: AppTypography.labelSmall.copyWith(
                  color: isLatest ? AppColors.primary : AppColors.textTertiary,
                  fontWeight: isLatest ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.rank,
    required this.name,
    required this.time,
    required this.podiumHeight,
    required this.crownIcon,
    required this.crownColor,
    required this.borderColor,
    required this.nameColor,
    required this.isMyRank,
    required this.trend,
    required this.trendUp,
  });
  final int rank;
  final String name;
  final String time;
  final double podiumHeight;
  final IconData crownIcon;
  final Color crownColor;
  final Color borderColor;
  final Color nameColor;
  final bool isMyRank;
  final String trend;
  final bool? trendUp; // null = no change

  String get _medal {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    return '🥉';
  }

  double get _medalSize => rank == 1 ? 28.0 : 24.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Medal
        TossFace(_medal, size: _medalSize),
        const SizedBox(height: 8),
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMyRank ? AppColors.primary : borderColor.withValues(alpha: 0.12),
            border: Border.all(color: borderColor, width: 2.5),
          ),
          child: Center(
            child: Text(
              name.substring(0, 1),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isMyRank ? Colors.white : nameColor,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: AppTypography.titleMedium.copyWith(
            color: isMyRank ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: AppTypography.labelSmall.copyWith(
            color: nameColor,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        if (trendUp != null) ...[
          const SizedBox(height: 4),
          Text(
            trendUp! ? '↑$trend' : '↓${trend.replaceAll('-', '')}',
            style: AppTypography.labelSmall.copyWith(
              color: trendUp! ? AppColors.accent : AppColors.hot,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 10),
        // Podium block
        Container(
          height: podiumHeight,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: nameColor,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ],
    );
  }
}
