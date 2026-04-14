import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_session.freezed.dart';
part 'study_session.g.dart';

@freezed
class StudySession with _$StudySession {
  const StudySession._();
  const factory StudySession({
    required String id,
    required String studentId,
    required String status,
    String? linkedPlanId,
    String? startedAt,
    String? endedAt,
    @Default(0) int studyMinutes,
    @Default(0) int breakMinutes,
  }) = _StudySession;

  factory StudySession.fromJson(Map<String, dynamic> json) =>
      _$StudySessionFromJson(json);
}
