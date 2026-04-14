// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentImpl _$$StudentImplFromJson(Map<String, dynamic> json) =>
    _$StudentImpl(
      id: json['id'] as String,
      studentNo: json['studentNo'] as String,
      name: json['name'] as String,
      gradeId: json['gradeId'] as String?,
      classId: json['classId'] as String?,
      groupId: json['groupId'] as String?,
      gradeName: json['gradeName'] as String?,
      className: json['className'] as String?,
      groupName: json['groupName'] as String?,
      assignedSeatId: json['assignedSeatId'] as String?,
      assignedSeatNo: json['assignedSeatNo'] as String?,
      status: json['status'] as String,
    );

Map<String, dynamic> _$$StudentImplToJson(_$StudentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentNo': instance.studentNo,
      'name': instance.name,
      'gradeId': instance.gradeId,
      'classId': instance.classId,
      'groupId': instance.groupId,
      'gradeName': instance.gradeName,
      'className': instance.className,
      'groupName': instance.groupName,
      'assignedSeatId': instance.assignedSeatId,
      'assignedSeatNo': instance.assignedSeatNo,
      'status': instance.status,
    };
