// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeatImpl _$$SeatImplFromJson(Map<String, dynamic> json) => _$SeatImpl(
  id: json['id'] as String,
  seatNo: json['seatNo'] as String,
  status: json['status'] as String,
  zone: json['zone'] as String?,
  assignedStudentId: json['assignedStudentId'] as String?,
  assignedStudentName: json['assignedStudentName'] as String?,
  isLocked: json['isLocked'] as bool? ?? false,
  isReserved: json['isReserved'] as bool? ?? false,
);

Map<String, dynamic> _$$SeatImplToJson(_$SeatImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seatNo': instance.seatNo,
      'status': instance.status,
      'zone': instance.zone,
      'assignedStudentId': instance.assignedStudentId,
      'assignedStudentName': instance.assignedStudentName,
      'isLocked': instance.isLocked,
      'isReserved': instance.isReserved,
    };
