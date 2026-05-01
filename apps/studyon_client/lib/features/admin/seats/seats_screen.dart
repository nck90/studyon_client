import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_models/studyon_models.dart';
import '../../../shared/providers/providers.dart';

class SeatsScreen extends ConsumerStatefulWidget {
  const SeatsScreen({super.key});

  @override
  ConsumerState<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatData {
  final String id;
  final String seatNo;
  final String status;
  final String zone;
  final String? assignedStudentName;

  _SeatData({
    required this.id,
    required this.seatNo,
    required this.status,
    required this.zone,
    this.assignedStudentName,
  });

  factory _SeatData.fromSeat(Seat seat) => _SeatData(
        id: seat.id,
        seatNo: seat.seatNo,
        status: seat.status,
        zone: seat.zone ?? 'A',
        assignedStudentName: seat.assignedStudentName,
      );

  Seat toSeat() => Seat(
        id: id,
        seatNo: seatNo,
        status: status,
        zone: zone,
        assignedStudentName: assignedStudentName,
      );
}

class _SeatsScreenState extends ConsumerState<SeatsScreen> {
  String _filter = 'all';
  bool _editMode = false;
  List<_SeatData>? _editSeats;
  Timer? _refreshTimer;

  static const _statuses = ['studying', 'onBreak', 'empty'];

  static const _filters = [
    ('all', '전체'),
    ('studying', '공부 중'),
    ('onBreak', '휴식'),
    ('notCheckedIn', '미입실'),
    ('empty', '빈 좌석'),
  ];

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_editMode && _editSeats != null && _editSeats!.isNotEmpty) {
        final rng = Random();
        final i = rng.nextInt(_editSeats!.length);
        setState(() {
          final seat = _editSeats![i];
          _editSeats![i] = _SeatData(
            id: seat.id,
            seatNo: seat.seatNo,
            status: _statuses[rng.nextInt(_statuses.length)],
            zone: seat.zone,
            assignedStudentName: seat.assignedStudentName,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seatsAsync = ref.watch(adminSeatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: seatsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('오류: $e', style: AppTypography.bodyMedium)),
          data: (seats) {
            // Initialize edit seats from provider data once
            _editSeats ??= seats.map(_SeatData.fromSeat).toList();
            return _buildContent(seats);
          },
        ),
      ),
    );
  }

  void _showAddSeatDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
        title: Text('좌석 추가', style: AppTypography.headlineSmall),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '좌석 번호 (예: D7)',
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('취소', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final seatNo = controller.text.trim();
              if (seatNo.isNotEmpty) {
                await ref.read(adminRepositoryProvider).createSeat(seatNo);
                ref.invalidate(adminSeatsProvider);
              }
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: Text(
              '추가',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(String seatId, String seatNo) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
        title: Text('좌석 삭제', style: AppTypography.headlineSmall),
        content: Text(
          '좌석 $seatNo를 삭제하시겠어요?',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('취소', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(adminRepositoryProvider).deleteSeat(seatId);
              ref.invalidate(adminSeatsProvider);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: Text(
              '삭제',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<Seat> allSeats) {
    final List<_SeatData> sourceSeats = _editMode
        ? _editSeats!
        : allSeats.map(_SeatData.fromSeat).toList();
    final List<_SeatData> filtered = _filter == 'all' || _editMode
        ? sourceSeats
        : sourceSeats.where((s) => s.status == _filter).toList();

    final studying = allSeats.where((s) => s.status == 'studying').length;
    final onBreak = allSeats.where((s) => s.status == 'onBreak').length;
    final notChecked = allSeats.where((s) => s.status == 'notCheckedIn').length;
    final empty = allSeats.where((s) => s.status == 'empty').length;

    return Column(
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
                      Text('좌석 현황', style: AppTypography.headlineLarge),
                      const SizedBox(height: 4),
                      Text(
                        '${allSeats.length}석 전체 현황',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  _editMode
                      ? Row(
                          children: [
                            StudyonButton(
                              label: '취소',
                              onPressed: () => setState(() {
                                _editMode = false;
                                _editSeats = allSeats.map(_SeatData.fromSeat).toList();
                              }),
                              variant: StudyonButtonVariant.secondary,
                              isExpanded: false,
                              isSmall: true,
                            ),
                            const SizedBox(width: 10),
                            StudyonButton(
                              label: '완료',
                              onPressed: () => setState(() => _editMode = false),
                              variant: StudyonButtonVariant.primary,
                              isExpanded: false,
                              isSmall: true,
                            ),
                          ],
                        )
                      : StudyonButton(
                          label: '편집',
                          onPressed: () => setState(() {
                            _editMode = true;
                            _editSeats = allSeats.map(_SeatData.fromSeat).toList();
                          }),
                          variant: StudyonButtonVariant.secondary,
                          icon: Icons.edit_rounded,
                          isExpanded: false,
                          isSmall: true,
                        ),
                ],
              ),
              const SizedBox(height: 20),
              _buildStatusSummary(studying, onBreak, notChecked, empty),
              const SizedBox(height: 20),
              if (!_editMode) _buildFilterRow(),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(message: '해당 상태의 좌석이 없습니다.', icon: Icons.event_seat_rounded)
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _editMode
                      ? _EditableSeatGrid(
                          seats: filtered,
                          onDelete: (id, seatNo) => _showDeleteConfirm(id, seatNo),
                          onAdd: _showAddSeatDialog,
                        )
                      : InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 2.0,
                          child: _SeatDetailGrid(seats: filtered.map((s) => s.toSeat()).toList()),
                        ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatusSummary(int studying, int onBreak, int notChecked, int empty) {
    return Row(
      children: [
        _SummaryChip(label: '공부 중', count: studying, color: AppColors.studying, bgColor: AppColors.tintPurple),
        const SizedBox(width: 10),
        _SummaryChip(label: '휴식', count: onBreak, color: AppColors.onBreak, bgColor: AppColors.tintOrange),
        const SizedBox(width: 10),
        _SummaryChip(label: '미입실', count: notChecked, color: AppColors.notCheckedIn, bgColor: AppColors.tintPink),
        const SizedBox(width: 10),
        _SummaryChip(label: '빈 좌석', count: empty, color: AppColors.textTertiary, bgColor: AppColors.background),
      ],
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((f) {
          final (value, label) = f;
          final isActive = _filter == value;
          return GestureDetector(
            onTap: () => setState(() => _filter = value),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.cardBorder,
                ),
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
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: bgColor == AppColors.background ? Border.all(color: AppColors.cardBorder) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: AppTypography.titleMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

void _showSeatInfoSheet(BuildContext context, Seat seat) {
  Color statusColor;
  switch (seat.status) {
    case 'studying':
      statusColor = AppColors.studying;
    case 'onBreak':
      statusColor = AppColors.onBreak;
    case 'notCheckedIn':
      statusColor = AppColors.notCheckedIn;
    default:
      statusColor = AppColors.empty;
  }

  String statusLabel;
  switch (seat.status) {
    case 'studying':
      statusLabel = '공부 중';
    case 'onBreak':
      statusLabel = '휴식';
    default:
      statusLabel = seat.status;
  }

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
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
          if (seat.status == 'studying' || seat.status == 'onBreak') ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${seat.assignedStudentName} 강제 퇴실 처리됨'),
                    backgroundColor: AppColors.hot,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.hot.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text('강제 퇴실', style: AppTypography.titleMedium.copyWith(color: AppColors.hot))),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _EditableSeatGrid extends StatelessWidget {
  const _EditableSeatGrid({
    required this.seats,
    required this.onDelete,
    required this.onAdd,
  });
  final List<_SeatData> seats;
  final void Function(String id, String seatNo) onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: seats.length + 1, // +1 for add button
      itemBuilder: (_, i) {
        if (i == seats.length) {
          // Add button
          return GestureDetector(
            onTap: onAdd,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Icon(Icons.add_rounded, size: 28, color: AppColors.primary),
              ),
            ),
          );
        }

        final seat = seats[i];
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    seat.seatNo,
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    seat.assignedStudentName ?? '빈 좌석',
                    style: AppTypography.bodySmall.copyWith(
                      color: seat.assignedStudentName != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onDelete(seat.id, seat.seatNo),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SeatDetailGrid extends StatelessWidget {
  const _SeatDetailGrid({required this.seats});
  final List<Seat> seats;

  Color _colorForStatus(String status) {
    switch (status) {
      case 'studying': return AppColors.studying;
      case 'onBreak': return AppColors.onBreak;
      case 'notCheckedIn': return AppColors.notCheckedIn;
      default: return AppColors.empty;
    }
  }

  String _labelForStatus(String status) {
    switch (status) {
      case 'studying': return '공부 중';
      case 'onBreak': return '휴식';
      case 'notCheckedIn': return '미입실';
      default: return '빈 좌석';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: seats.length,
      itemBuilder: (_, i) {
        final seat = seats[i];
        final color = _colorForStatus(seat.status);
        final hasStudent = seat.status == 'studying' || seat.status == 'onBreak';
        final card = Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    seat.seatNo,
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    seat.assignedStudentName ?? '—',
                    style: AppTypography.bodySmall.copyWith(
                      color: seat.assignedStudentName != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _labelForStatus(seat.status),
                    style: AppTypography.bodySmall.copyWith(color: color, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );

        if (hasStudent) {
          return GestureDetector(
            onTap: () => _showSeatInfoSheet(context, seat),
            child: card,
          );
        }
        return card;
      },
    );
  }
}
