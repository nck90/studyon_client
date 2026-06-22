import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../../shared/providers/student_providers.dart';
import '../../../shared/services/focus_mode_service.dart';
import '../../../shared/utils/snackbar_helper.dart';
import '../character/character_avatar.dart';

class MotivationSettingsScreen extends ConsumerStatefulWidget {
  const MotivationSettingsScreen({super.key});

  @override
  ConsumerState<MotivationSettingsScreen> createState() =>
      _MotivationSettingsScreenState();
}

class _MotivationSettingsScreenState
    extends ConsumerState<MotivationSettingsScreen> {
  late final TextEditingController _universityCtrl;
  final _focusMode = FocusModeService();
  FocusModeCapability? _capability;
  String? _targetImagePath;
  String? _homeBackgroundPath;
  String? _checkInBackgroundPath;
  late String _themePreset;
  late bool _tvGoalConsent;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _universityCtrl = TextEditingController(
      text: ref.read(studentProvider).targetUniversityName,
    );
    _themePreset = ref.read(studentProvider).themePreset;
    _tvGoalConsent = ref.read(studentProvider).tvGoalConsent;
    _loadCapability();
  }

  Future<void> _loadCapability() async {
    final capability = await _focusMode.getCapability();
    if (mounted) setState(() => _capability = capability);
  }

  Future<void> _pickTarget() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1400,
    );
    if (picked != null) setState(() => _targetImagePath = picked.path);
  }

  Future<void> _pickHomeBackground() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 2200,
    );
    if (picked != null) setState(() => _homeBackgroundPath = picked.path);
  }

  Future<void> _pickCheckInBackground() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 2200,
    );
    if (picked != null) setState(() => _checkInBackgroundPath = picked.path);
  }

  Future<void> _save({bool? focusModeEnabled}) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(studentProvider.notifier)
          .updateMotivationPreferences(
            targetUniversityName: _universityCtrl.text.trim(),
            targetUniversityImagePath: _targetImagePath,
            homeBackgroundImagePath: _homeBackgroundPath,
            checkInBackgroundImagePath: _checkInBackgroundPath,
            themePreset: _themePreset,
            focusModeEnabled: focusModeEnabled,
            tvGoalConsent: _tvGoalConsent,
          );
      if (!mounted) return;
      setState(() {
        _targetImagePath = null;
        _homeBackgroundPath = null;
        _checkInBackgroundPath = null;
      });
      showStudyonSnackbar(context, '동기부여 설정을 저장했어요');
    } catch (_) {
      if (mounted) {
        showStudyonSnackbar(context, '설정을 저장하지 못했어요', isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _universityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final pad = MediaQuery.of(context).size.shortestSide >= 600 ? 32.0 : 20.0;
    final capability = _capability;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(pad, 20, pad, 100),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 8),
                Text('동기부여 설정', style: AppTypography.headlineLarge),
              ],
            ),
            const SizedBox(height: 24),
            _Section(
              title: '목표 대학',
              child: Column(
                children: [
                  TextField(
                    controller: _universityCtrl,
                    decoration: const InputDecoration(
                      labelText: '대학명',
                      hintText: '예: 서울대학교',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PickerRow(
                    icon: Icons.school_rounded,
                    title: '로고/사진',
                    value: _targetImagePath == null
                        ? (student.targetUniversityMediaUrl.isEmpty
                              ? '미설정'
                              : '등록됨')
                        : '새 이미지 선택됨',
                    onTap: _pickTarget,
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _tvGoalConsent,
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _tvGoalConsent = value),
                    title: const Text('TV 목표 월 노출 동의'),
                    subtitle: Text(
                      student.tvGoalApprovalStatus == 'APPROVED'
                          ? '관리자 승인 완료'
                          : _tvGoalConsent
                          ? '저장 후 관리자 승인 대기'
                          : 'TV에는 내 목표가 표시되지 않아요',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: '배경',
              child: Column(
                children: [
                  _PickerRow(
                    icon: Icons.home_rounded,
                    title: '홈 배경',
                    value: _homeBackgroundPath == null
                        ? (student.homeBackgroundMediaUrl.isEmpty
                              ? '기본'
                              : '등록됨')
                        : '새 이미지 선택됨',
                    onTap: _pickHomeBackground,
                  ),
                  const Divider(height: 1),
                  _PickerRow(
                    icon: Icons.lock_rounded,
                    title: '입실 화면 배경',
                    value: _checkInBackgroundPath == null
                        ? (student.checkInBackgroundMediaUrl.isEmpty
                              ? '기본'
                              : '등록됨')
                        : '새 이미지 선택됨',
                    onTap: _pickCheckInBackground,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: '테마',
              child: _ThemePresetPicker(
                value: _themePreset,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _themePreset = value),
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: '집중모드',
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: student.focusModeEnabled,
                    onChanged: _saving
                        ? null
                        : (value) async {
                            if (value) {
                              await _focusMode.requestPermission();
                              await _loadCapability();
                            }
                            await _save(focusModeEnabled: value);
                          },
                    title: const Text('집중 복귀 알림'),
                    subtitle: Text(
                      capability == null ? '기기 지원 상태 확인 중' : capability.reason,
                    ),
                  ),
                  if (capability != null && !capability.canHardBlock)
                    Text(
                      'iOS에서는 강제 차단 대신 공부 중 이탈을 기록하고 복귀 알림을 보내는 심사안전형 소프트락으로 동작합니다.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            StudyonButton(
              label: _saving ? '저장 중' : '저장',
              onPressed: _saving ? null : () => _save(),
              variant: StudyonButtonVariant.primary,
              icon: Icons.save_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption {
  const _ThemeOption(this.value, this.label, this.color, this.icon);

  final String value;
  final String label;
  final Color color;
  final IconData icon;
}

const _themeOptions = [
  _ThemeOption('default', '기본', AppColors.primary, Icons.auto_awesome_rounded),
  _ThemeOption('mint', '민트', AppColors.accent, Icons.spa_rounded),
  _ThemeOption('sky', '스카이', Color(0xFF0984E3), Icons.cloud_rounded),
  _ThemeOption(
    'coral',
    '코랄',
    AppColors.hot,
    Icons.local_fire_department_rounded,
  ),
  _ThemeOption('night', '나이트', Color(0xFF4C6FFF), Icons.dark_mode_rounded),
];

class _ThemePresetPicker extends StatelessWidget {
  const _ThemePresetPicker({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _themeOptions.map((option) {
        final selected = option.value == value;
        return Semantics(
          selected: selected,
          button: true,
          label: '${option.label} 테마',
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onChanged == null ? null : () => onChanged!(option.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 108,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? option.color.withValues(alpha: 0.12)
                    : AppColors.bg(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? option.color : AppColors.cardBorder,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 88,
                      height: 58,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          RpgThemePreview(preset: option.value),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: option.color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    option.label,
                    style: AppTypography.labelLarge.copyWith(
                      color: selected ? option.color : AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.photo_library_outlined),
      onTap: onTap,
    );
  }
}
