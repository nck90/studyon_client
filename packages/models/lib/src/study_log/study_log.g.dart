// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudyLogImpl _$$StudyLogImplFromJson(Map<String, dynamic> json) =>
    _$StudyLogImpl(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      logDate: json['logDate'] as String,
      subjectName: json['subjectName'] as String,
      planId: json['planId'] as String?,
      studySessionId: json['studySessionId'] as String?,
      pagesCompleted: (json['pagesCompleted'] as num?)?.toInt() ?? 0,
      problemsSolved: (json['problemsSolved'] as num?)?.toInt() ?? 0,
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      memo: json['memo'] as String?,
    );

Map<String, dynamic> _$$StudyLogImplToJson(_$StudyLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'logDate': instance.logDate,
      'subjectName': instance.subjectName,
      'planId': instance.planId,
      'studySessionId': instance.studySessionId,
      'pagesCompleted': instance.pagesCompleted,
      'problemsSolved': instance.problemsSolved,
      'progressPercent': instance.progressPercent,
      'isCompleted': instance.isCompleted,
      'memo': instance.memo,
    };

_$CreateStudyLogRequestImpl _$$CreateStudyLogRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateStudyLogRequestImpl(
  logDate: json['logDate'] as String,
  subjectName: json['subjectName'] as String,
  planId: json['planId'] as String?,
  studySessionId: json['studySessionId'] as String?,
  pagesCompleted: (json['pagesCompleted'] as num?)?.toInt() ?? 0,
  problemsSolved: (json['problemsSolved'] as num?)?.toInt() ?? 0,
  progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0,
  isCompleted: json['isCompleted'] as bool? ?? false,
  memo: json['memo'] as String?,
);

Map<String, dynamic> _$$CreateStudyLogRequestImplToJson(
  _$CreateStudyLogRequestImpl instance,
) => <String, dynamic>{
  'logDate': instance.logDate,
  'subjectName': instance.subjectName,
  'planId': instance.planId,
  'studySessionId': instance.studySessionId,
  'pagesCompleted': instance.pagesCompleted,
  'problemsSolved': instance.problemsSolved,
  'progressPercent': instance.progressPercent,
  'isCompleted': instance.isCompleted,
  'memo': instance.memo,
};
