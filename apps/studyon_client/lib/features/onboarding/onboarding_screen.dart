import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_client/shared/services/local_storage.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  int _page = 0;

  late final AnimationController _heroController;
  late final AnimationController _contentController;
  late final AnimationController _floatController;

  static const _brandGrad = [Color(0xFF6C5CE7), Color(0xFFA29BFE)];
  static const _brandBg = Color(0xFFF0EEFF);

  final _pages = const [
    _PageData(
      icon: Icons.timer_rounded,
      gradColors: _brandGrad,
      bgAccent: _brandBg,
      title: '학습 시간 관리',
      subtitle: '공부 시작부터 종료까지\n자동으로 기록하고 분석해요',
      features: ['실시간 타이머', '자동 기록', '일별 리포트'],
      featureIcons: [Icons.auto_graph_rounded, Icons.schedule_rounded, Icons.insights_rounded],
    ),
    _PageData(
      icon: Icons.event_seat_rounded,
      gradColors: _brandGrad,
      bgAccent: _brandBg,
      title: '스마트 좌석',
      subtitle: '실시간 좌석 현황을 확인하고\n원하는 자리에 바로 착석해요',
      features: ['실시간 현황', 'QR 체크인', '자리 변경'],
      featureIcons: [Icons.qr_code_scanner_rounded, Icons.grid_view_rounded, Icons.swap_horiz_rounded],
    ),
    _PageData(
      icon: Icons.emoji_events_rounded,
      gradColors: _brandGrad,
      bgAccent: _brandBg,
      title: '랭킹 & 성장',
      subtitle: '친구들과 함께 경쟁하며\n매일 성장하는 나를 확인해요',
      features: ['일간 랭킹', '연속 출석', '뱃지 수집'],
      featureIcons: [Icons.leaderboard_rounded, Icons.local_fire_department_rounded, Icons.military_tech_rounded],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _heroController.forward();
    _contentController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _heroController.dispose();
    _contentController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _page = i);
    _heroController.reset();
    _contentController.reset();
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _contentController.forward();
    });
  }

  void _goToLogin() async {
    await LocalStorage.setOnboardingDone();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final p = _pages[_page];
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  p.bgAccent.withValues(alpha: 0.5),
                  Colors.white,
                  Colors.white,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: p.gradColors[0],
                        ),
                        child: Text('${_page + 1} / 3'),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Row(
                          children: List.generate(3, (i) {
                            return Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                height: 4,
                                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                                decoration: BoxDecoration(
                                  color: i <= _page
                                      ? p.gradColors[0]
                                      : const Color(0xFFEEECF5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: _goToLogin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F3F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '건너뛰기',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, i) {
                      final page = _pages[i];
                      return _OnboardingPage(
                        page: page,
                        isTablet: isTablet,
                        heroController: _heroController,
                        contentController: _contentController,
                        floatController: _floatController,
                      );
                    },
                  ),
                ),

                // Bottom
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 60 : 32, 8,
                    isTablet ? 60 : 32,
                    isTablet ? 44 : 32,
                  ),
                  child: GestureDetector(
                    onTap: _page == 2
                        ? _goToLogin
                        : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: double.infinity,
                      height: isTablet ? 58 : 54,
                      constraints: const BoxConstraints(maxWidth: 420),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: p.gradColors),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: p.gradColors[0].withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _page == 2 ? '시작하기' : '다음',
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (_page == 2) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 18, color: Colors.white),
                          ],
                        ],
                      ),
                    ),
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

class _OnboardingPage extends StatelessWidget {
  final _PageData page;
  final bool isTablet;
  final AnimationController heroController;
  final AnimationController contentController;
  final AnimationController floatController;

  const _OnboardingPage({
    required this.page,
    required this.isTablet,
    required this.heroController,
    required this.contentController,
    required this.floatController,
  });

  @override
  Widget build(BuildContext context) {
    final heroSize = isTablet ? 130.0 : 110.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Hero
          ScaleTransition(
            scale: CurvedAnimation(
              parent: heroController,
              curve: Curves.easeOutBack,
            ),
            child: SizedBox(
              width: heroSize + 80,
              height: heroSize + 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow
                  Container(
                    width: heroSize + 60,
                    height: heroSize + 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: page.gradColors[0].withValues(alpha: 0.06),
                    ),
                  ),
                  // Main circle
                  Container(
                    width: heroSize,
                    height: heroSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: page.gradColors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: page.gradColors[0].withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(
                      page.icon,
                      size: heroSize * 0.38,
                      color: Colors.white,
                    ),
                  ),
                  // Orbiting icons
                  ...List.generate(3, (j) {
                    final angle = (j * 120 - 30) * pi / 180;
                    final radius = heroSize * 0.52;
                    return AnimatedBuilder(
                      animation: floatController,
                      builder: (context, _) {
                        final wobble = sin(floatController.value * pi * 2 + j * 2.1) * 3;
                        final cx = (heroSize + 80) / 2;
                        final cy = (heroSize + 80) / 2;
                        return Positioned(
                          left: cx + cos(angle) * radius - 16 + wobble,
                          top: cy + sin(angle) * radius - 16,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              page.featureIcons[j],
                              size: 14,
                              color: page.gradColors[0],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          SizedBox(height: isTablet ? 40 : 32),

          // Content
          FadeTransition(
            opacity: CurvedAnimation(
              parent: contentController,
              curve: Curves.easeOut,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.12),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: contentController,
                curve: Curves.easeOut,
              )),
              child: Column(
                children: [
                  Text(
                    page.title,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: isTablet ? 32 : 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    page.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Feature cards row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 18 : 14,
                          vertical: isTablet ? 12 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: page.gradColors[0].withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: page.gradColors[0].withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: isTablet ? 36 : 30,
                              height: isTablet ? 36 : 30,
                              decoration: BoxDecoration(
                                color: page.gradColors[0].withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                page.featureIcons[i],
                                size: isTablet ? 18 : 14,
                                color: page.gradColors[0],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              page.features[i],
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: isTablet ? 12 : 11,
                                fontWeight: FontWeight.w600,
                                color: page.gradColors[0],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _PageData {
  final IconData icon;
  final List<Color> gradColors;
  final Color bgAccent;
  final String title;
  final String subtitle;
  final List<String> features;
  final List<IconData> featureIcons;

  const _PageData({
    required this.icon,
    required this.gradColors,
    required this.bgAccent,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.featureIcons,
  });
}
