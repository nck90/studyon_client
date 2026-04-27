import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../../shared/providers/student_providers.dart';
import '../../../shared/utils/snackbar_helper.dart';

class StudyLogDraft {
  const StudyLogDraft({
    required this.subject,
    required this.pageCount,
    required this.problemCount,
    required this.goalCompleted,
    required this.memo,
  });

  final String subject;
  final int pageCount;
  final int problemCount;
  final bool goalCompleted;
  final String memo;
}

class StudyLogSheet extends ConsumerStatefulWidget {
  const StudyLogSheet({super.key, this.initialSubject});

  final String? initialSubject;

  static Future<StudyLogDraft?> show(
    BuildContext context, {
    String? initialSubject,
  }) {
    return showModalBottomSheet<StudyLogDraft>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudyLogSheet(initialSubject: initialSubject),
    );
  }

  @override
  ConsumerState<StudyLogSheet> createState() => _StudyLogSheetState();
}

class _StudyLogSheetState extends ConsumerState<StudyLogSheet> {
  late final Future<List<String>> _subjectsFuture;
  List<String> _subjects = const [];
  late String _selectedSubject;
  int _pageCount = 0;
  int _problemCount = 0;
  bool _goalCompleted = false;
  final TextEditingController _memoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subjectsFuture = ref.read(studentRepositoryProvider).getSubjects();
    _selectedSubject = widget.initialSubject ?? '';
    _bootstrapSubjects();
  }

  @override
  void dispose() {
    _memoCtrl.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      StudyLogDraft(
        subject: _selectedSubject,
        pageCount: _pageCount,
        problemCount: _problemCount,
        goalCompleted: _goalCompleted,
        memo: _memoCtrl.text.trim(),
      ),
    );
    showStudyonSnackbar(context, '학습 기록이 저장되었어요');
  }

  Future<void> _bootstrapSubjects() async {
    try {
      final subjects = await _subjectsFuture;
      if (!mounted) return;
      setState(() {
        _subjects = subjects.isEmpty ? const ['기타'] : subjects;
        _selectedSubject = _subjects.contains(widget.initialSubject)
            ? widget.initialSubject!
            : (_selectedSubject.isNotEmpty && _subjects.contains(_selectedSubject))
                ? _selectedSubject
                : _subjects.first;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _subjects = const ['기타'];
        _selectedSubject = widget.initialSubject?.trim().isNotEmpty == true
            ? widget.initialSubject!
            : '기타';
      });
      showStudyonSnackbar(context, '과목 목록을 불러오지 못해 직접 기록으로 저장할게요');
    }
  }

  Widget _buildStepper({
    required BuildContext context,
    required String label,
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSub(context)),
          ),
        ),
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.bg(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.remove_rounded,
                size: 18, color: AppColors.textSub(context)),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 48,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.text(context),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.bg(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.add_rounded,
                size: 18, color: AppColors.textSub(context)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Text('오늘 뭘 공부했나요?',
                style: AppTypography.headlineSmall
                    .copyWith(color: AppColors.text(context))),
            const SizedBox(height: 6),
            Text(
              '학습한 내용을 기록하면 성장을 추적할 수 있어요',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
            if (_subjects.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
            _buildStepper(
              context: context,
              label: '페이지 수',
              value: _pageCount,
              onDecrement: () {
                if (_pageCount > 0) setState(() => _pageCount--);
              },
              onIncrement: () => setState(() => _pageCount++),
            ),
            const SizedBox(height: 14),
            _buildStepper(
              context: context,
              label: '문제 수',
              value: _problemCount,
              onDecrement: () {
                if (_problemCount > 0) setState(() => _problemCount--);
              },
              onIncrement: () => setState(() => _problemCount++),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _goalCompleted = !_goalCompleted),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _goalCompleted
                      ? AppColors.tintMint
                      : AppColors.bg(context),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.inputRadius),
                  border: Border.all(
                    color: _goalCompleted
                        ? AppColors.accent
                        : AppColors.borderColor(context),
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _goalCompleted
                              ? AppColors.accent
                              : AppColors.borderColor(context),
                          width: 1.5,
                        ),
                        color: _goalCompleted
                            ? AppColors.accent
                            : Colors.transparent,
                      ),
                      child: _goalCompleted
                          ? const Icon(Icons.check_rounded,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        '목표 완료했어요',
                        style: AppTypography.titleMedium.copyWith(
                          color: _goalCompleted
                              ? AppColors.accent
                              : AppColors.text(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('메모 (선택)',
                style: AppTypography.labelLarge
                    .copyWith(color: AppColors.textSub(context))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bg(context),
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              ),
              child: TextField(
                controller: _memoCtrl,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.text(context)),
                decoration: InputDecoration(
                  hintText: '한 줄 메모를 남겨보세요',
                  hintStyle: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 28),
            StudyonButton(
              label: '저장',
              onPressed: _save,
              variant: StudyonButtonVariant.primary,
            ),
            ],
          ],
        ),
      ),
    );
  }
}
