// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceImpl _$$AttendanceImplFromJson(Map<String, dynamic> json) =>
    _$AttendanceImpl(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      attendanceDate: json['attendanceDate'] as String,
      status: json['status'] as String,
      checkInAt: json['checkInAt'] as String?,
      checkOutAt: json['checkOutAt'] as String?,
      stayMinutes: (json['stayMinutes'] as num?)?.toInt() ?? 0,
      isLate: json['isLate'] as bool? ?? false,
      isEarlyLeave: json['isEarlyLeave'] as bool? ?? false,
    );

Map<String, dynamic> _$$AttendanceImplToJson(_$AttendanceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'attendanceDate': instance.attendanceDate,
      'status': instance.status,
      'checkInAt': instance.checkInAt,
      'checkOutAt': instance.checkOutAt,
      'stayMinutes': instance.stayMinutes,
      'isLate': instance.isLate,
      'isEarlyLeave': instance.isEarlyLeave,
    };
