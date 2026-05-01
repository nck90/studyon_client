import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_models/studyon_models.dart';

import '../../../shared/providers/student_providers.dart';

class RankingsScreen extends ConsumerStatefulWidget {
  const RankingsScreen({super.key});

  @override
  ConsumerState<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends ConsumerState<RankingsScreen>
    with TickerProviderStateMixin {
  static const _tabs = ['오늘', '주간', '월간'];
  static const _cacheTtl = Duration(minutes: 3);

  late final AnimationController _podiumCtrl;
  int _tab = 0;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  RankingResponse? _ranking;
  final Map<String, RankingResponse> _rankingCache = {};
  final Map<String, DateTime> _rankingFetchedAt = {};

  @override
  void initState() {
    super.initState();
    _podiumCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadRanking();
  }

  @override
  void dispose() {
    _podiumCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRanking({bool forceRefresh = false}) async {
    final periodType = _periodType;
    final cached = _rankingCache[periodType];
    final fetchedAt = _rankingFetchedAt[periodType];
    final isFresh =
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < _cacheTtl;

    if (!forceRefresh && cached != null && isFresh) {
      setState(() {
        _ranking = cached;
        _isLoading = false;
        _isRefreshing = false;
        _error = null;
      });
      _podiumCtrl
        ..reset()
        ..forward();
      return;
    }

    setState(() {
      _error = null;
      _isLoading = cached == null;
      _isRefreshing = cached != null;
      if (cached != null) {
        _ranking = cached;
      }
    });

    try {
      final ranking = await ref.read(studentRepositoryProvider).getRankings(
            periodType: periodType,
          );
      if (!mounted) return;
      _rankingCache[periodType] = ranking;
      _rankingFetchedAt[periodType] = DateTime.now();
      setState(() {
        _ranking = ranking;
        _error = null;
      });
      _podiumCtrl
        ..reset()
        ..forward();
    } catch (_) {
      if (!mounted) return;
      if (cached == null) {
        setState(() => _error = '랭킹을 불러오지 못했어요');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  String get _periodType {
    switch (_tab) {
      case 1:
        return 'WEEKLY';
      case 2:
        return 'MONTHLY';
      default:
        return 'DAILY';
    }
  }

  String _formatScore(int score) {
    final h = score ~/ 60;
    final m = score % 60;
    if (h <= 0) return '$m분';
    if (m == 0) return '$h시간';
    return '$h시간 $m분';
  }

  Widget _animatedPodium(double delay, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
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
    final student = ref.watch(studentProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _loadRanking(forceRefresh: true),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
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
              const SizedBox(height: 20),
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
                          if (_tab == i) return;
                          HapticFeedback.lightImpact();
                          setState(() => _tab = i);
                          _loadRanking();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: i < _tabs.length - 1 ? 24 : 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _tabs[i],
                                style: AppTypography.titleMedium.copyWith(
                                  color: selected
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
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
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              if (_isRefreshing)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: const LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.primary,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              if (_isRefreshing) const SizedBox(height: 12),
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: EmptyState(
                    icon: Icons.leaderboard_rounded,
                    message: _error!,
                    actionLabel: '다시 시도',
                    onAction: _loadRanking,
                  ),
                )
              else ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: _MyRankCard(
                    periodLabel: _tabs[_tab],
                    rankNo: _ranking?.myRank.rankNo ?? 0,
                    scoreText: _formatScore(_ranking?.myRank.score ?? 0),
                    name: student.name,
                    participantCount: _ranking?.items.length ?? 0,
                  ),
                ),
                const SizedBox(height: 20),
                if ((_ranking?.items.length ?? 0) >= 3)
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
                              Expanded(
                                child: _animatedPodium(
                                  0.0,
                                  _PodiumColumn(
                                    item: _ranking!.items[1],
                                    podiumHeight: isIPad ? 126 : 108,
                                    crownIcon: Icons.workspace_premium_rounded,
                                    color: AppColors.rankSilver,
                                    isMe: _ranking!.items[1].studentName == student.name,
                                    scoreText: _formatScore(_ranking!.items[1].score),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _animatedPodium(
                                  0.15,
                                  _PodiumColumn(
                                    item: _ranking!.items[0],
                                    podiumHeight: isIPad ? 146 : 122,
                                    crownIcon: Icons.emoji_events_rounded,
                                    color: AppColors.rankGold,
                                    isMe: _ranking!.items[0].studentName == student.name,
                                    scoreText: _formatScore(_ranking!.items[0].score),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _animatedPodium(
                                  0.3,
                                  _PodiumColumn(
                                    item: _ranking!.items[2],
                                    podiumHeight: isIPad ? 112 : 96,
                                    crownIcon: Icons.military_tech_rounded,
                                    color: AppColors.rankBronze,
                                    isMe: _ranking!.items[2].studentName == student.name,
                                    scoreText: _formatScore(_ranking!.items[2].score),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card(context),
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    ),
                    child: (_ranking?.items.isEmpty ?? true)
                        ? const EmptyState(
                            icon: Icons.leaderboard_rounded,
                            message: '랭킹 데이터가 아직 없어요',
                          )
                        : Column(
                            children: _ranking!.items.map((item) {
                              final isMe = item.studentName == student.name;
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
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      child: Text(
                                        '${item.rankNo}',
                                        style: AppTypography.titleMedium.copyWith(
                                          color: isMe
                                              ? AppColors.primary
                                              : AppColors.textTertiary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        isMe
                                            ? '${item.studentName} (나)'
                                            : item.studentName,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: isMe
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                          fontWeight: isMe
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatScore(item.score),
                                      style: AppTypography.titleMedium.copyWith(
                                        color: isMe
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MyRankCard extends StatelessWidget {
  const _MyRankCard({
    required this.periodLabel,
    required this.rankNo,
    required this.scoreText,
    required this.name,
    required this.participantCount,
  });

  final String periodLabel;
  final int rankNo;
  final String scoreText;
  final String name;
  final int participantCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
            '$periodLabel 나의 순위',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rankNo == 0 ? '-' : '$rankNo',
                style: AppTypography.displayLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 56,
                  height: 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  '위',
                  style: AppTypography.titleMedium.copyWith(color: Colors.white),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    scoreText,
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '공부 시간',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoTile(label: '이름', value: name),
                ),
                Expanded(
                  child: _InfoTile(
                    label: '참가자',
                    value: '$participantCount명',
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.item,
    required this.podiumHeight,
    required this.crownIcon,
    required this.color,
    required this.isMe,
    required this.scoreText,
  });

  final RankingItem item;
  final double podiumHeight;
  final IconData crownIcon;
  final Color color;
  final bool isMe;
  final String scoreText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(crownIcon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(
          '${item.rankNo}',
          style: AppTypography.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isMe ? '${item.studentName} (나)' : item.studentName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          scoreText,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: podiumHeight,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
        ),
      ],
    );
  }
}
