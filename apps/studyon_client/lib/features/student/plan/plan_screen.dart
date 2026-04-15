import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../../shared/providers/student_providers.dart';
import '../../../shared/utils/snackbar_helper.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  static const _subjects = ['수학', '영어', '국어', '과학', '사회', '기타'];
  bool _isSaving = false;

  Future<void> _showAddSheet({StudyPlanItem? editing}) async {
    final item = await showModalBottomSheet<StudyPlanItem>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanFormSheet(
        editing: editing,
        subjects: _subjects,
      ),
    );

    if (!mounted || item == null) return;

    setState(() => _isSaving = true);
    try {
      if (editing != null) {
        await ref.read(studentProvider.notifier).updatePlan(item);
        if (mounted) showStudyonSnackbar(context, '계획이 수정되었어요');
      } else {
        await ref.read(studentProvider.notifier).addPlan(item);
        if (mounted) showStudyonSnackbar(context, '계획이 추가되었어요');
      }
    } catch (error) {
      if (mounted) {
        showStudyonSnackbar(context, '계획 저장에 실패했어요', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete(StudyPlanItem item) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(studentProvider.notifier).removePlan(item.id);
      if (mounted) {
        showStudyonSnackbar(context, '계획이 삭제되었어요', isError: true);
      }
    } catch (_) {
      if (mounted) {
        showStudyonSnackbar(context, '계획 삭제에 실패했어요', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggle(StudyPlanItem item) async {
    setState(() => _isSaving = true);
    try {
      final notifier = ref.read(studentProvider.notifier);
      if (item.progress >= 1.0) {
        await notifier.updatePlan(
          StudyPlanItem(
            id: item.id,
            subject: item.subject,
            detail: item.detail,
            targetHours: item.targetHours,
            priority: item.priority,
            progress: 0.0,
          ),
        );
      } else {
        await notifier.completePlan(item.id);
      }
    } catch (_) {
      if (mounted) {
        showStudyonSnackbar(context, '계획 상태를 바꾸지 못했어요', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case '높음':
        return AppColors.hot;
      case '낮음':
        return AppColors.accent;
      default:
        return AppColors.warm;
    }
  }

  static Color subjectBadgeColor(String subject) {
    switch (subject) {
      case '수학':
        return AppColors.tintPurple;
      case '영어':
        return AppColors.tintMint;
      case '과학':
        return AppColors.tintYellow;
      case '국어':
        return AppColors.tintCoral;
      default:
        return AppColors.background;
    }
  }

  static Color subjectTextColor(String subject) {
    switch (subject) {
      case '수학':
        return AppColors.primary;
      case '영어':
        return AppColors.accent;
      case '과학':
        return AppColors.warm;
      case '국어':
        return AppColors.hot;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final hPad = isIPad ? 32.0 : 20.0;
    final plans = ref.watch(studentProvider).plans;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text('오늘의 학습 계획', style: AppTypography.headlineLarge),
                      ),
                      StudyonButton(
                        label: '추가',
                        onPressed: _isSaving ? null : () => _showAddSheet(),
                        variant: StudyonButtonVariant.primary,
                        icon: Icons.add_rounded,
                        isExpanded: false,
                        isSmall: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: plans.isEmpty
                      ? _EmptyState(onAdd: _isSaving ? null : () => _showAddSheet())
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
                          itemCount: plans.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final item = plans[i];
                            return Dismissible(
                              key: Key(item.id),
                              direction: _isSaving
                                  ? DismissDirection.none
                                  : DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.hot.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete_rounded, color: AppColors.hot),
                              ),
                              onDismissed: (_) => _delete(item),
                              child: _PlanCard(
                                item: item,
                                priorityColor: _priorityColor(item.priority),
                                onDelete: _isSaving ? null : () => _delete(item),
                                onTap: _isSaving ? null : () => _showAddSheet(editing: item),
                                onToggle: _isSaving ? null : () => _toggle(item),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          if (_isSaving)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.item,
    required this.priorityColor,
    required this.onDelete,
    required this.onTap,
    required this.onToggle,
  });

  final StudyPlanItem item;
  final Color priorityColor;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: item.progress >= 1.0
                            ? AppColors.accent
                            : AppColors.cardBorder,
                        width: 1.5,
                      ),
                      color: item.progress >= 1.0
                          ? AppColors.accent
                          : Colors.transparent,
                    ),
                    child: item.progress >= 1.0
                        ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
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
                    style: AppTypography.titleMedium.copyWith(
                      decoration: item.progress >= 1.0
                          ? TextDecoration.lineThrough
                          : null,
                      color: item.progress >= 1.0
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    ),
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
                    child: const Icon(Icons.close_rounded, size: 16, color: AppColors.hot),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: item.progress,
                      minHeight: 8,
                      backgroundColor: AppColors.background,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback? onAdd;

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

class _PlanFormSheet extends StatefulWidget {
  const _PlanFormSheet({
    required this.subjects,
    this.editing,
  });

  final List<String> subjects;
  final StudyPlanItem? editing;

  @override
  State<_PlanFormSheet> createState() => _PlanFormSheetState();
}

class _PlanFormSheetState extends State<_PlanFormSheet> {
  late String _subject;
  late int _targetHours;
  late String _priority;
  late final TextEditingController _detailCtrl;

  @override
  void initState() {
    super.initState();
    _subject = widget.editing?.subject ?? widget.subjects.first;
    _targetHours = widget.editing?.targetHours ?? 1;
    _priority = widget.editing?.priority ?? '보통';
    _detailCtrl = TextEditingController(text: widget.editing?.detail ?? '');
  }

  @override
  void dispose() {
    _detailCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_detailCtrl.text.trim().isEmpty) return;
    Navigator.of(context).pop(
      StudyPlanItem(
        id: widget.editing?.id ?? '',
        subject: _subject,
        detail: _detailCtrl.text.trim(),
        targetHours: _targetHours,
        priority: _priority,
        progress: widget.editing?.progress ?? 0.0,
      ),
    );
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
                items: widget.subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _subject = v!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('내용', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            ),
            child: TextField(
              controller: _detailCtrl,
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
                  onTap: () => setState(() => _targetHours++),
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
          Text('우선순위', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['높음', '보통', '낮음'].map((priority) {
              final isSelected = _priority == priority;
              return GestureDetector(
                onTap: () => setState(() => _priority = priority),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.tintPurple : AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    priority,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          StudyonButton(
            label: widget.editing != null ? '수정하기' : '저장',
            onPressed: _save,
            variant: StudyonButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}
