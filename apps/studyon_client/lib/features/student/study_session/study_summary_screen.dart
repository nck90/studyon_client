import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';

class StudySummaryScreen extends ConsumerStatefulWidget {
  const StudySummaryScreen({super.key});

  @override
  ConsumerState<StudySummaryScreen> createState() => _StudySummaryScreenState();
}

class _StudySummaryScreenState extends ConsumerState<StudySummaryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final Animation<double> _checkmarkScale;
  late final List<Animation<double>> _cardFades;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _checkmarkScale = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );

    // 4 cards, staggered by 200ms each, starting at 300ms
    _cardFades = List.generate(4, (i) {
      final start = 0.2 + i * 0.15;
      final end = (start + 0.25).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final pad = isIPad ? 40.0 : 24.0;

    final achieved = student.todayStudySeconds >= (student.goalHours * 3600);
    final headerColors = achieved
        ? const [Color(0xFF00B894), Color(0xFF00CEC9)]
        : AppColors.mintGradient;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: headerColors,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 32, pad, 40),
                child: Column(
                  children: [
                    if (achieved) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          '목표 달성',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ScaleTransition(
                      scale: _checkmarkScale,
                      child: TossFace(achieved ? '🎉' : '✅', size: 48),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      achieved ? '목표 달성!' : '공부 종료',
                      style: AppTypography.headlineLarge.copyWith(
                        color: Colors.white,
                        fontSize: isIPad ? 28 : 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achieved ? '오늘 목표를 모두 달성했어요!' : '오늘의 학습 기록이에요',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(pad, 28, pad, 40),
              children: [
                if (isIPad)
                  _buildIPadContent(pad, student.todayStudyFormatted, student.streakDays)
                else
                  _buildPhoneContent(student.todayStudyFormatted, student.streakDays),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIPadContent(double pad, String studyTime, int streakDays) {
    return Column(
      children: [
        // Stats grid + weekly chart side by side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Stats grid
            Expanded(
              flex: 5,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  FadeTransition(
                    opacity: _cardFades[0],
                    child: _BigStatCard(
                      value: studyTime,
                      label: '공부 시간',
                      icon: Icons.timer_rounded,
                      bgColor: AppColors.tintPurple,
                      valueColor: AppColors.primary,
                      iconColor: AppColors.primary,
                    ),
                  ),
                  FadeTransition(
                    opacity: _cardFades[1],
                    child: const _BigStatCard(
                      value: '104%',
                      label: '목표 달성률',
                      icon: Icons.flag_rounded,
                      bgColor: AppColors.tintMint,
                      valueColor: AppColors.accent,
                      iconColor: AppColors.accent,
                    ),
                  ),
                  FadeTransition(
                    opacity: _cardFades[2],
                    child: const _BigStatCard(
                      value: '#2',
                      label: '오늘 순위',
                      icon: Icons.leaderboard_rounded,
                      bgColor: AppColors.tintYellow,
                      valueColor: AppColors.rankGold,
                      iconColor: AppColors.rankGold,
                    ),
                  ),
                  FadeTransition(
                    opacity: _cardFades[3],
                    child: _BigStatCard(
                      value: '$streakDays일',
                      label: '연속 학습',
                      icon: Icons.local_fire_department_rounded,
                      bgColor: AppColors.tintCoral,
                      valueColor: AppColors.hot,
                      iconColor: AppColors.hot,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Right: Weekly chart
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('이번 주 학습', style: AppTypography.headlineSmall),
                        Text(
                          '총 17시간',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      height: 160,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _Bar(day: '월', h: 60),
                          _Bar(day: '화', h: 80),
                          _Bar(day: '수', h: 45),
                          _Bar(day: '목', h: 70),
                          _Bar(day: '금', h: 90),
                          _Bar(day: '토', h: 100, today: true),
                          _Bar(day: '일', h: 0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Comparison + Next goal side by side on iPad
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildComparisonCard(),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildNextGoalCard(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildMotivationalCard(),
        const SizedBox(height: 28),
        _buildButtons(),
      ],
    );
  }

  Widget _buildPhoneContent(String studyTime, int streakDays) {
    return Column(
      children: [
        // Stats grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            FadeTransition(
              opacity: _cardFades[0],
              child: _BigStatCard(
                value: studyTime,
                label: '공부 시간',
                icon: Icons.timer_rounded,
                bgColor: AppColors.tintPurple,
                valueColor: AppColors.primary,
                iconColor: AppColors.primary,
              ),
            ),
            FadeTransition(
              opacity: _cardFades[1],
              child: const _BigStatCard(
                value: '104%',
                label: '목표 달성률',
                icon: Icons.flag_rounded,
                bgColor: AppColors.tintMint,
                valueColor: AppColors.accent,
                iconColor: AppColors.accent,
              ),
            ),
            FadeTransition(
              opacity: _cardFades[2],
              child: const _BigStatCard(
                value: '#2',
                label: '오늘 순위',
                icon: Icons.emoji_events_rounded,
                bgColor: AppColors.tintYellow,
                valueColor: AppColors.rankGold,
                iconColor: AppColors.rankGold,
              ),
            ),
            FadeTransition(
              opacity: _cardFades[3],
              child: _BigStatCard(
                value: '\${streakDays}일',
                label: '연속 학습',
                icon: Icons.local_fire_department_rounded,
                bgColor: AppColors.tintCoral,
                valueColor: AppColors.hot,
                iconColor: AppColors.hot,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Weekly chart
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('이번 주 학습', style: AppTypography.headlineSmall),
                  Text(
                    '총 17시간',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Bar(day: '월', h: 60),
                    _Bar(day: '화', h: 80),
                    _Bar(day: '수', h: 45),
                    _Bar(day: '목', h: 70),
                    _Bar(day: '금', h: 90),
                    _Bar(day: '토', h: 100, today: true),
                    _Bar(day: '일', h: 0),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildComparisonCard(),
        const SizedBox(height: 20),
        _buildMotivationalCard(),
        const SizedBox(height: 20),
        _buildNextGoalCard(),
        const SizedBox(height: 28),
        _buildButtons(),
      ],
    );
  }

  Widget _buildComparisonCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows_rounded, size: 16, color: AppColors.accent),
              const SizedBox(width: 10),
              Text('오늘의 기록', style: AppTypography.headlineSmall),
            ],
          ),
          const SizedBox(height: 16),
          _ComparisonRow(
            icon: Icons.arrow_upward_rounded,
            iconColor: AppColors.accent,
            text: '어제 대비 +30분',
            highlight: '+30분',
            highlightColor: AppColors.accent,
          ),
          const SizedBox(height: 10),
          _ComparisonRow(
            icon: Icons.bar_chart_rounded,
            iconColor: AppColors.primary,
            text: '이번 주 평균 대비 +45분',
            highlight: '+45분',
            highlightColor: AppColors.primary,
          ),
          const SizedBox(height: 10),
          _ComparisonRow(
            icon: Icons.workspace_premium_rounded,
            iconColor: AppColors.rankGold,
            text: '이번 달 개인 최고 기록',
            highlight: '개인 최고 기록',
            highlightColor: AppColors.rankGold,
          ),
        ],
      ),
    );
  }

  Widget _buildNextGoalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 10),
              Text('다음 목표', style: AppTypography.headlineSmall),
            ],
          ),
          const SizedBox(height: 16),
          _NextGoalItem(
            icon: Icons.menu_book_rounded,
            title: '내일 목표도 설정해보세요',
            subtitle: '영어 단어 암기 · 지난 7일 평균 2시간 26분',
          ),
          const SizedBox(height: 12),
          _NextGoalItem(
            icon: Icons.schedule_rounded,
            title: '목표 시간 3시간 30분',
            subtitle: '지난 7일 평균: 2시간 26분',
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center_rounded, size: 28, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '내일 목표도 설정해보세요',
                  style: AppTypography.headlineSmall.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  '꾸준한 학습이 실력이 됩니다.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => context.go('/student/home'),
          child: Container(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  '홈으로',
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        StudyonButton(
          label: '퇴실',
          variant: StudyonButtonVariant.secondary,
          icon: Icons.logout_rounded,
          onPressed: () => context.go('/student/home'),
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
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
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
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
    );
  }
}

class _NextGoalItem extends StatelessWidget {
  const _NextGoalItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  const _BigStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.valueColor,
    required this.iconColor,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color valueColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.headlineMedium.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.day, required this.h, this.today = false});
  final String day;
  final double h;
  final bool today;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (h > 0)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: h,
                decoration: BoxDecoration(
                  color: today
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              day,
              style: AppTypography.labelSmall.copyWith(
                color: today ? AppColors.primary : AppColors.textTertiary,
                fontWeight: today ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
