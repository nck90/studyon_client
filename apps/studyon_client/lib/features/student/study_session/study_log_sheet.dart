import 'package:flutter/material.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

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

class StudyLogSheet extends StatefulWidget {
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
  State<StudyLogSheet> createState() => _StudyLogSheetState();
}

class _StudyLogSheetState extends State<StudyLogSheet> {
  static const _subjects = ['수학', '영어', '국어', '과학', '사회', '기타'];

  late String _selectedSubject;
  int _pageCount = 0;
  int _problemCount = 0;
  bool _goalCompleted = false;
  final TextEditingController _memoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSubject = _subjects.contains(widget.initialSubject)
        ? widget.initialSubject!
        : _subjects.first;
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

  Widget _buildStepper({
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
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.remove_rounded, size: 18, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 48,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add_rounded, size: 18, color: AppColors.textSecondary),
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
        color: AppColors.surface,
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
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('오늘 뭘 공부했나요?', style: AppTypography.headlineSmall),
            const SizedBox(height: 6),
            Text(
              '학습한 내용을 기록하면 성장을 추적할 수 있어요',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
            Text('과목', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _subjects.map((subject) {
                final isSelected = _selectedSubject == subject;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSubject = subject),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.tintPurple : AppColors.background,
                      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      subject,
                      style: AppTypography.labelLarge.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _buildStepper(
              label: '페이지 수',
              value: _pageCount,
              onDecrement: () {
                if (_pageCount > 0) setState(() => _pageCount--);
              },
              onIncrement: () => setState(() => _pageCount++),
            ),
            const SizedBox(height: 14),
            _buildStepper(
              label: '문제 수',
              value: _problemCount,
              onDecrement: () {
                if (_problemCount > 0) setState(() => _problemCount--);
              },
              onIncrement: () => setState(() => _problemCount++),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _goalCompleted ? AppColors.tintMint : AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                border: Border.all(
                  color: _goalCompleted ? AppColors.accent : AppColors.cardBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: _goalCompleted ? AppColors.accent : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '목표 완료했어요',
                      style: AppTypography.titleMedium.copyWith(
                        color: _goalCompleted ? AppColors.accent : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Switch(
                    value: _goalCompleted,
                    onChanged: (value) => setState(() => _goalCompleted = value),
                    activeThumbColor: AppColors.accent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('메모 (선택)', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              ),
              child: TextField(
                controller: _memoCtrl,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '한 줄 메모를 남겨보세요',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        ),
      ),
    );
  }
}
