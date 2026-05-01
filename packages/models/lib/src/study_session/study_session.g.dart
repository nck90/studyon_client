// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudySessionImpl _$$StudySessionImplFromJson(Map<String, dynamic> json) =>
    _$StudySessionImpl(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      status: json['status'] as String,
      linkedPlanId: json['linkedPlanId'] as String?,
      startedAt: json['startedAt'] as String?,
      endedAt: json['endedAt'] as String?,
      studyMinutes: (json['studyMinutes'] as num?)?.toInt() ?? 0,
      studySeconds: (json['studySeconds'] as num?)?.toInt() ?? 0,
      breakMinutes: (json['breakMinutes'] as num?)?.toInt() ?? 0,
      breakSeconds: (json['breakSeconds'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$StudySessionImplToJson(_$StudySessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'status': instance.status,
      'linkedPlanId': instance.linkedPlanId,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
      'studyMinutes': instance.studyMinutes,
      'studySeconds': instance.studySeconds,
      'breakMinutes': instance.breakMinutes,
      'breakSeconds': instance.breakSeconds,
    };
