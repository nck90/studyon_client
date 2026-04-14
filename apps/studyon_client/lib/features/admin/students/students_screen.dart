import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_models/studyon_models.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/utils/snackbar_helper.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  String _search = '';
  String _statusFilter = 'all';
  String _sortColumn = 'name';
  bool _sortAsc = true;
  final _searchCtrl = TextEditingController();

  bool _selectMode = false;
  final Set<String> _selected = {};

  static const _statusFilters = [
    ('all', '전체'),
    ('studying', '공부 중'),
    ('onBreak', '휴식'),
    ('notCheckedIn', '미입실'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showBulkMessageSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_selected.length}명에게 알림', style: AppTypography.headlineSmall),
            const SizedBox(height: 4),
            Text(
              '선택된 학생들에게 알림을 보냅니다',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '메시지 내용을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _selectMode = false;
                  _selected.clear();
                });
                showStudyonSnackbar(context, '알림이 전송되었어요');
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
                    '보내기',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(adminStudentsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: studentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('오류: $e', style: AppTypography.bodyMedium)),
          data: (students) => _buildContent(students),
        ),
      ),
    );
  }

  Widget _buildContent(List<Student> allStudents) {
    final filtered = allStudents.where((s) {
      final matchSearch = _search.isEmpty ||
          s.name.contains(_search) ||
          s.studentNo.contains(_search);
      final matchStatus = _statusFilter == 'all' || s.status == _statusFilter;
      return matchSearch && matchStatus;
    }).toList()
      ..sort((a, b) {
        int cmp;
        switch (_sortColumn) {
          case 'grade':
            cmp = (a.gradeName ?? '').compareTo(b.gradeName ?? '');
          case 'status':
            cmp = a.status.compareTo(b.status);
          default:
            cmp = a.name.compareTo(b.name);
        }
        return _sortAsc ? cmp : -cmp;
      });

    return Stack(
      children: [
        Column(
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
                          Text('학생 관리', style: AppTypography.headlineLarge),
                          const SizedBox(height: 4),
                          Text(
                            '총 ${allStudents.length}명',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              _selectMode = !_selectMode;
                              _selected.clear();
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectMode
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.card(context),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectMode
                                      ? AppColors.primary.withValues(alpha: 0.3)
                                      : AppColors.borderColor(context),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _selectMode ? Icons.close_rounded : Icons.send_rounded,
                                    size: 16,
                                    color: _selectMode ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectMode ? '취소' : '알림',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _selectMode ? AppColors.primary : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          StudyonButton(
                            label: '학생 추가',
                            onPressed: () => context.push('/admin/students/new'),
                            variant: StudyonButtonVariant.primary,
                            icon: Icons.add_rounded,
                            isExpanded: false,
                            isSmall: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildFilterRow(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyState(message: '검색 결과가 없어요', icon: Icons.people_rounded)
                  : _buildStudentTable(filtered),
            ),
            if (_selectMode) const SizedBox(height: 72),
          ],
        ),
        if (_selectMode && _selected.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.card(context),
              child: Row(
                children: [
                  Text('${_selected.length}명 선택', style: AppTypography.titleLarge),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showBulkMessageSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '알림 보내기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _search = v),
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: '이름 또는 학번으로 검색',
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
          suffixIcon: _search.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() => _search = '');
                  },
                  child: const Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 18),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: _statusFilters.map((f) {
        final (value, label) = f;
        final isActive = _statusFilter == value;
        return GestureDetector(
          onTap: () => setState(() => _statusFilter = value),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStudentTable(List<Student> students) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          const Divider(height: 1, color: AppColors.cardBorder),
          Expanded(
            child: ListView.separated(
              itemCount: students.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.cardBorder),
              itemBuilder: (_, i) {
                final student = students[i];
                return _StudentRow(
                  student: student,
                  selectMode: _selectMode,
                  isSelected: _selected.contains(student.id),
                  onSelect: () => setState(() {
                    if (_selected.contains(student.id)) {
                      _selected.remove(student.id);
                    } else {
                      _selected.add(student.id);
                    }
                  }),
                  onTap: _selectMode
                      ? () => setState(() {
                            if (_selected.contains(student.id)) {
                              _selected.remove(student.id);
                            } else {
                              _selected.add(student.id);
                            }
                          })
                      : () => context.go('/admin/students/${student.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(String column, String label, int flex) {
    final isActive = _sortColumn == column;
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => setState(() {
          if (_sortColumn == column) {
            _sortAsc = !_sortAsc;
          } else {
            _sortColumn = column;
            _sortAsc = true;
          }
        }),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 2),
              Icon(
                _sortAsc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 12,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Row(
        children: [
          if (_selectMode) const SizedBox(width: 36),
          _buildSortableHeader('name', '이름', 3),
          _buildSortableHeader('grade', '학년/반', 2),
          Expanded(
            flex: 2,
            child: Text('좌석', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
          ),
          _buildSortableHeader('status', '상태', 2),
          Expanded(
            flex: 2,
            child: Text('오늘 공부시간', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.student,
    required this.onTap,
    this.selectMode = false,
    this.isSelected = false,
    this.onSelect,
  });
  final Student student;
  final VoidCallback onTap;
  final bool selectMode;
  final bool isSelected;
  final VoidCallback? onSelect;

  Color _statusColor(String status) {
    switch (status) {
      case 'studying': return AppColors.studying;
      case 'onBreak': return AppColors.onBreak;
      case 'notCheckedIn': return AppColors.notCheckedIn;
      default: return AppColors.textTertiary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'studying': return '공부 중';
      case 'onBreak': return '휴식 중';
      case 'notCheckedIn': return '미입실';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(student.status);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            if (selectMode)
              GestureDetector(
                onTap: onSelect,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                    size: 22,
                    color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  ),
                ),
              ),
            // Name with avatar
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.tintPurple,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Center(
                      child: Text(
                        student.name.substring(0, 1),
                        style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: AppTypography.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          student.studentNo,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Grade/class
            Expanded(
              flex: 2,
              child: Text(
                '${student.gradeName ?? ''} ${student.className ?? ''}'.trim(),
                style: AppTypography.bodyMedium,
              ),
            ),
            // Seat
            Expanded(
              flex: 2,
              child: Text(
                student.assignedSeatNo ?? '—',
                style: AppTypography.bodyMedium.copyWith(
                  color: student.assignedSeatNo != null ? AppColors.textPrimary : AppColors.textTertiary,
                ),
              ),
            ),
            // Status badge
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    _statusLabel(student.status),
                    style: AppTypography.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            // Today's study hours (placeholder)
            Expanded(
              flex: 2,
              child: Text(
                '—',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
            ),
            // Detail arrow
            const SizedBox(
              width: 32,
              child: Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
