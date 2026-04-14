import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_plan.freezed.dart';
part 'study_plan.g.dart';

@freezed
class StudyPlan with _$StudyPlan {
  const StudyPlan._();
  const factory StudyPlan({
    required String id,
    required String studentId,
    required String planDate,
    required String subjectName,
    required String title,
    String? description,
    @Default(0) int targetMinutes,
    @Default('medium') String priority,
    @Default('pending') String status,
  }) = _StudyPlan;

  factory StudyPlan.fromJson(Map<String, dynamic> json) =>
      _$StudyPlanFromJson(json);
}

@freezed
class CreateStudyPlanRequest with _$CreateStudyPlanRequest {
  const CreateStudyPlanRequest._();
  const factory CreateStudyPlanRequest({
    required String planDate,
    required String subjectName,
    required String title,
    String? description,
    @Default(0) int targetMinutes,
    @Default('medium') String priority,
  }) = _CreateStudyPlanRequest;

  factory CreateStudyPlanRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateStudyPlanRequestFromJson(json);
}
