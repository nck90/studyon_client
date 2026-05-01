import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../../shared/providers/student_providers.dart';
import '../../../shared/utils/snackbar_helper.dart';

class StudentSeatsScreen extends ConsumerStatefulWidget {
  const StudentSeatsScreen({super.key});

  @override
  ConsumerState<StudentSeatsScreen> createState() => _StudentSeatsScreenState();
}

class _StudentSeatsScreenState extends ConsumerState<StudentSeatsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _seats = const [];

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final seats = await ref.read(studentRepositoryProvider).getSeatMap();
      if (!mounted) return;
      setState(() => _seats = seats);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '좌석 정보를 불러오지 못했어요');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestSeatChange(Map<String, dynamic> seat) async {
    final mySeat = ref.read(studentProvider).seatNo;
    final seatNo = seat['seatNo'] as String? ?? '';
    final seatId = seat['id'] as String? ?? '';
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.tintPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text('좌석 변경 요청', style: AppTypography.headlineSmall),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.event_seat_rounded,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '현재 좌석',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          mySeat.isEmpty ? '미배정' : mySeat,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '변경 좌석',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          seatNo,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              StudyonButton(
                label: '요청하기',
                onPressed: () => Navigator.of(ctx).pop(true),
                variant: StudyonButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    try {
      await ref.read(studentRepositoryProvider).requestSeatChange(
            toSeatId: seatId,
          );
      if (!mounted) return;
      showStudyonSnackbar(context, '변경 요청이 전송되었어요');
    } catch (_) {
      if (!mounted) return;
      showStudyonSnackbar(context, '좌석 변경 요청에 실패했어요', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final student = ref.watch(studentProvider);
    final studying = _seats.where((seat) => seat['uiStatus'] == 'studying').length;
    final onBreak = _seats.where((seat) => seat['uiStatus'] == 'onBreak').length;
    final empty = _seats.where((seat) => seat['uiStatus'] == 'empty').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(isIPad ? 28 : 20, 16, isIPad ? 28 : 20, 0),
              child: Row(
                children: [
                  PressableScale(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('좌석 현황', style: AppTypography.headlineLarge),
                  const Spacer(),
                  if (student.seatNo.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.tintPurple,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        '내 좌석 ${student.seatNo}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isIPad ? 28 : 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    _LegendChip(color: AppColors.accent, label: '공부 중'),
                    SizedBox(width: 10),
                    _LegendChip(color: AppColors.warm, label: '휴식'),
                    SizedBox(width: 10),
                    _LegendChip(
                      color: AppColors.textTertiary,
                      label: '빈자리',
                      bordered: true,
                    ),
                    SizedBox(width: 10),
                    _LegendChip(color: AppColors.error, label: '잠금'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: EmptyState(
                            icon: Icons.event_seat_rounded,
                            message: _error!,
                            actionLabel: '다시 시도',
                            onAction: _loadSeats,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadSeats,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: isIPad ? 28 : 20),
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isIPad ? 6 : 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: isIPad ? 1.3 : 1.1,
                              ),
                              itemCount: _seats.length,
                              itemBuilder: (_, i) {
                                final seat = _seats[i];
                                final uiStatus = seat['uiStatus'] as String? ?? 'empty';
                                final seatNo = seat['seatNo'] as String? ?? '';
                                final isMySeat = student.seatNo == seatNo;
                                final isRequestable = uiStatus == 'empty' && !isMySeat;

                                final card = _SeatCard(
                                  seat: seat,
                                  isMySeat: isMySeat,
                                );

                                if (!isRequestable) return card;
                                return GestureDetector(
                                  onTap: () => _requestSeatChange(seat),
                                  child: card,
                                );
                              },
                            ),
                          ),
                        ),
            ),
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(
                isIPad ? 28 : 20,
                16,
                isIPad ? 28 : 20,
                20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SummaryItem(
                    label: '빈 자리',
                    value: '$empty개',
                    color: AppColors.textTertiary,
                  ),
                  const _SummaryDivider(),
                  _SummaryItem(
                    label: '공부 중',
                    value: '$studying명',
                    color: AppColors.accent,
                  ),
                  const _SummaryDivider(),
                  _SummaryItem(
                    label: '휴식',
                    value: '$onBreak명',
                    color: AppColors.warm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeatCard extends StatelessWidget {
  const _SeatCard({
    required this.seat,
    required this.isMySeat,
  });

  final Map<String, dynamic> seat;
  final bool isMySeat;

  String get _uiStatus => seat['uiStatus'] as String? ?? 'empty';
  String get _seatNo => seat['seatNo'] as String? ?? '';
  Map<String, dynamic>? get _currentStudent =>
      seat['currentStudent'] as Map<String, dynamic>?;

  Color _bgColor() {
    switch (_uiStatus) {
      case 'studying':
        return AppColors.accent.withValues(alpha: 0.10);
      case 'onBreak':
        return AppColors.warm.withValues(alpha: 0.12);
      case 'locked':
        return AppColors.error.withValues(alpha: 0.08);
      default:
        return AppColors.surface;
    }
  }

  Color _borderColor() {
    if (isMySeat) return AppColors.primary;
    switch (_uiStatus) {
      case 'studying':
        return AppColors.accent.withValues(alpha: 0.35);
      case 'onBreak':
        return AppColors.warm.withValues(alpha: 0.40);
      case 'locked':
        return AppColors.error.withValues(alpha: 0.30);
      default:
        return AppColors.cardBorder;
    }
  }

  Color _labelColor() {
    switch (_uiStatus) {
      case 'studying':
        return AppColors.accent;
      case 'onBreak':
        return AppColors.warm;
      case 'locked':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  String _statusLabel() {
    switch (_uiStatus) {
      case 'studying':
        return '공부 중';
      case 'onBreak':
        return '휴식';
      case 'locked':
        return '잠금';
      default:
        return '빈자리';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _borderColor(),
          width: isMySeat ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _seatNo,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isMySeat)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '내 좌석',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentStudent?['name'] as String? ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _statusLabel(),
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _labelColor(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    this.bordered = false,
  });

  final Color color;
  final String label;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bordered ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: bordered ? Border.all(color: color) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      color: AppColors.divider,
    );
  }
}
