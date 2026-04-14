import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_models/studyon_models.dart';
import '../../../shared/providers/providers.dart';

class AdminRankingsScreen extends ConsumerStatefulWidget {
  const AdminRankingsScreen({super.key});

  @override
  ConsumerState<AdminRankingsScreen> createState() => _AdminRankingsScreenState();
}

class _AdminRankingsScreenState extends ConsumerState<AdminRankingsScreen> {
  String _period = 'daily';

  static const _periods = [
    ('daily', '오늘'),
    ('weekly', '이번 주'),
    ('monthly', '이번 달'),
  ];

  @override
  Widget build(BuildContext context) {
    final rankingsAsync = ref.watch(adminRankingsProvider(_period));

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('랭킹', style: AppTypography.headlineLarge),
                          const SizedBox(height: 4),
                          Text('공부 시간 기준 순위', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _showAwardSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.rankGold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(color: AppColors.rankGold.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.rankGold),
                              const SizedBox(width: 6),
                              Text('시상하기', style: AppTypography.titleMedium.copyWith(color: AppColors.rankGold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPeriodToggle(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: rankingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Center(child: Text('오류: $e', style: AppTypography.bodyMedium)),
                data: (rankings) => _buildRankingList(rankings),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAwardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final selected = <int>{1, 2, 3};
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('이번 주 시상', style: AppTypography.headlineSmall),
                  const SizedBox(height: 4),
                  Text('선택한 학생에게 시상 알림을 보냅니다', style: AppTypography.bodySmall),
                  const SizedBox(height: 20),
                  ...['1위  김민수  4시간 12분', '2위  박지현  3시간 48분', '3위  이서준  3시간 12분']
                    .asMap()
                    .entries
                    .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => setSheetState(() {
                          if (selected.contains(e.key + 1)) {
                            selected.remove(e.key + 1);
                          } else {
                            selected.add(e.key + 1);
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: selected.contains(e.key + 1)
                                ? AppColors.primary.withValues(alpha: 0.06)
                                : AppColors.bg(ctx),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected.contains(e.key + 1)
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : AppColors.borderColor(ctx),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected.contains(e.key + 1)
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 20,
                                color: selected.contains(e.key + 1)
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(e.value, style: AppTypography.titleLarge),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                          '시상 알림이 전송되었어요',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: AppColors.accent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ));
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          '시상하기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

  Widget _buildRankingList(List<RankingItem> rankings) {
    if (rankings.isEmpty) {
      return const EmptyState(message: '랭킹 데이터가 없습니다.', icon: Icons.leaderboard_rounded);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      children: [
        if (rankings.length >= 3) _buildPodium(rankings),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: rankings.asMap().entries.map((e) {
              return _RankingRow(item: e.value, isLast: e.key == rankings.length - 1);
            }).toList(),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildPodium(List<RankingItem> rankings) {
    final top3 = rankings.take(3).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd
        Expanded(child: _PodiumCard(item: top3[1], height: 100)),
        const SizedBox(width: 10),
        // 1st
        Expanded(child: _PodiumCard(item: top3[0], height: 130)),
        const SizedBox(width: 10),
        // 3rd
        Expanded(child: _PodiumCard(item: top3[2], height: 80)),
      ],
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({required this.item, required this.height});
  final RankingItem item;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.rankGold, AppColors.rankSilver, AppColors.rankBronze];
    final color = item.rankNo <= 3 ? colors[item.rankNo - 1] : AppColors.textTertiary;
    final hours = item.score ~/ 60;
    final mins = item.score % 60;

    return Column(
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
          ),
          child: Center(
            child: Text(
              item.studentName.substring(0, 1),
              style: AppTypography.titleLarge.copyWith(color: color),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(item.studentName, style: AppTypography.titleMedium, overflow: TextOverflow.ellipsis),
        Text(
          hours > 0 ? '$hours시간 $mins분' : '$mins분',
          style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border(
              top: BorderSide(color: color.withValues(alpha: 0.3)),
              left: BorderSide(color: color.withValues(alpha: 0.3)),
              right: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
          ),
          child: Center(
            child: Text(
              '${item.rankNo}',
              style: AppTypography.headlineLarge.copyWith(color: color),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.item, required this.isLast});
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
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
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
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.tintPurple,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Center(
              child: Text(
                item.studentName.substring(0, 1),
                style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(item.studentName, style: AppTypography.titleLarge),
          ),
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
