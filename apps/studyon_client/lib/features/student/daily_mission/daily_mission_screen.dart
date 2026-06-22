import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_design_system/studyon_design_system.dart';

import '../../../shared/providers/student_providers.dart';
import '../../../shared/services/local_mission_notification_service.dart';

class DailyMissionScreen extends ConsumerStatefulWidget {
  const DailyMissionScreen({super.key});

  @override
  ConsumerState<DailyMissionScreen> createState() => _DailyMissionScreenState();
}

class _DailyMissionScreenState extends ConsumerState<DailyMissionScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = LocalMissionNotificationService.instance;
      if (service.openedFromNotification) {
        service.consumeNotificationOpenFlag();
        ref.read(studentProvider.notifier).recordAppEvent('NOTIFICATION_OPEN');
      }
      ref.read(studentProvider.notifier).recordAppEvent('DAILY_MISSION_VIEW');
    });
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final mission = student.dailyMission;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: const Text('오늘 미션'),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(studentProvider.notifier).hydrate(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _MissionHero(mission: mission),
            const SizedBox(height: 16),
            _MissionActionPanel(
              mission: mission,
              busy: _busy,
              onGenerate: _run(
                () => ref.read(studentProvider.notifier).generateDailyMission(),
              ),
              onComplete: mission == null
                  ? null
                  : () => _completeMission(mission.id),
            ),
            const SizedBox(height: 16),
            _ReminderPanel(
              mission: mission,
              onChanged: (enabled, time) async {
                await ref
                    .read(studentProvider.notifier)
                    .updateDailyMissionReminder(enabled: enabled, time: time);
              },
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback _run(Future<void> Function() action) {
    return () async {
      if (_busy) return;
      setState(() => _busy = true);
      try {
        await action();
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    };
  }

  Future<void> _completeMission(String missionId) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final reward = await ref
          .read(studentProvider.notifier)
          .completeDailyMission(missionId);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        backgroundColor: AppColors.card(context),
        builder: (_) => _MissionRewardSheet(reward: reward),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _MissionHero extends StatelessWidget {
  const _MissionHero({required this.mission});
  final DailyMissionItem? mission;

  @override
  Widget build(BuildContext context) {
    final completed = mission?.isCompleted == true;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: completed ? AppColors.success : AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.local_fire_department_rounded,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(height: 18),
          Text(
            mission?.title ?? '오늘 미션을 준비해 주세요',
            style: AppTypography.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            mission == null
                ? '로드맵과 템플릿을 기준으로 오늘 루틴을 만들어요.'
                : '${mission!.subjectName} · ${mission!.targetMinutes}분',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionActionPanel extends StatelessWidget {
  const _MissionActionPanel({
    required this.mission,
    required this.busy,
    required this.onGenerate,
    required this.onComplete,
  });
  final DailyMissionItem? mission;
  final bool busy;
  final VoidCallback onGenerate;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final completed = mission?.isCompleted == true;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: busy ? null : onGenerate,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(mission == null ? '오늘 미션 만들기' : '미션 새로고침'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: busy || completed ? null : onComplete,
            icon: Icon(
              completed ? Icons.check_rounded : Icons.add_task_rounded,
            ),
            label: Text(completed ? '완료됨' : '미션 완료'),
          ),
        ],
      ),
    );
  }
}

class _ReminderPanel extends StatefulWidget {
  const _ReminderPanel({required this.mission, required this.onChanged});
  final DailyMissionItem? mission;
  final Future<void> Function(bool enabled, String time) onChanged;

  @override
  State<_ReminderPanel> createState() => _ReminderPanelState();
}

class _ReminderPanelState extends State<_ReminderPanel> {
  late bool _enabled;
  late String _time;

  @override
  void initState() {
    super.initState();
    _enabled = widget.mission?.reminderEnabled ?? true;
    _time = widget.mission?.reminderTime ?? '20:00';
  }

  @override
  void didUpdateWidget(covariant _ReminderPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mission?.id != widget.mission?.id) {
      _enabled = widget.mission?.reminderEnabled ?? true;
      _time = widget.mission?.reminderTime ?? '20:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _enabled,
            onChanged: (value) async {
              setState(() => _enabled = value);
              await widget.onChanged(_enabled, _time);
            },
            title: const Text('미션 알림'),
            subtitle: Text(_time),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.schedule_rounded),
              label: const Text('알림 시간 변경'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTime() async {
    final parts = _time.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 20,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      ),
    );
    if (picked == null) return;
    final next =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(() => _time = next);
    await widget.onChanged(_enabled, _time);
  }
}

class _MissionRewardSheet extends StatelessWidget {
  const _MissionRewardSheet({required this.reward});

  final Map<String, dynamic> reward;

  @override
  Widget build(BuildContext context) {
    final rewardData =
        (reward['reward'] as Map?)?.cast<String, dynamic>() ??
        (reward['xpReward'] as Map?)?.cast<String, dynamic>() ??
        reward;
    final points =
        (rewardData['points'] as num?)?.toInt() ??
        (rewardData['pointsAwarded'] as num?)?.toInt() ??
        0;
    final xp = (rewardData['xp'] as num?)?.toInt() ?? 0;
    final level = (rewardData['level'] as num?)?.toInt() ?? 1;
    final leveledUp = rewardData['leveledUp'] == true;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              leveledUp ? Icons.auto_awesome_rounded : Icons.bolt_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            leveledUp ? '레벨 $level 달성' : '오늘 퀘스트 완료',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '+$points 포인트 · +$xp XP',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _panelDecoration(BuildContext context) {
  return BoxDecoration(
    color: AppColors.card(context),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.cardBorder),
  );
}
