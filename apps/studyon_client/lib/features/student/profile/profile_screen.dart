import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';
import '../../../shared/utils/snackbar_helper.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = ref.read(studentProvider).isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final pad = isIPad ? 32.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        bottom: false,
        child: isIPad
            ? _buildIPadLayout(context, pad)
            : _buildPhoneLayout(context, pad),
      ),
    );
  }

  Widget _buildIPadLayout(BuildContext context, double pad) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column: student card + badges + settings
        Expanded(
          flex: 4,
          child: ListView(
            padding: EdgeInsets.fromLTRB(pad, 20, pad / 2, 100),
            children: [
              _buildHeader(context, pad: 0),
              const SizedBox(height: 24),
              _buildStudentCard(context, isIPad: true),
              const SizedBox(height: 16),
              _buildStatsSummary(),
              const SizedBox(height: 24),
              _buildBadgeCollection(),
              const SizedBox(height: 24),
              _buildSettingsSection(context),
            ],
          ),
        ),
        // Right column: study stats dashboard
        Expanded(
          flex: 5,
          child: ListView(
            padding: EdgeInsets.fromLTRB(pad / 2, 20, pad, 100),
            children: [
              _buildMonthlyAchievement(),
              const SizedBox(height: 20),
              _buildStudyPattern(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout(BuildContext context, double pad) {
    return ListView(
      padding: EdgeInsets.fromLTRB(pad, 20, pad, 100),
      children: [
        _buildHeader(context, pad: 0),
        const SizedBox(height: 24),
        _buildStudentCard(context, isIPad: false),
        const SizedBox(height: 16),
        _buildStatsSummary(),
        const SizedBox(height: 24),
        _buildBadgeCollection(),
        const SizedBox(height: 24),
        _buildSettingsSection(context),
        const SizedBox(height: 12),
        _buildCheckoutButton(context),
      ],
    );
  }

  void _showEditProfile(BuildContext context) {
    final nameCtrl = TextEditingController(text: ref.read(studentProvider).name);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('프로필 수정', style: AppTypography.headlineSmall),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: '이름',
                labelStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.bg(ctx),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                showStudyonSnackbar(context, '저장되었어요');
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '저장',
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

  Widget _buildHeader(BuildContext context, {required double pad}) {
    return Row(
      children: [
        Text('프로필', style: AppTypography.headlineLarge),
        const Spacer(),
        PressableScale(
          onTap: () => _showEditProfile(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(BuildContext context, {required bool isIPad}) {
    final student = ref.watch(studentProvider);
    final gradeClass = [
      if (student.grade.isNotEmpty) student.grade,
      if (student.className.isNotEmpty) student.className,
    ].join(' · ');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Purple header bar — "자습ON" brand bar
          Container(
            height: 48,
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  '자습ON',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  'STUDENT ID',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // White body area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: name + info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        gradeClass.isEmpty
                            ? '학번 ${student.studentNo}'
                            : '학번 ${student.studentNo} · $gradeClass',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.seatNo.isEmpty
                            ? '좌석 미배정'
                            : '좌석 ${student.seatNo}',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.tintPurple,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Lv.${student.level} ${student.levelName}',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${student.totalPoints}P',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right: QR code area
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2_rounded, size: 36, color: AppColors.textPrimary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Bottom purple accent line
          Container(height: 3, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    final student = ref.watch(studentProvider);
    final monthlyHours = (student.monthlyStudyMinutes / 60).toStringAsFixed(1);
    final pointsLabel = '${student.totalPoints}P';

    return Row(
      children: [
        Expanded(
          child: _SummaryStatCard(
            label: '이번 달',
            value: '${monthlyHours}h',
            icon: Icons.timer_outlined,
            color: AppColors.primary,
            bgColor: AppColors.tintPurple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryStatCard(
            label: '연속일',
            value: '${student.streakDays}일',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.accent,
            bgColor: AppColors.tintMint,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PressableScale(
            onTap: () => context.push('/student/points'),
            child: _SummaryStatCard(
              label: '포인트',
              value: pointsLabel,
              icon: Icons.stars_rounded,
              color: AppColors.warm,
              bgColor: AppColors.tintYellow,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final student = ref.watch(studentProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '설정',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Column(
            children: [
              _SettingsRow(
                icon: Icons.notifications_outlined,
                iconColor: AppColors.primary,
                iconBg: AppColors.tintPurple,
                label: '알림 설정',
                trailing: Switch.adaptive(
                  value: student.notificationEnabled,
                  onChanged: (v) async {
                    await ref.read(studentProvider.notifier).setNotificationEnabled(v);
                    if (!context.mounted) return;
                    showStudyonSnackbar(
                      context,
                      v ? '알림 켜짐' : '알림 꺼짐',
                    );
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                ),
                onTap: () async {
                  final newVal = !student.notificationEnabled;
                  await ref.read(studentProvider.notifier).setNotificationEnabled(newVal);
                  if (!context.mounted) return;
                  showStudyonSnackbar(
                    context,
                    newVal ? '알림 켜짐' : '알림 꺼짐',
                  );
                },
                showChevron: false,
              ),
              const Divider(height: 0.5, thickness: 0.5, indent: 16, endIndent: 16),
              _SettingsRow(
                icon: Icons.dark_mode_outlined,
                iconColor: AppColors.primaryDark,
                iconBg: AppColors.tintPurple,
                label: '다크 모드',
                trailing: Switch.adaptive(
                  value: _darkModeEnabled,
                  onChanged: (v) {
                    setState(() => _darkModeEnabled = v);
                    ref.read(studentProvider.notifier).toggleDarkMode();
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                ),
                onTap: () {
                  setState(() => _darkModeEnabled = !_darkModeEnabled);
                  ref.read(studentProvider.notifier).toggleDarkMode();
                },
                showChevron: false,
              ),
              const Divider(height: 0.5, thickness: 0.5, indent: 16, endIndent: 16),
              _SettingsRow(
                icon: Icons.flag_outlined,
                iconColor: AppColors.accent,
                iconBg: AppColors.tintMint,
                label: '목표 관리',
                onTap: () => context.push('/student/plan'),
              ),
              const Divider(height: 0.5, thickness: 0.5, indent: 16, endIndent: 16),
              _SettingsRow(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.warm,
                iconBg: AppColors.tintYellow,
                label: '앱 정보',
                trailing: Text(
                  'v1.0.0',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                ),
                onTap: () => showStudyonSnackbar(context, '자습ON v1.0.0'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Semantics(
          label: '로그아웃',
          button: true,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            ),
            child: _SettingsRow(
              icon: Icons.logout_rounded,
              iconColor: AppColors.hot,
              iconBg: AppColors.tintCoral,
              label: '로그아웃',
              labelColor: AppColors.hot,
              onTap: () async {
                await ref.read(studentProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              showChevron: false,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Text('자습ON v1.0.0', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary.withValues(alpha: 0.5))),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showBadgeDetail(BuildContext context, ({String emoji, String label, bool active}) badge) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TossFace(badge.emoji, size: 48),
            const SizedBox(height: 16),
            Text(badge.label, style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text(
              badge.active ? '획득 완료' : '아직 달성하지 못했어요',
              style: AppTypography.bodyMedium.copyWith(
                color: badge.active ? AppColors.accent : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _badgeDescription(badge.label),
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _badgeDescription(String label) {
    switch (label) {
      case '7일 연속': return '7일 연속 출석하면 획득';
      case '첫 100시간': return '누적 학습 시간 100시간 달성';
      case 'TOP 3': return '일간 랭킹 TOP 3 진입';
      case '목표 달성왕': return '10회 연속 목표 달성';
      case '새벽형': return '오전 6시 이전에 입실';
      case '마라톤러': return '한 세션에 5시간 이상 학습';
      default: return '';
    }
  }

  bool _hasBadge(List<String> badges, String target) {
    final normalized = badges.map((badge) => badge.replaceAll(' ', '')).toSet();
    return normalized.contains(target.replaceAll(' ', ''));
  }

  Widget _buildBadgeCollection() {
    final badges = ref.watch(studentProvider).badges;
    final badgeItems = [
      (emoji: '🔥', label: '7일 연속', active: _hasBadge(badges, '7일연속')),
      (emoji: '💯', label: '첫 100시간', active: _hasBadge(badges, '첫100시간')),
      (emoji: '🏆', label: 'TOP 3', active: _hasBadge(badges, 'TOP3')),
      (emoji: '🎯', label: '목표 달성왕', active: _hasBadge(badges, '목표달성왕')),
      (emoji: '🌅', label: '새벽형', active: _hasBadge(badges, '새벽형')),
      (emoji: '🏃', label: '마라톤러', active: _hasBadge(badges, '마라톤러')),
    ];
    final activeCount = badgeItems.where((b) => b.active).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '배지 컬렉션',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            Text(
              '$activeCount/${badgeItems.length}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
          children: badgeItems.map((badge) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _showBadgeDetail(context, badge),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.card(context),
                    ),
                    child: Center(
                      child: badge.active
                          ? TossFace(badge.emoji, size: 36)
                          : Opacity(
                              opacity: 0.35,
                              child: TossFace(badge.emoji, size: 32),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: badge.active ? AppColors.text(context) : AppColors.textTertiary,
                    fontWeight: badge.active ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(BuildContext context) {
    return PressableScale(
      onTap: () {
        HapticFeedback.mediumImpact();
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              '퇴실하시겠습니까?',
              style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w700),
            ),
            content: const Text(
              '퇴실하면 오늘 학습이 종료됩니다.',
              style: TextStyle(fontFamily: 'Pretendard'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('취소', style: TextStyle(fontFamily: 'Pretendard', color: AppColors.textTertiary)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await ref.read(studentProvider.notifier).checkOut();
                  if (context.mounted) context.go('/login');
                },
                child: const Text(
                  '퇴실',
                  style: TextStyle(fontFamily: 'Pretendard', color: AppColors.hot, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.tintCoral,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 18, color: AppColors.hot),
            const SizedBox(width: 8),
            Text(
              '퇴실하기',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.hot,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyAchievement() {
    final student = ref.watch(studentProvider);
    final records = student.recentRecords;
    final topSubject = records.isEmpty
        ? '기록 없음'
        : (records.toList()
              ..sort((a, b) => b.studyMinutes.compareTo(a.studyMinutes)))
            .first
            .subject;
    final monthlyHours = (student.monthlyStudyMinutes / 60).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('이번 달 성과', style: AppTypography.headlineSmall),
              Text(
                '${DateTime.now().month}월',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Total study hours with comparison
          _AchievementRow(
            icon: Icons.timer_outlined,
            iconColor: AppColors.primary,
            iconBg: AppColors.tintPurple,
            title: '총 공부 시간',
            value: '$monthlyHours시간',
            subtitle: '이번 달 누적 학습 시간',
            subtitleColor: AppColors.accent,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          // Attendance rate with mini calendar dots
          _AchievementRow(
            icon: Icons.event_available_rounded,
            iconColor: AppColors.accent,
            iconBg: AppColors.tintMint,
            title: '오늘 상태',
            value: student.isCheckedIn ? '입실 중' : '미입실',
            subtitle: student.seatNo.isEmpty ? '좌석 미배정' : '좌석 ${student.seatNo}',
            subtitleColor: AppColors.textSecondary,
            trailing: _MiniAttendanceDots(active: student.isCheckedIn),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          // Best study day
          _AchievementRow(
            icon: Icons.workspace_premium_rounded,
            iconColor: AppColors.rankGold,
            iconBg: AppColors.tintYellow,
            title: '오늘 공부',
            value: student.todayStudyFormatted,
            subtitle: '최근 공부 세션 기준',
            subtitleColor: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          // Most studied subject
          _AchievementRow(
            icon: Icons.book_outlined,
            iconColor: AppColors.hot,
            iconBg: AppColors.tintCoral,
            title: '레벨 · 포인트',
            value: 'Lv.${student.level} ${student.levelName}',
            subtitle: '$topSubject · ${student.totalPoints}P',
            subtitleColor: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildStudyPattern() {
    final student = ref.watch(studentProvider);
    final recent = student.recentRecords.take(7).toList();
    final averageMinutes = recent.isEmpty
        ? 0
        : recent.fold<int>(0, (sum, item) => sum + item.studyMinutes) ~/
            recent.length;
    final bestSubject = recent.isEmpty
        ? '기록 없음'
        : (recent.toList()
              ..sort((a, b) => b.studyMinutes.compareTo(a.studyMinutes)))
            .first
            .subject;
    final intensity = student.goalProgress >= 0.8
        ? '${(student.goalProgress * 100).round()}%'
        : '${(student.goalProgress * 100).round()}%';
    final hourlyIntensities = _normalizeHourlyMinutes(student.hourlyStudyMinutes);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 12),
              Text('학습 패턴', style: AppTypography.headlineSmall),
            ],
          ),
          const SizedBox(height: 20),
          // Pattern insight cards
          _PatternCard(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.primary,
            text: '최근 평균 공부 시간 $averageMinutes분',
            highlight: '$averageMinutes분',
            highlightColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _PatternCard(
            icon: Icons.menu_book_rounded,
            iconColor: AppColors.accent,
            text: '가장 많이 공부한 과목 $bestSubject',
            highlight: bestSubject,
            highlightColor: AppColors.accent,
          ),
          const SizedBox(height: 12),
          _PatternCard(
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.rankGold,
            text: '오늘 목표 진행률 $intensity',
            highlight: intensity,
            highlightColor: AppColors.rankGold,
          ),
          const SizedBox(height: 20),
          // Hourly heat row
          Text(
            '오늘 공부 시간대',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          _HourlyHeatRow(intensities: hourlyIntensities),
        ],
      ),
    );
  }

  List<int> _normalizeHourlyMinutes(List<int> minutes) {
    final maxMinutes = minutes.fold<int>(0, (best, item) => item > best ? item : best);
    if (maxMinutes == 0) return List<int>.filled(minutes.length, 0);
    return minutes
        .map((item) => item == 0 ? 0 : ((item / maxMinutes) * 4).ceil().clamp(1, 4))
        .toList();
  }
}

class _AchievementRow extends StatelessWidget {
  const _AchievementRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
    this.trailing,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
  final String subtitle;
  final Color subtitleColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.text(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.labelSmall.copyWith(
                  color: subtitleColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _MiniAttendanceDots extends StatelessWidget {
  const _MiniAttendanceDots({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(14, (i) {
        final isActiveDot = active && i >= 9;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActiveDot
                ? AppColors.primary.withValues(alpha: 0.8)
                : AppColors.background,
            border: Border.all(
              color: isActiveDot ? Colors.transparent : AppColors.cardBorder,
            ),
          ),
        );
      }),
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.highlight,
    required this.highlightColor,
  });
  final IconData icon;
  final Color iconColor;
  final String text;
  final String highlight;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    final parts = text.split(highlight);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSub(context)),
                children: [
                  if (parts.isNotEmpty) TextSpan(text: parts[0]),
                  TextSpan(
                    text: highlight,
                    style: AppTypography.bodySmall.copyWith(
                      color: highlightColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (parts.length > 1) TextSpan(text: parts[1]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyHeatRow extends StatelessWidget {
  const _HourlyHeatRow({required this.intensities});

  final List<int> intensities;
  static const _labels = ['6', '8', '10', '12', '14', '16', '18', '20', '22'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(intensities.length, (i) {
            final intensity = intensities[i];
            return Expanded(
              child: Container(
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: intensity == 0
                      ? AppColors.background
                      : AppColors.primary.withValues(alpha: 0.15 + intensity * 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        // Hour labels (approximate positions)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _labels.map((l) => Text(
            l,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 9,
            ),
          )).toList(),
        ),
      ],
    );
  }
}



class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSub(context),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.onTap,
    this.trailing,
    this.labelColor,
    this.showChevron = true,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? labelColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.titleLarge.copyWith(
                    color: labelColor ?? AppColors.text(context),
                  ),
                ),
              ),
              if (trailing != null) ...[trailing!, const SizedBox(width: 4)],
              if (showChevron)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
