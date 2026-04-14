// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_home.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentHomeImpl _$$StudentHomeImplFromJson(Map<String, dynamic> json) =>
    _$StudentHomeImpl(
      todayAttendance: json['todayAttendance'] == null
          ? null
          : TodayAttendanceSummary.fromJson(
              json['todayAttendance'] as Map<String, dynamic>,
            ),
      seat: json['seat'] == null
          ? null
          : SeatSummary.fromJson(json['seat'] as Map<String, dynamic>),
      study: json['study'] == null
          ? null
          : StudySummary.fromJson(json['study'] as Map<String, dynamic>),
      plans: json['plans'] == null
          ? null
          : PlanSummary.fromJson(json['plans'] as Map<String, dynamic>),
      notifications:
          (json['notifications'] as List<dynamic>?)
              ?.map(
                (e) => NotificationSummary.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$StudentHomeImplToJson(_$StudentHomeImpl instance) =>
    <String, dynamic>{
      'todayAttendance': instance.todayAttendance,
      'seat': instance.seat,
      'study': instance.study,
      'plans': instance.plans,
      'notifications': instance.notifications,
    };

_$TodayAttendanceSummaryImpl _$$TodayAttendanceSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$TodayAttendanceSummaryImpl(
  status: json['status'] as String,
  checkInAt: json['checkInAt'] as String?,
  checkOutAt: json['checkOutAt'] as String?,
  stayMinutes: (json['stayMinutes'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$TodayAttendanceSummaryImplToJson(
  _$TodayAttendanceSummaryImpl instance,
) => <String, dynamic>{
  'status': instance.status,
  'checkInAt': instance.checkInAt,
  'checkOutAt': instance.checkOutAt,
  'stayMinutes': instance.stayMinutes,
};

_$SeatSummaryImpl _$$SeatSummaryImplFromJson(Map<String, dynamic> json) =>
    _$SeatSummaryImpl(
      seatId: json['seatId'] as String,
      seatNo: json['seatNo'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$$SeatSummaryImplToJson(_$SeatSummaryImpl instance) =>
    <String, dynamic>{
      'seatId': instance.seatId,
      'seatNo': instance.seatNo,
      'status': instance.status,
    };

_$StudySummaryImpl _$$StudySummaryImplFromJson(Map<String, dynamic> json) =>
    _$StudySummaryImpl(
      sessionStatus: json['sessionStatus'] as String,
      studyMinutes: (json['studyMinutes'] as num?)?.toInt() ?? 0,
      breakMinutes: (json['breakMinutes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$StudySummaryImplToJson(_$StudySummaryImpl instance) =>
    <String, dynamic>{
      'sessionStatus': instance.sessionStatus,
      'studyMinutes': instance.studyMinutes,
      'breakMinutes': instance.breakMinutes,
    };

_$PlanSummaryImpl _$$PlanSummaryImplFromJson(Map<String, dynamic> json) =>
    _$PlanSummaryImpl(
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      targetMinutes: (json['targetMinutes'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PlanSummaryImplToJson(_$PlanSummaryImpl instance) =>
    <String, dynamic>{
      'totalCount': instance.totalCount,
      'completedCount': instance.completedCount,
      'targetMinutes': instance.targetMinutes,
    };

_$NotificationSummaryImpl _$$NotificationSummaryImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationSummaryImpl(
  id: json['id'] as String,
  title: json['title'] as String,
);

Map<String, dynamic> _$$NotificationSummaryImplToJson(
  _$NotificationSummaryImpl instance,
) => <String, dynamic>{'id': instance.id, 'title': instance.title};
