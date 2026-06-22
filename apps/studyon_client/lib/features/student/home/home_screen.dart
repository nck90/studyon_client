import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';

import '../character/character_avatar.dart';

final _rpgDashboardProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) {
  return ref.read(studentRepositoryProvider).getRpgDashboard();
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final student = ref.watch(studentProvider);
    final seatMapFuture = ref.read(studentRepositoryProvider).getSeatMap();

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_rpgDashboardProvider);
          await ref.read(studentProvider.notifier).hydrate();
        },
        color: AppColors.primary,
        child: StudentHomeContent(
          student: student,
          seatMapFuture: seatMapFuture,
        ),
      ),
    );
  }
}

class StudentHomeContent extends ConsumerWidget {
  const StudentHomeContent({
    super.key,
    required this.student,
    required this.seatMapFuture,
    this.rpgDashboard,
  });

  final StudentState student;
  final Future<List<Map<String, dynamic>>> seatMapFuture;
  final AsyncValue<Map<String, dynamic>>? rpgDashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final pad = isIPad ? 28.0 : 20.0;

    return ListView(
      padding: EdgeInsets.zero,
      cacheExtent: 10000,
      children: [
        // ── Purple Hero Banner ──
        _HeroBanner(isIPad: isIPad, pad: pad, student: student),

        // ── Not checked in warning ──
        if (!student.isCheckedIn)
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.hot.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: AppColors.hot,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '아직 입실 전이에요',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.hot,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        Padding(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
          child: _MotivationSnapshot(student: student, isIPad: isIPad),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
          child: _RpgQuestDashboard(
            dashboard: rpgDashboard ?? ref.watch(_rpgDashboardProvider),
            student: student,
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
          child: isIPad
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _BadgeStrip(student: student)),
                    const SizedBox(width: 12),
                    Expanded(child: _FocusModeCard(student: student)),
                    const SizedBox(width: 12),
                    Expanded(child: _RoomStatusCard(future: seatMapFuture)),
                  ],
                )
              : Column(
                  children: [
                    _BadgeStrip(student: student),
                    const SizedBox(height: 12),
                    _FocusModeCard(student: student),
                    const SizedBox(height: 12),
                    _RoomStatusCard(future: seatMapFuture),
                  ],
                ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
          child: _DailyMissionEntryCard(student: student),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
          child: _RoadmapEntryCard(student: student),
        ),

        // ── Plans + Recent ──
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
          child: _RecommendationCard(student: student),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(pad, 24, pad, 0),
          child: isIPad
              ? SizedBox(
                  height: 160,
                  child: Row(
                    children: [
                      Expanded(
                        child: _TodayPlans(
                          student: student,
                          onTap: () => context.push('/student/plan'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _RecentActivity(student: student)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _TodayPlans(
                      student: student,
                      onTap: () => context.push('/student/plan'),
                    ),
                    const SizedBox(height: 12),
                    _RecentActivity(student: student),
                  ],
                ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _RpgQuestDashboard extends StatelessWidget {
  const _RpgQuestDashboard({required this.dashboard, required this.student});

  final AsyncValue<Map<String, dynamic>> dashboard;
  final StudentState student;

  @override
  Widget build(BuildContext context) {
    return dashboard.when(
      loading: () => const _RpgQuestShell(
        title: '성장 퀘스트 불러오는 중',
        subtitle: '오늘 보상과 캐릭터 상태를 확인하고 있어요',
      ),
      error: (_, _) => _RpgQuestShell(
        title: '오늘 미션으로 성장하기',
        subtitle: student.dailyMission?.title ?? '공부 기록을 쌓으면 캐릭터가 성장해요',
        character: const <String, dynamic>{
          'stageAssetKey': 'stage_01',
          'level': 1,
        },
        points: student.totalPoints,
      ),
      data: (data) {
        final character =
            (data['character'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{'stageAssetKey': 'stage_01', 'level': 1};
        final mission =
            (data['dailyMission'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
        final missionTitle =
            (mission['title'] as String?) ??
            student.dailyMission?.title ??
            '오늘 퀘스트를 시작하세요';
        final completed =
            mission['isCompleted'] == true ||
            student.dailyMission?.isCompleted == true;
        return _RpgQuestShell(
          title: data['title'] as String? ?? '성장 퀘스트',
          subtitle: completed ? '오늘 퀘스트 완료' : missionTitle,
          character: character,
          points: (data['points'] as num?)?.toInt() ?? student.totalPoints,
          streakDays:
              (data['streakDays'] as num?)?.toInt() ?? student.streakDays,
        );
      },
    );
  }
}

class _RpgQuestShell extends StatelessWidget {
  const _RpgQuestShell({
    required this.title,
    required this.subtitle,
    this.character,
    this.points = 0,
    this.streakDays = 0,
  });

  final String title;
  final String subtitle;
  final Map<String, dynamic>? character;
  final int points;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    final characterData =
        character ??
        const <String, dynamic>{'stageAssetKey': 'stage_01', 'level': 1};
    final level = (characterData['level'] as num?)?.toInt() ?? 1;
    final xp = (characterData['xp'] as num?)?.toInt() ?? 0;
    final xpToNext = (characterData['xpToNext'] as num?)?.toInt() ?? 100;
    final progress = xpToNext <= 0 ? 1.0 : (xp / xpToNext).clamp(0.0, 1.0);

    return PressableScale(
      onTap: () => context.push('/student/character'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: CharacterAvatar(character: characterData, size: 82),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      color: AppColors.primary,
                      backgroundColor: AppColors.divider,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _RpgStatPill(
                        label: 'Lv.$level',
                        icon: Icons.auto_awesome_rounded,
                      ),
                      _RpgStatPill(
                        label: '$points P',
                        icon: Icons.toll_rounded,
                      ),
                      _RpgStatPill(
                        label: '$streakDays일',
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RpgStatPill extends StatelessWidget {
  const _RpgStatPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends ConsumerStatefulWidget {
  const _RecommendationCard({required this.student});

  final StudentState student;

  @override
  ConsumerState<_RecommendationCard> createState() =>
      _RecommendationCardState();
}

class _RecommendationCardState extends ConsumerState<_RecommendationCard> {
  bool _isApplying = false;

  String _riskLabel(String riskLevel) {
    switch (riskLevel) {
      case 'HIGH':
        return '집중 점검';
      case 'MEDIUM':
        return '리듬 보정';
      default:
        return '안정적';
    }
  }

  Color _riskColor(String riskLevel) {
    switch (riskLevel) {
      case 'HIGH':
        return AppColors.hot;
      case 'MEDIUM':
        return AppColors.warm;
      default:
        return AppColors.accent;
    }
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remain = minutes % 60;
    if (hours == 0) return '$remain분';
    if (remain == 0) return '$hours시간';
    return '$hours시간 $remain분';
  }

  Future<void> _applyRecommendation() async {
    setState(() => _isApplying = true);
    try {
      await ref.read(studentProvider.notifier).applyRecommendation();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('추천 계획을 오늘 일정에 추가했어요'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('추천 계획을 불러오지 못했어요'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.hot,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendation = widget.student.recommendation;
    final riskColor = _riskColor(recommendation.riskLevel);
    // Filter to math only for math academy
    final mathFocusSubjects = recommendation.focusSubjects
        .where((s) => s == '수학')
        .toList();
    final mathPlanTemplate = recommendation.planTemplate
        .where((item) => item.subject == '수학')
        .toList();
    final existingKeys = widget.student.plans
        .map((plan) => '${plan.subject}|${plan.detail}')
        .toSet();
    final missingTemplates = mathPlanTemplate.where((item) {
      return !existingKeys.contains('${item.subject}|${item.detail}');
    }).toList();

    return Container(
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
              const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 추천',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _riskLabel(recommendation.riskLevel),
                  style: AppTypography.labelSmall.copyWith(
                    color: riskColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '권장 공부 시간 ${_formatMinutes(recommendation.recommendedTargetMinutes)}',
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '집중 과목 수학',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (mathFocusSubjects.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mathFocusSubjects.map((subject) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    subject,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.subjectColor(subject),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (mathPlanTemplate.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...mathPlanTemplate.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: AppColors.subjectColor(item.subject),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.detail,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.subject} · ${_formatMinutes(item.targetMinutes)}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StudyonButton(
                  label: missingTemplates.isEmpty ? '추천 반영 완료' : '추천 계획 가져오기',
                  onPressed: missingTemplates.isEmpty || _isApplying
                      ? null
                      : _applyRecommendation,
                  variant: StudyonButtonVariant.primary,
                  icon: Icons.file_download_done_rounded,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.push('/student/plan'),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '직접 편집',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Hero Banner
// ─────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.isIPad,
    required this.pad,
    required this.student,
  });
  final bool isIPad;
  final double pad;
  final StudentState student;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '좋은 아침이에요';
    if (hour < 18) return '좋은 오후에요';
    return '오늘도 수고했어요';
  }

  @override
  Widget build(BuildContext context) {
    final bgUrl = student.homeBackgroundMediaUrl;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        image: bgUrl.isEmpty
            ? null
            : DecorationImage(
                image: NetworkImage(bgUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  AppColors.primary.withValues(alpha: 0.52),
                  BlendMode.srcOver,
                ),
              ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(pad, 16, pad, 28),
          child: isIPad
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(flex: 5, child: _buildContent(context)),
                    const SizedBox(width: 32),
                    _DailyProgressRing(
                      progress: student.goalProgress,
                      size: 120,
                    ),
                  ],
                )
              : _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final seatLabel = student.seatNo.isEmpty ? '좌석 미배정' : student.seatNo;
    final displayName = student.name.isEmpty ? '학생' : '${student.name}님';
    final rankLabel = student.todayRank > 0
        ? '#${student.todayRank} 순위'
        : '순위 집계 중';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top: seat + bell
        Row(
          children: [
            Text(
              seatLabel,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const Spacer(),
            Semantics(
              label: '알림',
              button: true,
              child: GestureDetector(
                onTap: () => context.push('/student/notifications'),
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Greeting + Name
        Text(
          _greeting(),
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          displayName,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 8),

        // Big time
        _AnimatedStudyTime(
          isIPad: isIPad,
          totalSeconds: student.todayStudySeconds,
        ),
        const SizedBox(height: 4),
        Text(
          '오늘 공부',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),

        // Chips: streak + rank
        Row(
          children: [
            const TossFace('🔥', size: 15),
            const SizedBox(width: 4),
            Text(
              '${student.streakDays}일 연속',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              rankLabel,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.85),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // CTA
        if (student.isCheckedIn)
          Builder(
            builder: (context) {
              final shouldResumeLabel =
                  student.isStudying || student.todayStudySeconds > 0;
              return Semantics(
                label: shouldResumeLabel ? '이어서 공부' : '공부 시작',
                button: true,
                child: GestureDetector(
                  onTap: () => context.push('/student/study-session'),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          shouldResumeLabel ? '이어서 공부' : '공부 시작',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _TargetUniversityCard extends StatelessWidget {
  const _TargetUniversityCard({required this.student});
  final StudentState student;

  @override
  Widget build(BuildContext context) {
    final university = student.targetUniversityName.trim();
    final hasTarget = university.isNotEmpty;
    final imageUrl = student.targetUniversityMediaUrl;
    return PressableScale(
      onTap: () => context.push('/student/motivation-settings'),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 88,
              height: 112,
              decoration: BoxDecoration(
                color: AppColors.tintPurple,
                image: imageUrl.isEmpty
                    ? null
                    : DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
              ),
              child: imageUrl.isEmpty
                  ? const Icon(
                      Icons.school_rounded,
                      color: AppColors.primary,
                      size: 34,
                    )
                  : null,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      hasTarget ? '목표 대학' : '목표 대학을 설정해 보세요',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasTarget ? university : '첫 화면에 목표를 고정해요',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hasTarget ? '공부 시작 전마다 목표를 확인해요' : '로고나 사진도 함께 등록할 수 있어요',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MotivationSnapshot extends StatelessWidget {
  const _MotivationSnapshot({required this.student, required this.isIPad});
  final StudentState student;
  final bool isIPad;

  @override
  Widget build(BuildContext context) {
    if (isIPad) {
      return SizedBox(
        height: 168,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(flex: 5, child: _TargetUniversityCard(student: student)),
            const SizedBox(width: 12),
            Expanded(flex: 4, child: _GoalCard(student: student)),
            const SizedBox(width: 12),
            Expanded(flex: 4, child: _WeeklyChart(student: student)),
          ],
        ),
      );
    }
    return Column(
      children: [
        _TargetUniversityCard(student: student),
        const SizedBox(height: 12),
        _GoalCard(student: student),
        const SizedBox(height: 12),
        _WeeklyChart(student: student),
      ],
    );
  }
}

class _RoadmapEntryCard extends StatelessWidget {
  const _RoadmapEntryCard({required this.student});
  final StudentState student;

  @override
  Widget build(BuildContext context) {
    final roadmap = student.goalRoadmap;
    final mission = roadmap?.currentMission;
    final target = roadmap?.targetName.trim().isNotEmpty == true
        ? roadmap!.targetName
        : (student.targetUniversityName.trim().isEmpty
              ? 'D-day 로드맵'
              : student.targetUniversityName.trim());
    return PressableScale(
      onTap: () => context.push('/student/goal-roadmap'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.tintPurple,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.flag_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roadmap == null
                        ? '로드맵 만들기'
                        : '$target D-${roadmap.daysLeft}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mission?.title ?? '월간 목표와 이번 주 미션을 설정해요',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyMissionEntryCard extends StatelessWidget {
  const _DailyMissionEntryCard({required this.student});
  final StudentState student;

  @override
  Widget build(BuildContext context) {
    final mission = student.dailyMission;
    final completed = mission?.isCompleted == true;
    return PressableScale(
      onTap: () => context.push('/student/daily-mission'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: completed
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.tintPurple,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.local_fire_department_rounded,
                color: completed ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission?.title ?? '오늘 미션 만들기',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mission == null
                        ? '매일 하나씩 공부 루틴을 이어가요'
                        : completed
                        ? '오늘 미션 완료'
                        : '${mission.subjectName} ${mission.targetMinutes}분 · ${mission.reminderTime}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyProgressRing extends StatelessWidget {
  const _DailyProgressRing({required this.progress, required this.size});
  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                '달성',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedStudyTime extends StatelessWidget {
  const _AnimatedStudyTime({required this.isIPad, required this.totalSeconds});
  final bool isIPad;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final targetMinutes = totalSeconds ~/ 60;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: targetMinutes.toDouble()),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        final mins = value.round();
        final h = mins ~/ 60;
        final m = mins % 60;
        final text = h > 0 ? '$h시간 $m분' : (m > 0 ? '$m분' : '0분');
        return Text(
          text,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: isIPad ? 44 : 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1,
            height: 1.0,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────
// Goal Card
// ─────────────────────────────────────────────────
class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.student});
  final StudentState student;

  @override
  Widget build(BuildContext context) {
    final hasGoal =
        student.goalSubject.isNotEmpty || student.goalDetail.isNotEmpty;
    final subject = student.goalSubject.isNotEmpty
        ? student.goalSubject
        : '계획 미설정';
    final detail = student.goalDetail.isNotEmpty
        ? student.goalDetail
        : '목표를 설정해주세요';
    final progress = student.goalProgress;
    final percent = (progress * 100).round().clamp(0, 100);
    final status = !hasGoal
        ? '오늘 목표가 비어 있어요'
        : progress >= 1
        ? '목표 달성 완료'
        : '진행 중';
    final statusColor = !hasGoal
        ? AppColors.textTertiary
        : progress >= 1
        ? AppColors.accent
        : AppColors.primary;

    return Semantics(
      label: '오늘 목표 $percent퍼센트',
      child: PressableScale(
        onTap: () => context.push('/student/plan'),
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
                  const Text(
                    '오늘 목표',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: AppTypography.labelSmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subject,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.subjectColor(subject),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              StudyonProgressBar(value: progress, height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Weekly Chart
// ─────────────────────────────────────────────────
class _WeeklyChart extends StatefulWidget {
  const _WeeklyChart({required this.student});
  final StudentState student;

  @override
  State<_WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<_WeeklyChart> {
  String? _selectedDay;

  List<(String, double)> _weeklyHours() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: today.weekday - 1));
    final labels = const ['월', '화', '수', '목', '금', '토', '일'];
    final dailyMinutes = <int, int>{};

    for (final record in widget.student.recentRecords) {
      final parsed = DateTime.tryParse(record.isoDate);
      if (parsed == null) continue;
      final date = DateTime(parsed.year, parsed.month, parsed.day);
      final diff = date.difference(start).inDays;
      if (diff < 0 || diff > 6) continue;
      dailyMinutes.update(
        diff,
        (value) => value + record.studyMinutes,
        ifAbsent: () => record.studyMinutes,
      );
    }

    return List.generate(7, (index) {
      final hours = (dailyMinutes[index] ?? 0) / 60;
      return (labels[index], hours);
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _weeklyHours();
    final maxH = days.fold<double>(
      1.0,
      (maxValue, item) => item.$2 > maxValue ? item.$2 : maxValue,
    );
    final totalHours = days.fold<double>(0, (sum, item) => sum + item.$2);
    final todayLabel = const [
      '월',
      '화',
      '수',
      '목',
      '금',
      '토',
      '일',
    ][DateTime.now().weekday - 1];
    return Container(
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
              const Text(
                '이번 주',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Text(
                '${totalHours.toStringAsFixed(1)}h',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.student.weeklyTargetMinutes > 0
                ? '목표 ${(widget.student.weeklyAchievedRate).round()}%'
                : '이번 주 리듬을 확인해요',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((d) {
                final (label, hours) = d;
                final isToday = label == todayLabel;
                final isSel = _selectedDay == label;
                final dimmed = _selectedDay != null && !isSel;
                final ratio = hours / maxH;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedDay = isSel ? null : label),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isSel)
                            Text(
                              '${hours}h',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          if (isSel) const SizedBox(height: 2),
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity: dimmed ? 0.3 : 1.0,
                                child: FractionallySizedBox(
                                  heightFactor: ratio.clamp(0.08, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: (isToday || isSel)
                                          ? AppColors.primary
                                          : const Color(0xFFE5E7EB),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 11,
                              fontWeight: (isToday || isSel)
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: (isToday || isSel)
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
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
}

class _BadgeStrip extends StatelessWidget {
  const _BadgeStrip({required this.student});
  final StudentState student;

  @override
  Widget build(BuildContext context) {
    final badges = student.badges.take(3).toList();
    return PressableScale(
      onTap: () => context.push('/student/profile'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '최근 배지',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTertiary,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Text(
                  '${student.badges.length}개',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (badges.isEmpty)
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.tintYellow,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.warm,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '첫 배지를 향해 시작해요',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  ...badges.map(
                    (badge) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.tintPurple,
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                            ),
                            child: Center(
                              child: TossFace(badge.emoji, size: 22),
                            ),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 56,
                            child: Text(
                              badge.name,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _FocusModeCard extends StatelessWidget {
  const _FocusModeCard({required this.student});
  final StudentState student;

  @override
  Widget build(BuildContext context) {
    final enabled = student.focusModeEnabled;
    final color = enabled ? AppColors.accent : AppColors.warm;
    return PressableScale(
      onTap: () => context.push('/student/motivation-settings'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                enabled ? Icons.lock_rounded : Icons.lock_open_rounded,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enabled ? '집중모드 준비됨' : '집중모드 꺼짐',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    enabled ? '자습 시작 시 차단이 함께 켜져요' : '자습 중 딴 앱 사용을 줄여요',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Room Status
// ─────────────────────────────────────────────────
class _RoomStatusCard extends StatelessWidget {
  const _RoomStatusCard({required this.future});

  final Future<List<Map<String, dynamic>>> future;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          final seats = snapshot.data ?? const <Map<String, dynamic>>[];
          final studying = seats
              .where((seat) => seat['uiStatus'] == 'studying')
              .length;
          final onBreak = seats
              .where((seat) => seat['uiStatus'] == 'onBreak')
              .length;
          final empty = seats
              .where((seat) => seat['uiStatus'] == 'empty')
              .length;
          final total = seats.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '학원',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$studying',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      '/$total',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '공부 $studying · 휴식 $onBreak · 빈자리 $empty',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Today Plans
// ─────────────────────────────────────────────────
class _TodayPlans extends StatelessWidget {
  const _TodayPlans({required this.student, required this.onTap});
  final StudentState student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Text(
                '오늘 할 일',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onTap,
                child: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (student.plans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                '등록된 계획이 없어요',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            )
          else
            ...student.plans
                .take(3)
                .map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: plan.progress >= 1.0
                                  ? AppColors.accent
                                  : AppColors.cardBorder,
                              width: 1.5,
                            ),
                            color: plan.progress >= 1.0
                                ? AppColors.accent
                                : Colors.transparent,
                          ),
                          child: plan.progress >= 1.0
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          plan.subject,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.subjectColor(plan.subject),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            plan.detail,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          plan.targetLabel,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            color: AppColors.textTertiary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Recent Activity
// ─────────────────────────────────────────────────
class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.student});
  final StudentState student;

  String _formatRecordDate(String raw) {
    final match = RegExp(r'(\d+)월 (\d+)일').firstMatch(raw);
    if (match == null) return raw;
    return '${match.group(1)}/${match.group(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 활동',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textTertiary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 14),
          if (student.recentRecords.isEmpty)
            Text(
              '기록이 없어요',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            )
          else
            ...student.recentRecords
                .take(3)
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Text(
                            _formatRecordDate(r.date),
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        Text(
                          r.subject,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subjectColor(r.subject),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${r.studyMinutes ~/ 60}h ${r.studyMinutes % 60}m',
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
