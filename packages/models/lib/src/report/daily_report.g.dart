// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyReportImpl _$$DailyReportImplFromJson(Map<String, dynamic> json) =>
    _$DailyReportImpl(
      date: json['date'] as String,
      attendanceMinutes: (json['attendanceMinutes'] as num?)?.toInt() ?? 0,
      studyMinutes: (json['studyMinutes'] as num?)?.toInt() ?? 0,
      breakMinutes: (json['breakMinutes'] as num?)?.toInt() ?? 0,
      targetMinutes: (json['targetMinutes'] as num?)?.toInt() ?? 0,
      achievedRate: (json['achievedRate'] as num?)?.toDouble() ?? 0,
      attendanceStatus: json['attendanceStatus'] as String,
      subjectBreakdown:
          (json['subjectBreakdown'] as List<dynamic>?)
              ?.map((e) => SubjectBreakdown.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$DailyReportImplToJson(_$DailyReportImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'attendanceMinutes': instance.attendanceMinutes,
      'studyMinutes': instance.studyMinutes,
      'breakMinutes': instance.breakMinutes,
      'targetMinutes': instance.targetMinutes,
      'achievedRate': instance.achievedRate,
      'attendanceStatus': instance.attendanceStatus,
      'subjectBreakdown': instance.subjectBreakdown,
    };

_$SubjectBreakdownImpl _$$SubjectBreakdownImplFromJson(
  Map<String, dynamic> json,
) => _$SubjectBreakdownImpl(
  subjectName: json['subjectName'] as String,
  studyMinutes: (json['studyMinutes'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$SubjectBreakdownImplToJson(
  _$SubjectBreakdownImpl instance,
) => <String, dynamic>{
  'subjectName': instance.subjectName,
  'studyMinutes': instance.studyMinutes,
};
