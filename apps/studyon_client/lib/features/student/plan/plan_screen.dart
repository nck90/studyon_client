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
  bool _isSaving = false;
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  bool _loadingDate = false;
  List<StudyPlanItem>? _datePlans;

  @override
  void initState() {
    super.initState();
    _loadDate(_selectedDate);
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = d.difference(today).inDays;
    final weekday = const ['월', '화', '수', '목', '금', '토', '일'][d.weekday - 1];
    final base = '${d.month}월 ${d.day}일 ($weekday)';
    if (diff == 0) return '오늘 · $base';
    if (diff == -1) return '어제 · $base';
    if (diff == 1) return '내일 · $base';
    return base;
  }

  String _toIso(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-${dd}T00:00:00.000Z';
  }

  Future<void> _loadDate(DateTime date) async {
    setState(() {
      _loadingDate = true;
      _datePlans = null;
    });
    try {
      if (_isToday) {
        await ref.read(studentProvider.notifier).hydrate();
        if (mounted) setState(() => _datePlans = null);
      } else {
        final iso = _toIso(date).split('T').first;
        final plans = await ref
            .read(studentRepositoryProvider)
            .getPlans(date: iso);
        if (mounted) setState(() => _datePlans = plans);
      }
    } catch (_) {
      if (mounted) setState(() => _datePlans = const []);
    } finally {
      if (mounted) setState(() => _loadingDate = false);
    }
  }

  void _shiftDate(int days) {
    final next = _selectedDate.add(Duration(days: days));
    setState(() => _selectedDate = next);
    _loadDate(next);
  }

  Future<void> _showAddSheet({StudyPlanItem? editing}) async {
    List<String> subjects;
    try {
      subjects = await ref.read(studentRepositoryProvider).getSubjects();
    } catch (_) {
      subjects = const ['기타'];
      if (mounted) {
        showStudyonSnackbar(context, '과목 목록을 불러오지 못해 기본 목록으로 열었어요');
      }
    }
    if (!mounted) return;
    final item = await showModalBottomSheet<StudyPlanItem>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanFormSheet(
        editing: editing,
        subjects: subjects,
      ),
    );

    if (!mounted || item == null) return;

    setState(() => _isSaving = true);
    try {
      if (editing != null) {
        await ref.read(studentProvider.notifier).updatePlan(item);
        if (mounted) showStudyonSnackbar(context, '계획이 수정되었어요');
      } else {
        await ref
            .read(studentProvider.notifier)
            .addPlan(item, planDate: _toIso(_selectedDate));
        if (mounted) showStudyonSnackbar(context, '계획이 추가되었어요');
      }
      await _loadDate(_selectedDate);
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
      await _loadDate(_selectedDate);
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
            targetMinutes: item.targetMinutes,
            priorityStars: item.priorityStars,
            progress: 0.0,
            planDate: item.planDate,
          ),
        );
      } else {
        await notifier.completePlan(item.id);
      }
      await _loadDate(_selectedDate);
    } catch (_) {
      if (mounted) {
        showStudyonSnackbar(context, '계획 상태를 바꾸지 못했어요', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Color _starColor(int stars) {
    if (stars >= 5) return AppColors.hot;
    if (stars >= 3) return AppColors.warm;
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final hPad = isIPad ? 32.0 : 20.0;
    final livePlans = ref.watch(studentProvider).plans;
    final plans = _isToday ? livePlans : (_datePlans ?? const <StudyPlanItem>[]);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
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
                            color: AppColors.card(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: 20,
                            color: AppColors.textSub(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '학습 계획',
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.text(context),
                          ),
                        ),
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
                const SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: _DateBar(
                    label: _dateLabel(_selectedDate),
                    onPrev: _loadingDate ? null : () => _shiftDate(-1),
                    onNext: _loadingDate ? null : () => _shiftDate(1),
                    onToday: _isToday
                        ? null
                        : () {
                            final now = DateTime.now();
                            final today =
                                DateTime(now.year, now.month, now.day);
                            setState(() => _selectedDate = today);
                            _loadDate(today);
                          },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _loadingDate
                      ? const Center(child: CircularProgressIndicator())
                      : (plans.isEmpty
                          ? _EmptyState(
                              isToday: _isToday,
                              isFuture: _selectedDate.isAfter(DateTime.now()),
                              onAdd: _isSaving ? null : () => _showAddSheet(),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
                              itemCount: plans.length,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(height: 12),
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
                                    child: const Icon(Icons.delete_rounded,
                                        color: AppColors.hot),
                                  ),
                                  onDismissed: (_) => _delete(item),
                                  child: _PlanCard(
                                    item: item,
                                    starColor: _starColor(item.priorityStars),
                                    onDelete:
                                        _isSaving ? null : () => _delete(item),
                                    onTap: _isSaving
                                        ? null
                                        : () => _showAddSheet(editing: item),
                                    onToggle:
                                        _isSaving ? null : () => _toggle(item),
                                  ),
                                );
                              },
                            )),
                ),
              ],
            ),
          ),
          if (_isSaving)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

class _DateBar extends StatelessWidget {
  const _DateBar({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  final String label;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor(context)),
      ),
      child: Row(
        children: [
          _NavBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
          Expanded(
            child: GestureDetector(
              onTap: onToday,
              child: Center(
                child: Text(
                  label,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.text(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          _NavBtn(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.bg(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null
              ? AppColors.textTertiary
              : AppColors.textSub(context),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.item,
    required this.starColor,
    required this.onDelete,
    required this.onTap,
    required this.onToggle,
  });

  final StudyPlanItem item;
  final Color starColor;
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
          color: AppColors.card(context),
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
                            : AppColors.borderColor(context),
                        width: 1.5,
                      ),
                      color: item.progress >= 1.0
                          ? AppColors.accent
                          : Colors.transparent,
                    ),
                    child: item.progress >= 1.0
                        ? const Icon(Icons.check_rounded,
                            size: 13, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.subjectTint(item.subject),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    item.subject,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.subjectColor(item.subject),
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
                          : AppColors.text(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.targetLabel,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSub(context),
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
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.hot),
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
                      backgroundColor: AppColors.bg(context),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(item.progress * 100).toInt()}%',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSub(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                _StarRow(stars: item.priorityStars, color: starColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.stars, required this.color});

  final int stars;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 14,
            color: filled ? color : AppColors.textTertiary,
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onAdd,
    required this.isToday,
    required this.isFuture,
  });

  final VoidCallback? onAdd;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final message = isToday
        ? '오늘의 학습 계획이 없어요'
        : (isFuture ? '아직 추가된 계획이 없어요' : '이 날에는 계획이 없었어요');
    return EmptyState(
      icon: Icons.flag_rounded,
      message: message,
      actionLabel: isFuture || isToday ? '계획 추가하기' : null,
      onAction: isFuture || isToday ? onAdd : null,
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
  late int _targetMinutes;
  late int _priorityStars;
  late final TextEditingController _detailCtrl;

  static const int _stepMinutes = 30;
  static const int _maxMinutes = 12 * 60;

  List<String> get _availableSubjects {
    final items =
        widget.subjects.where((item) => item.trim().isNotEmpty).toList();
    if (widget.editing != null && !items.contains(widget.editing!.subject)) {
      items.insert(0, widget.editing!.subject);
    }
    if (items.isEmpty) {
      items.add('기타');
    }
    return items;
  }

  @override
  void initState() {
    super.initState();
    final subjects = _availableSubjects;
    _subject = widget.editing?.subject ?? subjects.first;
    final minutes = widget.editing?.targetMinutes ?? 60;
    _targetMinutes = ((minutes / _stepMinutes).round() * _stepMinutes)
        .clamp(_stepMinutes, _maxMinutes);
    _priorityStars = widget.editing?.priorityStars ?? 3;
    _detailCtrl = TextEditingController(text: widget.editing?.detail ?? '');
  }

  @override
  void dispose() {
    _detailCtrl.dispose();
    super.dispose();
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}분';
    if (m == 0) return '${h}시간';
    return '${h}시간 ${m}분';
  }

  void _save() {
    if (_detailCtrl.text.trim().isEmpty) return;
    Navigator.of(context).pop(
      StudyPlanItem(
        id: widget.editing?.id ?? '',
        subject: _subject,
        detail: _detailCtrl.text.trim(),
        targetMinutes: _targetMinutes,
        priorityStars: _priorityStars,
        progress: widget.editing?.progress ?? 0.0,
        planDate: widget.editing?.planDate ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = _availableSubjects;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(28),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.editing != null ? '계획 수정' : '계획 추가',
              style: AppTypography.headlineSmall
                  .copyWith(color: AppColors.text(context)),
            ),
            const SizedBox(height: 24),
            Text('과목',
                style: AppTypography.labelLarge
                    .copyWith(color: AppColors.textSub(context))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bg(context),
                borderRadius:
                    BorderRadius.circular(AppSpacing.inputRadius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _subject,
                  isExpanded: true,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.text(context)),
                  dropdownColor: AppColors.card(context),
                  items: subjects
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _subject = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('내용',
                style: AppTypography.labelLarge
                    .copyWith(color: AppColors.textSub(context))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bg(context),
                borderRadius:
                    BorderRadius.circular(AppSpacing.inputRadius),
              ),
              child: TextField(
                controller: _detailCtrl,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.text(context)),
                decoration: InputDecoration(
                  hintText: '학습 내용을 입력하세요',
                  hintStyle: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('목표 시간',
                    style: AppTypography.labelLarge
                        .copyWith(color: AppColors.textSub(context))),
                const Spacer(),
                Text('30분 단위',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.textTertiary)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bg(context),
                borderRadius:
                    BorderRadius.circular(AppSpacing.inputRadius),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_targetMinutes > _stepMinutes) {
                        setState(() => _targetMinutes -= _stepMinutes);
                      }
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppColors.borderColor(context)),
                      ),
                      child: Icon(Icons.remove_rounded,
                          size: 18, color: AppColors.textSub(context)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _formatMinutes(_targetMinutes),
                      textAlign: TextAlign.center,
                      style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.text(context)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_targetMinutes < _maxMinutes) {
                        setState(() => _targetMinutes += _stepMinutes);
                      }
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.card(context),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppColors.borderColor(context)),
                      ),
                      child: Icon(Icons.add_rounded,
                          size: 18, color: AppColors.textSub(context)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final mins = (i + 1) * _stepMinutes;
                  final selected = mins == _targetMinutes;
                  return GestureDetector(
                    onTap: () => setState(() => _targetMinutes = mins),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.tintPurple
                            : AppColors.bg(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _formatMinutes(mins),
                          style: AppTypography.labelSmall.copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSub(context),
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('우선순위',
                    style: AppTypography.labelLarge
                        .copyWith(color: AppColors.textSub(context))),
                const Spacer(),
                Text('별이 많을수록 우선',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.textTertiary)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bg(context),
                borderRadius:
                    BorderRadius.circular(AppSpacing.inputRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  final stars = i + 1;
                  final filled = stars <= _priorityStars;
                  return GestureDetector(
                    onTap: () => setState(() => _priorityStars = stars),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 32,
                        color: filled
                            ? (_priorityStars >= 4
                                ? AppColors.hot
                                : (_priorityStars == 3
                                    ? AppColors.warm
                                    : AppColors.accent))
                            : AppColors.textTertiary,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 28),
            StudyonButton(
              label: widget.editing != null ? '수정하기' : '저장',
              onPressed: _save,
              variant: StudyonButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}
