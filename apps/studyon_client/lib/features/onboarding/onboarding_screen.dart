import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_client/shared/services/local_storage.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _PageData(
      icon: Icons.timer_rounded,
      color: AppColors.primary,
      bg: AppColors.tintPurple,
      title: '학습 관리',
      subtitle: '공부 시작부터 종료까지\n자동으로 기록해요',
    ),
    _PageData(
      icon: Icons.event_seat_rounded,
      color: AppColors.accent,
      bg: AppColors.tintMint,
      title: '좌석 관리',
      subtitle: '실시간 좌석 현황을\n한눈에 확인해요',
    ),
    _PageData(
      icon: Icons.leaderboard_rounded,
      color: AppColors.warm,
      bg: AppColors.tintYellow,
      title: '랭킹',
      subtitle: '친구들과 함께\n성장해요',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Text(
                    '건너뛰기',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: p.bg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(p.icon, size: 56, color: p.color),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        p.title,
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        p.subtitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textTertiary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _page == i ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _page == i
                              ? AppColors.primary
                              : AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_page == 2)
                    GestureDetector(
                      onTap: () async {
                        await LocalStorage.setOnboardingDone();
                        if (context.mounted) context.go('/login');
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            '시작하기',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        constraints: const BoxConstraints(maxWidth: 400),
                        decoration: BoxDecoration(
                          color: AppColors.tintPurple,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            '다음',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
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

class _PageData {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String subtitle;

  const _PageData({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.subtitle,
  });
}
