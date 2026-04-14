import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';
import 'package:studyon_client/shared/utils/snackbar_helper.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});
  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _bgImagePath;
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;
  Timer? _clockTimer;
  String _timeStr = '';
  String _dateStr = '';

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    setState(() {
      _timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      _dateStr = '${now.month}월 ${now.day}일 ${weekdays[now.weekday - 1]}요일';
    });
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _checkIn() async {
    if (_isLoading) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    _scaleCtrl.forward();
    ref.read(studentProvider.notifier).checkIn();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      showStudyonSnackbar(context, '입실 완료');
      context.go('/student/home');
    }
  }

  void _pickBackground() async {
    // Show options: presets or custom
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('배경 선택', style: AppTypography.headlineSmall),
            const SizedBox(height: 20),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _BgOption(color: AppColors.bg(ctx), label: '기본', selected: _bgImagePath == null && true,
                    onTap: () { setState(() => _bgImagePath = null); Navigator.pop(ctx); }),
                  const SizedBox(width: 10),
                  _BgOption(gradient: const [Color(0xFFE8D5F5), Color(0xFFF5E6D0)], label: '라벤더',
                    onTap: () { setState(() => _bgImagePath = 'lavender'); Navigator.pop(ctx); }),
                  const SizedBox(width: 10),
                  _BgOption(gradient: const [Color(0xFFD5E8F5), Color(0xFFE0F0E8)], label: '스카이',
                    onTap: () { setState(() => _bgImagePath = 'sky'); Navigator.pop(ctx); }),
                  const SizedBox(width: 10),
                  _BgOption(gradient: const [Color(0xFFF5E0D5), Color(0xFFF5F0D5)], label: '선셋',
                    onTap: () { setState(() => _bgImagePath = 'sunset'); Navigator.pop(ctx); }),
                  const SizedBox(width: 10),
                  _BgOption(gradient: const [Color(0xFF1A1A2E), Color(0xFF16213E)], label: '다크', isDark: true,
                    onTap: () { setState(() => _bgImagePath = 'dark'); Navigator.pop(ctx); }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _bgDecoration() {
    switch (_bgImagePath) {
      case 'lavender':
        return const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE8D5F5), Color(0xFFF5E6D0)]));
      case 'sky':
        return const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFD5E8F5), Color(0xFFE0F0E8)]));
      case 'sunset':
        return const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF5E0D5), Color(0xFFF5F0D5)]));
      case 'dark':
        return const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]));
      default:
        return BoxDecoration(color: AppColors.bg(context));
    }
  }

  bool get _isDarkBg => _bgImagePath == 'dark';
  Color get _textColor => _isDarkBg ? Colors.white : AppColors.textPrimary;
  Color get _subTextColor => _isDarkBg ? Colors.white54 : AppColors.textTertiary;

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _bgDecoration(),
        child: SafeArea(
          child: Stack(
            children: [
              // Background customize button (top right)
              Positioned(
                top: 16, right: 20,
                child: GestureDetector(
                  onTap: _pickBackground,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: (_isDarkBg ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.palette_outlined, size: 18, color: _subTextColor),
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  const Spacer(flex: 3),

                  // Time
                  Text(
                    _timeStr,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: isIPad ? 96 : 72,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                      letterSpacing: -4,
                      height: 1.0,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _dateStr,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: isIPad ? 18 : 15,
                      fontWeight: FontWeight.w400,
                      color: _subTextColor,
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Check-in: pill button (not circle)
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Semantics(
                      label: '입실하기',
                      button: true,
                      child: GestureDetector(
                        onTap: _checkIn,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: isIPad ? 56 : 50,
                          padding: EdgeInsets.symmetric(horizontal: isIPad ? 48 : 40),
                          decoration: BoxDecoration(
                            color: _isLoading
                                ? AppColors.accent
                                : (_isDarkBg ? Colors.white.withValues(alpha: 0.15) : AppColors.primary),
                            borderRadius: BorderRadius.circular(16),
                            border: _isDarkBg && !_isLoading
                                ? Border.all(color: Colors.white.withValues(alpha: 0.2))
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isLoading)
                                const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              else
                                Text(
                                  '입실하기',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _isDarkBg ? Colors.white : Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Bottom widgets - iPad widget style
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isIPad ? 80 : 32),
                    child: Row(
                      children: [
                        // Seat widget
                        Expanded(
                          child: _LockWidget(
                            isDark: _isDarkBg,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_seat_rounded, size: 16, color: _isDarkBg ? AppColors.primaryLight : AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  student.seatNo,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard', fontSize: 15, fontWeight: FontWeight.w700,
                                    color: _textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Room status widget
                        Expanded(
                          child: _LockWidget(
                            isDark: _isDarkBg,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '18',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard', fontSize: 20, fontWeight: FontWeight.w800,
                                    color: _isDarkBg ? AppColors.accent : AppColors.primary,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                                Text(
                                  '/22명',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard', fontSize: 14, fontWeight: FontWeight.w400,
                                    color: _subTextColor,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// iPad lockscreen widget style card
class _LockWidget extends StatelessWidget {
  const _LockWidget({required this.isDark, required this.child});
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

// Background preset option
class _BgOption extends StatelessWidget {
  const _BgOption({this.color, this.gradient, required this.label, this.selected = false, this.isDark = false, required this.onTap});
  final Color? color;
  final List<Color>? gradient;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: color,
              gradient: gradient != null ? LinearGradient(colors: gradient!) : null,
              borderRadius: BorderRadius.circular(14),
              border: selected ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontFamily: 'Pretendard', fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
