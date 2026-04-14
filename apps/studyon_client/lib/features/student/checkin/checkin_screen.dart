import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';
import 'package:studyon_client/shared/utils/snackbar_helper.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});
  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen>
    with TickerProviderStateMixin {
  Timer? _clockTimer;
  String _hourStr = '';
  String _minStr = '';
  String _dateStr = '';
  bool _isChecking = false;

  // Swipe up state
  double _dragOffset = 0;
  late final AnimationController _hintCtrl;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    _hintCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  void _updateTime() {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    setState(() {
      _hourStr = now.hour.toString().padLeft(2, '0');
      _minStr = now.minute.toString().padLeft(2, '0');
      _dateStr = '${now.month}월 ${now.day}일 ${weekdays[now.weekday - 1]}요일';
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _hintCtrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isChecking) return;
    setState(() {
      _dragOffset = (_dragOffset - details.delta.dy).clamp(0.0, 200.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isChecking) return;
    if (_dragOffset > 100) {
      _checkIn();
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  void _checkIn() async {
    HapticFeedback.heavyImpact();
    setState(() => _isChecking = true);
    _hintCtrl.stop();
    ref.read(studentProvider.notifier).checkIn();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      showStudyonSnackbar(context, '입실 완료');
      context.go('/student/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final swipeProgress = (_dragOffset / 200).clamp(0.0, 1.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: GestureDetector(
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                'assets/images/lockscreen_bg.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

              // Dim overlay (gets darker as you swipe)
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                color: Colors.black.withValues(alpha: 0.2 + 0.3 * swipeProgress),
              ),

              // Content moves up as you swipe
              SafeArea(
                child: Transform.translate(
                  offset: Offset(0, -_dragOffset * 0.3),
                  child: Column(
                    children: [
                      SizedBox(height: isIPad ? 60 : 40),

                      // Clock - SF Pro style (system font on iOS)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _hourStr,
                            style: TextStyle(
                              fontSize: isIPad ? 104 : 76,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -2,
                              height: 1.0,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: isIPad ? 96 : 70,
                                fontWeight: FontWeight.w300,
                                color: Colors.white.withValues(alpha: 0.7),
                                height: 1.0,
                              ),
                            ),
                          ),
                          Text(
                            _minStr,
                            style: TextStyle(
                              fontSize: isIPad ? 104 : 76,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -2,
                              height: 1.0,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Date
                      Text(
                        _dateStr,
                        style: TextStyle(
                          fontSize: isIPad ? 20 : 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Widgets - iPad style square-ish cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _FrostedWidget(
                            width: isIPad ? 150 : 130,
                            height: isIPad ? 80 : 70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.event_seat_rounded, size: 20, color: Colors.white60),
                                const SizedBox(height: 6),
                                Text(
                                  student.seatNo,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          _FrostedWidget(
                            width: isIPad ? 150 : 130,
                            height: isIPad ? 80 : 70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people_outline_rounded, size: 20, color: Colors.white60),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('18', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()])),
                                    Text('/22명', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.5))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Bottom: swipe hint with float animation
                      if (!_isChecking) ...[
                        AnimatedBuilder(
                          animation: _hintCtrl,
                          builder: (context, _) => Transform.translate(
                            offset: Offset(0, -6 * _hintCtrl.value),
                            child: Opacity(
                              opacity: 0.5 + 0.4 * _hintCtrl.value,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    size: 32,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    '위로 올려서 입실',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '입실 중',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white70),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Home indicator bar - wider
                      Container(
                        width: 180,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Frosted glass widget - like iPadOS lockscreen widgets
class _FrostedWidget extends StatelessWidget {
  const _FrostedWidget({required this.child, this.width, this.height});
  final Widget child;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.5),
          ),
          child: child,
        ),
      ),
    );
  }
}
