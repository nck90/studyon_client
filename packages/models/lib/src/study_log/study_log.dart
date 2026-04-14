import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_log.freezed.dart';
part 'study_log.g.dart';

@freezed
class StudyLog with _$StudyLog {
  const StudyLog._();
  const factory StudyLog({
    required String id,
    required String studentId,
    required String logDate,
    required String subjectName,
    String? planId,
    String? studySessionId,
    @Default(0) int pagesCompleted,
    @Default(0) int problemsSolved,
    @Default(0) double progressPercent,
    @Default(false) bool isCompleted,
    String? memo,
  }) = _StudyLog;

  factory StudyLog.fromJson(Map<String, dynamic> json) =>
      _$StudyLogFromJson(json);
}

@freezed
class CreateStudyLogRequest with _$CreateStudyLogRequest {
  const CreateStudyLogRequest._();
  const factory CreateStudyLogRequest({
    required String logDate,
    required String subjectName,
    String? planId,
    String? studySessionId,
    @Default(0) int pagesCompleted,
    @Default(0) int problemsSolved,
    @Default(0) double progressPercent,
    @Default(false) bool isCompleted,
    String? memo,
  }) = _CreateStudyLogRequest;

  factory CreateStudyLogRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateStudyLogRequestFromJson(json);
}
