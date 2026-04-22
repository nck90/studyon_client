import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';
import 'package:studyon_client/shared/services/local_storage.dart';
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
  late final Future<({int checkedInStudentCount, int totalActiveStudents})>
      _lobbyStatsFuture;
  String? _backgroundPath;
  bool _isChangingBackground = false;

  // Swipe up state
  double _dragOffset = 0;
  late final AnimationController _hintCtrl;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    _lobbyStatsFuture = ref.read(studentRepositoryProvider).getCheckInLobbyStats();
    _hintCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    unawaited(_loadBackgroundPath());
  }

  Future<void> _loadBackgroundPath() async {
    final path = await LocalStorage.getCheckInBackgroundPath();
    if (!mounted) return;
    if (path == null || path.isEmpty) return;
    final file = File(path);
    if (await file.exists()) {
      setState(() => _backgroundPath = path);
      return;
    }
    await LocalStorage.clearCheckInBackgroundPath();
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

  Future<void> _checkIn() async {
    HapticFeedback.heavyImpact();
    setState(() => _isChecking = true);
    _hintCtrl.stop();
    try {
      await ref.read(studentProvider.notifier).checkIn();
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        showStudyonSnackbar(context, '입실 완료');
        context.go('/student/home');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _dragOffset = 0;
        });
        _hintCtrl.repeat(reverse: true);
        showStudyonSnackbar(context, '입실 처리에 실패했어요', isError: true);
      }
    }
  }

  Future<void> _showBackgroundOptions() async {
    if (_isChangingBackground) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1D1C29),
      builder: (context) {
        final hasCustomBackground = _backgroundPath != null;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '입실 화면 배경',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 14),
                _BackgroundActionTile(
                  icon: Icons.photo_library_outlined,
                  label: '사진에서 선택',
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickBackgroundImage();
                  },
                ),
                if (hasCustomBackground) ...[
                  const SizedBox(height: 10),
                  _BackgroundActionTile(
                    icon: Icons.restart_alt_rounded,
                    label: '기본 배경으로 되돌리기',
                    onTap: () async {
                      Navigator.of(context).pop();
                      await _resetBackgroundImage();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickBackgroundImage() async {
    setState(() => _isChangingBackground = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
        maxWidth: 2200,
      );
      if (picked == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final targetPath = '${dir.path}/checkin_background${_extensionFor(picked.path)}';
      final copied = await File(picked.path).copy(targetPath);
      await LocalStorage.setCheckInBackgroundPath(copied.path);
      if (!mounted) return;
      setState(() => _backgroundPath = copied.path);
      showStudyonSnackbar(context, '입실 배경을 변경했어요');
    } catch (_) {
      if (!mounted) return;
      showStudyonSnackbar(context, '배경 이미지를 바꾸지 못했어요', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isChangingBackground = false);
      }
    }
  }

  Future<void> _resetBackgroundImage() async {
    final oldPath = _backgroundPath;
    await LocalStorage.clearCheckInBackgroundPath();
    if (oldPath != null) {
      unawaited(_deleteIfExists(oldPath));
    }
    if (!mounted) return;
    setState(() => _backgroundPath = null);
    showStudyonSnackbar(context, '기본 배경으로 되돌렸어요');
  }

  Future<void> _deleteIfExists(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  String _extensionFor(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0) return '.jpg';
    return path.substring(dot);
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final isIPad = MediaQuery.of(context).size.shortestSide >= 600;
    final swipeProgress = (_dragOffset / 200).clamp(0.0, 1.0);
    final widgetWidth = isIPad ? 170.0 : 148.0;
    final widgetHeight = isIPad ? 92.0 : 82.0;

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
              Positioned.fill(
                child: _backgroundPath == null
                    ? Image.asset(
                        'assets/images/lockscreen_bg.jpg',
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_backgroundPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/lockscreen_bg.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: _showBackgroundOptions,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                                  child: Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.22),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: _isChangingBackground
                                        ? const Padding(
                                            padding: EdgeInsets.all(12),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.photo_library_outlined,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                              fontSize: isIPad ? 116 : 86,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -2.6,
                              height: 1.0,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              ':',
                              style: TextStyle(
                                fontSize: isIPad ? 108 : 80,
                                fontWeight: FontWeight.w300,
                                color: Colors.white.withValues(alpha: 0.7),
                                height: 1.0,
                              ),
                            ),
                          ),
                          Text(
                            _minStr,
                            style: TextStyle(
                              fontSize: isIPad ? 116 : 86,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -2.6,
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
                          fontSize: isIPad ? 22 : 18,
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
                            width: widgetWidth,
                            height: widgetHeight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.event_seat_rounded, size: 24, color: Colors.white60),
                                const SizedBox(height: 6),
                                Text(
                                  student.seatNo.isEmpty ? '미배정' : student.seatNo,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          _FrostedWidget(
                            width: widgetWidth,
                            height: widgetHeight,
                            child: FutureBuilder<
                                ({int checkedInStudentCount, int totalActiveStudents})>(
                              future: _lobbyStatsFuture,
                              builder: (context, snapshot) {
                                final stats = snapshot.data;
                                final checkedIn =
                                    stats?.checkedInStudentCount ?? 0;
                                final total =
                                    stats?.totalActiveStudents ?? 0;

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.people_outline_rounded, size: 24, color: Colors.white60),
                                    const SizedBox(height: 6),
                                    if (snapshot.connectionState == ConnectionState.waiting)
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white70,
                                        ),
                                      )
                                    else
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '$checkedIn',
                                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, fontFeatures: [FontFeature.tabularFigures()]),
                                          ),
                                          Text(
                                            '/$total명',
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.58)),
                                          ),
                                        ],
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Bottom: swipe hint with float animation (also tappable for a11y)
                      if (!_isChecking) ...[
                        Semantics(
                          container: true,
                          button: true,
                          identifier: 'checkin-action',
                          label: '입실하기',
                          hint: '위로 올려서 입실하거나 두 번 탭하세요',
                          onTap: _checkIn,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _checkIn,
                            child: AnimatedBuilder(
                              animation: CurvedAnimation(
                                parent: _hintCtrl,
                                curve: Curves.easeInOutSine,
                              ),
                              builder: (context, _) => Transform.translate(
                                offset: Offset(0, -10 * _hintCtrl.value),
                                child: Opacity(
                                  opacity: 0.72 + 0.22 * _hintCtrl.value,
                                  child: Column(
                                    children: [
                                      ExcludeSemantics(
                                        child: Icon(
                                          Icons.keyboard_arrow_up_rounded,
                                          size: 48,
                                          color: Colors.white.withValues(alpha: 0.86),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const ExcludeSemantics(
                                        child: Text(
                                          '위로 올려서 입실',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(
                          width: 28, height: 28,
                          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '입실 중',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white70),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Home indicator bar - wider
                      Container(
                        width: 270,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(4),
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

class _BackgroundActionTile extends StatelessWidget {
  const _BackgroundActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
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
