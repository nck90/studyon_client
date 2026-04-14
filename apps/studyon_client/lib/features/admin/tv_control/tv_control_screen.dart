import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_models/studyon_models.dart';
import '../../../shared/providers/providers.dart';

class TvControlScreen extends ConsumerStatefulWidget {
  const TvControlScreen({super.key});

  @override
  ConsumerState<TvControlScreen> createState() => _TvControlScreenState();
}

class _TvControlScreenState extends ConsumerState<TvControlScreen> {
  bool _isOn = true;
  String _displayMode = 'ranking';
  final _messageCtrl = TextEditingController(text: '오늘도 열심히 공부합시다!');

  static const _modes = [
    ('ranking', '랭킹', Icons.leaderboard_rounded),
    ('seats', '좌석 현황', Icons.event_seat_rounded),
    ('message', '공지 메시지', Icons.campaign_rounded),
    ('clock', '시계', Icons.access_time_rounded),
  ];

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tvAsync = ref.watch(tvControlProvider);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: tvAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('오류: $e', style: AppTypography.bodyMedium)),
          data: (data) {
            return _buildContent(data.rankings);
          },
        ),
      ),
    );
  }

  Widget _buildContent(List<RankingItem> rankings) {
    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildPowerControl(),
        if (_isOn) ...[
          const SizedBox(height: 20),
          _buildDisplayModeSection(),
          const SizedBox(height: 20),
          if (_displayMode == 'message') _buildMessageSection(),
          const SizedBox(height: 4),
          _buildPreview(_displayMode, rankings),
          const SizedBox(height: 20),
          _buildBrightnessSection(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TV 제어', style: AppTypography.headlineLarge),
        const SizedBox(height: 4),
        Text('자습실 TV 화면 관리', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }

  Widget _buildPowerControl() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _isOn ? AppColors.tintGreen : AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.tv_rounded,
              size: 24,
              color: _isOn ? AppColors.success : AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TV 전원', style: AppTypography.titleLarge),
                Text(
                  _isOn ? '현재 켜져 있음' : '현재 꺼져 있음',
                  style: AppTypography.bodySmall.copyWith(
                    color: _isOn ? AppColors.success : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOn,
            onChanged: (v) => setState(() => _isOn = v),
            activeThumbColor: AppColors.success,
            activeTrackColor: AppColors.tintGreen,
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.background,
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('표시 모드', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemCount: _modes.length,
          itemBuilder: (_, i) {
            final (value, label, icon) = _modes[i];
            final isActive = _displayMode == value;
            return GestureDetector(
              onTap: () => setState(() => _displayMode = value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.tintPurple : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.cardBorder,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: isActive ? AppColors.primary : AppColors.textTertiary),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: AppTypography.titleMedium.copyWith(
                        color: isActive ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('공지 메시지', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _messageCtrl,
                maxLines: 3,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'TV에 표시할 메시지를 입력하세요',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 14),
              StudyonButton(
                label: '메시지 전송',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('메시지가 전송되었어요', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ));
                },
                variant: StudyonButtonVariant.primary,
                icon: Icons.send_rounded,
                isExpanded: false,
                isSmall: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(String mode, List<RankingItem> rankings) {
    final modeLabels = {
      'ranking': '랭킹 미리보기',
      'seats': '좌석 현황 미리보기',
      'message': '메시지 미리보기',
      'clock': '시계 미리보기',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(modeLabels[mode] ?? '미리보기', style: AppTypography.headlineSmall),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkBg,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          padding: const EdgeInsets.all(20),
          child: _buildPreviewContent(mode, rankings),
        ),
      ],
    );
  }

  Widget _buildPreviewContent(String mode, List<RankingItem> rankings) {
    switch (mode) {
      case 'ranking':
        final top3 = rankings.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '실시간 랭킹 TOP 3',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard',
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            ...top3.map((item) {
              final colors = [AppColors.rankGold, AppColors.rankSilver, AppColors.rankBronze];
              final color = item.rankNo <= 3 ? colors[item.rankNo - 1] : Colors.white70;
              final hours = item.score ~/ 60;
              final mins = item.score % 60;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Text(
                      '${item.rankNo}',
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.studentName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                    Text(
                      hours > 0 ? '$hours시간 $mins분' : '$mins분',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );

      case 'seats':
        // 5×8 dot grid representing seats
        const totalSeats = 40;
        const occupiedSeats = 27;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '좌석 현황',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard',
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$occupiedSeats / $totalSeats 석',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemCount: totalSeats,
                itemBuilder: (_, i) => Container(
                  decoration: BoxDecoration(
                    color: i < occupiedSeats
                        ? AppColors.accent.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );

      case 'message':
        final msg = _messageCtrl.text.trim().isEmpty
            ? '메시지를 입력하세요'
            : _messageCtrl.text;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.campaign_rounded, color: Colors.white54, size: 28),
              const SizedBox(height: 12),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                  height: 1.5,
                ),
              ),
            ],
          ),
        );

      case 'clock':
        final now = DateTime.now();
        final h = now.hour.toString().padLeft(2, '0');
        final m = now.minute.toString().padLeft(2, '0');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$h:$m',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w300,
                  fontFamily: 'Pretendard',
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBrightnessSection() {
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
              const Icon(Icons.brightness_6_rounded, size: 18, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Text('빠른 제어', style: AppTypography.titleLarge),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StudyonButton(
                  label: '화면 갱신',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('화면이 갱신되었어요', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
                      backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                  variant: StudyonButtonVariant.secondary,
                  icon: Icons.refresh_rounded,
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StudyonButton(
                  label: '전체화면',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('전체화면으로 전환되었어요', style: TextStyle(fontFamily: 'Pretendard', fontWeight: FontWeight.w600)),
                      backgroundColor: AppColors.accent, behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                  variant: StudyonButtonVariant.secondary,
                  icon: Icons.fullscreen_rounded,
                  isSmall: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
