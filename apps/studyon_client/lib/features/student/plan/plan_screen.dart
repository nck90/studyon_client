import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import '../../../shared/utils/snackbar_helper.dart';

class _PlanItem {
  final String id;
  String subject;
  String detail;
  int targetHours;
  String priority;
  double progress;
  _PlanItem({
    String? id,
    required this.subject,
    required this.detail,
    required this.targetHours,
    this.priority = '보통',
    this.progress = 0.0,
  }) : id = id ?? '${DateTime.now().microsecondsSinceEpoch}_${subject}_$detail';
}

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final List<_PlanItem> _plans = [
    _PlanItem(subject: '수학', detail: '수1 3단원 문제풀이', targetHours: 3, priority: '높음', progress: 0.74),
    _PlanItem(subject: '영어', detail: '수능 기출 독해 20문제', targetHours: 2, priority: '보통', progress: 0.40),
  ];

  static const _subjects = ['수학', '영어', '국어', '과학', '사회', '기타'];

  void _showAddSheet({_PlanItem? editing, int? editIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanFormSheet(
        editing: editing,
        subjects: _subjects,
        onSave: (item) {
          setState(() {
            if (editIndex != null) {
              _plans[editIndex] = item;
            } else {
              _plans.add(item);
            }
          });
          showStudyonSnackbar(
            context,
            editIndex != null ? '계획이 수정되었어요' : '계획이 추가되었어요',
          );
        },
      ),
    );
  }

  void _delete(int index) {
    setState(() => _plans.removeAt(index));
    showStudyonSnackbar(context, '계획이 삭제되었어요', isSuccess: false);
  }

  Color _priorityColor(String p) {
    switch (p) {
      case '높음': return AppColors.hot;
      case '낮음': return AppColors.accent;
      default: return AppColors.warm;
    }
  }

  static Color subjectBadgeColor(String subject) {
    switch (subject) {
      case '수학': return AppColors.tintPurple;
      case '영어': return AppColors.tintMint;
      case '과학': return AppColors.tintYellow;
      case '국어': return AppColors.tintCoral;
      default: return AppColors.background;
    }
  }

  static Color subjectTextColor(String subject) {
    switch (subject) {
      case '수학': return AppColors.primary;
      case '영어': return AppColors.accent;
      case '과학': return AppColors.warm;
      case '국어': return AppColors.hot;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final hPad = isIPad ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text('오늘의 학습 계획', style: AppTypography.headlineLarge),
                  ),
                  StudyonButton(
                    label: '추가',
                    onPressed: () => _showAddSheet(),
                    variant: StudyonButtonVariant.primary,
                    icon: Icons.add_rounded,
                    isExpanded: false,
                    isSmall: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Plan list or empty state
            Expanded(
              child: _plans.isEmpty
                  ? _EmptyState(onAdd: () => _showAddSheet())
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
                      itemCount: _plans.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final item = _plans[i];
                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.hot.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.delete_rounded, color: AppColors.hot),
                          ),
                          onDismissed: (_) => _delete(i),
                          child: _PlanCard(
                            item: item,
                            priorityColor: _priorityColor(item.priority),
                            onDelete: () => _delete(i),
                            onTap: () => _showAddSheet(editing: item, editIndex: i),
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

// ─────────────────────────────────────────────
// Plan Card
// ─────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.item,
    required this.priorityColor,
    required this.onDelete,
    required this.onTap,
  });
  final _PlanItem item;
  final Color priorityColor;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: subject badge + detail + hours + delete
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _PlanScreenState.subjectBadgeColor(item.subject),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    item.subject,
                    style: AppTypography.labelSmall.copyWith(
                      color: _PlanScreenState.subjectTextColor(item.subject),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.detail,
                    style: AppTypography.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.targetHours}시간',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onDelete,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.tintCoral,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.close_rounded, size: 16, color: AppColors.hot),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress row
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 8,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(item.progress * 100).toInt()}%',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    item.priority,
                    style: AppTypography.labelSmall.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.flag_rounded,
      message: '오늘의 학습 계획이 없어요',
      actionLabel: '계획 추가하기',
      onAction: onAdd,
    );
  }
}

// ─────────────────────────────────────────────
// Plan Form Bottom Sheet
// ─────────────────────────────────────────────
class _PlanFormSheet extends StatefulWidget {
  const _PlanFormSheet({
    required this.subjects,
    required this.onSave,
    this.editing,
  });
  final List<String> subjects;
  final _PlanItem? editing;
  final void Function(_PlanItem) onSave;

  @override
  State<_PlanFormSheet> createState() => _PlanFormSheetState();
}

class _PlanFormSheetState extends State<_PlanFormSheet> {
  late String _subject;
  late String _detail;
  late int _targetHours;
  late String _priority;
  late final TextEditingController _detailCtrl;

  @override
  void initState() {
    super.initState();
    _subject = widget.editing?.subject ?? widget.subjects.first;
    _detail = widget.editing?.detail ?? '';
    _targetHours = widget.editing?.targetHours ?? 1;
    _priority = widget.editing?.priority ?? '보통';
    _detailCtrl = TextEditingController(text: _detail);
  }

  @override
  void dispose() {
    _detailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_detailCtrl.text.trim().isEmpty) return;
    final item = _PlanItem(
      subject: _subject,
      detail: _detailCtrl.text.trim(),
      targetHours: _targetHours,
      priority: _priority,
      progress: widget.editing?.progress ?? 0.0,
    );
    widget.onSave(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.editing != null ? '계획 수정' : '계획 추가',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Subject dropdown
          Text('과목', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _subject,
                isExpanded: true,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                dropdownColor: AppColors.surface,
                items: widget.subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _subject = v!),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Detail input
          Text('내용', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            ),
            child: TextField(
              controller: _detailCtrl,
              onChanged: (v) => _detail = v,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '학습 내용을 입력하세요',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Target hours stepper
          Text('목표 시간', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_targetHours > 1) setState(() => _targetHours--);
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Icon(Icons.remove_rounded, size: 18, color: AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  child: Text(
                    '$_targetHours시간',
                    textAlign: TextAlign.center,
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_targetHours < 8) setState(() => _targetHours++);
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Icon(Icons.add_rounded, size: 18, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Priority selector
          Text('우선순위', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: ['높음', '보통', '낮음'].map((p) {
              final isSelected = _priority == p;
              Color pillColor;
              switch (p) {
                case '높음': pillColor = AppColors.hot; break;
                case '낮음': pillColor = AppColors.accent; break;
                default: pillColor = AppColors.warm;
              }
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: Container(
                    margin: EdgeInsets.only(right: p != '낮음' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? pillColor.withValues(alpha: 0.15) : AppColors.background,
                      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                      border: Border.all(
                        color: isSelected ? pillColor : AppColors.cardBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      p,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected ? pillColor : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Save button
          StudyonButton(
            label: widget.editing != null ? '수정 완료' : '저장',
            onPressed: _save,
            variant: StudyonButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}
