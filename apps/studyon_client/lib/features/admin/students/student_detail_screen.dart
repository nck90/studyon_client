import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_models/studyon_models.dart';
import '../../../shared/providers/providers.dart';
import '../../../shared/utils/snackbar_helper.dart';

class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({super.key, required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(adminStudentDetailProvider(studentId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: studentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('오류: $e', style: AppTypography.bodyMedium)),
          data: (detail) => _buildContent(context, ref, detail),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, AdminStudentDetail detail) {
    final student = detail.student;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        return Column(
          children: [
            // Header always full-width
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
              child: _buildHeader(context, ref, student),
            ),
            const Divider(height: 1, color: AppColors.cardBorder),
            Expanded(
              child: isWide
                  ? _buildWideLayout(detail)
                  : _buildNarrowLayout(detail),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, Student student) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.go('/admin/students'),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(student.name, style: AppTypography.headlineLarge),
            Text(
              '학번 ${student.studentNo}',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
        const Spacer(),
        StudyonButton(
          label: '정보 수정',
          onPressed: () => context.push('/admin/students/$studentId/edit'),
          variant: StudyonButtonVariant.secondary,
          isExpanded: false,
          isSmall: true,
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _showMessageSheet(context, ref, student.name),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.send_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  '메시지',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _DeleteButton(studentId: studentId, studentName: student.name, ref: ref),
      ],
    );
  }

  // 2-column layout for wide screens (iPad)
  Widget _buildWideLayout(AdminStudentDetail detail) {
    final student = detail.student;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: profile + stats + settings placeholder
        Expanded(
          flex: 5,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 24, 14, 28),
            children: [
              _buildProfileCard(student),
              const SizedBox(height: 20),
              _buildStatsRow(detail),
              const SizedBox(height: 24),
              Text('설정', style: AppTypography.headlineSmall),
              const SizedBox(height: 12),
              _buildSettingsCard(student),
            ],
          ),
        ),
        // Right column: weekly chart + subject distribution + activity log
        Expanded(
          flex: 6,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 24, 28, 28),
            children: [
              Text('이번 주 공부 현황', style: AppTypography.headlineSmall),
              const SizedBox(height: 12),
              _buildWeeklyChart(detail),
              const SizedBox(height: 24),
              _buildSubjectDistribution(detail),
              const SizedBox(height: 24),
              Text('최근 활동 로그', style: AppTypography.headlineSmall),
              const SizedBox(height: 12),
              _buildActivityLog(detail),
            ],
          ),
        ),
      ],
    );
  }

  // Single-column layout for narrow screens
  Widget _buildNarrowLayout(AdminStudentDetail detail) {
    final student = detail.student;
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        _buildProfileCard(student),
        const SizedBox(height: 20),
        _buildStatsRow(detail),
        const SizedBox(height: 24),
        Text('최근 활동 로그', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        _buildActivityLog(detail),
        const SizedBox(height: 24),
        Text('이번 주 공부 현황', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        _buildWeeklyChart(detail),
        const SizedBox(height: 24),
        _buildSubjectDistribution(detail),
      ],
    );
  }

  Widget _buildProfileCard(Student student) {
    Color statusColor;
    String statusLabel;
    switch (student.status) {
      case 'studying':
        statusColor = AppColors.studying;
        statusLabel = '공부 중';
      case 'onBreak':
        statusColor = AppColors.onBreak;
        statusLabel = '휴식 중';
      case 'notCheckedIn':
        statusColor = AppColors.notCheckedIn;
        statusLabel = '미입실';
      default:
        statusColor = AppColors.textTertiary;
        statusLabel = '퇴실';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: AppColors.tintPurple,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Center(
              child: Text(
                student.name.substring(0, 1),
                style: AppTypography.headlineLarge.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(student.name, style: AppTypography.headlineMedium),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _InfoChip(label: student.gradeName ?? '—', icon: Icons.school_rounded),
                    _InfoChip(label: student.className ?? '—', icon: Icons.group_rounded),
                    _InfoChip(label: '좌석 ${student.assignedSeatNo ?? '미배정'}', icon: Icons.event_seat_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AdminStudentDetail detail) {
    String formatMinutes(int minutes) {
      final hours = minutes ~/ 60;
      final remain = minutes % 60;
      return hours > 0 ? '$hours시간 $remain분' : '$remain분';
    }

    final stats = [
      ('오늘 공부시간', formatMinutes(detail.todayStudyMinutes), Icons.timer_rounded, AppColors.studying, AppColors.tintPurple),
      ('이번 주', formatMinutes(detail.weeklyStudyMinutes), Icons.calendar_month_rounded, AppColors.success, AppColors.tintMint),
      ('이번 달', formatMinutes(detail.monthlyStudyMinutes), Icons.bar_chart_rounded, AppColors.accent, AppColors.tintPurple),
      ('출석률', '${(detail.attendanceRate * 100).round()}%', Icons.checklist_rounded, AppColors.warning, AppColors.tintYellow),
    ];

    return Row(
      children: stats.asMap().entries.map((e) {
        final i = e.key;
        final (label, value, icon, color, bg) = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < stats.length - 1 ? 12 : 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 10),
                Text(label, style: AppTypography.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.titleLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsCard(Student student) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.event_seat_rounded,
            label: '배정 좌석',
            value: student.assignedSeatNo ?? '미배정',
            isLast: false,
          ),
          _SettingsRow(
            icon: Icons.school_rounded,
            label: '학년',
            value: student.gradeName ?? '—',
            isLast: false,
          ),
          _SettingsRow(
            icon: Icons.group_rounded,
            label: '반',
            value: student.className ?? '—',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLog(AdminStudentDetail detail) {
    final logs = detail.activityLogs.map((item) {
      switch (item.kind) {
        case 'checkin':
          return (item.time, item.label, Icons.login_rounded, AppColors.success);
        case 'checkout':
          return (item.time, item.label, Icons.logout_rounded, AppColors.textSecondary);
        default:
          return (item.time, item.label, Icons.menu_book_rounded, AppColors.studying);
      }
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: logs.asMap().entries.map((e) {
          final i = e.key;
          final (time, label, icon, color) = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: i < logs.length - 1
                  ? const Border(bottom: BorderSide(color: AppColors.divider))
                  : null,
            ),
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
                Expanded(child: Text(label, style: AppTypography.titleMedium)),
                Text(
                  time,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyChart(AdminStudentDetail detail) {
    final stats = detail.weeklyStats.isEmpty
        ? [const DailyStat(date: '오늘', minutes: 0, count: 0)]
        : detail.weeklyStats;
    final maxMin = stats.map((item) => item.minutes).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('공부 시간', style: AppTypography.titleMedium),
              const Spacer(),
              Text('단위: 분', style: AppTypography.bodySmall),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.asMap().entries.map((e) {
                final i = e.key;
                final day = e.value.date;
                final min = e.value.minutes;
                final ratio = min / maxMin;
                final isToday = i == stats.length - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${(min / 60).toStringAsFixed(0)}h',
                          style: AppTypography.bodySmall.copyWith(fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 80 * ratio,
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.primary : AppColors.tintPurple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          day,
                          style: AppTypography.bodySmall.copyWith(
                            color: isToday ? AppColors.primary : AppColors.textTertiary,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectDistribution(AdminStudentDetail detail) {
    final palette = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.accent,
      AppColors.textTertiary,
    ];
    final total = detail.subjectStats.fold<int>(0, (sum, item) => sum + item.minutes);
    final subjects = detail.subjectStats.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('과목별 공부 비중', style: AppTypography.titleMedium),
          const SizedBox(height: 16),
          ...subjects.asMap().entries.map((entry) {
            final index = entry.key;
            final s = entry.value;
            final name = s.subject;
            final ratio = total == 0 ? 0.0 : s.minutes / total;
            final color = palette[index % palette.length];
            final pct = (ratio * 100).toStringAsFixed(0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(name, style: AppTypography.bodySmall),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: ratio),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 10,
                            backgroundColor: AppColors.background,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '$pct%',
                      style: AppTypography.bodySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showMessageSheet(BuildContext context, WidgetRef ref, String studentName) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$studentName에게 알림', style: AppTypography.headlineSmall),
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
              onTap: () async {
                final message = controller.text.trim();
                if (message.isEmpty) return;
                await ref.read(adminRepositoryProvider).sendNotification(
                      title: '$studentName 학생 안내',
                      body: message,
                      userIds: [studentId],
                    );
                if (!context.mounted) return;
                Navigator.pop(ctx);
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
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isLast,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTypography.bodyMedium),
          ),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// Delete button widget with confirmation dialog
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({
    required this.studentId,
    required this.studentName,
    required this.ref,
  });
  final String studentId;
  final String studentName;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDeleteConfirm(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
            const SizedBox(width: 4),
            Text(
              '삭제',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text('이 학생을 삭제하시겠어요?', style: AppTypography.headlineSmall),
        content: Text(
          '삭제된 데이터는 복구할 수 없어요',
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
            onPressed: () async {
              await ref.read(adminRepositoryProvider).deleteStudent(studentId);
              ref.invalidate(adminStudentsProvider);
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '삭제되었어요',
                    style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              context.go('/admin/students');
            },
            child: Text(
              '삭제',
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
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
