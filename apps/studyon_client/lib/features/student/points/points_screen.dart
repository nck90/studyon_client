import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/student_providers.dart';

class PointsScreen extends ConsumerStatefulWidget {
  const PointsScreen({super.key});

  @override
  ConsumerState<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends ConsumerState<PointsScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ref.read(studentApiProvider);
      final balanceData = await api.getPointBalance();
      final history = await api.getPointHistory(take: 50);
      if (!mounted) return;
      setState(() {
        _balance = (balanceData['balance'] as num?)?.toInt() ?? 0;
        _history = history;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _sourceLabel(String source) {
    switch (source) {
      case 'STUDY_TIME': return '공부 시간';
      case 'ATTENDANCE': return '출석 보너스';
      case 'STREAK_BONUS': return '연속 출석';
      case 'BADGE_EARNED': return '뱃지 획득';
      case 'ITEM_PURCHASE': return '아이템 구매';
      case 'ADMIN_GRANT': return '관리자 지급';
      default: return source;
    }
  }

  IconData _sourceIcon(String source) {
    switch (source) {
      case 'STUDY_TIME': return Icons.timer_rounded;
      case 'ATTENDANCE': return Icons.login_rounded;
      case 'STREAK_BONUS': return Icons.local_fire_department_rounded;
      case 'BADGE_EARNED': return Icons.emoji_events_rounded;
      case 'ITEM_PURCHASE': return Icons.shopping_bag_rounded;
      case 'ADMIN_GRANT': return Icons.card_giftcard_rounded;
      default: return Icons.stars_rounded;
    }
  }

  Color _sourceColor(String source) {
    switch (source) {
      case 'STUDY_TIME': return AppColors.primary;
      case 'ATTENDANCE': return AppColors.accent;
      case 'STREAK_BONUS': return AppColors.warm;
      case 'BADGE_EARNED': return const Color(0xFFFFB800);
      case 'ITEM_PURCHASE': return AppColors.hot;
      case 'ADMIN_GRANT': return const Color(0xFF74B9FF);
      default: return AppColors.primary;
    }
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      '포인트',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  PressableScale(
                    onTap: () => context.push('/student/character'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.tintPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.face_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '캐릭터 꾸미기',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Balance card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, Color(0xFFA29BFE)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Text(
                      '보유 포인트',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_loading ? '...' : _balance}P',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Pretendard',
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lv.${student.level} ${student.levelName}',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // History header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    '포인트 내역',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '${_history.length}건',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // History list
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TossFace('💰', size: 48),
                              const SizedBox(height: 12),
                              Text(
                                '아직 포인트 내역이 없어요',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '공부하면 포인트가 쌓여요!',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: _history.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 2),
                          itemBuilder: (context, index) {
                            final tx = _history[index];
                            final amount = (tx['amount'] as num?)?.toInt() ?? 0;
                            final source = tx['source'] as String? ?? '';
                            final isEarn = amount > 0;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.card(context),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _sourceColor(source).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _sourceIcon(source),
                                      size: 20,
                                      color: _sourceColor(source),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx['memo'] as String? ?? _sourceLabel(source),
                                          style: AppTypography.titleMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatDate(tx['createdAt'] as String? ?? ''),
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isEarn ? '+' : ''}${amount}P',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Pretendard',
                                      color: isEarn ? AppColors.accent : AppColors.hot,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
