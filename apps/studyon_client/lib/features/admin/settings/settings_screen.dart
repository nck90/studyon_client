import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/utils/snackbar_helper.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _academyNameCtrl = TextEditingController();
  final _openTimeCtrl = TextEditingController();
  final _closeTimeCtrl = TextEditingController();
  bool _autoCheckout = true;
  bool _notifications = true;
  bool _tvDisplay = true;
  bool _isEditing = false;
  bool _loaded = false;

  // 알림 규칙 state
  bool _alertNoCheckIn = true;
  bool _alertBreakOvertime = true;
  bool _alertCheckOut = true;

  @override
  void dispose() {
    _academyNameCtrl.dispose();
    _openTimeCtrl.dispose();
    _closeTimeCtrl.dispose();
    super.dispose();
  }

  void _loadSettings(AppSettings settings) {
    if (!_loaded) {
      _academyNameCtrl.text = settings.academyName;
      _openTimeCtrl.text = settings.openTime;
      _closeTimeCtrl.text = settings.closeTime;
      _autoCheckout = settings.autoCheckoutEnabled;
      _notifications = settings.notificationEnabled;
      _tvDisplay = settings.tvDisplayEnabled;
      _loaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('오류: $e', style: AppTypography.bodyMedium)),
          data: (settings) {
            _loadSettings(settings);
            return _buildContent();
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        _buildHeader(),
        const SizedBox(height: 28),
        _buildSection(
          title: '학원 정보',
          icon: Icons.school_rounded,
          children: [
            _buildTextField(
              controller: _academyNameCtrl,
              label: '학원명',
              hint: '학원 이름을 입력하세요',
              enabled: _isEditing,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: '운영 시간',
          icon: Icons.access_time_rounded,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTimeDisplayRow(
                    label: '시작 시간',
                    time: _openTimeCtrl.text.isNotEmpty ? _openTimeCtrl.text : '09:00',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeDisplayRow(
                    label: '종료 시간',
                    time: _closeTimeCtrl.text.isNotEmpty ? _closeTimeCtrl.text : '22:00',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: '자동화 설정',
          icon: Icons.auto_mode_rounded,
          children: [
            _buildToggleRow(
              label: '자동 퇴실',
              desc: '폐원 시간에 자동으로 퇴실 처리합니다',
              value: _autoCheckout,
              onChanged: _isEditing ? (v) => setState(() => _autoCheckout = v) : null,
            ),
            const Divider(height: 1, color: AppColors.divider),
            _buildToggleRow(
              label: '알림 발송',
              desc: '미입실, 지각 등 알림을 자동 발송합니다',
              value: _notifications,
              onChanged: _isEditing ? (v) => setState(() => _notifications = v) : null,
            ),
            const Divider(height: 1, color: AppColors.divider),
            _buildToggleRow(
              label: 'TV 화면 표시',
              desc: '자습실 TV에 실시간 현황을 표시합니다',
              value: _tvDisplay,
              onChanged: _isEditing ? (v) => setState(() => _tvDisplay = v) : null,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: '알림 규칙',
          icon: Icons.notifications_rounded,
          children: [
            _buildToggleWithValueRow(
              label: '미입실 알림',
              desc: '지정 시간까지 미입실 시 알림 발송',
              value: _alertNoCheckIn,
              displayValue: '09:30',
              onChanged: (v) => setState(() => _alertNoCheckIn = v),
            ),
            const Divider(height: 1, color: AppColors.divider),
            _buildToggleWithValueRow(
              label: '휴식 초과 알림',
              desc: '휴식 시간 초과 시 알림 발송',
              value: _alertBreakOvertime,
              displayValue: '15분',
              onChanged: (v) => setState(() => _alertBreakOvertime = v),
            ),
            const Divider(height: 1, color: AppColors.divider),
            _buildToggleWithValueRow(
              label: '퇴실 알림',
              desc: '지정 시간에 퇴실 알림 발송',
              value: _alertCheckOut,
              displayValue: '21:00',
              onChanged: (v) => setState(() => _alertCheckOut = v),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: '데이터',
          icon: Icons.storage_rounded,
          children: [
            _buildActionRow(
              label: 'CSV 내보내기',
              desc: '학생 및 출결 데이터를 CSV로 내보냅니다',
              icon: Icons.download_rounded,
              color: AppColors.primary,
              onTap: () => _exportCSV(context),
            ),
            const Divider(height: 1, color: AppColors.divider),
            _buildActionRow(
              label: '데이터 초기화',
              desc: '모든 데이터를 초기화합니다. 되돌릴 수 없습니다.',
              icon: Icons.delete_forever_rounded,
              color: AppColors.error,
              onTap: () => _showResetConfirm(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildAppInfo(),
        const SizedBox(height: 32),
        Center(
          child: Text('자습ON v1.0.0', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary.withValues(alpha: 0.5))),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _exportCSV(BuildContext context) {
    const csv = '이름,학번,학년,반,좌석,오늘 공부시간,출석률\n'
        '김민수,2401,고3,A반,A-12,192분,95%\n'
        '박지현,2402,고3,A반,A-4,210분,92%\n'
        '이서준,2403,고2,B반,A-3,168분,88%\n';
    Clipboard.setData(const ClipboardData(text: csv));
    showStudyonSnackbar(context, 'CSV가 클립보드에 복사되었어요');
  }

  void _showResetConfirm(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text('데이터를 초기화하시겠어요?', style: AppTypography.headlineSmall),
        content: Text(
          '모든 데이터가 삭제되며 복구할 수 없어요',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '취소',
              style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('데이터가 초기화되었어요', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text(
              '초기화',
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('설정', style: AppTypography.headlineLarge),
            const SizedBox(height: 4),
            Text('앱 및 학원 설정', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
          ],
        ),
        _isEditing
            ? Row(
                children: [
                  StudyonButton(
                    label: '취소',
                    onPressed: () => setState(() {
                      _isEditing = false;
                      _loaded = false;
                    }),
                    variant: StudyonButtonVariant.secondary,
                    isExpanded: false,
                    isSmall: true,
                  ),
                  const SizedBox(width: 10),
                  StudyonButton(
                    label: '저장',
                    onPressed: () => setState(() => _isEditing = false),
                    variant: StudyonButtonVariant.primary,
                    isExpanded: false,
                    isSmall: true,
                  ),
                ],
              )
            : StudyonButton(
                label: '편집',
                onPressed: () => setState(() => _isEditing = true),
                variant: StudyonButtonVariant.secondary,
                icon: Icons.edit_rounded,
                isExpanded: false,
                isSmall: true,
              ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(title, style: AppTypography.headlineSmall),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDisplayRow({required String label, required String time}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          ),
          child: Text(
            time,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
            filled: true,
            fillColor: enabled ? AppColors.background : AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String label,
    required String desc,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.titleMedium),
                const SizedBox(height: 2),
                Text(desc, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.tintPurple,
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.background,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleWithValueRow({
    required String label,
    required String desc,
    required bool value,
    required String displayValue,
    required void Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.titleMedium),
                const SizedBox(height: 2),
                Text(desc, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: value ? AppColors.tintPurple : AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              displayValue,
              style: AppTypography.labelSmall.copyWith(
                color: value ? AppColors.primary : AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.tintPurple,
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.background,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required String label,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.titleMedium.copyWith(color: color)),
                  Text(desc, style: AppTypography.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('앱 정보', style: AppTypography.headlineSmall),
          const SizedBox(height: 14),
          _buildInfoRow('버전', '1.0.0'),
          const Divider(height: 20, color: AppColors.divider),
          _buildInfoRow('빌드', '2024.04.14'),
          const Divider(height: 20, color: AppColors.divider),
          _buildInfoRow('개발', 'StudyON Team'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        Text(value, style: AppTypography.titleMedium.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }
}
