import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyon_design_system/studyon_design_system.dart';
import 'package:studyon_client/shared/providers/student_providers.dart';

class GoalRoadmapScreen extends ConsumerStatefulWidget {
  const GoalRoadmapScreen({super.key});

  @override
  ConsumerState<GoalRoadmapScreen> createState() => _GoalRoadmapScreenState();
}

class _GoalRoadmapScreenState extends ConsumerState<GoalRoadmapScreen> {
  final _targetController = TextEditingController();
  DateTime? _targetDate;
  bool _reminderEnabled = true;
  String _reminderTime = '20:00';
  bool _saving = false;

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(studentProvider);
    final roadmap = student.goalRoadmap;
    if (_targetController.text.isEmpty) {
      _targetController.text =
          roadmap?.targetName ?? student.targetUniversityName.ifEmpty('목표 대학');
      _targetDate = roadmap?.targetDate;
      _reminderEnabled = roadmap?.reminderEnabled ?? true;
      _reminderTime = roadmap?.reminderTime ?? '20:00';
    }

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        title: const Text('D-day 로드맵'),
        backgroundColor: AppColors.bg(context),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _RoadmapHeader(roadmap: roadmap),
          const SizedBox(height: 16),
          _SetupPanel(
            controller: _targetController,
            targetDate: _targetDate,
            reminderEnabled: _reminderEnabled,
            reminderTime: _reminderTime,
            saving: _saving,
            onDateTap: _pickDate,
            onReminderChanged: (value) {
              setState(() => _reminderEnabled = value);
            },
            onSave: _saveRoadmap,
          ),
          if (roadmap?.currentMission != null) ...[
            const SizedBox(height: 16),
            _MissionPanel(
              mission: roadmap!.currentMission!,
              onAccept: () => ref
                  .read(studentProvider.notifier)
                  .acceptRoadmapMission(roadmap.currentMission!.id),
            ),
          ],
          const SizedBox(height: 16),
          _MilestoneList(milestones: roadmap?.milestones ?? const []),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now.add(const Duration(days: 100)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 1200)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _saveRoadmap() async {
    final targetName = _targetController.text.trim();
    if (targetName.isEmpty || _targetDate == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(studentProvider.notifier)
          .saveGoalRoadmap(
            targetName: targetName,
            targetDate: _targetDate!,
            reminderEnabled: _reminderEnabled,
            reminderTime: _reminderTime,
          );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _RoadmapHeader extends StatelessWidget {
  const _RoadmapHeader({required this.roadmap});
  final GoalRoadmapItem? roadmap;

  @override
  Widget build(BuildContext context) {
    final daysLeft = roadmap?.daysLeft;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            roadmap?.targetName ?? '목표를 설정해 주세요',
            style: AppTypography.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            daysLeft == null ? 'D-day 없음' : 'D-$daysLeft',
            style: AppTypography.displayMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: ((roadmap?.progressPercent ?? 0) / 100).clamp(0.0, 1.0),
            color: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.24),
            minHeight: 8,
            borderRadius: BorderRadius.circular(99),
          ),
        ],
      ),
    );
  }
}

class _SetupPanel extends StatelessWidget {
  const _SetupPanel({
    required this.controller,
    required this.targetDate,
    required this.reminderEnabled,
    required this.reminderTime,
    required this.saving,
    required this.onDateTap,
    required this.onReminderChanged,
    required this.onSave,
  });

  final TextEditingController controller;
  final DateTime? targetDate;
  final bool reminderEnabled;
  final String reminderTime;
  final bool saving;
  final VoidCallback onDateTap;
  final ValueChanged<bool> onReminderChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: '목표',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDateTap,
                  icon: const Icon(Icons.event_rounded, size: 18),
                  label: Text(_dateLabel(targetDate)),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: saving ? null : onSave,
                child: Text(saving ? '저장 중' : '저장'),
              ),
            ],
          ),
          const Divider(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: reminderEnabled,
            onChanged: onReminderChanged,
            title: const Text('저녁 알림'),
            subtitle: Text(reminderTime),
          ),
        ],
      ),
    );
  }
}

class _MissionPanel extends StatelessWidget {
  const _MissionPanel({required this.mission, required this.onAccept});
  final RoadmapMissionItem mission;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final accepted = mission.status != 'RECOMMENDED';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _panelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mission.title,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${mission.focusSubjects.join(' · ')} · ${mission.targetMinutes}분',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: accepted ? null : onAccept,
              icon: Icon(
                accepted ? Icons.check_rounded : Icons.add_task_rounded,
              ),
              label: Text(accepted ? '수락됨' : '이번 주 계획에 추가'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneList extends StatelessWidget {
  const _MilestoneList({required this.milestones});
  final List<RoadmapMilestoneItem> milestones;

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _panelDecoration(context),
        child: Text(
          '저장 후 월간 로드맵이 생성됩니다.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '월간 로드맵',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...milestones.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: _panelDecoration(context),
            child: Row(
              children: [
                const Icon(Icons.flag_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.focusSubjects.join(' · ')} · 주 ${item.targetMinutes}분',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

String _dateLabel(DateTime? value) {
  if (value == null) return '목표일';
  return '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
