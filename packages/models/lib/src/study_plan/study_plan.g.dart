// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudyPlanImpl _$$StudyPlanImplFromJson(Map<String, dynamic> json) =>
    _$StudyPlanImpl(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      planDate: json['planDate'] as String,
      subjectName: json['subjectName'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      targetMinutes: (json['targetMinutes'] as num?)?.toInt() ?? 0,
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$StudyPlanImplToJson(_$StudyPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'planDate': instance.planDate,
      'subjectName': instance.subjectName,
      'title': instance.title,
      'description': instance.description,
      'targetMinutes': instance.targetMinutes,
      'priority': instance.priority,
      'status': instance.status,
    };

_$CreateStudyPlanRequestImpl _$$CreateStudyPlanRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateStudyPlanRequestImpl(
  planDate: json['planDate'] as String,
  subjectName: json['subjectName'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  targetMinutes: (json['targetMinutes'] as num?)?.toInt() ?? 0,
  priority: json['priority'] as String? ?? 'medium',
);

Map<String, dynamic> _$$CreateStudyPlanRequestImplToJson(
  _$CreateStudyPlanRequestImpl instance,
) => <String, dynamic>{
  'planDate': instance.planDate,
  'subjectName': instance.subjectName,
  'title': instance.title,
  'description': instance.description,
  'targetMinutes': instance.targetMinutes,
  'priority': instance.priority,
};
