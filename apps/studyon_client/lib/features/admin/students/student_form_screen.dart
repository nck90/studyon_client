import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key, this.studentId});
  final String? studentId;

  bool get isEditing => studentId != null;

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _nameCtrl = TextEditingController();
  final _studentNoCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  String _grade = '고1';
  String _className = 'A반';
  String? _seat;

  static const _grades = ['고1', '고2', '고3'];
  static const _classes = ['A반', 'B반', 'C반'];
  static const _seatRows = ['A', 'B', 'C', 'D'];
  static const _seatCols = [1, 2, 3, 4, 5, 6];

  List<String> get _seats => [
    for (final row in _seatRows)
      for (final col in _seatCols) '$row$col',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _studentNoCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty || _studentNoCtrl.text.trim().isEmpty) return;
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
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final hPad = isIPad ? 32.0 : 24.0;

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
                            value: _grade,
                            items: _grades,
                            onChanged: (v) { if (v != null) setState(() => _grade = v); },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          label: '반',
                          field: _buildDropdown<String>(
                            value: _className,
                            items: _classes,
                            onChanged: (v) { if (v != null) setState(() => _className = v); },
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
                      items: _seats,
                      hint: '좌석 선택 (선택)',
                      onChanged: (v) => setState(() => _seat = v),
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
                    onPressed: _save,
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
  }
}
