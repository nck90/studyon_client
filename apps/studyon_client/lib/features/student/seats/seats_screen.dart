import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import '../../../shared/utils/snackbar_helper.dart';

// Mock seat data
class _SeatData {
  const _SeatData({
    required this.id,
    required this.label,
    required this.status,
    this.studentName,
    this.isMyeSeat = false,
  });
  final String id;
  final String label;
  final String status; // studying | onBreak | empty | notCheckedIn
  final String? studentName;
  final bool isMyeSeat;
}

const _mockSeats = [
  _SeatData(id: 'A1',  label: 'A-1',  status: 'studying',      studentName: '김민준'),
  _SeatData(id: 'A2',  label: 'A-2',  status: 'studying',      studentName: '이서연'),
  _SeatData(id: 'A3',  label: 'A-3',  status: 'onBreak',       studentName: '박지호'),
  _SeatData(id: 'A4',  label: 'A-4',  status: 'studying',      studentName: '최예은'),
  _SeatData(id: 'A5',  label: 'A-5',  status: 'empty'),
  _SeatData(id: 'A6',  label: 'A-6',  status: 'studying',      studentName: '정다원'),
  _SeatData(id: 'B1',  label: 'B-1',  status: 'studying',      studentName: '윤채린'),
  _SeatData(id: 'B2',  label: 'B-2',  status: 'empty'),
  _SeatData(id: 'B3',  label: 'B-3',  status: 'studying',      studentName: '임재현'),
  _SeatData(id: 'B4',  label: 'B-4',  status: 'onBreak',       studentName: '한소희'),
  _SeatData(id: 'B5',  label: 'B-5',  status: 'studying',      studentName: '오준영'),
  _SeatData(id: 'B6',  label: 'B-6',  status: 'studying',      studentName: '신미래'),
  _SeatData(id: 'C1',  label: 'C-1',  status: 'notCheckedIn'),
  _SeatData(id: 'C2',  label: 'C-2',  status: 'studying',      studentName: '권태양'),
  _SeatData(id: 'C3',  label: 'C-3',  status: 'studying',      studentName: '백하늘'),
  _SeatData(id: 'C4',  label: 'C-4',  status: 'empty'),
  _SeatData(id: 'C5',  label: 'C-5',  status: 'studying',      studentName: '류지민'),
  _SeatData(id: 'C6',  label: 'C-6',  status: 'studying',      studentName: '송유나'),
  _SeatData(id: 'D1',  label: 'D-1',  status: 'studying',      studentName: '전민서'),
  _SeatData(id: 'D2',  label: 'D-2',  status: 'empty'),
  _SeatData(id: 'D3',  label: 'D-3',  status: 'studying',      studentName: '조현우'),
  _SeatData(id: 'A12', label: 'A-12', status: 'studying',      studentName: '민수', isMyeSeat: true),
];

class StudentSeatsScreen extends StatelessWidget {
  const StudentSeatsScreen({super.key});

  void _showSeatChangeSheet(BuildContext context, _SeatData tappedSeat) {
    const mySeat = 'A-12';
    showModalBottomSheet<void>(
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
                    child: const Icon(Icons.swap_horiz_rounded, size: 20, color: AppColors.primary),
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
                        const Icon(Icons.event_seat_rounded, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 8),
                        Text('현재 좌석', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
                        const Spacer(),
                        Text(mySeat, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('변경 좌석', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
                        const Spacer(),
                        Text(
                          tappedSeat.label,
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
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  showStudyonSnackbar(context, '변경 요청이 전송되었어요');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '요청하기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final studying = _mockSeats.where((s) => s.status == 'studying').length;
    final onBreak  = _mockSeats.where((s) => s.status == 'onBreak').length;
    final empty    = _mockSeats.where((s) => s.status == 'empty').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('좌석 현황', style: AppTypography.headlineLarge),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Legend
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isIPad ? 28 : 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _LegendChip(color: AppColors.accent,       label: '공부 중'),
                    const SizedBox(width: 10),
                    _LegendChip(color: AppColors.warm,         label: '휴식'),
                    const SizedBox(width: 10),
                    _LegendChip(color: AppColors.textTertiary, label: '빈자리',  bordered: true),
                    const SizedBox(width: 10),
                    _LegendChip(color: AppColors.error,        label: '미입실'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Seat Grid
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isIPad ? 28 : 20),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isIPad ? 6 : 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: isIPad ? 1.3 : 1.1,
                  ),
                  itemCount: _mockSeats.length,
                  itemBuilder: (_, i) {
                    final seat = _mockSeats[i];
                    if (seat.status == 'empty' && !seat.isMyeSeat) {
                      return GestureDetector(
                        onTap: () => _showSeatChangeSheet(context, seat),
                        child: _SeatCard(seat: seat),
                      );
                    }
                    return _SeatCard(seat: seat);
                  },
                ),
              ),
            ),

            // Summary bar
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(
                isIPad ? 28 : 20, 16, isIPad ? 28 : 20, 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SummaryItem(label: '빈 자리', value: '$empty개', color: AppColors.textTertiary),
                  _SummaryDivider(),
                  _SummaryItem(label: '공부 중', value: '$studying명', color: AppColors.accent),
                  _SummaryDivider(),
                  _SummaryItem(label: '휴식', value: '$onBreak명', color: AppColors.warm),
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
  const _SeatCard({required this.seat});
  final _SeatData seat;

  Color _bgColor() {
    switch (seat.status) {
      case 'studying':      return AppColors.accent.withValues(alpha: 0.10);
      case 'onBreak':       return AppColors.warm.withValues(alpha: 0.12);
      case 'notCheckedIn':  return AppColors.error.withValues(alpha: 0.08);
      default:              return AppColors.surface;
    }
  }

  Color _borderColor() {
    if (seat.isMyeSeat) return AppColors.primary;
    switch (seat.status) {
      case 'studying':      return AppColors.accent.withValues(alpha: 0.35);
      case 'onBreak':       return AppColors.warm.withValues(alpha: 0.40);
      case 'notCheckedIn':  return AppColors.error.withValues(alpha: 0.30);
      default:              return AppColors.cardBorder;
    }
  }

  Color _labelColor() {
    switch (seat.status) {
      case 'studying':      return AppColors.accent;
      case 'onBreak':       return AppColors.warm;
      case 'notCheckedIn':  return AppColors.error;
      default:              return AppColors.textTertiary;
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
          width: seat.isMyeSeat ? 2.0 : 1.0,
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
                seat.label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (seat.isMyeSeat)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '내 자리',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 8,
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
              if (seat.studentName != null)
                Text(
                  seat.studentName!,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _labelColor(),
                  shape: BoxShape.circle,
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
  const _LegendChip({required this.color, required this.label, this.bordered = false});
  final Color color;
  final String label;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bordered ? Colors.transparent : color,
            border: bordered ? Border.all(color: AppColors.textTertiary.withValues(alpha: 0.4)) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 28),
      color: AppColors.divider,
    );
  }
}
