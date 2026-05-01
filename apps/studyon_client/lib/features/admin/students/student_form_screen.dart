import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_models/studyon_models.dart';

import '../../../shared/providers/providers.dart';
import '../../../shared/utils/snackbar_helper.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  const StudentFormScreen({super.key, this.studentId});
  final String? studentId;

  bool get isEditing => studentId != null;

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _nameCtrl = TextEditingController();
  final _studentNoCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  String? _gradeId;
  String? _classId;
  String? _seat;
  bool _didLoad = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _studentNoCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _studentNoCtrl.text.trim().isEmpty) {
      showStudyonSnackbar(context, '이름과 학번을 입력해 주세요', isError: true);
      return;
    }
    final repo = ref.read(adminRepositoryProvider);
    if (widget.isEditing) {
      await repo.updateStudent(
        studentId: widget.studentId!,
        name: _nameCtrl.text.trim(),
        studentNo: _studentNoCtrl.text.trim(),
        gradeId: _gradeId,
        classId: _classId,
        assignedSeatId: _seat,
      );
    } else {
      await repo.createStudent(
        name: _nameCtrl.text.trim(),
        studentNo: _studentNoCtrl.text.trim(),
        gradeId: _gradeId,
        classId: _classId,
        assignedSeatId: _seat,
      );
    }
    ref.invalidate(adminStudentsProvider);
    if (widget.studentId != null) {
      ref.invalidate(studentDetailProvider(widget.studentId!));
    }
    if (!mounted) return;
    context.pop();
  }

  Widget _buildField({
    required String label,
    required Widget field,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    String Function(T)? labelBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          dropdownColor: AppColors.surface,
          items: items.map((item) {
            final label = labelBuilder != null ? labelBuilder(item) : item.toString();
            return DropdownMenuItem<T>(value: item, child: Text(label));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNullableDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
    String Function(String)? labelBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          dropdownColor: AppColors.surface,
          items: items.map((item) {
            final label = labelBuilder != null ? labelBuilder(item) : item;
            return DropdownMenuItem(value: item, child: Text(label));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(adminFormOptionsProvider);
    final AsyncValue<Student?> studentAsync = widget.isEditing
        ? ref.watch(studentDetailProvider(widget.studentId!)).whenData((student) => student)
        : const AsyncData<Student?>(null);
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final hPad = isIPad ? 32.0 : 24.0;

    return optionsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('오류: $e')),
      ),
      data: (options) {
        return studentAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
          error: (e, _) => Scaffold(
            body: Center(child: Text('오류: $e')),
          ),
          data: (student) {
            if (!_didLoad && student != null) {
              _nameCtrl.text = student.name;
              _studentNoCtrl.text = student.studentNo;
              _gradeId = student.gradeId;
              _classId = student.classId;
              _seat = student.assignedSeatId;
              _didLoad = true;
            }
            _gradeId ??= options.grades.isNotEmpty ? options.grades.first.id : null;
            _classId ??= options.classes.isNotEmpty ? options.classes.first.id : null;

            return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
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
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.isEditing ? '학생 정보 수정' : '학생 추가',
                    style: AppTypography.headlineLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Form
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                children: [
                  _buildField(
                    label: '이름',
                    field: _buildTextInput(controller: _nameCtrl, hint: '학생 이름'),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: '학번',
                    field: _buildTextInput(
                      controller: _studentNoCtrl,
                      hint: '학번 입력',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          label: '학년',
                          field: _buildDropdown<String>(
                            value: _gradeId!,
                            items: options.grades.map((item) => item.id).toList(),
                            labelBuilder: (id) => options.grades
                                .firstWhere((item) => item.id == id)
                                .name,
                            onChanged: (v) { if (v != null) setState(() => _gradeId = v); },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          label: '반',
                          field: _buildDropdown<String>(
                            value: _classId!,
                            items: options.classes.map((item) => item.id).toList(),
                            labelBuilder: (id) => options.classes
                                .firstWhere((item) => item.id == id)
                                .name,
                            onChanged: (v) { if (v != null) setState(() => _classId = v); },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: '좌석 배정',
                    field: _buildNullableDropdown(
                      value: _seat,
                      items: options.seats.map((item) => item.id).toList(),
                      hint: '좌석 선택 (선택)',
                      onChanged: (v) => setState(() => _seat = v),
                      labelBuilder: (id) => options.seats
                          .firstWhere((item) => item.id == id)
                          .name,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: '연락처 (선택)',
                    field: _buildTextInput(
                      controller: _contactCtrl,
                      hint: '연락처 입력',
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Buttons
                  StudyonButton(
                    label: widget.isEditing ? '수정 완료' : '저장',
                    onPressed: () => _save(),
                    variant: StudyonButtonVariant.primary,
                  ),
                  const SizedBox(height: 12),
                  StudyonButton(
                    label: '취소',
                    onPressed: () => context.pop(),
                    variant: StudyonButtonVariant.secondary,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
          },
        );
      },
    );
  }
}
